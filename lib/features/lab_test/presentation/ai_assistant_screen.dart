import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../l10n/app_localizations.dart';
import 'health_overview_provider.dart';
import 'utils/health_assistant.dart';

/// Chat screen for the local AI health assistant.
///
/// The assistant answers questions using the health overview already loaded
/// in the app; no question or health data leaves the device.
class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _greeted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_greeted) return;
    _greeted = true;
    final l10n = AppLocalizations.of(context)!;
    final overview = ref.read(healthOverviewProvider).value;
    _messages.add(
      _ChatMessage(text: buildAssistantGreeting(overview: overview, l10n: l10n), isUser: false),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Sends the current input to the assistant and appends its reply.
  Future<void> _send() async {
    final question = _inputController.text.trim();
    if (question.isEmpty || _isTyping) return;

    final l10n = AppLocalizations.of(context)!;
    final overview = ref.read(healthOverviewProvider).value;

    setState(() {
      _messages.add(_ChatMessage(text: question, isUser: true));
      _isTyping = true;
    });
    _inputController.clear();
    _scrollToBottom();

    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;

    final reply = buildAssistantReply(question: question, overview: overview, l10n: l10n);
    setState(() {
      _isTyping = false;
      _messages.add(_ChatMessage(text: reply, isUser: false));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        title: Text(l10n.aiAssistantTitle),
        centerTitle: true,
        backgroundColor: AppTheme.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _MedicalPatternPainter(
                color: context.colorScheme.primary.withValues(alpha: 0.07),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _DisclaimerBanner(text: l10n.aiDisclaimer),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.screenPadding,
                      vertical: AppConstants.paddingMedium,
                    ),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= _messages.length) {
                        return const _TypingBubble();
                      }
                      return _MessageBubble(message: _messages[index]);
                    },
                  ),
                ),
                _InputBar(
                  controller: _inputController,
                  hint: l10n.aiInputHint,
                  onSend: _send,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Immutable chat message.
class _ChatMessage {
  const _ChatMessage({required this.text, required this.isUser});

  final String text;
  final bool isUser;
}

/// Chat bubble for one message.
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final background = isUser ? context.colorScheme.primary : context.surfaceColor;
    final foreground = isUser ? context.colorScheme.onPrimary : context.textPrimaryColor;

    return Align(
      alignment: isUser ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.82,
        ),
        margin: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingSmall + 2,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadiusDirectional.only(
            topStart: const Radius.circular(AppConstants.cardRadius),
            topEnd: const Radius.circular(AppConstants.cardRadius),
            bottomStart: Radius.circular(isUser ? AppConstants.cardRadius : AppConstants.paddingTiny),
            bottomEnd: Radius.circular(isUser ? AppConstants.paddingTiny : AppConstants.cardRadius),
          ),
          border: isUser ? null : Border.all(color: context.appDividerColor),
          boxShadow: isUser
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Text(
          message.text,
          style: TextStyle(fontSize: 13, height: 1.6, color: foreground),
        ),
      ),
    );
  }
}

/// Small typing indicator bubble.
class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          border: Border.all(color: context.appDividerColor),
        ),
        child: SizedBox(
          width: 36,
          height: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final size in [6.0, 8.0, 6.0])
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: context.textTertiaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Translucent disclaimer banner at the top of the chat.
class _DisclaimerBanner extends StatelessWidget {
  const _DisclaimerBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(
        AppConstants.screenPadding,
        AppConstants.paddingSmall,
        AppConstants.screenPadding,
        0,
      ),
      padding: const EdgeInsets.all(AppConstants.paddingSmall),
      decoration: BoxDecoration(
        color: context.surfaceColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: context.appDividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: context.textSecondaryColor),
          const SizedBox(width: AppConstants.paddingTiny),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 11, height: 1.5, color: context.textSecondaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom text field + send button.
class _InputBar extends StatelessWidget {
  const _InputBar({required this.controller, required this.hint, required this.onSend});

  final TextEditingController controller;
  final String hint;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppConstants.screenPadding,
        AppConstants.paddingSmall,
        AppConstants.screenPadding,
        AppConstants.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(top: BorderSide(color: context.appDividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: hint,
                filled: true,
                fillColor: context.surfaceVariantColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                  vertical: AppConstants.paddingSmall + 4,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          IconButton(
            onPressed: onSend,
            icon: Icon(Icons.send, color: context.colorScheme.primary),
          ),
        ],
      ),
    );
  }
}

/// Faint tiled medical pattern used as the chat background.
class _MedicalPatternPainter extends CustomPainter {
  const _MedicalPatternPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const step = 56.0;
    final columns = (size.width / step).ceil();
    final rows = (size.height / step).ceil();

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < columns; col++) {
        final center = Offset(col * step + step / 2, row * step + step / 2);
        switch ((row * 3 + col) % 5) {
          case 0:
            _drawPlus(canvas, paint, center);
            break;
          case 1:
            canvas.drawCircle(center, 7, paint);
            break;
          case 2:
            canvas.save();
            canvas.translate(center.dx, center.dy);
            canvas.rotate(math.pi / 4);
            canvas.drawRRect(
              RRect.fromRectAndRadius(
                const Rect.fromLTWH(-10, -4, 20, 8),
                const Radius.circular(4),
              ),
              paint,
            );
            canvas.restore();
            break;
          case 3:
            canvas.drawCircle(center, 8, paint);
            _drawPlus(canvas, paint, center, length: 4);
            break;
          default:
            canvas.drawCircle(center, 2.5, Paint()..color = color);
        }
      }
    }
  }

  void _drawPlus(Canvas canvas, Paint paint, Offset center, {double length = 7}) {
    canvas.drawLine(
      Offset(center.dx - length, center.dy),
      Offset(center.dx + length, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - length),
      Offset(center.dx, center.dy + length),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _MedicalPatternPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
