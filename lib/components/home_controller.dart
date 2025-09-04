import 'package:flutter/material.dart';
import 'package:lol_competitive/classes/league.dart';
import 'package:lol_competitive/classes/match.dart';
import 'package:lol_competitive/classes/tournament.dart';
import 'package:lol_competitive/services/github.dart';
import 'package:lol_competitive/services/panda.dart';
import 'package:lol_competitive/services/shared_prefs.dart';
import 'package:url_launcher/url_launcher.dart';

mixin HomeController<T extends StatefulWidget> on State<T> {
  bool _error = false;
  bool _isLoading = true;
  bool _isLoadingSchedule = false;
  List<League> _leagues = [];
  late List<Match> _allMatches = [];
  int _selectedIndex = 1;
  int _selectedLeagueId = 0;
  late final PageController _pageController;
  ScrollController _scrollController = ScrollController();
  String apkUrl = '';
  String latestVersion = '';
  bool _updateAvailable = false;

  bool get isError => _error;
  bool get isLoading => _isLoading;
  bool get isLoadingSchedule => _isLoadingSchedule;
  List<League> get getLeagues => _leagues;
  List<Match> get getAllMatches => _allMatches;
  int get selectedIndex => _selectedIndex;
  int get selectedLeagueId => _selectedLeagueId;
  bool get isUpdateAvailable => _updateAvailable;
  PageController get pageController => _pageController;
  ScrollController get scrollController => _scrollController;

  // SETTER
  set isError(bool value) {
    setState(() {
      _error = value;
    });
  }

  set isLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  set updateAvailable(bool value) {
    setState(() {
      _updateAvailable = value;
    });
  }

  set isLoadingSchedule(bool value) {
    setState(() {
      _isLoadingSchedule = value;
    });
  }

  set getLeagues(List<League> value) {
    setState(() {
      _leagues = value;
    });
  }

  set getAllMatches(List<Match> value) {
    setState(() {
      _allMatches = value;
    });
  }

  set selectedIndex(int value) {
    setState(() {
      _selectedIndex = value;
    });
  }

  set selectedLeagueId(int value) {
    setState(() {
      _selectedLeagueId = value;
    });
  }

  set pageController(PageController value) {
    setState(() {
      _pageController = value;
    });
  }

  set scrollController(ScrollController value) {
    setState(() {
      _scrollController = value;
    });
  }

  @override
  void initState() {
    super.initState();
    _init();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  void _init() async {
    try {
      await _checkUpdate();
      await loadHomePage();
    } catch (e) {
      isError = true;
      isLoading = false;
      isLoadingSchedule = false;
    }
  }

  Future<void> loadHomePage() async {
    try {
      await loadChampionship();
      if (_leagues.isNotEmpty) {
        await currentLeagueSchedule(_leagues.first);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refreshLeagueSchedule() async {
    await currentLeagueSchedule(_leagues.first);
    setState(() {});
  }

  Future<void> loadChampionship() async {
    try {
      List<League>? leagues = await PandaService().loadListOfLeagues();
      if (leagues != null) {
        setState(() {
          _leagues = leagues;
          isLoading = false;
          isError = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } on Exception catch (e) {
      throw Exception('Error during init');
    }
  }

  void onReorder(int oldIndex, int newIndex) {
    setState(() {
      final item = _leagues.removeAt(oldIndex);
      _leagues.insert(newIndex, item);
    });

    SharedPreferencesService().setSharedPreferences(
      'league_ids',
      _leagues.map((item) => item.id.toString()).toList(),
    );
  }

  Future<void> currentLeagueSchedule(League lg) async {
    setState(() {
      isLoadingSchedule = true;
    });

    _selectedLeagueId = lg.id;

    _allMatches.clear();
    try {
      List<Tournament>? tournament = await PandaService().getCurrentTournament(
        lg.id,
      );
      if (tournament != null) {
        for (int i = 0; i < tournament.length; i++) {
          final past = await PandaService().getMatches(
            'past',
            tournament[i].id!,
          );
          // check past notifications not deleted in shared preferences
          SharedPreferencesService().checkNotificationsPastMatch(past);
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
    } catch (ex) {
      setState(() {
        isLoadingSchedule = false;
        isError = true;
        return;
      });
    }

    setState(() {
      isLoadingSchedule = false;
      isError = false;
    });
    return;
  }

  Future<void> _checkUpdate() async {
    var update = await GitHubService().getCheckUpdates();

    if (update != null && mounted) {
      setState(() {
        updateAvailable = true;
        apkUrl = update[1];
        latestVersion = update[0];
      });
      
    } else if (mounted) {
      setState(() {
        updateAvailable = false;
      });
    }
  }

  void showUpdateDialog(
    BuildContext context,
    String latestVersion,
    String apkUrl,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Version available'),
        content: Text('New version $latestVersion '),
        actions: [
          TextButton(
            child: const Text('Later'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Download'),
            onPressed: () {
              Navigator.pop(context);
              launchURL(apkUrl);
            },
          ),
        ],
      ),
    );
  }

  Future<void> launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}
