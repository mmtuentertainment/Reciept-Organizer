import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:receipt_organizer/features/capture/screens/capture_screen.dart';
import 'package:receipt_organizer/features/capture/screens/batch_capture_screen.dart';
import 'package:receipt_organizer/features/receipts/presentation/providers/image_viewer_provider.dart';
import 'package:receipt_organizer/features/receipts/providers/realtime_sync_provider.dart';
import 'package:receipt_organizer/features/receipts/providers/presence_provider.dart';
import 'package:receipt_organizer/features/receipts/widgets/sync_status_widget.dart';
import 'package:receipt_organizer/features/auth/providers/auth_provider.dart';
import 'package:receipt_organizer/features/auth/screens/login_screen.dart';
import 'package:receipt_organizer/features/auth/widgets/auth_guard.dart';
import 'package:receipt_organizer/core/services/background_sync_service.dart';
import 'package:receipt_organizer/core/services/network_connectivity_service.dart';
import 'package:receipt_organizer/core/services/request_queue_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  try {
    // Load environment variables (optional - can also use const values)
    await dotenv.load(fileName: '.env.local');
    
    // Initialize Supabase with credentials from environment
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
    
    if (supabaseUrl == null || supabaseAnonKey == null) {
      print('⚠️ Supabase credentials not found in .env.local file');
      print('   Please create .env.local file from .env.example');
      // Continue without Supabase for local-only mode
    } else {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
          autoRefreshToken: true,
        ),
      );
      print('✅ Supabase initialized successfully');
    }
  } catch (e) {
    print('⚠️ Failed to initialize Supabase: $e');
    // Continue without Supabase for local-only mode
  }
  
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

class ReceiptOrganizerApp extends ConsumerWidget {
  const ReceiptOrganizerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    return MaterialApp(
      title: 'Receipt Organizer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: authState.isLoading 
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : authState.isAuthenticated 
          ? const HomeScreen() 
          : const LoginScreen(),
      routes: {
        '/home': (context) => const AuthGuard(
          allowOffline: true,
          child: HomeScreen(),
        ),
        '/login': (context) => const LoginScreen(),
        '/capture': (context) => const AuthGuard(
          allowOffline: true,
          child: BatchCaptureScreen(),
        ),
        '/capture/batch': (context) => const AuthGuard(
          allowOffline: true,
          child: BatchCaptureScreen(),
        ),
      },
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Auto-initialize real-time sync and presence
    ref.watch(realtimeSyncInitializerProvider);
    ref.watch(presenceInitializerProvider);
    
    final authState = ref.watch(authProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Organizer'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          const SyncStatusIndicator(),
          if (authState.isAuthenticated) 
            PopupMenuButton<String>(
              icon: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  authState.user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
              onSelected: (value) async {
                if (value == 'signout') {
                  await ref.read(authProvider.notifier).signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'profile',
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(authState.user?.email ?? 'User'),
                    subtitle: const Text('View profile'),
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'signout',
                  child: ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Sign Out'),
                  ),
                ),
              ],
            ),
        ],
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