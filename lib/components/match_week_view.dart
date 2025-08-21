import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lol_competitive/classes/match.dart';
import 'package:lol_competitive/components/card_match.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class MatchWeekView extends StatefulWidget {
  final List<Match> allMatches;

  const MatchWeekView({super.key, required this.allMatches});

  @override
  State<MatchWeekView> createState() => _MatchWeekViewState();
}

class _MatchWeekViewState extends State<MatchWeekView> {
  final PageController _pageController = PageController();

  late Map<DateTime, List<Match>> grouped;
  late List<DateTime> weekStartDates;

  @override
  void initState() {
    super.initState();
    grouped = groupMatchesByWeek(widget.allMatches);
    weekStartDates = grouped.keys.toList()..sort();

    // Scroll alla settimana corrente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final index = indexOfCurrentWeek();
      if (mounted) {
        _pageController.jumpToPage(index);
      }
    });
  }

  Map<DateTime, List<Match>> groupMatchesByWeek(List<Match> matches) {
    matches.sort((a, b) {
      if (a.beginAt == null && b.beginAt == null) return 0;
      if (a.beginAt == null) return 1;
      if (b.beginAt == null) return -1;
      return a.beginAt!.compareTo(b.beginAt!);
    });

    return groupBy(matches, (Match match) {
      final date = match.beginAt;

      final startOfWeek = DateTime(
        date!.year,
        date.month,
        date.day,
      ).subtract(Duration(days: date.weekday - 1));
      return DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    });
  }

  int indexOfCurrentWeek() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (int i = 0; i < weekStartDates.length; i++) {
      final start = weekStartDates[i];
      final end = start.add(const Duration(days: 6));
      if (today.isAfter(start.subtract(const Duration(days: 1))) &&
          today.isBefore(end.add(const Duration(days: 1)))) {
        return i;
      }
    }

    // Se non troviamo la settimana corrente (ad esempio se è prima di tutte)
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final isTabletLandscape =
        MediaQuery.of(context).size.width > 600 &&
        MediaQuery.of(context).orientation == Orientation.landscape;

    final headerStyle = TextStyle(
      fontSize: isTabletLandscape ? 24 : 18, // più grande su tablet landscape
      fontWeight: FontWeight.bold,
    );

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: weekStartDates.length,
            itemBuilder: (context, index) {
              final weekStart = weekStartDates[index];
              final matches = grouped[weekStart]!;
              final weekEnd = weekStart.add(const Duration(days: 6));
              final formatter = DateFormat('dd MMM');

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      '${formatter.format(weekStart)} - ${formatter.format(weekEnd)}',
                      style: headerStyle,
                    ),
                  ),
                  Expanded(
                    child: isTabletLandscape
                        ? GridView.builder(
                            padding: const EdgeInsets.all(8),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, // two cards per row
                                  childAspectRatio:
                                      5, // adjust height/width ratio
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                ),
                            itemCount: matches.length,
                            itemBuilder: (context, i) =>
                                CardMatch(match: matches[i]),
                          )
                        : ListView.builder(
                            itemCount: matches.length,
                            itemBuilder: (context, i) =>
                                CardMatch(match: matches[i]),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        SmoothPageIndicator(
          controller: _pageController,
          count: weekStartDates.length,
          effect: WormEffect(
            dotHeight: 10,
            dotWidth: 10,
            activeDotColor: Colors.blueAccent,
            dotColor: Colors.grey.shade300,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
