package com.mercadolibre.itacademy

import grails.converters.JSON
import groovy.json.JsonSlurper


class SiteController {

    def index() {
        String url = message(code: "default.grail.api.rest.marcas")
        [sites: getJson(url)]
    }

    def categories(String id) {
        println "getting categories for " + id
        String url = message(code: "default.grail.api.rest.marcas.id.articulos", args: [id])
        def categories = getJson(url)
        println categories
        def resultado = [categories: categories]
        render resultado as JSON
    }

    def subCategories(String id) {
        println "getting subcategories for " + id
        String url = message(code: "default.grail.api.rest.articulo.id", args: [id])
        def subCategories = getJson(url)
        def response = [subCategories: subCategories]
        render response as JSON
    }

    def deleteItem(String id) {
        println "deliting article with id " + id
        String urlString = message(code: "default.grail.api.rest.articulo.id", args: [id])
        def url = new URL(urlString.replace('"', ''))
        def connection = (HttpURLConnection) url.openConnection()
        connection.setRequestMethod("DELETE")
        connection.setRequestProperty("Accept", "application/json")
        connection.setRequestProperty("agent", "Mozilla/5.0")
        connection.getInputStream()

        def response = [statusCode: 204]
        render response as JSON
    }

    def create (String data) {
        String urlString = message(code: "default.grail.api.rest.articulo")
        def url = new URL(urlString.replace('"',""))
        def connection = (HttpURLConnection) url.openConnection()
        connection.setDoOutput(true)
        connection.setDoInput(true)
        connection.setRequestProperty("Content-Type", "application/json")
        connection.setRequestProperty("Accept", "application/json")
        connection.setRequestMethod("POST")

        OutputStreamWriter wr = new OutputStreamWriter(connection.getOutputStream())
        wr.write(data)
        wr.flush()
        JsonSlurper json = new JsonSlurper()
        def items = json.parse(connection.getInputStream())
        render items as JSON
    }



    def getJson(String stringUrl) {
        def url = new URL(stringUrl.replace('"', ''))
        def connection = (HttpURLConnection) url.openConnection()
        connection.setRequestMethod("GET")
        connection.setRequestProperty("Accept", "application/json")
        connection.setRequestProperty("agent", "Mozilla/5.0")

        JsonSlurper json = new JsonSlurper()
        return json.parse(connection.getInputStream())
    }
}
