package net.abesto.ruboard.client

import net.abesto.ruboard.shared.messages.MsgBye
import net.abesto.ruboard.shared.messages.MsgHello
import net.abesto.ruboard.shared.messages.TestMessages
import kotlin.reflect.KClass
import org.w3c.dom.WebSocket
import kotlin.browser.document
import org.w3c.dom.events.Event

interface WSMessage {
    val type: String
    val data: String
}

fun handleWSMessage(msg: WSMessage) {
    val parsed = TestMessages.read(msg.data)
    console.log(parsed.speak())
}

fun main(args: Array<String>) {
    val el = document.createElement("div")
    el.appendChild(document.createTextNode("Hello!"))
    document.body!!.appendChild(el)

    val ws = WebSocket("ws://localhost:8080/hello")
    ws.onerror = { error -> console.error(error) }
    ws.onmessage = { message -> handleWSMessage(message as WSMessage) }

    ws.onopen = { wtf ->
        console.info(wtf)
        ws.send(TestMessages.write(MsgHello("[client hello]")))
        ws.send(TestMessages.write(MsgBye("[client bye]")))
    }
}