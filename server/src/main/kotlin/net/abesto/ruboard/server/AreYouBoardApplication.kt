package net.abesto.ruboard.server

import javax.ws.rs.core.Application
import javax.ws.rs.Path

Path("/api")
public class AreYouBoardApplication: Application()
{
    override fun getClasses(): MutableSet<Class<out Any?>>? = hashSetOf(
            javaClass<HelloWorldResource>(),
            javaClass<GreeterResource>()
    )
}

