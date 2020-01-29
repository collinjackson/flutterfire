// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore_platform_interface;

/// Represents a query over the data at a particular location.
class MethodChannelQuery extends Query {
  /// Create a [MethodChannelQuery] from [pathComponents]
  MethodChannelQuery(
      {@required FirestorePlatform firestore,
      @required List<String> pathComponents,
      bool isCollectionGroup = false,
      Map<String, dynamic> parameters})
      : super(
          firestore: firestore,
          pathComponents: pathComponents,
          isCollectionGroup: isCollectionGroup,
          parameters: parameters,
        );

  Query _copyWithParameters(Map<String, dynamic> parameters) {
    return MethodChannelQuery(
      firestore: firestore,
      isCollectionGroup: isCollectionGroup,
      pathComponents: pathComponents,
      parameters: Map<String, dynamic>.unmodifiable(
        Map<String, dynamic>.from(this.parameters)..addAll(parameters),
      ),
    );
  }

  // TODO(jackson): Reduce code duplication with [DocumentReference]
  @override
  Stream<QuerySnapshot> snapshots({bool includeMetadataChanges = false}) {
    assert(includeMetadataChanges != null);
    Future<int> _handle;
    // It's fine to let the StreamController be garbage collected once all the
    // subscribers have cancelled; this analyzer warning is safe to ignore.
    StreamController<QuerySnapshot> controller; // ignore: close_sinks
    controller = StreamController<QuerySnapshot>.broadcast(
      onListen: () {
        _handle = MethodChannelFirestore.channel.invokeMethod<int>(
          'Query#addSnapshotListener',
          <String, dynamic>{
            'app': firestore.app.name,
            'path': path,
            'isCollectionGroup': isCollectionGroup,
            'parameters': parameters,
            'includeMetadataChanges': includeMetadataChanges,
          },
        ).then<int>((dynamic result) => result);
        _handle.then((int handle) {
          MethodChannelFirestore._queryObservers[handle] = controller;
        });
      },
      onCancel: () {
        _handle.then((int handle) async {
          await MethodChannelFirestore.channel.invokeMethod<void>(
            'removeListener',
            <String, dynamic>{'handle': handle},
          );
          MethodChannelFirestore._queryObservers.remove(handle);
        });
      },
    );
    return controller.stream;
  }

  /// Fetch the documents for this query
  Future<QuerySnapshot> getDocuments(
      {Source source = Source.serverAndCache}) async {
    assert(source != null);
    final Map<dynamic, dynamic> data =
        await MethodChannelFirestore.channel.invokeMapMethod<String, dynamic>(
      'Query#getDocuments',
      <String, dynamic>{
        'app': firestore.app.name,
        'path': path,
        'isCollectionGroup': isCollectionGroup,
        'parameters': parameters,
        'source': _getSourceString(source),
      },
    );
    return MethodChannelQuerySnapshot(data, firestore);
  }

  @override
  Map<String, dynamic> buildArguments() => Map<String, dynamic>.from(parameters)
    ..addAll(<String, dynamic>{
      'path': path,
    });

  @override
  Query where(field,
      {isEqualTo,
      isLessThan,
      isLessThanOrEqualTo,
      isGreaterThan,
      isGreaterThanOrEqualTo,
      arrayContains,
      List arrayContainsAny,
      List whereIn,
      bool isNull}) {
    assert(field is String || field is FieldPath,
        'Supported [field] types are [String] and [FieldPath].');

    final ListEquality<dynamic> equality = const ListEquality<dynamic>();
    final List<List<dynamic>> conditions =
        List<List<dynamic>>.from(parameters['where']);

    void addCondition(dynamic field, String operator, dynamic value) {
      final List<dynamic> condition = <dynamic>[field, operator, value];
      assert(
          conditions
              .where((List<dynamic> item) => equality.equals(condition, item))
              .isEmpty,
          'Condition $condition already exists in this query.');
      conditions.add(condition);
    }

    if (isEqualTo != null) addCondition(field, '==', isEqualTo);
    if (isLessThan != null) addCondition(field, '<', isLessThan);
    if (isLessThanOrEqualTo != null) {
      addCondition(field, '<=', isLessThanOrEqualTo);
    }
    if (isGreaterThan != null) addCondition(field, '>', isGreaterThan);
    if (isGreaterThanOrEqualTo != null) {
      addCondition(field, '>=', isGreaterThanOrEqualTo);
    }
    if (arrayContains != null) {
      addCondition(field, 'array-contains', arrayContains);
    }
    if (arrayContainsAny != null) {
      addCondition(field, 'array-contains-any', arrayContainsAny);
    }
    if (whereIn != null) addCondition(field, 'in', whereIn);
    if (isNull != null) {
      assert(
          isNull,
          'isNull can only be set to true. '
          'Use isEqualTo to filter on non-null values.');
      addCondition(field, '==', null);
    }

    return _copyWithParameters(<String, dynamic>{'where': conditions});
  }

  @override
  Query orderBy(field, {bool descending = false}) {
    assert(field != null && descending != null);
    assert(field is String || field is FieldPath,
        'Supported [field] types are [String] and [FieldPath].');

    final List<List<dynamic>> orders =
        List<List<dynamic>>.from(parameters['orderBy']);

    final List<dynamic> order = <dynamic>[field, descending];
    assert(orders.where((List<dynamic> item) => field == item[0]).isEmpty,
        'OrderBy $field already exists in this query');

    assert(() {
      if (field == FieldPath.documentId) {
        return !(parameters.containsKey('startAfterDocument') ||
            parameters.containsKey('startAtDocument') ||
            parameters.containsKey('endAfterDocument') ||
            parameters.containsKey('endAtDocument'));
      }
      return true;
    }(),
        '{start/end}{At/After/Before}Document order by document id themselves. '
        'Hence, you may not use an order by [FieldPath.documentId] when using any of these methods for a query.');

    orders.add(order);
    return _copyWithParameters(<String, dynamic>{'orderBy': orders});
  }

