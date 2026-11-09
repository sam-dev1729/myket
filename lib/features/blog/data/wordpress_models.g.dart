// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wordpress_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlogPost _$BlogPostFromJson(Map<String, dynamic> json) => BlogPost(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  excerpt: json['excerpt'] as String,
  content: json['content'] as String,
  date: json['date'] as String,
  featuredImageUrl: json['featuredImageUrl'] as String?,
  categoryIds: (json['categoryIds'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  categories: (json['categories'] as List<dynamic>)
      .map((e) => BlogCategory.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BlogPostToJson(BlogPost instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'excerpt': instance.excerpt,
  'content': instance.content,
  'date': instance.date,
  'featuredImageUrl': instance.featuredImageUrl,
  'categoryIds': instance.categoryIds,
  'categories': instance.categories.map((e) => e.toJson()).toList(),
};

BlogCategory _$BlogCategoryFromJson(Map<String, dynamic> json) => BlogCategory(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  count: (json['count'] as num).toInt(),
);

Map<String, dynamic> _$BlogCategoryToJson(BlogCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'count': instance.count,
    };
