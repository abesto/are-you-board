package net.abesto.ruboard.server

import javax.ws.rs.core.Application

public class AreYouBoardApplication: Application()
{
    override fun getClasses(): MutableSet<Class<out Any?>>? = hashSetOf(
            javaClass<HelloWorldResource>(),
            javaClass<GreeterResource>()
    )
}

