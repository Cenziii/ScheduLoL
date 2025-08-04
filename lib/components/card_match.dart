import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lol_competitive/classes/match.dart';

class CardMatch extends StatelessWidget {
  final Match match;
  const CardMatch({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String label_t1 = '';
    String label_t2 = '';
    String ico_t1 = '';
    String ico_t2 = '';
    String result = '';
    DateTime scheduleAt = DateTime.now();

    if (match.opponents != null) {
      if (match.opponents.isEmpty) {
        label_t1 = "TBD";
        label_t2 = "TBD";
      } else if (match.opponents.length == 1) {
        label_t1 = match.opponents[0].acronym!;
        label_t2 = "TBD";
        ico_t1 = match.opponents[0].imageUrl!;
      } else if (match.opponents.length == 2) {
        label_t1 = match.opponents[0].acronym!;
        ico_t1 = match.opponents[0].imageUrl!;
        label_t2 = match.opponents[1].acronym!;
        ico_t2 = match.opponents[1].imageUrl!;
      }
    }
    if (match.scheduledAt != null) {
      scheduleAt = match.scheduledAt!;
      scheduleAt = scheduleAt.add(Duration(hours: 2));
    }

    if (match.results.isNotEmpty) {
      result = '${match.results[0].score}-${match.results[1].score}';
    }

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Padding(
            padding: EdgeInsetsGeometry.all(8),
            child: CachedNetworkImage(
              imageUrl: ico_t1,
              width: 50,
              height: 50,
              placeholder: (context, url) =>
                  CircularProgressIndicator(color: theme.colorScheme.primary),
              errorWidget: (context, url, error) => const Icon(Icons.group),
            ),
          ),
          Text(
            label_t1,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          if (match.results.isNotEmpty)
            Text(
              result,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
          if (match.results.isEmpty)
            Column(
              children: [
                FittedBox(
                  child: Text(
                    DateFormat('dd-MMM').format(scheduleAt),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                FittedBox(
                  child: Text(
                    DateFormat('HH:mm').format(scheduleAt),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          Text(
            label_t2,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          Padding(
            padding: EdgeInsetsGeometry.all(8),
            child: CachedNetworkImage(
              imageUrl: ico_t2,
              width: 50,
              height: 50,
              placeholder: (context, url) =>
                  CircularProgressIndicator(color: theme.colorScheme.primary),
              errorWidget: (context, url, error) => const Icon(Icons.group),
            ),
          ),
        ],
      ),
    );
  }
}
