part of cloud_firestore_web;

/// Implementation of [FieldValue] that is compatible with
/// firestore web plugin
class FieldValueWeb extends FieldValuePlatform {
  web.FieldValue _delegate;

  FieldValueWeb._(this._delegate, this.type, this.value);

  @override
  final FieldValueType type;

  @override
  final dynamic value;

  @override
  FieldValueInterface get instance => this;
}
