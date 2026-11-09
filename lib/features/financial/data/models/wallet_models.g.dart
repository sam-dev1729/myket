// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletModel _$WalletModelFromJson(Map<String, dynamic> json) => WalletModel(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  balance: (json['balance'] as num).toInt(),
  updatedAt: json['updated_at'] as String?,
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$WalletModelToJson(WalletModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'balance': instance.balance,
      'updated_at': instance.updatedAt,
      'created_at': instance.createdAt,
    };

WalletTransactionModel _$WalletTransactionModelFromJson(
  Map<String, dynamic> json,
) => WalletTransactionModel(
  id: json['id'] as String,
  type: json['type'] as String,
  reason: json['reason'] as String,
  amount: (json['amount'] as num).toInt(),
  fee: (json['fee'] as num?)?.toInt(),
  paymentMethod: json['payment_method'] as String,
  gatewayProvider: json['gateway_provider'] as String,
  paymentId: json['payment_id'] as String?,
  status: json['status'] as String,
  description: json['description'] as String,
  createdAt: json['created_at'] as String,
  paidAt: json['paid_at'] as String?,
);

Map<String, dynamic> _$WalletTransactionModelToJson(
  WalletTransactionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'reason': instance.reason,
  'amount': instance.amount,
  'fee': instance.fee,
  'payment_method': instance.paymentMethod,
  'gateway_provider': instance.gatewayProvider,
  'payment_id': instance.paymentId,
  'status': instance.status,
  'description': instance.description,
  'created_at': instance.createdAt,
  'paid_at': instance.paidAt,
};

PaginatedWalletTransactions _$PaginatedWalletTransactionsFromJson(
  Map<String, dynamic> json,
) => PaginatedWalletTransactions(
  meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
  data: (json['data'] as List<dynamic>)
      .map((e) => WalletTransactionModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PaginatedWalletTransactionsToJson(
  PaginatedWalletTransactions instance,
) => <String, dynamic>{'meta': instance.meta, 'data': instance.data};

TopupRequest _$TopupRequestFromJson(Map<String, dynamic> json) => TopupRequest(
  amount: (json['amount'] as num).toInt(),
  paymentGateway: json['payment_gateway'] as String?,
);

Map<String, dynamic> _$TopupRequestToJson(TopupRequest instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'payment_gateway': ?instance.paymentGateway,
    };

TopupResponse _$TopupResponseFromJson(Map<String, dynamic> json) =>
    TopupResponse(
      transactionId: json['transaction_id'] as String,
      amount: (json['amount'] as num).toInt(),
      status: json['status'] as String,
      gatewayUrl: json['gateway_url'] as String?,
    );

Map<String, dynamic> _$TopupResponseToJson(TopupResponse instance) =>
    <String, dynamic>{
      'transaction_id': instance.transactionId,
      'amount': instance.amount,
      'status': instance.status,
      'gateway_url': instance.gatewayUrl,
    };
