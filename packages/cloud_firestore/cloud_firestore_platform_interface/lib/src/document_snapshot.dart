// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore_platform_interface;

/// A DocumentSnapshot contains data read from a document in your Firestore
/// database.
///
/// The data can be extracted with the data property or by using subscript
/// syntax to access a specific field.
class DocumentSnapshot {
  DocumentSnapshot(this._path, this.data, this.metadata, this._firestore);

  final String _path;
  final FirestorePlatform _firestore;

  /// The reference that produced this snapshot
  DocumentReference get reference => _firestore.document(_path);

  /// Contains all the data of this snapshot
  final Map<String, dynamic> data;

  /// Metadata about this snapshot concerning its source and if it has local
  /// modifications.
  final SnapshotMetadata metadata;

  /// Reads individual values from the snapshot
  dynamic operator [](String key) => data[key];

  /// Returns the ID of the snapshot's document
  String get documentID => _path.split('/').last;

  /// Returns `true` if the document exists.
  bool get exists => data != null;
}

Map<String, dynamic> _asStringKeyedMap(Map<dynamic, dynamic> map) =>
    map?.cast<String, dynamic>();
