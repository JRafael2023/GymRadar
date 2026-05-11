import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

export 'package:go_router/go_router.dart';

// Tipos de parámetro para serialización
enum ParamType {
  String,
  int,
  double,
  bool,
  DateTime,
  LatLng,
  Color,
  FFPlace,
  FFUploadedFile,
  JSON,
}

dynamic serializeParam(
  dynamic value,
  ParamType paramType, {
  bool isList = false,
}) {
  try {
    if (value == null) return null;
    switch (paramType) {
      case ParamType.String:
        return value;
      case ParamType.int:
        return value;
      case ParamType.double:
        return value;
      case ParamType.bool:
        return value;
      case ParamType.DateTime:
        return (value as DateTime).millisecondsSinceEpoch;
      default:
        return value;
    }
  } catch (_) {
    return null;
  }
}

dynamic deserializeParam<T>(
  dynamic value,
  ParamType paramType,
  bool isList,
) {
  try {
    switch (paramType) {
      case ParamType.String:
        return value as String;
      case ParamType.int:
        return value is int ? value : int.tryParse(value.toString());
      case ParamType.double:
        return value is double ? value : double.tryParse(value.toString());
      case ParamType.bool:
        return value is bool ? value : value.toString().toLowerCase() == 'true';
      case ParamType.DateTime:
        return value is int
            ? DateTime.fromMillisecondsSinceEpoch(value)
            : DateTime.tryParse(value.toString());
      default:
        return value;
    }
  } catch (_) {
    return null;
  }
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;
}

enum PageTransitionType {
  fade,
  rightToLeft,
  leftToRight,
  topToBottom,
  bottomToTop,
  scale,
  rotate,
  size,
  rightToLeftWithFade,
  leftToRightWithFade,
}
