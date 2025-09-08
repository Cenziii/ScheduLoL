import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  // Dispose method to clean up resources when the widget is disposed
  @override
  void dispose() {
    pageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  // Build method to construct the UI of the HomePage
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Check if there's an error or loading state
    if (!isError && !isLoading) {
      return ResponsiveBuilder(
        builder: (_, sizingInfo) {
          // Build mobile and tablet layouts
          if (sizingInfo.isMobile || sizingInfo.isTablet) {
            return SafeArea(
              child: Scaffold(
                appBar: HomeHeader(
                  theme: theme,
                  updateAvailable: isUpdateAvailable,
                  apkUrl: apkUrl,
                  onDownloadPressed: launchURL,
                ),
                body: Column(
                  children: [
                    SizedBox(height: 5),
                    LeagueSelector(
                      leagues: getLeagues, // List of leagues
                      selectedLeagueId: selectedLeagueId, // Currently selected league ID
                      onReorder: onReorder, // Callback for reordering leagues
                      onLeagueTap: (lg) => currentLeagueSchedule(lg), // Callback when a league is tapped
                    ),
                    const SizedBox(height: 2),
                    Expanded(
                      child: isLoadingSchedule
                          ? const Center(child: CircularProgressIndicator()) // Loading indicator while fetching schedule
                          : MatchWeekView(
                              allMatches: getAllMatches, // List of all matches
                              onRefresh: refreshLeagueSchedule, // Callback to refresh the league schedule
                            ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Placeholder(); // Placeholder for desktop layout (not implemented)
          }
        },
      );
    } 
    // Handle error state
    else if (isError) {
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
            onPressed: () => SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
            child: Text(
              'OK',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      );
    } 
    // Handle loading state
    else {
      return Center(
        child: CachedNetworkImage(
          imageUrl: "https://media.tenor.com/-O9a6WKx4uAAAAAi/league-of-legends-league-of-legends-alistar.gif",
          width: 150,
          height: 150,
          placeholder: (context, url) => SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      );
    }
  }
}