import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class NeumorphismContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool isPressed;
  final bool isInverted;
  final Color? backgroundColor;
  final double intensity;

  const NeumorphismContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 16.0,
    this.isPressed = false,
    this.isInverted = false,
    this.backgroundColor,
    this.intensity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ?? 
        (isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE0E5EC));
    
    // Calculate shadow colors based on background
    final lightShadow = isDark 
        ? bgColor.withOpacity(0.15)
        : Colors.white.withOpacity(0.7);
    final darkShadow = isDark
        ? Colors.black.withOpacity(0.5)
        : const Color(0xFFA3B1C6).withOpacity(0.3);

    // Adjust shadow offset and blur based on pressed state
    final shadowOffset = isPressed ? 2.0 * intensity : 6.0 * intensity;
    final shadowBlur = isPressed ? 4.0 * intensity : 12.0 * intensity;

    // Invert shadows if needed
    final topLeftShadow = isInverted ? darkShadow : lightShadow;
    final bottomRightShadow = isInverted ? lightShadow : darkShadow;

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isPressed
            ? [
                // Darker shadow when pressed to simulate inset
                BoxShadow(
                  color: darkShadow.withOpacity(0.4),
                  offset: Offset(shadowOffset * 0.5, shadowOffset * 0.5),
                  blurRadius: shadowBlur * 0.5,
                  spreadRadius: -2,
                ),
              ]
            : [
                // Raised effect when not pressed
                BoxShadow(
                  color: topLeftShadow,
                  offset: Offset(-shadowOffset, -shadowOffset),
                  blurRadius: shadowBlur,
                ),
                BoxShadow(
                  color: bottomRightShadow,
                  offset: Offset(shadowOffset, shadowOffset),
                  blurRadius: shadowBlur,
                ),
              ],
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: child,
      ),
    );
  }
}

class NeumorphismButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final double intensity;

  const NeumorphismButton({
    super.key,
    required this.child,
    this.onTap,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 16.0,
    this.backgroundColor,
    this.intensity = 1.0,
  });

  @override
  State<NeumorphismButton> createState() => _NeumorphismButtonState();
}

class _NeumorphismButtonState extends State<NeumorphismButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: NeumorphismContainer(
              width: widget.width,
              height: widget.height,
              padding: widget.padding,
              margin: widget.margin,
              borderRadius: widget.borderRadius,
              backgroundColor: widget.backgroundColor,
              intensity: widget.intensity,
              isPressed: _isPressed,
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}