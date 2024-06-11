import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lnu_nav_app/types/point.dart';
import 'package:lnu_nav_app/variables.dart';

class StartLocation extends StatefulWidget {
  const StartLocation(
      {super.key, this.onPointChange, this.onFocus, this.onSearchTextChange});

  final Function(Point?)? onPointChange;
  final Function(String)? onSearchTextChange;
  final Function()? onFocus;

  @override
  State<StartLocation> createState() => _StartLocationState();
}

class _StartLocationState extends State<StartLocation> {
  Point __selectedPoint = Point.zero;
  final TextEditingController __inputController = TextEditingController();
  final FocusNode __focusNode = FocusNode();
  String __searchText = '';

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: TextField(
              controller: __inputController,
              focusNode: __focusNode,
              onTap: () {
                widget.onFocus?.call();
              },
              onChanged: (value) {
                setState(() {
                  __selectedPoint = Point.zero;
                  __searchText = value;
                });
              },
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color: __selectedPoint == Point.zero
                          ? Colors.transparent
                          : purpleColor.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color: __selectedPoint == Point.zero
                          ? Colors.white
                          : purpleColor),
                ),
                filled: true,
                fillColor: inputBackgroundColor,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: 'Поточна локація',
                // icon from assets
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SvgPicture.asset(
                    'assets/icons/MapPin.svg',
                    color: __selectedPoint == Point.zero
                        ? Colors.white
                        : purpleColor.withOpacity(0.8),
                    width: 25,
                    height: 25,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // button
          MaterialButton(
              onPressed: () {},
              color: inputBackgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.location_searching, color: Colors.white)),
        ],
      ),
    );
  }
}
