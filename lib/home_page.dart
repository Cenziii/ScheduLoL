import 'package:flutter/material.dart';
import 'package:lol_competitive/components/home_controller.dart';
import 'package:lol_competitive/components/home_header.dart';
import 'package:lol_competitive/components/league_selector.dart';
import 'package:lol_competitive/components/match_week_view.dart';
import 'package:responsive_builder/responsive_builder.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with HomeController<HomePage> {
  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!isError && !isLoading) {
      return ResponsiveBuilder(
        builder: (_, sizingInfo) {
          if (sizingInfo.isMobile || sizingInfo.isTablet) {
            return Scaffold(
              appBar: HomeHeader(
                theme: theme,
                updateAvailable: updateAvailable,
                apkUrl: apkUrl,
                onDownloadPressed: launchURL,
              ),
              body: Column(
                children: [
                  SizedBox(height: 5),
                  LeagueSelector(
                    leagues: getLeagues,
                    selectedLeagueId: selectedLeagueId,
                    onReorder: onReorder,
                    onLeagueTap: (lg) => currentLeagueSchedule(lg),
                  ),
                  const SizedBox(height: 2),
                  Expanded(
                    child: isLoadingSchedule
                        ? const Center(child: CircularProgressIndicator())
                        : MatchWeekView(
                            allMatches: getAllMatches,
                            onRefresh: refreshLeagueSchedule,
                          ),
                  ),
                ],
              ),
            );
          } else {
            return const Placeholder();
          }
        },
      );
    } else if (isError) {
      return AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          'Error',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          'An error occurred. Please try again.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      );
    } else {
      return Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      );
    }
  }
}
