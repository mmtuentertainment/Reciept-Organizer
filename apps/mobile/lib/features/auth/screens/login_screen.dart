import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../infrastructure/config/supabase_config.dart';
import '../../../ui/components/shad/shad_components.dart';
import '../../../ui/responsive/responsive_builder.dart';
import '../../../ui/theme/shadcn_theme_provider.dart';
import '../services/offline_auth_service.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import '../../../core/services/input_validation_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isOfflineMode = false;

  @override
  void initState() {
    super.initState();
    _checkOfflineMode();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkOfflineMode() async {
    final isOnline = await OfflineAuthService.isOnline();
    if (!isOnline && mounted) {
      final hasOfflineAuth = await OfflineAuthService.isOfflineModeAvailable();
      setState(() {
        _isOfflineMode = !isOnline && hasOfflineAuth;
      });
    }
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check network connectivity
      final isOnline = await OfflineAuthService.isOnline();

      if (isOnline) {
        // Online authentication
        final response = await SupabaseConfig.client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (response.user != null && response.session != null) {
          // Cache credentials for offline access
          await OfflineAuthService.cacheCredentials(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
          await OfflineAuthService.cacheSession(response.session!);

          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/');
          }
        }
      } else {
        // Offline authentication
        final isValid = await OfflineAuthService.verifyOfflineCredentials(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (isValid) {
          final session = await OfflineAuthService.getCachedSession();
          if (session != null && mounted) {
            // Show offline mode notification
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Signed in offline. Data will sync when online.'),
                backgroundColor: Colors.orange,
              ),
            );
            Navigator.of(context).pushReplacementNamed('/');
          } else {
            setState(() {
              _errorMessage = 'Offline session expired. Please connect to internet.';
            });
          }
        } else {
          setState(() {
            _errorMessage = 'Invalid offline credentials';
          });
        }
      }
    } on AuthException catch (e) {
      // Try offline auth if network error
      if (e.message.toLowerCase().contains('network') ||
          e.message.toLowerCase().contains('connection')) {
        // Recursively try offline auth
        _isOfflineMode = true;
        await _signIn();
        return;
      }
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await SupabaseConfig.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.receiptorganizer.app://login-callback/',
      );
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? ReceiptColors.backgroundDark : ReceiptColors.background,
      body: SafeArea(
        child: ResponsiveContainer(
          mobileMaxWidth: 400,
          tabletMaxWidth: 500,
          desktopMaxWidth: 600,
          padding: Responsive.padding(context),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: ReceiptColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    size: 50,
                    color: ReceiptColors.success,
                  ),
                ),
                const SizedBox(height: 32),
                ResponsiveText(
                  'Welcome Back',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? ReceiptColors.textPrimaryDark : ReceiptColors.textPrimary,
                  ),
                  mobileFontSize: 28,
                  tabletFontSize: 32,
                  desktopFontSize: 36,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _isOfflineMode
                      ? 'Sign in offline to access cached receipts'
                      : 'Sign in to your account',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? ReceiptColors.textSecondaryDark : ReceiptColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_isOfflineMode) ...[
                  const SizedBox(height: 16),
                  AppCard(
                    backgroundColor: ReceiptColors.warning.withOpacity(0.1),
                    padding: const EdgeInsets.all(12),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_off, color: ReceiptColors.warning, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Offline Mode',
                          style: TextStyle(color: ReceiptColors.warning),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 48),
                AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            final result = InputValidationService.validateEmail(value);
                            return result.isValid ? null : result.errorMessage;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  AppCard(
                    backgroundColor: ReceiptColors.error.withOpacity(0.1),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: ReceiptColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: ReceiptColors.error,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: AppTextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  onPressed: _signIn,
                  isLoading: _isLoading,
                  child: const Text(
                    'Sign In',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
                AppOutlineButton(
                  onPressed: _signInWithGoogle,
                  isLoading: _isLoading,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.g_mobiledata, size: 24),
                      SizedBox(width: 8),
                      Text('Sign in with Google', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: isDark ? ReceiptColors.textSecondaryDark : ReceiptColors.textSecondary,
                      ),
                    ),
                    AppTextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }
}