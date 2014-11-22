package net.abesto.ruboard.client

import kotlin.js.dom.html.document
import jquery.jq
import net.abesto.ruboard.client.extensions.*


fun main(args: Array<String>) {
    val el = document.createElement("div")
    el.appendChild(document.createTextNode("Hello!"))
    document.body.appendChild(el)

    jQuery.get("/api/greet/client", { data ->
        document.body.appendChild(
                document.createTextNode(data.toString())
        )
    })
}