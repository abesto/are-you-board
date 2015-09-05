package net.abesto.ruboard.server

import com.cedarsoftware.util.io.JsonReader
import com.cedarsoftware.util.io.JsonWriter
import net.abesto.ruboard.shared.messages.MsgBye
import net.abesto.ruboard.shared.messages.MsgHello
import net.abesto.ruboard.shared.messages.TestMessage
import net.abesto.ruboard.shared.messages.TestMessages
import java.util.Collections;
import java.util.HashSet;
import javax.websocket.CloseReason;
import javax.websocket.OnClose;
import javax.websocket.OnError;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.ClientEndpoint;
import javax.websocket.server.ServerEndpoint;

@ClientEndpoint
@ServerEndpoint(value="/hello")
public class EventSocket {
    private val sessions = Collections.synchronizedSet(HashSet<Session>())

    @OnOpen
    public fun onWebSocketConnect(session: Session) {
        System.out.println("Socket Connected: " + session);
        sessions.add(session);
    }

    @OnMessage
    public fun onWebSocketText(client: Session, message: String) {
        System.out.println("Received TEXT message: " + message);
        val req = TestMessages.read(message)
        val res: TestMessage
        if (req is MsgHello) {
            res = MsgBye(req.name)
        } else if (req is MsgBye) {
            res = MsgHello(req.name)
        } else {
            throw RuntimeException("foo")
        }
        client.getBasicRemote().sendText(TestMessages.write(res))
    }

    @OnClose
    public fun onWebSocketClose(session: Session, reason: CloseReason) {
        System.out.println("Socket Closed: " + reason);
        sessions.remove(session);
    }

    @OnError
    public fun onWebSocketError(cause: Throwable) {
        cause.printStackTrace();
    }
}
