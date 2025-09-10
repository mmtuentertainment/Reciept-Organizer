import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:receipt_organizer/features/capture/screens/capture_screen.dart';
import 'package:receipt_organizer/features/capture/screens/batch_capture_screen.dart';
import 'package:receipt_organizer/features/receipts/presentation/providers/image_viewer_provider.dart';
import 'package:receipt_organizer/core/services/background_sync_service.dart';
import 'package:receipt_organizer/core/services/network_connectivity_service.dart';
import 'package:receipt_organizer/core/services/request_queue_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // EXPERIMENT: Phase 4 - Initialize background sync
  await BackgroundSyncService.initialize();
  
  // Initialize core services
  final connectivityService = NetworkConnectivityService();
  await connectivityService.initialize();
  
  final queueService = RequestQueueService();
  await queueService.initialize();
  
  // Register background sync if available
  final backgroundSync = BackgroundSyncService();
  if (backgroundSync.isBackgroundSyncAvailable()) {
    await backgroundSync.registerPeriodicSync();
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