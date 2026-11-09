import 'package:json_annotation/json_annotation.dart';

part 'common_models.g.dart';

/// Pagination metadata returned by all paginated API endpoints.
@JsonSerializable()
class PaginationMeta {
  /// Total number of items across all pages.
  final int total;

  /// Current page number (1-indexed).
  final int page;

  /// Maximum number of items per page.
  final int limit;

  /// Total number of pages available.
  @JsonKey(name: 'total_page')
  final int totalPage;

  /// Creates a [PaginationMeta] instance.
  const PaginationMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPage,
  });

  /// Deserializes a [PaginationMeta] from a JSON map.
  factory PaginationMeta.fromJson(Map<String, dynamic> json) => _$PaginationMetaFromJson(json);

  /// Serializes this [PaginationMeta] into a JSON map.
  Map<String, dynamic> toJson() => _$PaginationMetaToJson(this);
}
