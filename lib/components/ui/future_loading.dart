import 'package:flutter/material.dart';

class FutureLoading<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;
  final String? loadingText;

  const FutureLoading({
    Key? key,
    required this.future,
    required this.builder,
    this.loadingText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          return builder(context, snapshot.data as T);
        } else {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  if (loadingText != null) const SizedBox(height: 20),
                  if (loadingText != null) Text(loadingText!),
                ],
              ),
            ),
          );
        }
      },
    );
  }

}