import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'models/property.dart';
import 'pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Object? startupError;
  try {
    if (!SupabaseConfig.isConfigured) {
      throw StateError('Supabase client configuration is missing or unsafe.');
    }
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
    );
  } catch (error) {
    startupError = error;
  }

  runApp(GiftedPropertyApp(startupError: startupError));
}

class GiftedPropertyApp extends StatelessWidget {
  final Object? startupError;
  final Future<List<Property>> Function()? featuredPropertyLoader;
  final Future<List<Property>> Function()? propertyLoader;

  const GiftedPropertyApp({
    super.key,
    this.startupError,
    this.featuredPropertyLoader,
    this.propertyLoader,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gifted Property',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B1F33)),
      ),
      home: startupError == null
          ? HomePage(
              featuredPropertyLoader: featuredPropertyLoader,
              propertyLoader: propertyLoader,
            )
          : const _StartupErrorPage(),
    );
  }
}

class _StartupErrorPage extends StatelessWidget {
  const _StartupErrorPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_outlined, size: 48),
              SizedBox(height: 16),
              Text(
                'Gifted Property could not start because its listing service is '
                'unavailable or not configured for this app build. Please check '
                'the app configuration and try again.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
