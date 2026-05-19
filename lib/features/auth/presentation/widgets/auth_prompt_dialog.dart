import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../auth/presentation/pages/login_page.dart';

class AuthPromptDialog extends StatelessWidget {
  const AuthPromptDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(localizations?.translate('login_required') ?? 'Login Required'),
      content: Text(localizations?.translate('guest_limit_reached') ??
          'You have reached the limit for guest use. Please log in or create an account to continue tracking prices.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(localizations?.translate('cancel') ?? 'Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
          },
          child: Text(localizations?.translate('login') ?? 'Login'),
        ),
      ],
    );
  }
}
