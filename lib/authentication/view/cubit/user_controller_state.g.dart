// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_controller_state.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UserControllerStateCWProxy {
  UserControllerState user(User? user);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `UserControllerState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// UserControllerState(...).copyWith(id: 12, name: "My name")
  /// ```
  UserControllerState call({User? user});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfUserControllerState.copyWith(...)` or call `instanceOfUserControllerState.copyWith.fieldName(value)` for a single field.
class _$UserControllerStateCWProxyImpl implements _$UserControllerStateCWProxy {
  const _$UserControllerStateCWProxyImpl(this._value);

  final UserControllerState _value;

  @override
  UserControllerState user(User? user) => call(user: user);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `UserControllerState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// UserControllerState(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  UserControllerState call({Object? user = const $CopyWithPlaceholder()}) {
    return UserControllerState(
      user: user == const $CopyWithPlaceholder()
          ? _value.user
          // ignore: cast_nullable_to_non_nullable
          : user as User?,
    );
  }
}

extension $UserControllerStateCopyWith on UserControllerState {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfUserControllerState.copyWith(...)` or `instanceOfUserControllerState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UserControllerStateCWProxy get copyWith =>
      _$UserControllerStateCWProxyImpl(this);
}
