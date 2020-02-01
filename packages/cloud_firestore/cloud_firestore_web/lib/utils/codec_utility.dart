part of cloud_firestore_web;

// disabling lint as it's only visible for testing
@visibleForTesting
// ignore: public_member_api_docs
class CodecUtility {
  // disabling lint as it's only visible for testing
  @visibleForTesting
  // ignore: public_member_api_docs
  static Map<String, dynamic> encodeMapData(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    Map<String, dynamic> output = Map.from(data);
    output.updateAll((key, value) => valueEncode(value));
    return output;
  }

  // disabling lint as it's only visible for testing
  @visibleForTesting
  // ignore: public_member_api_docs
  static List<dynamic> encodeArrayData(List<dynamic> data) {
    if (data == null) {
      return null;
    }
    return List.from(data).map(valueEncode).toList();
  }

  // disabling lint as it's only visible for testing
  @visibleForTesting
  // ignore: public_member_api_docs
  static dynamic valueEncode(dynamic value) {
    if (value is FieldValuePlatform && value.instance is FieldValueWeb) {
      return (value.instance as FieldValueWeb)._delegate;
    } else if (value is Timestamp) {
      return value.toDate();
    } else if (value is GeoPoint) {
      return web.GeoPoint(value.latitude, value.longitude);
    } else if (value is Blob) {
      return web.Blob.fromUint8Array(value.bytes);
    } else if (value is DocumentReferenceWeb) {
      return value.delegate;
    } else if (value is Map<String, dynamic>) {
      return encodeMapData(value);
    } else if (value is List<dynamic>) {
      return encodeArrayData(value);
    }
    return value;
  }

  // disabling lint as it's only visible for testing
  @visibleForTesting
  // ignore: public_member_api_docs
  static Map<String, dynamic> decodeMapData(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    Map<String, dynamic> output = Map.from(data);
    output.updateAll((key, value) => valueDecode(value));
    return output;
  }

  // disabling lint as it's only visible for testing
  @visibleForTesting
  // ignore: public_member_api_docs
  static List<dynamic> decodeArrayData(List<dynamic> data) {
    if (data == null) {
      return null;
    }
    return List.from(data).map(valueDecode).toList();
  }

  // disabling lint as it's only visible for testing
  @visibleForTesting
  // ignore: public_member_api_docs
  static dynamic valueDecode(dynamic value) {
    if (value is web.GeoPoint) {
      return GeoPoint(value.latitude, value.longitude);
    } else if (value is DateTime) {
      return Timestamp.fromDate(value);
    } else if (value is web.Blob) {
      return Blob(value.toUint8Array());
    } else if (value is web.DocumentReference) {
      return (FirestorePlatform.instance as FirestoreWeb).document(
          value.path.split("/"));
    } else if (value is Map<String, dynamic>) {
      return decodeMapData(value);
    } else if (value is List<dynamic>) {
      return decodeArrayData(value);
    }
    return value;
  }
}
