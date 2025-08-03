import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../config/router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_card_provider.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _startSplashAnimation();
  }

  void _startSplashAnimation() async {
    // Start animation immediately
    _animationController.forward();
    
    // Reduced total time for faster app startup
    await Future.delayed(const Duration(milliseconds: 2000));
    
    if (mounted) {
      _checkAuthAndNavigate();
    }
  }

  void _checkAuthAndNavigate() {
    final authState = ref.read(authStateProvider);
    
    if (authState.isAuthenticated) {
      // Trigger Firebase sync for already authenticated users
      ref.read(profileCardProvider.notifier).syncFromFirebase();
      Navigator.of(context).pushReplacement(_createSmoothTransition(const HomeScreen()));
    } else if (authState.isUnauthenticated) {
      Navigator.of(context).pushReplacement(_createSmoothTransition(const LoginScreen()));
    } else {
      // Still loading, wait a bit more
      Timer(const Duration(milliseconds: 500), () {
        if (mounted) {
          _checkAuthAndNavigate();
        }
      });
    }
  }

  // Create smooth transition animation to target screen
  PageRouteBuilder _createSmoothTransition(Widget targetScreen) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
      transitionDuration: const Duration(milliseconds: 800),
      reverseTransitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Combine fade and slide animations
        const begin = Offset(0.0, 0.3);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var slideAnimation = Tween(
          begin: begin,
          end: end,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: curve,
        ));

        var fadeAnimation = Tween(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
        ));

        var scaleAnimation = Tween(
          begin: 0.95,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: curve,
        ));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: child,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: Image.asset(
                  'assets/images/splash_screen.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback if image fails to load
                    return Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primary.withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.credit_card,
                              size: 120,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'CardWave',
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}