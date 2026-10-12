import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:wedding/core/motion/reveal.dart';
import 'package:wedding/core/theme/app_colors.dart';
import 'package:wedding/features/wedding/presentation/controllers/cubits/comments/comments_cubit.dart';
import 'package:wedding/features/wedding/domain/wedding_comment.dart';
import 'package:wedding/features/wedding/presentation/ui/widgets/failure_message.dart';
import 'package:wedding/core/l10n/generated/app_localizations.dart';
import 'package:wedding/features/wedding/presentation/ui/widgets/comment_form.dart';
import 'package:wedding/features/wedding/presentation/ui/widgets/comment_item.dart';
import 'package:wedding/core/presentation/widgets/empty_state.dart';
import 'package:wedding/core/presentation/widgets/error_state.dart';
import 'package:wedding/core/presentation/widgets/loading_indicator.dart';
import 'package:wedding/features/wedding/presentation/ui/widgets/section.dart';

/// The guest-wishes section: heading, submission form and the live comment
/// list with its loading / empty / error / loaded states.
///
/// Owns no controllers and performs no navigation; the hosting page supplies
/// the form controllers and the edit/delete callbacks, so this widget can be
/// exercised in isolation with a fake repository.
class WishesSection extends StatelessWidget {
  const WishesSection({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.commentController,
    required this.accessCodeController,
    required this.onSubmit,
    required this.onEdit,
    required this.onDelete,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController commentController;
  final TextEditingController accessCodeController;
  final VoidCallback onSubmit;
  final void Function(WeddingComment comment) onEdit;
  final void Function(WeddingComment comment) onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<CommentsCubit, CommentsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeading(
              eyebrow: l10n.weddingInvitation,
              title: l10n.guestWishes,
              subtitle: l10n.wishesSubtitle,
            ),
            const SizedBox(height: 36),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.line),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.espresso.withValues(alpha: 0.05),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: CommentForm(
                formKey: formKey,
                nameController: nameController,
                commentController: commentController,
                accessCodeController: accessCodeController,
                isSubmitting: state.isSubmitting,
                submitMessage: _submitMessageFor(l10n, state),
                submitSuccess: state.submitResult?.isSuccess ?? false,
                onSubmit: onSubmit,
              ),
            ),
            const SizedBox(height: 36),
            _CommentsList(state: state, onEdit: onEdit, onDelete: onDelete),
          ],
        );
      },
    );
  }

  String? _submitMessageFor(AppLocalizations l10n, CommentsState state) {
    final result = state.submitResult;
    if (result == null) return null;
    if (result.isSuccess) return l10n.commentAdded;
    return messageForFailure(l10n, result.failure!);
  }
}

class _CommentsList extends StatelessWidget {
  const _CommentsList({
    required this.state,
    required this.onEdit,
    required this.onDelete,
  });

  final CommentsState state;
  final void Function(WeddingComment comment) onEdit;
  final void Function(WeddingComment comment) onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (state.isLoading) {
      return const Center(child: LoadingIndicator());
    }
    if (state.hasLoadFailure) {
      return ErrorState(
        message: messageForFailure(l10n, state.loadFailure!),
        onRetry: () => context.read<CommentsCubit>().subscribe(),
      );
    }
    if (state.comments.isEmpty) {
      return const EmptyState();
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.comments.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (_, i) => FadeSlideIn(
        delay: Duration(milliseconds: (i.clamp(0, 6)) * 80),
        child: CommentItem(
          comment: state.comments[i],
          onEdit: () => onEdit(state.comments[i]),
          onDelete: () => onDelete(state.comments[i]),
        ),
      ),
    );
  }
}
