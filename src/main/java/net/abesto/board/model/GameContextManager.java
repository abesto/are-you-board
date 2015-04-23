package net.abesto.board.model;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.stereotype.Component;

import javax.inject.Inject;
import javax.inject.Singleton;
import java.util.HashMap;
import java.util.Map;

@Singleton
@Component
public class GameContextManager {
    private Map<Class<?>, ApplicationContext> contexts;
    private Logger logger;

    @Inject
    GameContextManager(ApplicationContext applicationContext) {
        logger = LoggerFactory.getLogger(getClass());
        contexts = new HashMap<Class<?>, ApplicationContext>();
        int count = 0;
        for (Map.Entry<String, Object> entry : applicationContext.getBeansWithAnnotation(GameConfiguration.class).entrySet()) {
            Class<?> config = entry.getValue().getClass();
            contexts.put(config, new AnnotationConfigApplicationContext(config));
            count += 1;
            logger.trace("Registered GameConfiguration {}", config);
        }
        logger.debug("Registered {} GameConfigurations", count);
    }

    public ApplicationContext getContext(Class<?> gameConfiguration) {
        return contexts.get(gameConfiguration);
    }
}
