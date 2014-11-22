package net.abesto.ruboard.client.extensions

import kotlin.js.dom.html.Object

native public class jqXHR

native("$") object jQuery {
    public fun get(url: String, success: (data: Object) -> Unit): Unit = noImpl
    public fun get(url: String, success: (data: Object, textStatus: String) -> Unit): Unit = noImpl
    public fun get(url: String, success: (data: Object, textStatus: String, jqXHR: jqXHR) -> Unit): Unit = noImpl
}
