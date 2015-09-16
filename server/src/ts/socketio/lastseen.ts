import User = require("../models/User");

function seen(userId, cb)  {
    User.update(
        { _id: userId },
        { $set: { lastSeen: new Date() } },
        cb
    );
}

export function apply(sio) {
    sio.on("connection", (socket) => {
        var session = socket.handshake.session;
        setInterval(() => { socket.emit("ping"); }, 5000);
        socket.on("pong", () => seen(session.userId, (err, user) => {
            console.log(`Seen in session ${session.id} user ${session.userId}`);
        }));
    });
}
