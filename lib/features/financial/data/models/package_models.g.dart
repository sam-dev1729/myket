// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PackageModel _$PackageModelFromJson(Map<String, dynamic> json) => PackageModel(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  price: (json['price'] as num).toInt(),
  durationDays: (json['duration_days'] as num).toInt(),
  type: json['type'] as String,
  isActive: json['is_active'] as bool?,
);

Map<String, dynamic> _$PackageModelToJson(PackageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'price': instance.price,
      'duration_days': instance.durationDays,
      'type': instance.type,
      'is_active': instance.isActive,
    };

PaginatedPackages _$PaginatedPackagesFromJson(Map<String, dynamic> json) =>
    PaginatedPackages(
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
      data: (json['data'] as List<dynamic>)
          .map((e) => PackageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PaginatedPackagesToJson(PaginatedPackages instance) =>
    <String, dynamic>{'meta': instance.meta, 'data': instance.data};

PackageSummaryModel _$PackageSummaryModelFromJson(Map<String, dynamic> json) =>
    PackageSummaryModel(
      id: json['id'] as String,
      title: json['title'] as String?,
      type: json['type'] as String?,
      price: (json['price'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PackageSummaryModelToJson(
  PackageSummaryModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'type': instance.type,
  'price': instance.price,
};

UserPackageModel _$UserPackageModelFromJson(Map<String, dynamic> json) =>
    UserPackageModel(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      packageId: json['packageId'] as String?,
      status: json['status'] as String?,
      startsAt: json['startsAt'] as String?,
      expiresAt: json['expiresAt'] as String?,
      package: json['package'] == null
          ? null
          : PackageSummaryModel.fromJson(
              json['package'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$UserPackageModelToJson(UserPackageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'packageId': instance.packageId,
      'status': instance.status,
      'startsAt': instance.startsAt,
      'expiresAt': instance.expiresAt,
      'package': instance.package,
    };

PaginatedUserPackages _$PaginatedUserPackagesFromJson(
  Map<String, dynamic> json,
) => PaginatedUserPackages(
  meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
  data: (json['data'] as List<dynamic>)
      .map((e) => UserPackageModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PaginatedUserPackagesToJson(
  PaginatedUserPackages instance,
) => <String, dynamic>{'meta': instance.meta, 'data': instance.data};

CreateOrderRequest _$CreateOrderRequestFromJson(Map<String, dynamic> json) =>
    CreateOrderRequest(
      packageId: json['package_id'] as String,
      discountCode: json['discount_code'] as String?,
      useWallet: json['use_wallet'] as bool?,
      paymentGateway: json['payment_gateway'] as String?,
    );

Map<String, dynamic> _$CreateOrderRequestToJson(CreateOrderRequest instance) =>
    <String, dynamic>{
      'package_id': instance.packageId,
      'discount_code': ?instance.discountCode,
      'use_wallet': ?instance.useWallet,
      'payment_gateway': ?instance.paymentGateway,
    };

CreateOrderResponse _$CreateOrderResponseFromJson(Map<String, dynamic> json) =>
    CreateOrderResponse(
      orderId: json['order_id'] as String,
      discountAmount: (json['discount_amount'] as num).toInt(),
      walletAmount: (json['wallet_amount'] as num).toInt(),
      gatewayAmount: (json['gateway_amount'] as num).toInt(),
      status: json['status'] as String,
      gatewayUrl: json['gateway_url'] as String?,
    );

Map<String, dynamic> _$CreateOrderResponseToJson(
  CreateOrderResponse instance,
) => <String, dynamic>{
  'order_id': instance.orderId,
  'discount_amount': instance.discountAmount,
  'wallet_amount': instance.walletAmount,
  'gateway_amount': instance.gatewayAmount,
  'status': instance.status,
  'gateway_url': instance.gatewayUrl,
};

CreateMultiOrderRequest _$CreateMultiOrderRequestFromJson(
  Map<String, dynamic> json,
) => CreateMultiOrderRequest(
  packageIds: (json['package_ids'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  discountCode: json['discount_code'] as String?,
  useWallet: json['use_wallet'] as bool?,
  paymentGateway: json['payment_gateway'] as String?,
);

Map<String, dynamic> _$CreateMultiOrderRequestToJson(
  CreateMultiOrderRequest instance,
) => <String, dynamic>{
  'package_ids': instance.packageIds,
  'discount_code': ?instance.discountCode,
  'use_wallet': ?instance.useWallet,
  'payment_gateway': ?instance.paymentGateway,
};

CreateMultiOrderResponse _$CreateMultiOrderResponseFromJson(
  Map<String, dynamic> json,
) => CreateMultiOrderResponse(
  orderIds: (json['order_ids'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  discountAmount: (json['discount_amount'] as num).toInt(),
  walletAmount: (json['wallet_amount'] as num).toInt(),
  gatewayAmount: (json['gateway_amount'] as num).toInt(),
  status: json['status'] as String,
  gatewayUrl: json['gateway_url'] as String?,
);

Map<String, dynamic> _$CreateMultiOrderResponseToJson(
  CreateMultiOrderResponse instance,
) => <String, dynamic>{
  'order_ids': instance.orderIds,
  'discount_amount': instance.discountAmount,
  'wallet_amount': instance.walletAmount,
  'gateway_amount': instance.gatewayAmount,
  'status': instance.status,
  'gateway_url': instance.gatewayUrl,
};

GatewayStatusModel _$GatewayStatusModelFromJson(Map<String, dynamic> json) =>
    GatewayStatusModel(
      ap: json['AP'] as bool,
      zarinpal: json['ZARINPAL'] as bool,
    );

Map<String, dynamic> _$GatewayStatusModelToJson(GatewayStatusModel instance) =>
    <String, dynamic>{'AP': instance.ap, 'ZARINPAL': instance.zarinpal};
