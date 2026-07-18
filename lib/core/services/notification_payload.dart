import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationPayload {
  final String type;
  final String? id;
  final String? url;

  NotificationPayload({required this.type, this.id, this.url});

  factory NotificationPayload.fromJson(Map<String, dynamic> json) {
    return NotificationPayload(
      type: json['type'] as String? ?? 'notificacion',
      id: json['id'] as String?,
      url: json['url'] as String?,
    );
  }

  factory NotificationPayload.fromMessage(RemoteMessage message) {
    return NotificationPayload.fromJson(message.data);
  }

  Map<String, dynamic> toJson() => {'type': type, 'id': id, 'url': url};
}
