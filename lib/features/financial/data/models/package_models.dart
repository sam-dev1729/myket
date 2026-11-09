import 'package:json_annotation/json_annotation.dart';

import 'common_models.dart';

part 'package_models.g.dart';

/// Represents a purchasable package, returned by `GET /package`.
@JsonSerializable()
class PackageModel {
  /// Unique identifier (UUID) of the package.
  final String id;

  /// Display title of the package.
  final String title;

  /// Optional description of the package.
  final String? description;

  /// Price in Iranian Rial (IRR).
  final int price;

  /// Duration of the package in days.
  @JsonKey(name: 'duration_days')
  final int durationDays;

  /// Package type string (e.g. `BLOOD`, `GENETIC`, `GENEALOGY`).
  final String type;

  /// Whether the package is currently active and purchasable.
  @JsonKey(name: 'is_active')
  final bool? isActive;

  /// Creates a [PackageModel] instance.
  const PackageModel({
    required this.id,
    required this.title,
    this.description,
    required this.price,
    required this.durationDays,
    required this.type,
    this.isActive,
  });

  /// Deserializes a [PackageModel] from a JSON map.
  factory PackageModel.fromJson(Map<String, dynamic> json) => _$PackageModelFromJson(json);

  /// Serializes this [PackageModel] into a JSON map.
  Map<String, dynamic> toJson() => _$PackageModelToJson(this);
}

/// Paginated wrapper for [PackageModel] lists.
@JsonSerializable()
class PaginatedPackages {
  /// Pagination metadata.
  final PaginationMeta meta;

  /// Page items.
  final List<PackageModel> data;

  /// Creates a [PaginatedPackages] instance.
  const PaginatedPackages({required this.meta, required this.data});

  /// Deserializes a [PaginatedPackages] from a JSON map.
  factory PaginatedPackages.fromJson(Map<String, dynamic> json) =>
      _$PaginatedPackagesFromJson(json);

  /// Serializes this [PaginatedPackages] into a JSON map.
  Map<String, dynamic> toJson() => _$PaginatedPackagesToJson(this);
}

/// A lightweight summary of a package, embedded in user-package responses.
@JsonSerializable()
class PackageSummaryModel {
  /// Unique identifier (UUID) of the package.
  final String id;

  /// Optional display title.
  final String? title;

  /// Optional package type string.
  final String? type;

  /// Optional price in Iranian Rial (IRR).
  final int? price;

  /// Creates a [PackageSummaryModel] instance.
  const PackageSummaryModel({required this.id, this.title, this.type, this.price});

  /// Deserializes a [PackageSummaryModel] from a JSON map.
  factory PackageSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$PackageSummaryModelFromJson(json);

  /// Serializes this [PackageSummaryModel] into a JSON map.
  Map<String, dynamic> toJson() => _$PackageSummaryModelToJson(this);
}

/// Represents a user's entitlement to a package.
@JsonSerializable()
class UserPackageModel {
  /// Unique identifier (UUID) of the entitlement.
  final String id;

  /// Identifier of the owning user.
  @JsonKey(name: 'user_id')
  final String userId;

  /// Identifier of the purchased package.
  @JsonKey(name: 'package_id')
  final String packageId;

  /// Status string (`ACTIVE`, `EXPIRED`, `CANCELLED`).
  final String status;

  /// ISO-8601 timestamp when the entitlement starts.
  @JsonKey(name: 'starts_at')
  final String startsAt;

  /// ISO-8601 timestamp when the entitlement expires.
  @JsonKey(name: 'expires_at')
  final String expiresAt;

  /// Optional embedded package summary.
  final PackageSummaryModel? package;

  /// Creates a [UserPackageModel] instance.
  const UserPackageModel({
    required this.id,
    required this.userId,
    required this.packageId,
    required this.status,
    required this.startsAt,
    required this.expiresAt,
    this.package,
  });

  /// Deserializes a [UserPackageModel] from a JSON map.
  factory UserPackageModel.fromJson(Map<String, dynamic> json) => _$UserPackageModelFromJson(json);

  /// Serializes this [UserPackageModel] into a JSON map.
  Map<String, dynamic> toJson() => _$UserPackageModelToJson(this);
}

