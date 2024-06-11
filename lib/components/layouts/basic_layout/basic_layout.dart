import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lnu_nav_app/components/layouts/basic_layout/bottom_nav_bar.dart';
import 'package:lnu_nav_app/components/layouts/basic_layout/route.dart';
import 'package:lnu_nav_app/components/layouts/basic_layout/top_nav.dart';
import 'package:lnu_nav_app/components/map/controllers/map.dart';
import 'package:lnu_nav_app/components/map/layers/points.dart';
import 'package:lnu_nav_app/components/map/layers/walls.dart';
import 'package:lnu_nav_app/components/map/map.dart';
import 'package:lnu_nav_app/components/point_info/base.dart';
import 'package:lnu_nav_app/store/permanent/config-storage.dart';
import 'package:lnu_nav_app/store/structure-data.dart';
import 'package:lnu_nav_app/variables.dart';
import 'package:provider/provider.dart';
import 'package:lnu_nav_app/store/map-data.dart';
import 'package:url_launcher/url_launcher.dart';

class BasicLayout extends StatefulWidget {
  const BasicLayout({
    Key? key,
  }) : super(key: key);

  @override
  State<BasicLayout> createState() => _BasicLayoutState();
}

class _BasicLayoutState extends State<BasicLayout> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3, animationDuration: const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      backgroundColor: backgroundColor,
      bottomNavigationBar: BottomNavBar(tabController: _tabController),
      body: SafeArea(
        top: false,
        child: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: [
            Scaffold(
              restorationId: 'basic-map',
              appBar: const TopNav(),
              body: SizedBox.expand(
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Positioned(
                      top: -120,
                      right: -100,
                      child: Container(
                          clipBehavior: Clip.none,
                          width: 200,
                          height: 200,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(143, 147, 221, 0.25),
                                blurRadius: 100,
                                spreadRadius: 100,
                              )
                            ],
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                            child: Container(),
                          )),
                    ),

                    Consumer<StructureData>(
                        builder: (context, structData, _) {
                          if (structData.primaryController == null) {
                            return Container();
                          }
                          return MapWidget(
                            controller: structData.primaryController!,
                            layers: [
                              WallsLayer(),
                              PointsLayer(onPointTap: (point) => PointInfoSheet.generate(context, point))
                            ],
                          );
                        }
                    ),

                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: Consumer<StructureData>(
                        builder: (context, structData, _) {
                          if (structData.primaryController == null) {
                            return Container();
                          }
                          
                          return ListenableBuilder(
                            listenable: structData.primaryController!,
                            builder: (context, _) {
                              return RepaintBoundary(
                                child: FloatingActionButton(
                                  heroTag: 'basic-floor',
                                  backgroundColor: purpleColor,
                                  child: Text(
                                    structData.primaryController!.currentFloor.z.toInt().toString(),
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                  onPressed: () {
                                    // show select dialog
                                    showModalBottomSheet(
                                        context: context,
                                        backgroundColor: backgroundColor,
                                        clipBehavior: Clip.antiAlias,
                                        builder: (context) {
                                          final controller = Provider.of<StructureData>(context, listen: false).primaryController;
                                          if (controller == null) {
                                            return const Center(
                                              child: CircularProgressIndicator(),
                                            );
                                          }

                                          return ListenableBuilder(
                                              listenable: controller,
                                              builder: (context, _) {
                                                return Container(
                                                  // save area
                                                  padding: EdgeInsets.only(
                                                      bottom: MediaQuery.of(context).padding.bottom
                                                  ),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: controller.currentBuilding.floors.values.map((floor) {
                                                      return ListTile(
                                                        tileColor:
                                                        controller.currentFloor.id == floor.id
                                                            ? purpleColor.withOpacity(0.2)
                                                            : null,
                                                        onTap: () {
                                                          if (controller.currentFloor != floor) {
                                                            controller.updateCurrentFloor(floorId: floor.id);
                                                            controller.commit();
                                                          }
                                                          Navigator.pop(context);
                                                        },
                                                        leading: Container(
                                                          alignment: Alignment.centerRight,
                                                          width: 34,
                                                          child: Text(
                                                            floor.z.toInt().toString(),
                                                            style: const TextStyle(
                                                                fontSize: 20,
                                                                fontWeight: FontWeight.w600,
                                                                color: purpleColor),
                                                          ),
                                                        ),
                                                        title: Row(
                                                          children: [
                                                            const Text('Поверх'),
                                                            const SizedBox(width: 10),
                                                            Text(
                                                              floor.subtitle != null
                                                                  ? "(${floor.subtitle})"
                                                                  : '',
                                                              style: const TextStyle(
                                                                color: Colors.grey,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                );
                                              }
                                          );
                                        });
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const RouteForm(),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  centerTitle: true,
                  title: const Text('LnuNav'),
                ),
                Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: <Widget>[
                        // list tile change structure
                        Card(
                          clipBehavior: Clip.antiAlias,
                          color: purpleColor.withOpacity(0.1),
                          child: ListTile(
                            leading: Icon(Icons.location_city),
                            title: const Text('Змінити корпус'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              final config = Provider.of<ConfigStorage>(context, listen: false);
                              config.reset();
                            },
                          ),
                        ),

                        // section heading
                        const Padding(
                          padding: EdgeInsets.only(top: 20, bottom: 10),
                          child: Text('Зв\'язок', style: TextStyle(color: Colors.grey)),
                        ),
                        Card(
                          clipBehavior: Clip.antiAlias,
                          color: purpleColor.withOpacity(0.1),
                          child: ListTile(
                            // contact developer
                            leading: const Icon(Icons.telegram),
                            title: const Text('@naziks'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              launchUrl(Uri.parse('https://t.me/naziks'), mode: LaunchMode.externalApplication);
                            },
                          ),
                        ),
                      ],
                    )
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
