import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lol_competitive/classes/league.dart';
import 'package:lol_competitive/services/panda.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeaguesPage extends StatefulWidget {
  const LeaguesPage({super.key});

  @override
  State<LeaguesPage> createState() => _LeaguesPageState();
}

class _LeaguesPageState extends State<LeaguesPage> {
  List<League> _leagues = [];
  List<String> _preferredLeagues = [];
  bool _error = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    await _loadPrefs();
    await _loadHomeData();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadHomeData() async {
    var result = await PandaService().getLeagues();

    if (result != null) {
      _leagues.addAll(result);
    }
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _preferredLeagues = prefs.getStringList('league_ids') ?? [];
    });
  }

  Future<void> _changeFavourite(int id) async {
    final prefs = await SharedPreferences.getInstance();
    if (_preferredLeagues.contains(id.toString())) {
      _preferredLeagues.remove(id.toString());
    } else {
      _preferredLeagues.add(id.toString());
    }
    // Solo fuori da setState
    await prefs.setStringList(
      'league_ids',
      _preferredLeagues.map((e) => e).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                leading: Builder(
                  builder: (BuildContext context) {
                    return IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LeaguesPage(),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              body: !_isLoading
                  ? ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _leagues.length,
                      itemBuilder: (context, index) {
                        final league = _leagues[index];
                        return FutureBuilder<SharedPreferences>(
                          future: SharedPreferences.getInstance(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const CircularProgressIndicator();
                            }

                            final prefs = snapshot.data!;
                            final isFavorite =
                                (prefs.getStringList('league_ids') ?? [])
                                    .contains(league.id.toString());

                            return Card(
                              margin: EdgeInsets.all(6),
                              elevation: 10,
                              child: ListTile(
                                leading: CachedNetworkImage(
                                  imageUrl: league.imageUrl ?? '',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.contain,
                                  placeholder: (_, __) => const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  errorWidget: (_, __, ___) =>
                                      const Icon(Icons.error),
                                ),
                                title: Text(league.name!),
                              ),
                            );
                          },
                        );
                      },
                    )
                  : const Center(child: CircularProgressIndicator()),
            );
          } else {
            return const Placeholder();
          }
        },
      );
    }

    // Caso in cui _error == true o _isLoading == true
    return const Center(child: CircularProgressIndicator());
  }
}
