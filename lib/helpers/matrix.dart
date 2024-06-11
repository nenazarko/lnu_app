import 'dart:math' as math;
import 'package:flutter/material.dart';

double getMinScaleOnAxis(Matrix4 matrix) {
  final m = matrix.storage;

  final scaleXSq = m[0] * m[0] + m[1] * m[1] + m[2] * m[2];
  final scaleYSq = m[4] * m[4] + m[5] * m[5] + m[6] * m[6];
  final scaleZSq = m[8] * m[8] + m[9] * m[9] + m[10] * m[10];
  return math.sqrt(math.min(scaleXSq, math.min(scaleYSq, scaleZSq)));
}
