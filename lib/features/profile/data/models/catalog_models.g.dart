// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CatalogItem _$CatalogItemFromJson(Map<String, dynamic> json) => CatalogItem(
  id: json['id'] as String,
  name: json['name'] as String,
  isSystem: json['is_system'] as bool?,
);

Map<String, dynamic> _$CatalogItemToJson(CatalogItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'is_system': instance.isSystem,
    };

CreateCatalogItemRequest _$CreateCatalogItemRequestFromJson(
  Map<String, dynamic> json,
) => CreateCatalogItemRequest(name: json['name'] as String);

Map<String, dynamic> _$CreateCatalogItemRequestToJson(
  CreateCatalogItemRequest instance,
) => <String, dynamic>{'name': instance.name};

UpdateCatalogItemRequest _$UpdateCatalogItemRequestFromJson(
  Map<String, dynamic> json,
) => UpdateCatalogItemRequest(name: json['name'] as String);

Map<String, dynamic> _$UpdateCatalogItemRequestToJson(
  UpdateCatalogItemRequest instance,
) => <String, dynamic>{'name': instance.name};
