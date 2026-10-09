import 'package:flutter/material.dart';
import 'package:wedding/core/failure_message.dart';
import 'package:wedding/features/wedding/data/comment_access_code.dart';
import 'package:wedding/features/wedding/data/wedding_comment_repository.dart';
import 'package:wedding/l10n/generated/app_localizations.dart';

Future<String?> showAccessCodeDialog(
  BuildContext context, {
  required String title,
  required Future<CommentResult> Function(String code) onVerify,
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _AccessCodeDialog(title: title, onVerify: onVerify),
  );
}

class _AccessCodeDialog extends StatefulWidget {
  const _AccessCodeDialog({required this.title, required this.onVerify});

  final String title;
  final Future<CommentResult> Function(String code) onVerify;

  @override
  State<_AccessCodeDialog> createState() => _AccessCodeDialogState();
}

class _AccessCodeDialogState extends State<_AccessCodeDialog> {
  final _controller = TextEditingController();
  bool _isVerifying = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final code = CommentAccessCode.normalize(_controller.text);
    final issue = CommentAccessCode.validate(code);
    if (issue == AccessCodeIssue.empty) {
      setState(() => _error = l10n.accessCodeRequired);
      return;
    }
    if (issue == AccessCodeIssue.tooShort) {
      setState(() => _error = l10n.accessCodeTooShort);
      return;
    }
    setState(() {
      _isVerifying = true;
      _error = null;
    });
    final result = await widget.onVerify(code);
    if (!mounted) return;
    if (result.isSuccess) {
      Navigator.of(context).pop(code);
      return;
    }
    setState(() {
      _isVerifying = false;
      _error = messageForFailure(l10n, result.failure!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            enabled: !_isVerifying,
            obscureText: _obscure,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: l10n.accessCodeLabel,
              hintText: l10n.accessCodeObscuredHint,
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                ),
                tooltip: l10n.accessCodeLabel,
                onPressed: _isVerifying
                    ? null
                    : () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isVerifying ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _isVerifying ? null : _submit,
          child: _isVerifying
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.verify),
        ),
      ],
    );
  }
}

Future<String?> showEditCommentDialog(
  BuildContext context, {
  required String initialText,
  required Future<CommentResult> Function(String text) onSave,
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _EditCommentDialog(
      initialText: initialText,
      onSave: onSave,
    ),
  );
}

class _EditCommentDialog extends StatefulWidget {
  const _EditCommentDialog({required this.initialText, required this.onSave});

  final String initialText;
  final Future<CommentResult> Function(String text) onSave;

  @override
  State<_EditCommentDialog> createState() => _EditCommentDialogState();
}

class _EditCommentDialogState extends State<_EditCommentDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialText);
  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _error = l10n.commentRequired);
      return;
    }
    if (text.length > 500) {
      setState(() => _error = l10n.commentTooLong);
      return;
    }
    setState(() {
      _isSaving = true;
      _error = null;
    });
    final result = await widget.onSave(text);
    if (!mounted) return;
    if (result.isSuccess) {
      Navigator.of(context).pop(text);
      return;
    }
    setState(() {
      _isSaving = false;
      _error = messageForFailure(l10n, result.failure!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.editCommentTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            enabled: !_isSaving,
            maxLines: 4,
            maxLength: 500,
            decoration: InputDecoration(
              labelText: l10n.commentLabel,
              hintText: l10n.commentHint,
            ),
          ),
          if (_error != null)
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.save),
        ),
      ],
    );
  }
}

Future<bool?> showDeleteConfirmDialog(
  BuildContext context, {
  required Future<CommentResult> Function() onConfirm,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _DeleteConfirmDialog(onConfirm: onConfirm),
  );
}

class _DeleteConfirmDialog extends StatefulWidget {
  const _DeleteConfirmDialog({required this.onConfirm});

  final Future<CommentResult> Function() onConfirm;

  @override
  State<_DeleteConfirmDialog> createState() => _DeleteConfirmDialogState();
}

class _DeleteConfirmDialogState extends State<_DeleteConfirmDialog> {
  bool _isDeleting = false;
  String? _error;

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _isDeleting = true;
      _error = null;
    });
    final result = await widget.onConfirm();
    if (!mounted) return;
    if (result.isSuccess) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _isDeleting = false;
      _error = messageForFailure(l10n, result.failure!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.deleteConfirmTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.deleteConfirmBody),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _isDeleting ? null : _submit,
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          child: _isDeleting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.delete),
        ),
      ],
    );
  }
}
