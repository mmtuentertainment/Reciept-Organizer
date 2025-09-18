import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:receipt_organizer/infrastructure/config/supabase_config.dart';
import 'package:receipt_organizer/core/services/background_sync_service.dart';
import 'package:receipt_organizer/core/services/request_queue_service.dart';
import 'package:receipt_organizer/core/services/network_connectivity_service.dart';
import 'package:receipt_organizer/features/capture/screens/capture_screen.dart';
import 'package:receipt_organizer/features/capture/screens/batch_capture_screen.dart';
import 'package:receipt_organizer/features/receipts/presentation/providers/image_viewer_provider.dart';
import 'package:receipt_organizer/features/auth/screens/login_screen.dart';
import 'package:receipt_organizer/features/auth/providers/auth_provider.dart';
import 'package:receipt_organizer/features/auth/services/session_manager.dart';
import 'package:receipt_organizer/features/auth/services/offline_auth_service.dart';
import 'package:receipt_organizer/features/auth/services/inactivity_monitor.dart';
import 'package:receipt_organizer/features/receipts/screens/receipts_list_screen.dart';
import 'package:receipt_organizer/ui/theme/shadcn_theme_provider.dart';
import 'package:receipt_organizer/ui/components/shad/shad_components.dart';
import 'package:receipt_organizer/ui/responsive/responsive_builder.dart';

// Import database for initialization
import 'package:receipt_organizer/database/app_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up global error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Flutter Error: ${details.exception}');
    print('Stack trace: ${details.stack}');
  };

  // Platform identification for debugging
  if (kIsWeb) {
    print('📱 Running on Web - Using IndexedDB via Drift');
  } else if (defaultTargetPlatform == TargetPlatform.android ||
             defaultTargetPlatform == TargetPlatform.iOS) {
    print('📱 Running on Mobile - Using SQLite via Drift');
  } else {
    print('💻 Running on Desktop - Using SQLite via Drift');
  }

  // Initialize Drift database (works on ALL platforms)
  final database = AppDatabase();
  final stats = await database.getStats();
  print('📊 Database initialized: $stats');

  // Initialize core services early
  try {
    // Initialize network connectivity monitoring
    final connectivity = NetworkConnectivityService.instance;
    await connectivity.initialize();
    print('✅ Network connectivity service initialized');

    // Initialize request queue service
    final queueService = RequestQueueService.instance;
    await queueService.initialize();
    print('✅ Request queue service initialized');

    // Initialize background service
    await BackgroundSyncService.initialize();
    print('✅ Background service initialized');

    // Start periodic sync
    final backgroundService = BackgroundSyncService.instance;
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

    // Check for existing session
    final session = SupabaseConfig.client.auth.currentSession;
    if (session != null) {
      print('✅ Existing session found for: ${session.user.email}');
    }

    // Initialize session manager for auto-refresh
    SessionManager.initialize();

    // Migrate old storage format if needed
    await OfflineAuthService.migrateStorageIfNeeded();

    // Check offline mode availability
    final hasOfflineMode = await OfflineAuthService.isOfflineModeAvailable();
    if (hasOfflineMode) {
      print('✅ Offline authentication available');
    }
  } catch (e) {
    print('⚠️ Supabase initialization failed: $e');
    print('   Running in offline mode');

    // Check if we can use offline authentication
    final hasOfflineMode = await OfflineAuthService.isOfflineModeAvailable();
    if (hasOfflineMode) {
      print('✅ Offline authentication available from cache');
    }
  }

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: AppErrorBoundary(
        child: const ReceiptOrganizerApp(),
      ),
    ),
  );
}

class ReceiptOrganizerApp extends ConsumerWidget {
  const ReceiptOrganizerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final themeMode = ref.watch(themeModeProvider);

    // Use Material app with custom theming that matches shadcn
    return MaterialApp(
        title: 'Receipt Organizer',
        themeMode: themeMode,
        theme: AppTheme.getMaterialTheme(Brightness.light),
        darkTheme: AppTheme.getMaterialTheme(Brightness.dark),
        home: authState.when(
        data: (state) {
          if (state.session != null) {
            // Wrap home screen with inactivity monitoring
            return InactivityWrapper(
              timeout: const Duration(hours: 2),
              onTimeout: () async {
                // Sign out on inactivity
                await ref.read(authNotifierProvider.notifier).signOut();
              },
              child: const HomeScreen(),
            );
          } else {
            return const LoginScreen();
          }
        },
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, _) => const LoginScreen(),
      ),
      routes: {
        '/capture': (context) => const BatchCaptureScreen(),
        '/capture/batch': (context) => const BatchCaptureScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Organizer'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark
                ? Icons.light_mode
                : themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.auto_mode,
            ),
            onPressed: () {
              final currentMode = ref.read(themeModeProvider.notifier).state;
              ref.read(themeModeProvider.notifier).state =
                currentMode == ThemeMode.light
                  ? ThemeMode.dark
                  : currentMode == ThemeMode.dark
                    ? ThemeMode.system
                    : ThemeMode.light;
            },
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: ResponsiveContainer(
        padding: Responsive.padding(context),
        child: Center(
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
            if (user != null) ...[
              const SizedBox(height: 24),
              Text(
                'Logged in as: ${user.email}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
            const SizedBox(height: 48),
            AppButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CaptureScreen(),
                  ),
                );
              },
              size: ShadButtonSize.lg,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.camera_alt, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'Capture Receipt',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppOutlineButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ReceiptsListScreen(),
                  ),
                );
              },
              size: ShadButtonSize.lg,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.folder),
                  const SizedBox(width: 8),
                  const Text(
                    'View Receipts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}