  @override
  Query startAfterDocument(DocumentSnapshot documentSnapshot) {
    assert(documentSnapshot != null);
    assert(!parameters.containsKey('startAfter'));
    assert(!parameters.containsKey('startAt'));
    assert(!parameters.containsKey('startAfterDocument'));
    assert(!parameters.containsKey('startAtDocument'));
    assert(
        List<List<dynamic>>.from(parameters['orderBy'])
            .where((List<dynamic> item) => item[0] == FieldPath.documentId)
            .isEmpty,
        '[startAfterDocument] orders by document id itself. '
        'Hence, you may not use an order by [FieldPath.documentId] when using [startAfterDocument].');
    return _copyWithParameters(<String, dynamic>{
      'startAfterDocument': <String, dynamic>{
        'id': documentSnapshot.documentID,
        'path': documentSnapshot.reference.path,
        'data': documentSnapshot.data
      }
    });
  }

  @override
  Query startAtDocument(DocumentSnapshot documentSnapshot) {
    assert(documentSnapshot != null);
    assert(!parameters.containsKey('startAfter'));
    assert(!parameters.containsKey('startAt'));
    assert(!parameters.containsKey('startAfterDocument'));
    assert(!parameters.containsKey('startAtDocument'));
    assert(
        List<List<dynamic>>.from(parameters['orderBy'])
            .where((List<dynamic> item) => item[0] == FieldPath.documentId)
            .isEmpty,
        '[startAtDocument] orders by document id itself. '
        'Hence, you may not use an order by [FieldPath.documentId] when using [startAtDocument].');
    return _copyWithParameters(<String, dynamic>{
      'startAtDocument': <String, dynamic>{
        'id': documentSnapshot.documentID,
        'path': documentSnapshot.reference.path,
        'data': documentSnapshot.data
      },
    });
  }

  @override
  Query startAfter(List values) {
    assert(values != null);
    assert(!parameters.containsKey('startAfter'));
    assert(!parameters.containsKey('startAt'));
    assert(!parameters.containsKey('startAfterDocument'));
    assert(!parameters.containsKey('startAtDocument'));
    return _copyWithParameters(<String, dynamic>{'startAfter': values});
  }

  @override
  Query startAt(List values) {
    assert(values != null);
    assert(!parameters.containsKey('startAfter'));
    assert(!parameters.containsKey('startAt'));
    assert(!parameters.containsKey('startAfterDocument'));
    assert(!parameters.containsKey('startAtDocument'));
    return _copyWithParameters(<String, dynamic>{'startAt': values});
  }

  @override
  Query endAtDocument(DocumentSnapshot documentSnapshot) {
    assert(documentSnapshot != null);
    assert(!parameters.containsKey('endBefore'));
    assert(!parameters.containsKey('endAt'));
    assert(!parameters.containsKey('endBeforeDocument'));
    assert(!parameters.containsKey('endAtDocument'));
    assert(
        List<List<dynamic>>.from(parameters['orderBy'])
            .where((List<dynamic> item) => item[0] == FieldPath.documentId)
            .isEmpty,
        '[endAtDocument] orders by document id itself. '
        'Hence, you may not use an order by [FieldPath.documentId] when using [endAtDocument].');

    return _copyWithParameters(<String, dynamic>{
      'endAtDocument': <String, dynamic>{
        'id': documentSnapshot.documentID,
        'path': documentSnapshot.reference.path,
        'data': documentSnapshot.data
      },
    });
  }

  @override
  Query endAt(List values) {
    assert(values != null);
    assert(!parameters.containsKey('endBefore'));
    assert(!parameters.containsKey('endAt'));
    assert(!parameters.containsKey('endBeforeDocument'));
    assert(!parameters.containsKey('endAtDocument'));
    return _copyWithParameters(<String, dynamic>{'endAt': values});
  }

  @override
  Query endBeforeDocument(DocumentSnapshot documentSnapshot) {
    assert(documentSnapshot != null);
    assert(!parameters.containsKey('endBefore'));
    assert(!parameters.containsKey('endAt'));
    assert(!parameters.containsKey('endBeforeDocument'));
    assert(!parameters.containsKey('endAtDocument'));
    assert(
        List<List<dynamic>>.from(parameters['orderBy'])
            .where((List<dynamic> item) => item[0] == FieldPath.documentId)
            .isEmpty,
        '[endBeforeDocument] orders by document id itself. '
        'Hence, you may not use an order by [FieldPath.documentId] when using [endBeforeDocument].');
    return _copyWithParameters(<String, dynamic>{
      'endBeforeDocument': <String, dynamic>{
        'id': documentSnapshot.documentID,
        'path': documentSnapshot.reference.path,
        'data': documentSnapshot.data,
      },
    });
  }

  @override
  Query endBefore(List values) {
    assert(values != null);
    assert(!parameters.containsKey('endBefore'));
    assert(!parameters.containsKey('endAt'));
    assert(!parameters.containsKey('endBeforeDocument'));
    assert(!parameters.containsKey('endAtDocument'));
    return _copyWithParameters(<String, dynamic>{'endBefore': values});
  }
}
