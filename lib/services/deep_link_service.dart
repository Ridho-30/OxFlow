// lib/services/deep_link_service.dart

import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import '../screens/auth/reset_password_screen.dart';

class DeepLinkService {
  DeepLinkService._privateConstructor();
  static final DeepLinkService instance = DeepLinkService._privateConstructor();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  // Global navigator key to navigate from anywhere
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void init() {
    // Check initial link if app was in cold state (terminated)
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    });

    // Listen to incoming links when app is in background or foreground
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        _handleDeepLink(uri);
      },
      onError: (err) {
        debugPrint('Deep Link Error: $err');
      },
    );
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('Received Deep Link: $uri');
    
    // Check if the link is for reset password
    if (uri.path == '/reset-password') {
      final token = uri.queryParameters['token'];
      if (token != null && token.isNotEmpty) {
        // Navigate to ResetPasswordScreen with token
        final context = navigatorKey.currentContext;
        if (context != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ResetPasswordScreen(token: token),
            ),
          );
        } else {
          // If context is null, we might need to wait for the app to build
          // So we wait a bit and try again
          Future.delayed(const Duration(milliseconds: 500), () {
            final delayedContext = navigatorKey.currentContext;
            if (delayedContext != null) {
              Navigator.push(
                delayedContext,
                MaterialPageRoute(
                  builder: (_) => ResetPasswordScreen(token: token),
                ),
              );
            }
          });
        }
      } else {
        debugPrint('Token is missing in the deep link');
      }
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
