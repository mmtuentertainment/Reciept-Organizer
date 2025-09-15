import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../infrastructure/config/supabase_config.dart';
import '../providers/auth_provider.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String email;

  const VerifyEmailScreen({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _isResending = false;
  String? _message;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
  }

  Future<void> _checkEmailVerification() async {
    // Listen for auth state changes
    SupabaseConfig.client.auth.onAuthStateChange.listen((data) {
      if (data.session?.user.emailConfirmedAt != null) {
        // Email verified, navigate to home
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    });
  }

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isResending = true;
      _message = null;
      _isSuccess = false;
    });

    try {
      await SupabaseConfig.client.auth.resend(
        type: OtpType.signup,
        email: widget.email,
      );

      setState(() {
        _isSuccess = true;
        _message = 'Verification email has been resent. Please check your inbox.';
      });
    } on AuthException catch (e) {
      setState(() {
        _isSuccess = false;
        _message = e.message;
      });
    } catch (e) {
      setState(() {
        _isSuccess = false;
        _message = 'Failed to resend verification email. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    await ref.read(authNotifierProvider.notifier).signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.mark_email_unread,
                  size: 100,
                  color: Colors.orange,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Verify Your Email',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'We\'ve sent a verification email to:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.email,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Please check your inbox and click the verification link to activate your account.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_message != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isSuccess ? Colors.green.shade50 : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isSuccess ? Colors.green.shade200 : Colors.orange.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isSuccess ? Icons.check_circle : Icons.info,
                          color: _isSuccess ? Colors.green.shade800 : Colors.orange.shade800,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _message!,
                            style: TextStyle(
                              color: _isSuccess ? Colors.green.shade800 : Colors.orange.shade800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _isResending ? null : _resendVerificationEmail,
                  icon: _isResending
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.email),
                  label: Text(_isResending ? 'Sending...' : 'Resend Verification Email'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () async {
                    // Refresh and check status
                    final user = SupabaseConfig.client.auth.currentUser;
                    if (user?.emailConfirmedAt != null) {
                      Navigator.of(context).pushReplacementNamed('/home');
                    } else {
                      setState(() {
                        _message = 'Email not verified yet. Please check your inbox.';
                        _isSuccess = false;
                      });
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('I\'ve Verified My Email'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _signOut,
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}