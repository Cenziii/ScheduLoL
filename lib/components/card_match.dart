import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lol_competitive/classes/match.dart';
import 'package:lol_competitive/classes/streamlist.dart';
import 'package:lol_competitive/classes/team.dart';
import 'package:url_launcher/url_launcher.dart';

class CardMatch extends StatelessWidget {
  final Match match;

  const CardMatch({super.key, required this.match});

  String getTeamName(Team opponent) {
    if (opponent.acronym != null) {
      return opponent.acronym!;
    } else if (opponent.name != null && opponent.name!.length >= 3) {
      return opponent.name!.replaceAll(' ', '').substring(1, 3);
    } else {
      return 'TBD';
    }
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
      debugPrint('Could not launch Twitch app or website.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String team1 = '';
    String team2 = '';
    String logoTeam1 = '';
    String logoTeam2 = '';
    DateTime scheduleAt = DateTime.now();

    // Default values
    team1 = "TBD";
    team2 = "TBD";
    logoTeam1 = '';
    logoTeam2 = '';

    if (match.opponents.isNotEmpty) {
      // Team 1
      final opponent1 = match.opponents[0];
      team1 = getTeamName(opponent1);
      logoTeam1 = opponent1.imageUrl ?? '';

      // Team 2 (if exists)
      if (match.opponents.length > 1) {
        final opponent2 = match.opponents[1];
        team2 = getTeamName(opponent2);
        logoTeam2 = opponent2.imageUrl ?? '';
      }
    }

    if (match.scheduledAt != null) {
      scheduleAt = match.scheduledAt!;
      scheduleAt = scheduleAt.add(Duration(hours: 2));
    }

    String matchType = (match.matchType!.contains('best_of')) ? 'Bo' : '';
    String numberOfGames = match.numberOfGames!.toString();

    return Card(
      elevation: 8,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const SizedBox(width: 12),

          SizedBox(
            width: 50,
            height: 50,
            child: CachedNetworkImage(
              imageUrl: logoTeam1,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  CircularProgressIndicator(color: theme.colorScheme.primary),
              errorWidget: (context, url, error) => const Icon(Icons.group),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              team1,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                child: Text(
                  '$matchType$numberOfGames',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              if (match.status == 'running')
                IconButton(
                  icon: Image.asset('assets/icon/live-stream.png', scale: 12),
                  onPressed: () async {
                    if (match.streamsList.isNotEmpty) {
                      await launchLive(match.streamsList.first);
                    }
                  },
                ),
              if (match.status == 'not_started')
                Text(
                  ' - ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
              if (match.status == 'finished')
                Text(
                  '${match.results[0].score}-${match.results[1].score}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),

              FittedBox(
                child: Text(
                  DateFormat('dd-MMM - HH:mm').format(scheduleAt),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),

          // Team 2 name
          Expanded(
            flex: 2,
            child: Text(
              team2,
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            height: 50,
            child: CachedNetworkImage(
              imageUrl: logoTeam2,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  CircularProgressIndicator(color: theme.colorScheme.primary),
              errorWidget: (context, url, error) => const Icon(Icons.group),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}
