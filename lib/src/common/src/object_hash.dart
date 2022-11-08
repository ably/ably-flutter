/// BEGIN LEGACY DOCSTRING
/// @nodoc
/// Utility mixin to calculate hashCode values for complex objects
/// END LEGACY DOCSTRING
mixin ObjectHash {
  /// BEGIN LEGACY DOCSTRING
  /// @nodoc
  /// Returns hashCode value for list of fields inside and object
  /// that uses the mixin. Hash value is calculated with a pretty standard hash
  /// algorithm, using 31 as a prime number and adding 0 for null values
  /// This is roughly based on default JDK implementations
  /// END LEGACY DOCSTRING
  int objectHash(List<dynamic> fields) {
    var result = 1;

    for (final field in fields) {
      result = 31 * result + (field == null ? 0 : field.hashCode);
    }

    return result;
  }
}
