import 'package:flutter/material.dart';
import 'package:lnu_nav_app/helpers/ui.dart';
import 'package:lnu_nav_app/store/permanent/config-storage.dart';
import 'package:lnu_nav_app/store/structure-data.dart';
import 'package:provider/provider.dart';

class Providers extends StatelessWidget {
  final Widget child;

  const Providers({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<UiModel>(create: (_) => UiModel()),
      ChangeNotifierProvider<StructureData>(create: (_) => StructureData()),
      ChangeNotifierProvider<ConfigStorage>(create: (_) => ConfigStorage()),
    ], child: child);
  }
}
