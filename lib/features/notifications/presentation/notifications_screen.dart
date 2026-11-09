import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../l10n/app_localizations.dart';
import '../data/models/notification_models.dart';
import 'notifications_controller.dart';

/// The Notifications screen — paginated inbox from `GET /notification`.
///
/// Features:
/// - Search with submit
/// - Pull-to-refresh
/// - Infinite scroll
/// - Tap an unread notification → marks it as read (optimistic update)
/// - AppBar action → mark all as read
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - AppConstants.infiniteScrollThreshold) {
      ref.read(notificationsControllerProvider.notifier).loadMore();
    }
  }

  Future<void> _onMarkAllAsRead(AppLocalizations l10n) async {
    final ok = await ref.read(notificationsControllerProvider.notifier).markAllAsRead();
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.updateError), backgroundColor: AppTheme.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final asyncState = ref.watch(notificationsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: l10n.notificationsTitle,
            icon: Icon(Icons.done_all, color: context.iconColor),
            onPressed: () => _onMarkAllAsRead(l10n),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.screenPadding,
                vertical: AppConstants.paddingSmall,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: context.appDividerColor),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (q) => ref.read(notificationsControllerProvider.notifier).search(q),
                  decoration: InputDecoration(
                    hintText: l10n.notificationsSearchHint,
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: context.textSecondaryColor),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Expanded(
              child: asyncState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.screenPadding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
                        const SizedBox(height: AppConstants.paddingSmall),
                        Text('${l10n.genericErrorPrefix}: $e', textAlign: TextAlign.center),
                        const SizedBox(height: AppConstants.paddingSmall),
                        TextButton(
                          onPressed: () =>
                              ref.read(notificationsControllerProvider.notifier).refresh(),
                          child: Text(l10n.retry),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (data) {
                  if (data.items.isEmpty) {
                    return Center(child: Text(l10n.notificationsEmpty));
                  }
                  return RefreshIndicator(
                    onRefresh: () => ref.read(notificationsControllerProvider.notifier).refresh(),
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPadding),
                      itemCount: data.items.length + (data.hasMore ? 1 : 0),
                      separatorBuilder: (_, _) => const SizedBox(height: AppConstants.paddingSmall),
                      itemBuilder: (context, index) {
                        if (index >= data.items.length) {
                          return const Padding(
                            padding: EdgeInsets.all(AppConstants.paddingLarge),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final receipt = data.items[index];
                        return _NotificationCard(
                          receipt: receipt,
                          onTap: () async {
                            final ok = await ref
                                .read(notificationsControllerProvider.notifier)
                                .markAsRead(receipt.notification.id);
                            if (!mounted || ok) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.updateError),
                                backgroundColor: AppTheme.error,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single notification card.
class _NotificationCard extends StatelessWidget {
  final NotificationReceipt receipt;
  final VoidCallback onTap;

  const _NotificationCard({required this.receipt, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final item = receipt.notification;
    final unread = !receipt.isRead;

    return GestureDetector(
      onTap: unread ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        decoration: BoxDecoration(
          color: context.surfaceVariantColor,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          border: unread ? Border.all(color: AppTheme.primary, width: 1.5) : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: AppConstants.notificationCardImageSize,
              height: AppConstants.notificationCardImageSize,
              decoration: BoxDecoration(
                color: context.appDividerColor,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Icon(
                Icons.notifications_active_outlined,
                color: context.textSecondaryColor,
                size: 40,
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: context.appDividerColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.tag,
                      style: TextStyle(
                        fontSize: 10,
                        color: context.textSecondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    item.title,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: unread ? FontWeight.bold : FontWeight.w500,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingTiny),
                  Text(
                    _formatDate(item.releaseDate),
                    style: TextStyle(fontSize: 11, color: context.textTertiaryColor),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    item.description,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Formats an ISO date string into a localized date.
  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('yyyy/MM/dd HH:mm').format(dt);
    } catch (_) {
      return iso;
    }
  }
}
