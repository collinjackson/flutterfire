// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';

/// Platform Interface of a FieldValue; implementation for [FieldValueInterface]
abstract class FieldValuePlatform extends PlatformInterface {
  static final Object _token = Object();

  /// Throws an [AssertionError] if [instance] does not extend
  /// [FieldValuePlatform].
  ///
  /// This is used by the app-facing [FieldValue] to ensure that
  /// the object in which it's going to delegate calls has been
  /// constructed properly.
  static verifyExtends(FieldValuePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
  }

  /// Constructor
  FieldValuePlatform(this._delegate) : super(token: _token);

  final dynamic _delegate;

  // Used by platform implementers to obtain a value suitable for being passed
  // through to the underlying implementation.
  static dynamic getDelegate(FieldValuePlatform fieldValue) => fieldValue._delegate;
}
