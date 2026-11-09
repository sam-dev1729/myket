/// A three-state wrapper for PATCH request fields where the caller must
/// distinguish between:
///
/// - **[Optional.absent]** — omit the field from JSON (leave unchanged)
/// - **[Optional.of]** — include the field with a value
/// - **[Optional.ofNullable] with null** — include the field as `null`
///   (explicit clear on the backend)
///
/// This solves the limitation of `@JsonKey(includeIfNull: false)` in
/// json_serializable, which conflates "unchanged" with "clear".
class Optional<T> {
  final T? _value;
  final bool _isPresent;

  /// Present with a non-null value.
  const Optional.of(T value) : _value = value, _isPresent = true;

  /// Present with a nullable value (null → explicit clear in JSON).
  const Optional.ofNullable(T? value) : _value = value, _isPresent = true;

  /// Absent — field will be omitted from the JSON payload.
  const Optional.absent() : _value = null, _isPresent = false;

  /// Whether the field should be included in the JSON payload.
  bool get isPresent => _isPresent;

  /// The value (may be null when [isPresent] is true).
  T? get value => _value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Optional<T> && other._isPresent == _isPresent && other._value == _value);

  @override
  int get hashCode => Object.hash(_isPresent, _value);

  @override
  String toString() => isPresent ? 'Optional.of($_value)' : 'Optional.absent()';
}
