import 'package:flutter/material.dart';
import 'package:lnu_nav_app/store/structure-data.dart';
import 'package:lnu_nav_app/types/structures.dart';
import 'package:lnu_nav_app/variables.dart';
import 'package:provider/provider.dart';

class TopNav extends StatelessWidget implements PreferredSizeWidget {
  const TopNav({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        centerTitle: true,
        title: Consumer<StructureData>(
        builder: (context, structData, _) {
          final controller = structData.primaryController;
          if (controller == null) return const SizedBox();

          return ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                return DropdownButton<Building>(
                  alignment: Alignment.center,
                  underline: Container(),
                  icon: const Icon(Icons.expand_more, color: purpleColor),
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                  items: [
                    for (final building in structData.structure.buildings.values)
                      DropdownMenuItem<Building>(
                        value: building,
                        child: Text(building.name),
                      )
                  ],
                  value: controller.currentBuilding,
                  onChanged: (Building? value) {
                    if (value == null) return;
                    controller.updateCurrentBuilding(building: value);
                    final floor = value.floors[value.defaultFloorId];
                    if (floor != null) {
                      controller.updateCurrentFloor(floor: floor);
                    }
                    controller.commit();
                  },
                );
              }
          );
        }),
        backgroundColor: Colors.black.withOpacity(0.8),
    );
  }

  @override
  Size get preferredSize => const Size(double.infinity, 56);
}
