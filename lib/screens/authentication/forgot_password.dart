import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constants/colors.dart';
import '../../utils/providers/password_reset_provider.dart';

/// Universal forgot-password flow: email → reset code → new password.
class ForgotPasswordScreen extends StatefulWidget {
  static const routeName = '/forgot-password';
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _provider = PasswordResetProvider();
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  int _step = 0; // 0 email, 1 otp, 2 new password
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  String get _email => _emailCtrl.text.trim();

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? Colors.red : Colors.green,
    ));
  }

  Future<void> _run(Future<({bool ok, String message})> Function() action,
      {required VoidCallback onOk}) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final res = await action();
    if (!mounted) return;
    setState(() => _busy = false);
    if (res.ok) {
      _snack(res.message);
      onOk();
    } else {
      setState(() => _error = res.message);
    }
  }

  void _sendCode() {
    if (!_email.contains('@')) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    _run(() => _provider.requestOtp(_email),
        onOk: () => setState(() => _step = 1));
  }

  void _verify() {
    if (_otpCtrl.text.trim().length < 4) {
      setState(() => _error = 'Enter the 4-digit code sent to your email.');
      return;
    }
    _run(() => _provider.verifyOtp(_email, _otpCtrl.text.trim()),
        onOk: () => setState(() => _step = 2));
  }

  void _reset() {
    if (_passCtrl.text.length < 5) {
      setState(() => _error = 'Password must be at least 5 characters.');
      return;
    }
    if (_passCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    _run(
        () => _provider.setNewPassword(
            _email, _passCtrl.text, _confirmCtrl.text),
        onOk: () {
      // Back to login.
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: royalBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Reset Password',
            style: GoogleFonts.hind(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_title,
                  style: GoogleFonts.hind(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: royalBlue)),
              const SizedBox(height: 6),
              Text(_subtitle,
                  style: GoogleFonts.hind(
                      fontSize: 14, color: Colors.grey.shade600)),
              const SizedBox(height: 24),
              if (_step == 0) _field(_emailCtrl, 'Email address',
                  keyboardType: TextInputType.emailAddress),
              if (_step == 1) ...[
                _field(_otpCtrl, '4-digit code',
                    keyboardType: TextInputType.number, maxLength: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _busy
                        ? null
                        : () => _run(() => _provider.requestOtp(_email),
                            onOk: () {}),
                    child: Text('Resend code',
                        style: GoogleFonts.hind(color: royalBlue)),
                  ),
                ),
              ],
              if (_step == 2) ...[
                _field(_passCtrl, 'New password', obscure: true),
                const SizedBox(height: 12),
                _field(_confirmCtrl, 'Confirm new password', obscure: true),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!,
                    style: GoogleFonts.hind(
                        color: Colors.red.shade700, fontSize: 13)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _busy ? null : _primaryAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: royalBlue,
                    disabledBackgroundColor: royalBlue.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _busy
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : Text(_primaryLabel,
                          style: GoogleFonts.hind(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _title => switch (_step) {
        0 => 'Forgot your password?',
        1 => 'Enter reset code',
        _ => 'Set a new password',
      };

  String get _subtitle => switch (_step) {
        0 => 'Enter your account email and we\'ll send you a reset code.',
        1 => 'We sent a 4-digit code to $_email.',
        _ => 'Choose a new password for $_email.',
      };

  String get _primaryLabel => switch (_step) {
        0 => 'Send reset code',
        1 => 'Verify code',
        _ => 'Reset password',
      };

  void _primaryAction() {
    switch (_step) {
      case 0:
        _sendCode();
      case 1:
        _verify();
      default:
        _reset();
    }
  }

  Widget _field(TextEditingController c, String label,
      {TextInputType? keyboardType, bool obscure = false, int? maxLength}) {
    return TextField(
      controller: c,
      enabled: !_busy,
      keyboardType: keyboardType,
      obscureText: obscure,
      maxLength: maxLength,
      style: GoogleFonts.hind(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: royalBlue),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}
