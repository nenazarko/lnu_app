import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lnu_nav_app/variables.dart';

class TopNav extends StatelessWidget implements PreferredSizeWidget {
  final double size;
  const TopNav({Key? key, this.size = 100.0}) : super(key: key);

  @override
  PreferredSizeWidget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(size),
      child: Container(
        // safe area top padding
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Container(
          color: backgroundColor.withOpacity(0.3),
          // if android
          padding: (Theme.of(context).platform == TargetPlatform.android)
              ? EdgeInsets.only(top: MediaQuery.of(context).padding.top)
              : null,
          child: Container(
            color: Colors.white.withOpacity(0.04),
            padding: (Theme.of(context).platform == TargetPlatform.iOS)
                ? EdgeInsets.only(top: MediaQuery.of(context).padding.top)
                : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 64,
                  child: SvgPicture.asset('assets/logo.svg'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size(double.infinity, size);
}
