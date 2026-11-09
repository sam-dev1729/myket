import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_response.dart';
import 'models/notification_models.dart';

part 'notifications_api.g.dart';

/// Retrofit interface for `/notification/*` endpoints.
@RestApi()
abstract class NotificationsApi {
  factory NotificationsApi(Dio dio, {String? baseUrl}) = _NotificationsApi;

  /// Paginated inbox for the authenticated user.
  @GET(AppConstants.notificationsEndpoint)
  Future<ApiResponse<PaginatedNotifications>> getNotifications({
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('search') String? search,
    @Query('is_read') bool? isRead,
    @Query('tag') String? tag,
  });

  /// Unread notifications count.
  @GET(AppConstants.notificationsUnreadCountEndpoint)
  Future<ApiResponse<UnreadCountResponse>> getUnreadCount();

  /// Marks a single notification as read.
  ///
  /// The backend returns the updated receipt, but the client already
  /// updates local state optimistically — `ApiResponse<void>` discards
  /// the body and is compatible with the mock's `success: true, body: null`.
  @PATCH(AppConstants.notificationsReadEndpoint)
  Future<ApiResponse<void>> markAsRead(@Body() MarkNotificationReadRequest request);

  /// Marks every unread notification as read.
  @PATCH(AppConstants.notificationsReadAllEndpoint)
  Future<ApiResponse<void>> markAllAsRead();
}
