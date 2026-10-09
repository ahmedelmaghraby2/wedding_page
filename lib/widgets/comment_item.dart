import 'package:flutter/material.dart';
import 'package:wedding/features/wedding/data/wedding_comment.dart';
import 'package:wedding/l10n/generated/app_localizations.dart';

class CommentItem extends StatelessWidget {
  final WeddingComment comment;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CommentItem({
    super.key,
    required this.comment,
    this.onEdit,
    this.onDelete,
  });

  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'G';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return trimmed[0].toUpperCase();
  }

  Color _getAvatarColor(String seed) {
    final colors = [
      Colors.amber,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
    ];
    final hash = seed.codeUnits.fold(0, (prev, e) => prev + e);
    return colors[hash % colors.length].withValues(alpha: 0.2);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = comment.fullName?.trim().isNotEmpty == true
        ? comment.fullName!.trim()
        : l10n.guest;
    final message = comment.comment?.trim().isNotEmpty == true
        ? comment.comment!.trim()
        : '';
    final seed = comment.avatarSeed?.trim().isNotEmpty == true
        ? comment.avatarSeed!.trim()
        : name;
    final initials = _getInitials(name);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: _getAvatarColor(seed),
            child: Text(
              initials,
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleMedium),
                if (message.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(message, style: Theme.of(context).textTheme.bodyMedium),
                ],
                if (comment.createdAt != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _formatTimestamp(comment.createdAt!),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
          if (onEdit != null || onDelete != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              tooltip: '',
              onSelected: (value) {
                if (value == 'edit') onEdit?.call();
                if (value == 'delete') onDelete?.call();
              },
              itemBuilder: (context) => [
                if (onEdit != null)
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit_outlined, size: 18),
                        const SizedBox(width: 12),
                        Text(l10n.edit),
                      ],
                    ),
                  ),
                if (onDelete != null)
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline, size: 18),
                        const SizedBox(width: 12),
                        Text(l10n.delete),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    try {
      final dt = timestamp.toDate() as DateTime;
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}
