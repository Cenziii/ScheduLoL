import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lol_competitive/about_page.dart';
import 'package:lol_competitive/classes/league.dart';
import 'package:lol_competitive/classes/match.dart';
import 'package:lol_competitive/classes/tournament.dart';
import 'package:lol_competitive/components/match_week_view.dart';
import 'package:lol_competitive/services/github.dart';
import 'package:lol_competitive/services/panda.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reorderables/reorderables.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _error = false;
  bool _isLoading = true;
  bool _isLoadingSchedule = false;
  List<League> _leagues = [];
  List<int> _preferredLeagues = [];
  late League _currentLeague;
  late List<Match> _allMatches = [];
  int _selectedIndex = 0;
  int _selectedLeagueId = 0;
  late final PageController _pageController;
  final ScrollController _scrollController = ScrollController();
  String apkUrl = '';
  String latestVersion = '';
  bool updateAvailable = false;

  @override
  void initState() {
    super.initState();
    _init();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  void _init() async {
    await loadHomeData();

    _checkUpdate();
  }

  void _checkUpdate() async {
    var update = await GitHubService().getCheckUpdates();

    if (update != null && mounted) {
      setState(() {
        updateAvailable = true;
        apkUrl = update[1];
        latestVersion = update[0];
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showUpdateDialog(context, update[0], update[1]);
      });
    } else if (mounted) {
      setState(() {
        updateAvailable = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showUpdateDialog(
    BuildContext context,
    String latestVersion,
    String apkUrl,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nuova versione disponibile'),
        content: Text('È disponibile la versione $latestVersion dell’app.'),
        actions: [
          TextButton(
            child: const Text('Più tardi'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Aggiorna'),
            onPressed: () {
              Navigator.pop(context);
              _launchURL(apkUrl);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Future<void> loadHomeData() async {
    await loadTournaments();
    if (_leagues.isNotEmpty) {
      await currentLeagueSchedule(_leagues.first);
    }
  }

  Future<void> loadTournaments() async {
    List<League>? leagues = await PandaService().getLeagues();

    if (leagues != null && leagues.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      var strIds = prefs.getStringList('league_ids');

      if (strIds != null && strIds.isNotEmpty) {
        List<int> orderIds = strIds.map(int.parse).toList();

        Map<int, int> positionMap = {
          for (int i = 0; i < orderIds.length; i++) orderIds[i]: i,
        };

        leagues.sort(
          (a, b) => (positionMap[a.id] ?? orderIds.length).compareTo(
            positionMap[b.id] ?? orderIds.length,
          ),
        );
      } else {
        List<String> temp = [];
        prefs.setStringList('league_ids', temp);
      }
      setState(() {
        _leagues = leagues;

        _currentLeague = leagues[0];
        _isLoading = false;
        _error = false;
      });
    } else {
      setState(() {
        //_error = true;
        _isLoading = false;
      });
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      final item = _leagues.removeAt(oldIndex);
      _leagues.insert(newIndex, item);
    });

    storeInSharedPreferences();
  }

  Future<void> storeInSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    List<String> orderIds = _leagues.map((item) => item.id.toString()).toList();
    prefs.setStringList('league_ids', orderIds);
  }

  void checkNotificationsPastMatch(List<Match> match) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? ids = prefs.getStringList('notify_ids');
    print(ids);
    if (ids != null) {
      for (int i = 0; i < match.length; i++) {
        if (match[i].id != null) {
          ids.any((id) => id == match[i].id.toString());
          ids.removeWhere((element) => element == match[i].id.toString());
        }
      }
      prefs.setStringList('notify_ids', ids);
      print(ids);
    } else {
      List<String> ids = [];
      prefs.setStringList('notify_ids', ids);
    }
  }

  Future<void> currentLeagueSchedule(League lg) async {
    setState(() {
      _isLoadingSchedule = true;
    });

    _allMatches.clear();

    List<Tournament>? tournament = await PandaService().getCurrentTournament(
      lg.id,
    );

    if (tournament != null) {
      for (int i = 0; i < tournament.length; i++) {
        final past = await PandaService().getMatches('past', tournament[i].id!);
        // check past notifications not deleted in shared preferences
        checkNotificationsPastMatch(past);
        final running = await PandaService().getMatches(
          'running',
          tournament[i].id!,
        );
        final upcoming = await PandaService().getMatches(
          'upcoming',
          tournament[i].id!,
        );
        _allMatches = [
          ..._allMatches,
          ...past,
          ...running,
          ...upcoming,
        ].where((m) => m.beginAt != null).toList();
      }
    }

    setState(() {
      _isLoadingSchedule = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    List<Widget> leagueWidgets = _leagues.map((league) {
      final id = league.id;
      final isSelected = id == _selectedLeagueId;

      return GestureDetector(
        key: ValueKey(id), // Necessario per ReorderableRow
        onTap: () {
          setState(() {
            _selectedLeagueId = id;

            League? leagueSelected;
            try {
              leagueSelected = _leagues.firstWhere(
                (l) => l.id == _selectedLeagueId,
              );
            } catch (e) {
              leagueSelected = null;
            }
            if (leagueSelected != null) {
              currentLeagueSchedule(leagueSelected);
            }
          });
        },
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

    if (!_error && !_isLoading) {
      return ResponsiveBuilder(
        builder: (responsiveContext, sizingInformation) {
          if (sizingInformation.deviceScreenType == DeviceScreenType.mobile ||
              sizingInformation.deviceScreenType == DeviceScreenType.tablet) {
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  'ScheduLoL',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                backgroundColor: theme.colorScheme.primary,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(16),
                    bottomLeft: Radius.circular(25),
                  ),
                ),
                elevation: 1.0,
                centerTitle: true,
                leading: updateAvailable
                    ? IconButton(
                        icon: const Icon(Icons.download),
                        color: theme.colorScheme.surface,
                        tooltip: 'Scarica aggiornamento',
                        onPressed: () {
                          Navigator.pop(context);
                          _launchURL(apkUrl);
                        },
                      )
                    : null,
                iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
                actions: [
                  IconButton(
                    icon: Icon(Icons.info, color: theme.colorScheme.surface),
                    tooltip: 'About',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AboutPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              body: Column(
                children: [
                  SizedBox(height: 5),
                  SizedBox(
                    height: 105,
                    child: ReorderableRow(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      onReorder: _onReorder,
                      scrollController: _scrollController,
                      children: leagueWidgets,
                    ),
                  ),

                  const SizedBox(height: 2),
                  // Lista unica scrollabile
                  Expanded(
                    child: _isLoadingSchedule
                        ? const Center(child: CircularProgressIndicator())
                        : MatchWeekView(allMatches: _allMatches),
                  ),
                ],
              ),
            );
          } else {
            return const Placeholder();
          }
        },
      );
    } else if (_error) {
      return AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          'Errore',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Si è verificato un errore. Riprova.',
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
