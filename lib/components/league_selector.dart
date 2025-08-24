import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:reorderables/reorderables.dart';
import '../classes/league.dart';

class LeagueSelector extends StatelessWidget {
  final List<League> leagues;
  final int selectedLeagueId;
  final Function(int oldIndex, int newIndex) onReorder;
  final Function(League) onLeagueTap;

  final ScrollController scrollController = ScrollController();

  LeagueSelector({
    super.key,
    required this.leagues,
    required this.selectedLeagueId,
    required this.onReorder,
    required this.onLeagueTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    List<Widget> leagueWidgets = leagues.map((league) {
      final id = league.id;
      final isSelected = id == selectedLeagueId;

      return GestureDetector(
        key: ValueKey(id),
        onTap: () => onLeagueTap(league),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7),
          child: SizedBox(
            width: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.red : Colors.black,
                      width: 4,
                    ),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: league.imageUrl ?? '',
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (_, __, ___) => const Icon(Icons.error),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 40,
                  child: Text(
                    league.name ?? '',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();

    return SizedBox(
      height: 105,
      child: ReorderableRow(
        crossAxisAlignment: CrossAxisAlignment.start,
        onReorder: onReorder,
        scrollController: scrollController,
        children: leagueWidgets,
      ),
    );
  }
}
