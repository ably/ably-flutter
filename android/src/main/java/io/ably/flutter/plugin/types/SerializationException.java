package io.ably.flutter.plugin.types;

/**
 * Thrown during object serialization
 */
public class SerializationException extends RuntimeException {

    public SerializationException(String message) {
        super(message);
    }

    public static SerializationException forEnum(Object value, Class type) {
        return new SerializationException(value.toString() + " can't be encoded/decoded to " + type.toString());
    }

    public static SerializationException forEncoder(Class type) {
        return new SerializationException("No encoder found for " + type.toString());
    }

    public static SerializationException forDecoder(Object value) {
        return new SerializationException("No decoder found for value " + value.toString());
    }
}
