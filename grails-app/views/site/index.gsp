<!DOCTYPE html>
<html>
    <head>
        <meta name="layout" content="main" />
        <g:set var="entityName" value="${message(code: 'site.label', default: 'Site')}" />
        <title><g:message code="default.list.label" args="[entityName]" /></title>

        <script src="https://unpkg.com/vue/dist/vue.min.js"></script>
        <script src="https://unpkg.com/axios/dist/axios.min.js"></script>
    </head>

    <div id="sites">

        <select id="siteSelector" onchange="siteSelector.fetchData()" >
            <option id="selectPlaceHolder" selected hidden>Seleccion</option>
            <g:each in="${sites}" var="site">
                <option value="${site?.id}">${site?.name}</option>
            </g:each>
        </select>

        <table border="1" id="sitesTable">
            <thead>
                <tr>
                    <td id="tableTitle" style="font-weight: bolder">Categories</td>
                    <button id="createButton" onclick="showForm(true)">CREATE</button>
                </tr>
            </thead>
            <tr v-for="category in categories">
                <td>
                    <a href="#subCategoriesTable" @click="fetchSubCategories(category.id, category.name)">
                        {{category.name}}
                    </a>
                </td>
            </tr>
        </table>
        <div id="modal"></div>
        <div id="form">
            <form>
                <div class="form-group">
                    <select id="formSelectorMarcaId" style="width: 100%">
                        <option id="selectPlaceHolder" selected hidden>Seleccion</option>
                        <g:each in="${sites}" var="site">
                            <option value="${site?.id}">${site?.name}</option>
                        </g:each>
                    </select>
                </div>
                <div class="form-group">
                    <input type="text" class="form-control" id="articuloInput" placeholder="Articulo">
                </div>
                <div class="form-group">
                    <input type="text" class="form-control" id="pictureInput" placeholder="Picture">
                </div>
                <div class="form-group">
                    <input type="text" class="form-control" id="totalItemsInThisCategoryInput" placeholder="Total Items In This Category">
                </div>
                <button type="submit" class="btn btn-primary" onclick="siteSelector.createItem()">Submit</button>
            </form>
        </div>
    </div>

    <script>

        var siteSelector = new Vue({
            el: '#sites',
            data: {
                categories: [],
                sitePath: "MLA"
            },
            methods: {
                fetchData: function () {
                    var id = document.getElementById("siteSelector").value
                    this.sitePath = id;

                    showForm(false);
                    showSitesTable(true);

                    axios.get('/site/categories', {
                        params: {
                            id: id
                        }
                    }).then(function (response) {

                        document.getElementById("tableTitle").innerText = 'Categories'

                        siteSelector.categories = response.data.categories;
                    }).catch(function (error) {
                        console.log(error);
                    });
                },
                fetchSubCategories: function (id) {
                    showForm(false);
                    if (id == null) console.log("id is null");
                    console.log("fetching subCategories for " + id);
                    axios.get('/site/subCategories', {
                        params: {
                            id: id
                        }
                    }).then(function (response) {
                        siteSelector.categories = response.data.subCategories.children_categories;

                        var categoryInfo = response.data.subCategories;
                        var pathFromRoot = categoryInfo.path_from_root;

                        document.getElementById("tableTitle").innerHTML = "<a id='categoryText' href='#' >Categories</a>";
                        for (var i = 0; i < pathFromRoot.length; i++) {
                            document.getElementById("tableTitle").innerHTML += " > " + "<a href='#' data-identifier='" +
                                pathFromRoot[i].id + "' class='categories'>" + pathFromRoot[i].name + "<a/>";

                        }

                        document.getElementById("categoryText").onclick = function () {
                            siteSelector.fetchData(siteSelector.sitePath);
                        }

                        var elemArray = document.getElementsByClassName('categories');
                        for (var i = 0; i < elemArray.length; i++) {
                            elemArray[i].onclick = function (event) {
                                var clickedId = event.target.attributes[1].value;
                                console.log("clicked on: "+ clickedId);

                                showModal(false);

                                siteSelector.fetchSubCategories(clickedId)
                            }
                        }

                        if (siteSelector.categories.length == 0) {

                            if (categoryInfo.picture == null) {
                                categoryInfo.picture = "https://www.dubaiautodrome.com/wp-content/uploads/2016/08/placeholder.png";
                            }

                            createModal(categoryInfo.name, categoryInfo.id, categoryInfo.picture,
                                categoryInfo.total_items_in_this_category);
                            showModal(true);
                        }



                    }).catch(function (error) {
                        console.log(error);
                    });
                },
                deleteItem: function (id) {
                    console.log("deleting item...")
                    axios.get('/site/deleteItem', {
                        params: {
                            id: id
                        }
                    }).then(function (response) {

                        console.log("response recieved")
                        if (response.data.statusCode == 204) {
                            showModal(false);
                            siteSelector.fetchData(siteSelector.sitePath)
                        }

                    }).catch(function (error) {
                        console.log(error);
                    });
                },
                createItem: function () {
                    var data = {
                        "name": document.getElementById("articuloInput").value,
                        "picture": document.getElementById("pictureInput").value,
                        "total_items_in_this_category": parseInt(document.getElementById("totalItemsInThisCategoryInput").value),
                        "marca": parseInt(document.getElementById("formSelectorMarcaId").value)
                    }


                    console.log("creating item...");
                    axios.get("/site/create", {
                        params: {
                            data: data,
                        }
                    })
                        .then(function (response) {

                            console.log(response);

                            siteSelector.fetchSubCategories(response.data.id)
                        }).catch(function (error) {
                            console.log(error);
                    });
                }
            },
            created: function () {
                this.fetchData();
                showModal(false);
                showForm(false);

            }
        });


        function createModal (name, id, picturePath, totalItemsNum) {
            document.getElementById('modal').innerHTML = "<h1>Category Name:</h1><p>" + name + "</p>" +
                "<h1>ID:</h1><p>" + id + "</p>" +
                "<img style='max-width: 200px' src='" + picturePath + "' > " +
                "<h1>Total Items in this category:</h1><p>" + totalItemsNum + "</p>" +
                "<button onclick=''>Edit</button>" + "<button onclick='siteSelector.deleteItem(" + id + ")'>DELETE</button>";
        }

        function showSitesTable(boolean) {
            if (boolean) {
                document.getElementById("sitesTable").style.display = "block"
            } else {
                document.getElementById("sitesTable").style.display = "none";
            }
        }

        function showModal(boolean) {
            if (boolean) {
                document.getElementById("modal").style.display = "block"
            } else {
                document.getElementById("modal").style.display = "none";
            }
        }

        function showForm(boolean) {

            document.getElementById("selectPlaceHolder").selected = true;
            if (boolean) {
                document.getElementById("form").style.display = "block";
                showModal(false);
                showSitesTable(false);
            } else {
                document.getElementById("form").style.display = "none";
            }
        }

    </script>

    </body>
</html>