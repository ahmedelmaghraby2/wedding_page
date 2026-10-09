import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wedding/features/wedding/data/comment_access_code.dart';
import 'package:wedding/l10n/generated/app_localizations.dart';

class CommentForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController commentController;
  final TextEditingController accessCodeController;
  final bool isSubmitting;
  final String? submitMessage;
  final bool submitSuccess;
  final VoidCallback onSubmit;

  const CommentForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.commentController,
    required this.accessCodeController,
    required this.isSubmitting,
    required this.submitMessage,
    required this.submitSuccess,
    required this.onSubmit,
  });

  @override
  State<CommentForm> createState() => _CommentFormState();
}

class _CommentFormState extends State<CommentForm> {
  bool _showEmojiPicker = false;

  void _onEmojiSelected(Emoji emoji) {
    widget.commentController.text += emoji.emoji;
    widget.commentController.selection = TextSelection.fromPosition(
      TextPosition(offset: widget.commentController.text.length),
    );
  }

  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
    });
  }

  void _generateAccessCode() {
    final code = CommentAccessCode.generate();
    widget.accessCodeController.text = code;
    widget.accessCodeController.selection = TextSelection.fromPosition(
      TextPosition(offset: code.length),
    );
  }

  Future<void> _copyAccessCode() async {
    final l10n = AppLocalizations.of(context);
    var code = widget.accessCodeController.text.trim();
    if (code.isEmpty) {
      code = CommentAccessCode.generate();
      widget.accessCodeController.text = code;
    }
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.copiedToClipboard)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: widget.nameController,
            decoration: InputDecoration(
              labelText: l10n.fullNameLabel,
              hintText: l10n.fullNameHint,
              prefixIcon: const Icon(Icons.person_outline),
            ),
            enabled: !widget.isSubmitting,
            validator: (value) {
              final trimmed = value?.trim() ?? '';
              if (trimmed.isEmpty) {
                return l10n.fullNameRequired;
              }
              if (trimmed.length < 2) {
                return l10n.fullNameTooShort;
              }
              if (trimmed.length > 50) {
                return l10n.fullNameTooLong;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: widget.commentController,
            decoration: InputDecoration(
              labelText: l10n.commentLabel,
              hintText: l10n.commentHint,
              prefixIcon: const Icon(Icons.favorite_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _showEmojiPicker
                      ? Icons.keyboard_outlined
                      : Icons.emoji_emotions_outlined,
                  color: const Color(0xFF8B7355),
                ),
                onPressed: widget.isSubmitting ? null : _toggleEmojiPicker,
                tooltip: l10n.addEmoji,
              ),
            ),
            maxLines: 4,
            enabled: !widget.isSubmitting,
            validator: (value) {
              final trimmed = value?.trim() ?? '';
              if (trimmed.isEmpty) {
                return l10n.commentRequired;
              }
              if (trimmed.length > 500) {
                return l10n.commentTooLong;
              }
              return null;
            },
          ),
          if (_showEmojiPicker) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 250,
              child: EmojiPicker(
                onEmojiSelected: (category, emoji) => _onEmojiSelected(emoji),
                config: const Config(
                  height: 250,
                  checkPlatformCompatibility: true,
                  emojiViewConfig: EmojiViewConfig(emojiSizeMax: 24),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          TextFormField(
            controller: widget.accessCodeController,
            enabled: !widget.isSubmitting,
            decoration: InputDecoration(
              labelText: l10n.accessCodeLabel,
              hintText: l10n.accessCodeHint,
              prefixIcon: const Icon(Icons.key_outlined),
            ),
            validator: (value) {
              final code = CommentAccessCode.normalize(value ?? '');
              final issue = CommentAccessCode.validate(code);
              if (issue == AccessCodeIssue.empty) {
                return l10n.accessCodeRequired;
              }
              if (issue == AccessCodeIssue.tooShort) {
                return l10n.accessCodeTooShort;
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton.icon(
                onPressed: widget.isSubmitting ? null : _generateAccessCode,
                icon: const Icon(Icons.autorenew, size: 18),
                label: Text(l10n.generateAccessCode),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: widget.isSubmitting ? null : _copyAccessCode,
                icon: const Icon(Icons.copy_outlined, size: 18),
                label: Text(l10n.copy),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.accessCodeInfoBody,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: widget.isSubmitting ? null : widget.onSubmit,
            child: widget.isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.sendYourWish),
          ),
          if (widget.submitMessage != null) ...[
            const SizedBox(height: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.submitSuccess
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.submitSuccess ? Colors.green : Colors.orange,
                  width: 1,
                ),
              ),
              child: Text(
                widget.submitMessage!,
                style: TextStyle(
                  color: widget.submitSuccess
                      ? Colors.green[800]
                      : Colors.orange[800],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
