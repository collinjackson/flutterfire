part of cloud_firestore_platform_interface;

/// Sentinel values that can be used when writing document fields with set() or
/// update().
enum FieldValueType {
  /// adds elements to an array but only elements not already present
  arrayUnion,

  /// removes all instances of each given element
  arrayRemove,

  /// deletes field
  delete,

  /// sets field value to server timestamp
  serverTimestamp,

  ///  increment or decrement a numeric field value using a double value
  incrementDouble,

  ///  increment or decrement a numeric field value using an integer value
  incrementInteger,
}

/// An interface for a factory that is used to build [FieldValue] according to
/// Platform (web or mobile)
abstract class FieldValueFactoryPlatform implements PlatformInterface {
  /// Current instance of [FieldValueFactory]
  static FieldValueFactory get instance => _instance;

  static FieldValueFactory _instance = MethodChannelFieldValueFactory();

  /// Sets the default instance of [FieldValueFactory] which is used to build
  /// [FieldValue] items
  static set instance(FieldValueFactory instance) {

    _instance = instance;
  }

  /// Returns a special value that tells the server to union the given elements
  /// with any array value that already exists on the server.
  ///
  /// Each specified element that doesn't already exist in the array will be
  /// added to the end. If the field being modified is not already an array it
  /// will be overwritten with an array containing exactly the specified
  /// elements.
  FieldValueInterface arrayUnion(List<dynamic> elements);

  /// Returns a special value that tells the server to remove the given
  /// elements from any array value that already exists on the server.
  ///
  /// All instances of each element specified will be removed from the array.
  /// If the field being modified is not already an array it will be overwritten
  /// with an empty array.
  FieldValueInterface arrayRemove(List<dynamic> elements);

  /// Returns a sentinel for use with update() to mark a field for deletion.
  FieldValueInterface delete();

  /// Returns a sentinel for use with set() or update() to include a
  /// server-generated timestamp in the written data.
  FieldValueInterface serverTimestamp();

  /// Returns a special value for use with set() or update() that tells the
  /// server to increment the field’s current value by the given value.
  FieldValueInterface increment(num value);
}
