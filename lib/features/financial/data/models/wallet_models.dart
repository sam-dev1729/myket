import 'package:json_annotation/json_annotation.dart';

import '../../../../core/constants/app_constants.dart';
import 'common_models.dart';

part 'wallet_models.g.dart';

/// Represents the user's wallet, returned by `GET /wallet`.
@JsonSerializable()
class WalletModel {
  /// Unique identifier (UUID) of the wallet.
  final String id;

  /// Identifier of the owning user.
  @JsonKey(name: 'user_id')
  final String userId;

  /// Current balance in Iranian Rial (IRR).
  final int balance;

  /// ISO-8601 timestamp of the last update.
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  /// ISO-8601 timestamp of creation.
  @JsonKey(name: 'created_at')
  final String? createdAt;

  /// Creates a [WalletModel] instance.
  const WalletModel({
    required this.id,
    required this.userId,
    required this.balance,
    this.updatedAt,
    this.createdAt,
  });

  /// Deserializes a [WalletModel] from a JSON map.
  factory WalletModel.fromJson(Map<String, dynamic> json) => _$WalletModelFromJson(json);

  /// Serializes this [WalletModel] into a JSON map.
  Map<String, dynamic> toJson() => _$WalletModelToJson(this);
}

/// Represents a single wallet transaction returned by
/// `GET /wallet/transactions`.
@JsonSerializable()
class WalletTransactionModel {
  /// Unique identifier (UUID) of the transaction.
  final String id;

  /// Transaction type. Compare with [AppConstants.transactionTypeDeposit]
  /// or [AppConstants.transactionTypeWithdrawal].
  final String type;

  /// Transaction reason. Compare with
  /// [AppConstants.transactionReasonWalletTopup] or
  /// [AppConstants.transactionReasonPackagePurchase].
  final String reason;

  /// Amount in Iranian Rial (IRR).
  final int amount;

  /// Optional fee amount in Iranian Rial (IRR).
  final int? fee;

  /// Payment method. Compare with
  /// [AppConstants.paymentMethodWallet], [AppConstants.paymentMethodGateway],
  /// or [AppConstants.paymentMethodMixed].
  @JsonKey(name: 'payment_method')
  final String paymentMethod;

  /// Gateway provider. Compare with
  /// [AppConstants.gatewayZarinpal] or [AppConstants.gatewayAp].
  @JsonKey(name: 'gateway_provider')
  final String gatewayProvider;

  /// Optional gateway payment identifier.
  @JsonKey(name: 'payment_id')
  final String? paymentId;

  /// Transaction status. Compare with
  /// [AppConstants.statusPending], [AppConstants.statusSuccess],
  /// [AppConstants.statusFailed], or [AppConstants.statusCancelled].
  final String status;

  /// Human-readable description of the transaction.
  final String description;

  /// ISO-8601 timestamp of creation.
  @JsonKey(name: 'created_at')
  final String createdAt;

  /// ISO-8601 timestamp when the transaction was paid (if any).
  @JsonKey(name: 'paid_at')
  final String? paidAt;

  /// Creates a [WalletTransactionModel] instance.
  const WalletTransactionModel({
    required this.id,
    required this.type,
    required this.reason,
    required this.amount,
    this.fee,
    required this.paymentMethod,
    required this.gatewayProvider,
    this.paymentId,
    required this.status,
    required this.description,
    required this.createdAt,
    this.paidAt,
  });

  /// Deserializes a [WalletTransactionModel] from a JSON map.
  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) =>
      _$WalletTransactionModelFromJson(json);

  /// Serializes this [WalletTransactionModel] into a JSON map.
  Map<String, dynamic> toJson() => _$WalletTransactionModelToJson(this);

  /// Whether this transaction is a deposit (money added to wallet).
  bool get isDeposit => type == AppConstants.transactionTypeDeposit;

  /// Whether this transaction is a withdrawal (money removed from wallet).
  bool get isWithdrawal => type == AppConstants.transactionTypeWithdrawal;

  /// Whether this transaction represents a wallet top-up.
  bool get isWalletTopup => reason == AppConstants.transactionReasonWalletTopup;

  /// Whether this transaction represents a package purchase.
  bool get isPackagePurchase => reason == AppConstants.transactionReasonPackagePurchase;

  /// Whether this transaction has succeeded.
  bool get isSuccess => status == AppConstants.statusSuccess;
}

/// Paginated wrapper for [WalletTransactionModel] lists.
@JsonSerializable()
class PaginatedWalletTransactions {
  /// Pagination metadata.
  final PaginationMeta meta;

  /// Page items.
  final List<WalletTransactionModel> data;

  /// Creates a [PaginatedWalletTransactions] instance.
  const PaginatedWalletTransactions({required this.meta, required this.data});

  /// Deserializes a [PaginatedWalletTransactions] from a JSON map.
  factory PaginatedWalletTransactions.fromJson(Map<String, dynamic> json) =>
      _$PaginatedWalletTransactionsFromJson(json);

  /// Serializes this [PaginatedWalletTransactions] into a JSON map.
  Map<String, dynamic> toJson() => _$PaginatedWalletTransactionsToJson(this);
}

/// Request body for `POST /wallet/topup`.
@JsonSerializable()
class TopupRequest {
  /// Top-up amount in Iranian Rial (IRR).
  final int amount;

  /// Optional gateway provider string. One of
  /// [AppConstants.gatewayZarinpal] or [AppConstants.gatewayAp].
  @JsonKey(name: 'payment_gateway', includeIfNull: false)
  final String? paymentGateway;

  /// Creates a [TopupRequest] instance.
  const TopupRequest({required this.amount, this.paymentGateway});

  /// Serializes this [TopupRequest] into a JSON map.
  Map<String, dynamic> toJson() => _$TopupRequestToJson(this);
}

/// Response body for `POST /wallet/topup`.
@JsonSerializable()
class TopupResponse {
  /// Identifier of the created transaction.
  @JsonKey(name: 'transaction_id')
  final String transactionId;

  /// Top-up amount in Iranian Rial (IRR).
  final int amount;

  /// Status string. Typically [AppConstants.statusPending].
  final String status;

  /// Gateway URL to open for payment, or null when no payment is needed.
  @JsonKey(name: 'gateway_url')
  final String? gatewayUrl;

  /// Creates a [TopupResponse] instance.
  const TopupResponse({
    required this.transactionId,
    required this.amount,
    required this.status,
    this.gatewayUrl,
  });

  /// Deserializes a [TopupResponse] from a JSON map.
  factory TopupResponse.fromJson(Map<String, dynamic> json) => _$TopupResponseFromJson(json);

  /// Serializes this [TopupResponse] into a JSON map.
  Map<String, dynamic> toJson() => _$TopupResponseToJson(this);
}
