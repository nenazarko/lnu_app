import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lnu_nav_app/types/point.dart';
import 'package:lnu_nav_app/variables.dart';

class PointInputController extends ChangeNotifier {
  final Function? onChange;
  final Function(bool)? onFocusChange;

  Point? selectedPoint;
  bool focused = false;
  String text = '';

  final FocusNode focusController = FocusNode();
  final TextEditingController textEditingController = TextEditingController();
  Timer? debounce;

  selectPoint(Point point) {
    selectedPoint = point;
    notifyListeners();
  }

  reset() {
    textEditingController.clear();
    text = '';
    selectedPoint = null;
    notifyListeners();
  }

  PointInputController({
    this.onChange,
    this.onFocusChange,
  }) {
    focusController.addListener(() {
      if (focusController.hasFocus != focused) {
        focused = focusController.hasFocus;
        if (onFocusChange != null) onFocusChange!(focused);
        notifyListeners();
      }
    });

    textEditingController.addListener(() {
      if (debounce?.isActive ?? false) {
        debounce?.cancel();
      }

      if (selectedPoint != null) {
        selectedPoint = null;
        notifyListeners();
      }

      text = textEditingController.text.trim();
      debounce = Timer(const Duration(milliseconds: 500), () {
        onChange!(textEditingController.text);
        notifyListeners();
      });
    });
  }
}

class PointInput extends StatefulWidget {
  final PointInputController controller;
  final Widget Function(PointInputController) icon;
  final String hintText;

  const PointInput({
    Key? key,
    required this.controller,
    required this.icon,
    required this.hintText,
  }) : super(key: key);

  @override
  State<PointInput> createState() => _PointInputState();
}

class _PointInputState extends State<PointInput> {
  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return TextField(
      controller: controller.textEditingController,
      focusNode: controller.focusController,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: controller.selectedPoint == null
                  ? Colors.transparent
                  : purpleColor.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: controller.selectedPoint == null
                  ? Colors.white
                  : purpleColor),
        ),
        filled: true,
        fillColor: inputBackgroundColor,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        hintText: widget.hintText,
        // icon from assets
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 10),
          child: widget.icon(controller),
        ),
        suffixIcon: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            if (controller.selectedPoint == null) {
              return const SizedBox(width: 0);
            }

            return IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                  controller.reset();
              },
            );
          })
      ),
    );
  }
}

// SvgPicture.asset(
// 'assets/icons/MapPin.svg',
// color: _startPoint == Point.zero
// ? Colors.white
//     : purpleColor.withOpacity(0.8),
// width: 25,
// height: 25,
// )