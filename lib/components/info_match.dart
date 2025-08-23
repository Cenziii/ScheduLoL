import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lol_competitive/classes/match.dart';
import 'package:lol_competitive/classes/streamlist.dart';
import 'package:lol_competitive/services/notification.dart';
import 'package:lol_competitive/services/shared_prefs.dart';
import 'package:url_launcher/url_launcher.dart';
class NotificationState extends StatefulWidget {
  const NotificationState({super.key, required this.match, required this.scheduleAt, required this.team1, required this.team2});
  final DateTime scheduleAt;
  final Match match;
  final String team1;
  final String team2;

  @override
  State<NotificationState> createState() => _NotificationStateState();
}

Future<void> launchLive(StreamsList stream) async {
    String channel = stream.rawUrl!.split('/').last;
    final liveAppUrl = Uri.parse('twitch://stream/$channel');
    final liveWebUrl = Uri.parse(stream.rawUrl!);

    // Try to open the Twitch app
    if (await canLaunchUrl(liveAppUrl)) {
      await launchUrl(liveWebUrl);
    }
    // Fallback to browser
    else if (await canLaunchUrl(liveWebUrl)) {
      await launchUrl(liveWebUrl, mode: LaunchMode.externalApplication);
    } else {
      // Error handling
      debugPrint('Could not launch the app or website.');
    }
  }

class _NotificationStateState extends State<NotificationState> {
  @override
  Widget build(BuildContext context) {
    if (widget.match.status == 'running') {
      return IconButton(
        icon: Image.asset('assets/icon/live-stream.png', scale: 12),
        onPressed: () async {
          if (widget.match.streamsList.isNotEmpty) {
            await launchLive(widget.match.streamsList.first);
          }
        },
      );
    } else if (widget.match.status == 'finished') {
      return Text(
        '${widget.match.results[0].score}-${widget.match.results[1].score}',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
      );
    } else if (widget.match.status == 'not_started') {
      return FutureBuilder<bool>(
        future: SharedPreferencesService().checkNotification(widget.match.id!),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Icon(Icons.sync);
          }

          bool notificationActivated = snapshot.data ?? false;

          return IconButton(
            icon: Icon(
              notificationActivated
                  ? Icons.notifications_active
                  : Icons.notification_add,
            ),
            onPressed: notificationActivated
                ? null
                : () async {
                    if (widget.match.scheduledAt != null) {
                      await NotificationService().scheduleNotification(
                        title: 'Match is starting',
                        body: '${widget.team1} vs ${widget.team2}',
                        datetime: widget.scheduleAt,
                        matchId: widget.match.id!,
                      );

                      await SharedPreferencesService()
                          .addNotificationsPastMatch(widget.match);

                      setState(() {});

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Notification created for ${widget.team1} vs ${widget.team2} at "
                            "${widget.match.scheduledAt!.hour}:${widget.match.scheduledAt!.minute.toString().padLeft(2, '0')}",
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
          );
        },
      );
    }

    // 🔑 fallback obbligatorio
    return const SizedBox.shrink();
  }
}