import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:receipt_organizer/infrastructure/config/supabase_config.dart';
import 'package:receipt_organizer/core/services/background_sync_service.dart';
import 'package:receipt_organizer/core/services/request_queue_service.dart';
import 'package:receipt_organizer/core/services/network_connectivity_service.dart';
import 'package:receipt_organizer/features/capture/screens/capture_screen.dart';
import 'package:receipt_organizer/features/capture/screens/batch_capture_screen.dart';
import 'package:receipt_organizer/features/receipts/presentation/providers/image_viewer_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize core services early
  try {
    // Initialize network connectivity monitoring
    final connectivity = NetworkConnectivityService();
    await connectivity.initialize();
    print('✅ Network connectivity service initialized');

    // Initialize request queue service
    final queueService = RequestQueueService();
    await queueService.initialize();
    print('✅ Request queue service initialized');

    // Initialize background service
    await BackgroundSyncService.initialize();
    print('✅ Background service initialized');

    // Start periodic sync
    final backgroundService = BackgroundSyncService();
    await backgroundService.registerPeriodicSync();
    print('✅ Background periodic sync started');
  } catch (e) {
    print('⚠️ Service initialization failed: $e');
  }
  
  // Load environment variables (optional for local dev)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('ℹ️ .env file not found, using default configuration');
  }
  
  // Initialize Supabase using our config
  try {
    await SupabaseConfig.initialize();
    print('✅ Supabase initialized successfully');
    print('   URL: ${SupabaseConfig.supabaseUrl}');
  } catch (e) {
    print('⚠️ Supabase initialization failed: $e');
    print('   Running in offline mode');
  }
  
  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const ReceiptOrganizerApp(),
    ),
  );
}

class ReceiptOrganizerApp extends StatelessWidget {
  const ReceiptOrganizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Receipt Organizer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      routes: {
        '/capture': (context) => const BatchCaptureScreen(),
        '/capture/batch': (context) => const BatchCaptureScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Organizer'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt_long,
              size: 100,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            const Text(
              'Receipt Organizer MVP',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Capture, organize, and export receipts',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CaptureScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Capture Receipt'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.folder),
              label: const Text('View Receipts'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}