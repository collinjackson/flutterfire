// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// This is a cross-platform representation of a `FieldValue`.
///
/// The wrapped value is not in the app-facing interface, but concrete
/// platform implementation can use `getDelegate` to look it up.
class FieldValuePlatform {
  /// Constructor
  FieldValuePlatform(this._delegate);

  final dynamic _delegate;

  /// Used by platform implementers to obtain a value suitable for being passed
  /// through to the underlying implementation.
  static dynamic getDelegate(FieldValuePlatform fieldValue) =>
      fieldValue._delegate;

  @deprecated
  // This method is no longer in use, but kept in place to avoid a breaking change.
  static void verifyExtends(FieldValuePlatform instance) {}
}
