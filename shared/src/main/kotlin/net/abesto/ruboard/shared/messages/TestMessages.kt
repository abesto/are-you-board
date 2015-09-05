package net.abesto.ruboard.shared.messages

interface TestMessage {
    fun speak(): String
}

class MsgHello(val name: String): TestMessage {
    override fun speak(): String = "Hello, ${name}"
}

class MsgBye(val name: String): TestMessage {
    override fun speak(): String = "Bye, ${name}"
}

public object TestMessages {
    fun write(msg: TestMessage): String {
        if (msg is MsgHello) {
            return "h${msg.name}"
        }
        if (msg is MsgBye) {
            return "b${msg.name}"
        }
        throw RuntimeException("Can't serialize ${msg}")
    }

    fun read(msg: String): TestMessage {
        val head = msg[0]
        val tail = msg.substring(1)
        if (head == 'h') {
            return MsgHello(tail)
        }
        if (head == 'b') {
            return MsgBye(tail)
        }
        throw RuntimeException("Can't parse ${msg}")
    }
}