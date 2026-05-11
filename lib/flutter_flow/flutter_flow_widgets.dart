import 'package:flutter/material.dart';

class FFButtonOptions {
  const FFButtonOptions({
    this.width,
    this.height,
    this.padding,
    this.iconPadding,
    this.color,
    this.textStyle,
    this.elevation,
    this.borderSide,
    this.borderRadius,
    this.disabledColor,
    this.disabledTextColor,
    this.hoverColor,
    this.splashColor,
  });

  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? iconPadding;
  final Color? color;
  final TextStyle? textStyle;
  final double? elevation;
  final BorderSide? borderSide;
  final BorderRadius? borderRadius;
  final Color? disabledColor;
  final Color? disabledTextColor;
  final Color? hoverColor;
  final Color? splashColor;
}

class FFButtonWidget extends StatefulWidget {
  const FFButtonWidget({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.iconData,
    required this.options,
    this.showLoadingIndicator = true,
  });

  final String text;
  final Future Function()? onPressed;
  final Widget? icon;
  final IconData? iconData;
  final FFButtonOptions options;
  final bool showLoadingIndicator;

  @override
  State<FFButtonWidget> createState() => _FFButtonWidgetState();
}

class _FFButtonWidgetState extends State<FFButtonWidget> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    Widget textWidget = loading
        ? SizedBox(
            width: 23,
            height: 23,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.options.textStyle?.color ?? Colors.white,
              ),
              strokeWidth: 2.5,
            ),
          )
        : Text(widget.text, style: widget.options.textStyle);

    final onPressed = widget.onPressed == null
        ? null
        : () async {
            if (loading) return;
            if (widget.showLoadingIndicator) {
              setState(() => loading = true);
            }
            try {
              await widget.onPressed!();
            } finally {
              if (mounted && widget.showLoadingIndicator) {
                setState(() => loading = false);
              }
            }
          };

    ButtonStyle style = ElevatedButton.styleFrom(
      backgroundColor: widget.options.color,
      foregroundColor: widget.options.textStyle?.color,
      disabledBackgroundColor: widget.options.disabledColor,
      disabledForegroundColor: widget.options.disabledTextColor,
      elevation: widget.options.elevation,
      padding: widget.options.padding,
      shape: RoundedRectangleBorder(
        borderRadius:
            widget.options.borderRadius ?? BorderRadius.circular(8.0),
        side: widget.options.borderSide ?? BorderSide.none,
      ),
      minimumSize: Size(
        widget.options.width ?? double.infinity,
        widget.options.height ?? 50.0,
      ),
    );

    if (widget.icon != null || widget.iconData != null) {
      final icon = widget.icon ??
          Icon(widget.iconData, color: widget.options.textStyle?.color);
      return SizedBox(
        width: widget.options.width,
        height: widget.options.height,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: icon,
          label: textWidget,
          style: style,
        ),
      );
    }

    return SizedBox(
      width: widget.options.width,
      height: widget.options.height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: style,
        child: textWidget,
      ),
    );
  }
}
