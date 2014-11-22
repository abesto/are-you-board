package net.abesto.ruboard.server

import javax.ws.rs.Path
import javax.ws.rs.GET
import javax.ws.rs.Produces

Path("/hello")
public class HelloWorldResource {
    GET Produces("text/plain")
    public fun hello(): String = "hello world"
}