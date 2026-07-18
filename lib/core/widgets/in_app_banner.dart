import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/notification_payload.dart';
import '../services/notification_service.dart';

class _CurrentNotificationNotifier extends Notifier<RemoteMessage?> {
  @override
  RemoteMessage? build() => null;

  void show(RemoteMessage message) => state = message;
  void dismiss() => state = null;
}

final currentNotificationProvider =
    NotifierProvider<_CurrentNotificationNotifier, RemoteMessage?>(
  _CurrentNotificationNotifier.new,
);

class InAppBanner extends ConsumerStatefulWidget {
  const InAppBanner({super.key});

  @override
  ConsumerState<InAppBanner> createState() => _InAppBannerState();
}

class _InAppBannerState extends ConsumerState<InAppBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  Timer? _dismissTimer;
  RemoteMessage? _lastMessage;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<RemoteMessage?>(currentNotificationProvider, (_, next) {
      _dismissTimer?.cancel();
      if (next != null && next != _lastMessage) {
        _lastMessage = next;
        _controller.forward();
        _dismissTimer = Timer(const Duration(seconds: 4), () {
          if (mounted) {
            _controller.reverse();
            ref.read(currentNotificationProvider.notifier).dismiss();
          }
        });
      } else if (next == null && _lastMessage != null) {
        _lastMessage = null;
        _controller.reverse();
      }
    });

    final message = ref.watch(currentNotificationProvider);
    final notification = message?.notification;
    if (message == null || notification == null) {
      return const SizedBox.shrink();
    }

    return SlideTransition(
      position: _slideAnimation,
      child: Material(
        elevation: 8,
        color: Colors.transparent,
        child: SafeArea(
          bottom: false,
          child: GestureDetector(
            onTap: () {
              _dismissTimer?.cancel();
              _controller.reverse();
              final notifier = ref.read(currentNotificationProvider.notifier);
              notifier.dismiss();
              NotificationService.instance.onNotificationTap
                  ?.call(NotificationPayload.fromMessage(message));
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 4, 12, 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1A3A5C),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          notification.title ?? 'Notificación',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF1A3A5C),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          notification.body ?? '',
                          style: const TextStyle(fontSize: 12, color: Colors.black87),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      _dismissTimer?.cancel();
                      _controller.reverse();
                      ref.read(currentNotificationProvider.notifier).dismiss();
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close, size: 18, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
