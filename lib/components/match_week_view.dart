import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lol_competitive/classes/match.dart';
import 'package:lol_competitive/components/card_match.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class MatchWeekView extends StatefulWidget {
  final List<Match> allMatches;
  final Future<void> Function() onRefresh;

  const MatchWeekView({
    super.key,
    required this.allMatches,
    required this.onRefresh,
  });

  @override
  State<MatchWeekView> createState() => _MatchWeekViewState();
}

class _MatchWeekViewState extends State<MatchWeekView> {
  final PageController _pageController = PageController();

  late Map<DateTime, List<Match>> grouped;
  late List<DateTime> weekStartDates;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    grouped = groupMatchesByWeek(widget.allMatches);
    weekStartDates = grouped.keys.toList()..sort();

    // Scroll to the current week
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && weekStartDates.isNotEmpty) {
        final index = indexOfCurrentWeek();
        _pageController.jumpToPage(index);
      }
    });
  }

  // Group matches by week
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

  // Find the index of the current week
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

    return weekStartDates.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    final isTabletLandscape =
        MediaQuery.of(context).size.width > 600 &&
        MediaQuery.of(context).orientation == Orientation.landscape;

    final headerStyle = TextStyle(
      fontSize: isTabletLandscape ? 24 : 18, 
      fontWeight: FontWeight.bold,
    );

    if (weekStartDates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Text("No matches available"),
            CachedNetworkImage(
              imageUrl: "https://media.tenor.com/W_GgSsF7x9sAAAAi/amumu-sad.gif",
              width: 150,
              height: 150,
              placeholder: (context, url) => SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: widget.onRefresh,
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
                                    crossAxisCount: 2,
                                    childAspectRatio: 5,
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