part of cloud_firestore_web;

/// A web specific for [WriteBatch]
class WriteBatchWeb extends WriteBatchPlatform {
  final web.WriteBatch _delegate;

  // ignore: public_member_api_docs
  @visibleForTesting
  WriteBatchWeb(this._delegate);

  @override
  Future<void> commit() async {
    await _delegate.commit();
  }

  @override
  void delete(DocumentReferencePlatform document) {
    assert(document is DocumentReferenceWeb);
    _delegate.delete((document as DocumentReferenceWeb).delegate);
  }

  @override
  void setData(DocumentReferencePlatform document, Map<String, dynamic> data,
      {bool merge = false}) {
    assert(document is DocumentReferenceWeb);
    _delegate.set(
        (document as DocumentReferenceWeb).delegate,
        CodecUtility.encodeMapData(data),
        merge ? web.SetOptions(merge: merge) : null);
  }

  @override
  void updateData(DocumentReferencePlatform document, Map<String, dynamic> data) {
    assert(document is DocumentReferenceWeb);
    _delegate.update((document as DocumentReferenceWeb).delegate,
        data: CodecUtility.encodeMapData(data));
  }
}
