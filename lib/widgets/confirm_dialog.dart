import 'package:flutter/material.dart';
import '../theme/gym_theme.dart';

/// Confirmation dialog for destructive actions.
///
/// Requires user to type a confirmation phrase (e.g., "DELETE") before
/// the confirm button becomes enabled.
class ConfirmDialog extends StatefulWidget {
  final String title;
  final String message;
  final String confirmPhrase;
  final String confirmButtonText;
  final VoidCallback onConfirm;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmPhrase,
    this.confirmButtonText = 'Confirm',
    required this.onConfirm,
  });

  /// Show the dialog and return true if confirmed.
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmPhrase,
    String confirmButtonText = 'Confirm',
    required VoidCallback onConfirm,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ConfirmDialog(
        title: title,
        message: message,
        confirmPhrase: confirmPhrase,
        confirmButtonText: confirmButtonText,
        onConfirm: onConfirm,
      ),
    );
    return result ?? false;
  }

  @override
  State<ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<ConfirmDialog> {
  final _controller = TextEditingController();
  bool _canConfirm = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_checkInput);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkInput() {
    final matches = _controller.text.trim().toUpperCase() ==
        widget.confirmPhrase.toUpperCase();
    if (matches != _canConfirm) {
      setState(() => _canConfirm = matches);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: GymTheme.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GymTheme.radius.md),
      ),
      title: Text(
        widget.title,
        style: TextStyle(
          color: GymTheme.colors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.message,
            style: TextStyle(color: GymTheme.colors.textSecondary),
          ),
          const SizedBox(height: 16),
          Text(
            'Type "${widget.confirmPhrase}" to confirm:',
            style: TextStyle(
              color: GymTheme.colors.textMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            autofocus: true,
            style: TextStyle(color: GymTheme.colors.textPrimary),
            decoration: InputDecoration(
              hintText: widget.confirmPhrase,
              hintStyle: TextStyle(color: GymTheme.colors.textMuted),
              filled: true,
              fillColor: GymTheme.colors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Cancel',
            style: TextStyle(color: GymTheme.colors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: _canConfirm
              ? () {
                  Navigator.pop(context, true);
                  widget.onConfirm();
                }
              : null,
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
            disabledForegroundColor: Colors.red.withAlpha(77),
          ),
          child: Text(widget.confirmButtonText),
        ),
      ],
    );
  }
}
