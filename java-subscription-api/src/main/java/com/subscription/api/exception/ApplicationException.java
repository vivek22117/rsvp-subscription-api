package com.subscription.api.exception;

import java.io.Serializable;


public class ApplicationException extends RuntimeException implements Serializable {

    public ApplicationException(String message, Throwable throwable) {
        super(message, throwable);
    }

    public ApplicationException(String message) {
        super(message);
    }
}