/// Paginated wrapper for [UserPackageModel] lists.
@JsonSerializable()
class PaginatedUserPackages {
  /// Pagination metadata.
  final PaginationMeta meta;

  /// Page items.
  final List<UserPackageModel> data;

  /// Creates a [PaginatedUserPackages] instance.
  const PaginatedUserPackages({required this.meta, required this.data});

  /// Deserializes a [PaginatedUserPackages] from a JSON map.
  factory PaginatedUserPackages.fromJson(Map<String, dynamic> json) =>
      _$PaginatedUserPackagesFromJson(json);

  /// Serializes this [PaginatedUserPackages] into a JSON map.
  Map<String, dynamic> toJson() => _$PaginatedUserPackagesToJson(this);
}

/// Request body for `POST /order/create`.
@JsonSerializable()
class CreateOrderRequest {
  /// Identifier of the package to purchase.
  @JsonKey(name: 'package_id')
  final String packageId;

  /// Optional discount code.
  @JsonKey(name: 'discount_code', includeIfNull: false)
  final String? discountCode;

  /// Whether to apply the wallet balance to the order.
  @JsonKey(name: 'use_wallet', includeIfNull: false)
  final bool? useWallet;

  /// Optional gateway provider string.
  @JsonKey(name: 'payment_gateway', includeIfNull: false)
  final String? paymentGateway;

  /// Creates a [CreateOrderRequest] instance.
  const CreateOrderRequest({
    required this.packageId,
    this.discountCode,
    this.useWallet,
    this.paymentGateway,
  });

  /// Serializes this [CreateOrderRequest] into a JSON map.
  Map<String, dynamic> toJson() => _$CreateOrderRequestToJson(this);
}

/// Response body for `POST /order/create`.
@JsonSerializable()
class CreateOrderResponse {
  /// Identifier of the created order.
  @JsonKey(name: 'order_id')
  final String orderId;

  /// Discount amount applied (IRR).
  @JsonKey(name: 'discount_amount')
  final int discountAmount;

  /// Wallet amount consumed (IRR).
  @JsonKey(name: 'wallet_amount')
  final int walletAmount;

  /// Amount to be paid via gateway (IRR).
  @JsonKey(name: 'gateway_amount')
  final int gatewayAmount;

  /// Order status string (`PENDING`, `SUCCESS`, `FAILED`, `CANCELLED`).
  final String status;

  /// Gateway URL to redirect the user, or null if no payment is needed.
  @JsonKey(name: 'gateway_url')
  final String? gatewayUrl;

  /// Creates a [CreateOrderResponse] instance.
  const CreateOrderResponse({
    required this.orderId,
    required this.discountAmount,
    required this.walletAmount,
    required this.gatewayAmount,
    required this.status,
    this.gatewayUrl,
  });

  /// Deserializes a [CreateOrderResponse] from a JSON map.
  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderResponseFromJson(json);

  /// Serializes this [CreateOrderResponse] into a JSON map.
  Map<String, dynamic> toJson() => _$CreateOrderResponseToJson(this);
}

/// Payment gateway up/down status returned by `GET /gateway/status`.
@JsonSerializable()
class GatewayStatusModel {
  /// Whether the Asan Pardakht gateway is enabled.
  @JsonKey(name: 'AP')
  final bool ap;

  /// Whether the Zarinpal gateway is enabled.
  @JsonKey(name: 'ZARINPAL')
  final bool zarinpal;

  /// Creates a [GatewayStatusModel] instance.
  const GatewayStatusModel({required this.ap, required this.zarinpal});

  /// Deserializes a [GatewayStatusModel] from a JSON map. Defaults missing
  /// keys to `true` to align with the backend behavior.
  factory GatewayStatusModel.fromJson(Map<String, dynamic> json) {
    final ap = json['AP'] ?? json['ap'] ?? true;
    final zp = json['ZARINPAL'] ?? json['zarinpal'] ?? true;
    return GatewayStatusModel(ap: ap as bool? ?? true, zarinpal: zp as bool? ?? true);
  }

  /// Serializes this [GatewayStatusModel] into a JSON map.
  Map<String, dynamic> toJson() => {'AP': ap, 'ZARINPAL': zarinpal};
}
