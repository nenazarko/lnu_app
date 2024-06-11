import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:lnu_nav_app/components/ui/circle_nav_bar.dart';
import 'package:lnu_nav_app/helpers/ui.dart';
import 'package:lnu_nav_app/store/permanent/config-storage.dart';
import 'package:lnu_nav_app/variables.dart';
import 'package:provider/provider.dart';
import 'route.dart';

class BottomNavBar extends StatefulWidget {
  final TabController? tabController;
  const BottomNavBar({Key? key, required this.tabController}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int activeIndex = 0;

  void _tabChange() {
    final index = widget.tabController?.index ?? 0;
    if (index == activeIndex) return;
    setState(() => activeIndex = index);
  }

  @override
  void initState() {
    super.initState();
    widget.tabController?.addListener(_tabChange);
  }

  double safePaddingTop(MediaQueryData mqd) => mqd.padding.top + kToolbarHeight;
  double safeHeightTop(MediaQueryData mqd) =>
      mqd.size.height - safePaddingTop(mqd) - mqd.padding.bottom;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CustomCircleNavBar(
          activeIcons: const [
            Icon(Icons.location_pin, color: Colors.white),
            // path or route icon
            Icon(Icons.route, color: Colors.white),
            Icon(Icons.menu, color: Colors.white),
          ],
          inactiveIcons: const [
            Icon(Icons.location_pin, color: Colors.grey),
            Icon(Icons.route, color: Colors.grey),
            Icon(Icons.menu, color: Colors.grey),
          ],
          color: Colors.white,
          circleColor: Colors.white,
          height: 60,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          bottomOffset: MediaQuery.of(context).padding.bottom,
          circleWidth: 60,
          activeIndex: activeIndex,
          onTap: (index) {
            if (index == activeIndex) return;
            widget.tabController?.animateTo(index);
          },
          shadowColor: purpleColor,
          circleShadowColor: Colors.white.withOpacity(.2),
          elevation: 10,
          gradient: const LinearGradient(
            colors: [backgroundColorDark, backgroundColor],
          ),
          circleGradient: const LinearGradient(
            colors: [purpleColor, purpleColor],
          ),
        ),
        Positioned(
            top: MediaQuery.of(context).padding.top - 20,
            left: 0,
            right: 0,
            height: kToolbarHeight +
                MediaQuery.of(context).padding.top +
                30,
            child: Consumer<UiModel>(
                builder: (context, uiModel, child) {
                  return IgnorePointer(
                    ignoring: !uiModel.fullScreenSearch,
                    child: AnimatedOpacity(
                      opacity: uiModel.fullScreenSearch ? 1 : 0,
                      alwaysIncludeSemantics: true,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                      child: Container(
                        alignment: Alignment.bottomCenter,
                        decoration: const BoxDecoration(
                          color: purpleColor,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppBar(
                              primary: false,
                              automaticallyImplyLeading: false,
                              elevation: 0,
                              title: const Text(
                                'Маршрути',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              centerTitle: true,
                              leading: IconButton(
                                onPressed: () {
                                  uiModel.setFullScreenSearch(false);
                                  FocusScope.of(context).unfocus();
                                },
                                icon: const Icon(Icons.arrow_back,
                                    color: Colors.white),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                })),
      ],
    );
  }
}
