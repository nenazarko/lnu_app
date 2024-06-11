import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lnu_nav_app/components/layouts/basic_layout/bottom_nav_bar.dart';
import 'package:lnu_nav_app/components/layouts/basic_layout/basic_layout.dart';
import 'package:lnu_nav_app/components/ui/future_loading.dart';
import 'package:lnu_nav_app/helpers/data_manager/a-star.dart';
import 'package:lnu_nav_app/helpers/data_manager/graph.dart';
import 'package:lnu_nav_app/helpers/json-reader.dart';
import 'package:lnu_nav_app/providers.dart';
import 'package:lnu_nav_app/store/permanent/config-storage.dart';
import 'package:lnu_nav_app/store/structure-data.dart';
import 'package:lnu_nav_app/types/pair.dart';
import 'package:lnu_nav_app/types/structures.dart';
import 'package:lnu_nav_app/ui/select.dart';
import 'package:lnu_nav_app/variables.dart';
import 'package:provider/provider.dart';

import 'components/layouts/basic_layout/top_nav.dart';

const configPaths = [
  'assets/CM.nodes.json',
];

class Preloading {
  static Structure? cache;
  static String? cachedBuildingId;

  Future<Structure> _start(String structureData) async {
    final structure = JsonReader.readStr(structureData, Structure.blank);

    cache = structure;
    cachedBuildingId = ConfigStorage().buildingId;

    // Validate graph points
    final graph = Graph(structure.points, structure.adjacencyList, structure.offsets);

    Stopwatch stopwatch = Stopwatch()..start();
    for (final point1 in graph.points.values) {
      if (point1.label == null) continue;
      for (final point2 in graph.points.values) {
          if (point2.label == null) continue;
        AStar(graph).findPath(point1, point1);
      }
    }
    stopwatch.stop();
    print('Build all paths in ${stopwatch.elapsedMilliseconds}ms');

    // await Future.delayed(const Duration(seconds: 2));
    return structure;
  }

  Future<Structure?> start() async {
    final buildingId = ConfigStorage().buildingId;
    final structurePath = ConfigStorage().structurePath;

    if (structurePath == null) {
      print('No Structure Path');
      return null;
    }

    if (cache != null && cachedBuildingId == buildingId) {
      return cache!;
    } else {
      cachedBuildingId = buildingId;
    }

    try {
      final structureStr = await rootBundle.loadString(structurePath);
      final result = await compute(_start, structureStr);
      print('preload completed!');
      return result;
    } catch (e, stacktrace) {
      print('Failed to preload data | $e \n$stacktrace');
      throw Exception('Failed to preload data | $e');
    }
  }

  List<Pair<String, CompactStructure>> _getCompactStructures(List<Pair<String, String>> readStructures) {
    return  readStructures.map((data) {
      try {
        return Pair(
            data.first,
            JsonReader.readStr(data.second, CompactStructure.blank)
        );
      } catch (e, stacktrace) {
        print('Failed to read structure | $e \n$stacktrace');
      }
    }).whereType<Pair<String, CompactStructure>>()
        .toList();
  }

  Future<List<Pair<String, CompactStructure>>> getCompactStructures() async {
    final readStructures = await Future.wait(configPaths.map((path) async {
      return Pair(path, await rootBundle.loadString(path));
    }));

    try {
      return await compute(_getCompactStructures, readStructures);
    } catch (e, stacktrace) {
      print('Failed to preload data | $e \n$stacktrace');
      throw Exception('Failed to preload data | $e');
    }
  }
}

class SetupPage extends StatelessWidget {
  const SetupPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureLoading(
        future: Preloading().getCompactStructures(),
        loadingText: 'Завантаження структур',
        builder: (context, structures) {
          return Consumer<ConfigStorage>(
            builder: (context, config, _) {
              final currentStructurePath = config.structurePath;
              final currentStructure = config.structurePath != null
                  ? structures.firstWhere((element) => element.first == currentStructurePath).second
                  : null;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Welcome to LnuNav'),
                    SizedBox(
                      width: 400,
                      child: SelectWidget(
                        // better ui. change styles
                        hintText: 'Виберіть Корпус',
                        value: config.structurePath,
                        onChanged: (value) => config.structurePath = value,
                        items: structures.map((pair) {
                          return DropdownMenuItem(
                            value: pair.first,
                            // two lines of text
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(pair.second.name),
                                Text(pair.second.location.toString(), style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)))
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    if (config.structurePath != null && currentStructure != null)
                      SizedBox(
                          width: 400,
                          child: SelectWidget(
                            hintText: 'Виберіть Будівлю',
                            value: config.buildingId,
                            onChanged: (value) => config.buildingId = value,
                            items: currentStructure.buildings.values.map((building) {
                              return DropdownMenuItem(
                                value: building.id,
                                // two lines of text
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(building.name),
                                    Text("Кількість поверхів: ${building.floors}", style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))),
                                  ],
                                ),
                              );
                            }).toList(),
                          )
                      )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ReadyPage extends StatefulWidget {
  const ReadyPage({super.key});

  @override
  State<ReadyPage> createState() => _ReadyPageState();
}

class _ReadyPageState extends State<ReadyPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Preloading().start().then((struct) {
          if (struct == null) return;

          final structData =  Provider.of<StructureData>(context, listen: false);
          structData.structure = struct;
        }),
        builder: (_, __) {
          return const BasicLayout();
        });
  }
}

const overlayStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent, // transparent status bar
  systemNavigationBarColor: Colors.black, // navigation bar color
  statusBarIconBrightness:
  Brightness.light, // status bar icons' color
  systemNavigationBarIconBrightness:
  Brightness.light, //navigation bar icons' color
);

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LnuNav',
      theme: ThemeData(
        scaffoldBackgroundColor: backgroundColor,
        fontFamily: GoogleFonts.montserrat().fontFamily,
        colorScheme: const ColorScheme.dark(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlayStyle,
          child: FutureLoading(
            loadingText: 'Завантаження конфігурації',
            future: ConfigStorage.initialize(),
            builder: (context, config) {
              return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Consumer<ConfigStorage>(
                      builder: (context, config, _) {
                        final child = config.structurePath == null || config.buildingId == null
                            ? const SetupPage()
                            : const ReadyPage();

                        return child;
                      })
              );
            },
          )
      ),
    );
  }
}

void main() {
  return runApp(
      const Providers(
        child: MyApp(),
      )
  );
}
