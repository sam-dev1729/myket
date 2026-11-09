import 'package:json_annotation/json_annotation.dart';

part 'catalog_models.g.dart';

/// Represents a single item in a medical catalog (Allergy, Disease, History).
@JsonSerializable()
class CatalogItem {
  final String id;
  final String name;

  @JsonKey(name: 'is_system')
  final bool? isSystem;

  const CatalogItem({required this.id, required this.name, this.isSystem});

  factory CatalogItem.fromJson(Map<String, dynamic> json) => _$CatalogItemFromJson(json);
  Map<String, dynamic> toJson() => _$CatalogItemToJson(this);
}

/// Request body to create a custom catalog item.
@JsonSerializable()
class CreateCatalogItemRequest {
  final String name;

  const CreateCatalogItemRequest({required this.name});

  Map<String, dynamic> toJson() => _$CreateCatalogItemRequestToJson(this);
}

/// Request body to rename an existing catalog item.
@JsonSerializable()
class UpdateCatalogItemRequest {
  final String name;

  const UpdateCatalogItemRequest({required this.name});

  Map<String, dynamic> toJson() => _$UpdateCatalogItemRequestToJson(this);
}
