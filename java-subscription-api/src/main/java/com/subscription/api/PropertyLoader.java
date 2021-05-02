package com.subscription.api;


import com.subscription.api.exception.ApplicationException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

public class PropertyLoader {

    private static final Logger LOGGER = LoggerFactory.getLogger(PropertyLoader.class);

    private static final String ENVIRONMENT = "environment";
    private static final String PREFIX = "/application";
    private static final String SUFFIX = ".properties";

    private static Map<String, String> propertiesMap;

    private static PropertyLoader propertyLoader = null;

    private PropertyLoader() {
    }

    public static PropertyLoader getInstance() {
        if (propertyLoader == null) {
            synchronized (PropertyLoader.class) {
                if (propertyLoader == null) {
                    propertyLoader = new PropertyLoader();
                }
            }
        }
        return propertyLoader;
    }

    public String getPropertyValue(String propertyKey) {
        if (propertiesMap == null) {
            propertiesMap = loadAllProperties();
        }
        return propertiesMap.get(propertyKey);
    }

    private Map<String, String> loadAllProperties() {
        propertiesMap = new HashMap<>();
        String environment = System.getenv(ENVIRONMENT);
        LOGGER.debug("Environment fetched: " + environment);

        if (environment != null) {
            environment = "-" + environment;
            propertiesMap.putAll(loadProperties(PREFIX + environment + SUFFIX));
        }
        return propertiesMap;
    }

    private Map<String, String> loadProperties(String name) {
        Properties properties = new Properties();
        InputStream inputStream = PropertyLoader.class.getResourceAsStream(name);
        try {
            properties.load(inputStream);
        } catch (IOException e) {
            throw new ApplicationException("Unable to load properties.", e);
        }
        return (Map) properties;
    }
}
