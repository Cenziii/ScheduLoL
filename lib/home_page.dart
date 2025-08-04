import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:lol_competitive/classes/league.dart';
import 'package:lol_competitive/classes/match.dart';
import 'package:lol_competitive/classes/serie.dart';
import 'package:lol_competitive/classes/tournament.dart';
import 'package:lol_competitive/components/card_match.dart';
import 'package:lol_competitive/league_page.dart';
import 'package:lol_competitive/services/panda.dart';
import 'package:responsive_builder/responsive_builder.dart';

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
  late CarouselController _carouselController;
  late League _currentLeague;
  late List<Match> _pastMatches = [];
  late List<Match> _runningMatches = [];
  late List<Match> _upcomingMatches = [];
  late List<Match> _allMatches = [];
  int _selectedIndex = 0;
  late final PageController _pageController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _carouselController = CarouselController();

    _init();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  void _init() async {
    await loadHomeData();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _carouselController.dispose();
    super.dispose();
  }

  Future<void> loadHomeData() async {
    await loadTournaments();
  }

  Future<void> loadTournaments() async {
    List<League>? leagues = await PandaService().getLeagues();

    if (leagues != null) {
      _leagues = leagues;
    } else {
      setState(() {
        _error = true;
      });
    }
    setState(() {
      if (_leagues.isNotEmpty) {
        _currentLeague = _leagues[0];
      }
    });
  }

  void clearMatches() {
    _pastMatches.clear();
    _runningMatches.clear();
    _upcomingMatches.clear();
    _allMatches.clear();
  }

  double getScrollOffsetForGroup(
    int groupIndex,
    List<List<Match>> groupedMatches,
  ) {
    const double groupHeaderHeight = 40;
    const double cardHeight = 100;

    double offset = 0;
    for (int i = 0; i < groupIndex; i++) {
      final group = groupedMatches[i];
      offset += groupHeaderHeight + (group.length * cardHeight);
    }
    return offset;
  }

  Future<void> currentLeagueSchedule(League lg) async {
    setState(() {
      _isLoadingSchedule = true;
    });
    clearMatches();
    Tournament? tournament = await PandaService().getCurrentTournament(lg.id);

    if (tournament != null) {
      _pastMatches = (await PandaService().getMatches('past', tournament.id!));
      _runningMatches = (await PandaService().getMatches(
        'running',
        tournament.id!,
      ));
      _upcomingMatches = (await PandaService().getMatches(
        'upcoming',
        tournament.id!,
      ));
    }
    _allMatches = List.from(_allMatches)
      ..addAll(_pastMatches)
      ..addAll(_runningMatches)
      ..addAll(_upcomingMatches);

    _allMatches.sort((a, b) => a.beginAt!.compareTo(b.beginAt!));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final index = indexOfCurrentWeek(_allMatches);
      // Approssimiamo l'altezza delle card (modifica se necessario)
      const double cardHeight = 100;
      _scrollController.jumpTo(index * cardHeight);
    });
    setState(() {
      _isLoadingSchedule = false;
    });
  }

  int indexOfCurrentWeek(List<Match> matches) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    for (int i = 0; i < matches.length; i++) {
      final matchDate = matches[i].beginAt;
      if (!matchDate!.isBefore(startOfWeek) && !matchDate.isAfter(endOfWeek)) {
        return i;
      }
    }

    return 0; // fallback
  }

  String getMatchGroup(Match match) {
    final now = DateTime.now().toUtc();
    final begin = match.beginAt;

    if (match.status == 'running') return 'Ora';
    if (begin!.isAfter(now)) return 'Prossime';
    return 'Passate';
  }

  String getWeekRange(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = date.subtract(
      Duration(days: date.weekday - 1),
    ); // lunedì
    final endOfWeek = startOfWeek.add(const Duration(days: 6)); // domenica

    final format = (DateTime d) =>
        '${d.day} ${_monthName(d.month)}'; // es: 29 luglio

    return '${format(startOfWeek)} – ${format(endOfWeek)}';
  }

  String _monthName(int month) {
    const months = [
      '',
      'gennaio',
      'febbraio',
      'marzo',
      'aprile',
      'maggio',
      'giugno',
      'luglio',
      'agosto',
      'settembre',
      'ottobre',
      'novembre',
      'dicembre',
    ];
    return months[month];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final font = GoogleFonts.pixelifySansTextTheme;

    if (!_error && !_isLoading) {
      return ResponsiveBuilder(
        builder: (responsiveContext, sizingInformation) {
          if (sizingInformation.deviceScreenType == DeviceScreenType.mobile) {
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
                iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
              ),
              endDrawer: Drawer(
                backgroundColor: theme.colorScheme.surface,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    DrawerHeader(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                      ),
                      child: Text(
                        'Header',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    ...['Leagues', 'Teams', 'Schedule', 'Preferred'].map(
                      (title) => ListTile(
                        title: Text(
                          title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),
              body: Column(
                children: [
                  SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _leagues.length,
                      itemBuilder: (context, index) {
                        final league = _leagues[index];
                        final isSelected = index == _selectedIndex;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIndex = index;
                              /*_pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );*/
                              currentLeagueSchedule(_leagues[_selectedIndex]);
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  child: ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: league.imageUrl ?? '',
                                      width: 55,
                                      height: 55,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) =>
                                          const CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                      errorWidget: (_, __, ___) =>
                                          const Icon(Icons.error),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  league.name ?? '',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),
                  // Lista unica scrollabile
                  Expanded(
                    child: _isLoadingSchedule
                        ? const Center(child: CircularProgressIndicator())
                        : GroupedListView<Match, DateTime>(
                            elements: _allMatches,
                            groupComparator: (a, b) => a.compareTo(b),
                            groupBy: (match) {
                              final date = match.beginAt;
                              return DateTime(
                                date!.year,
                                date!.month,
                                date!.day - (date!.weekday - 1),
                              );
                            },
                            groupSeparatorBuilder: (DateTime group) {
                              final end = group.add(const Duration(days: 6));
                              final formatter = DateFormat(
                                'dd MMM',
                              ); // puoi usare anche intl locale

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 16,
                                ),
                                child: Text(
                                  '${formatter.format(group)} - ${formatter.format(end)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },

                            itemBuilder: (context, match) =>
                                CardMatch(match: match),
                            itemComparator: (a, b) =>
                                a.beginAt!.compareTo(b.beginAt!),
                            useStickyGroupSeparators: false,
                            floatingHeader: false,
                            order: GroupedListOrder.ASC,
                            controller: _scrollController,
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
