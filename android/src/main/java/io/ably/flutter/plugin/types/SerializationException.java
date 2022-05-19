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
}
