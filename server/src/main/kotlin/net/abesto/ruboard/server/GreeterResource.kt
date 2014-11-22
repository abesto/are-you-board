package net.abesto.ruboard.server

import javax.ws.rs.Path
import javax.ws.rs.GET
import javax.ws.rs.Produces
import javax.ws.rs.PathParam

Path("/greet")
public class GreeterResource {
    GET Path("/{name}") Produces("text/plain")
    public fun someone(PathParam("name") name: String): String = "oi-right ${name}"
}