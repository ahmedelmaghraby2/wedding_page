import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wedding/core/failure_message.dart';
import 'package:wedding/features/wedding/data/wedding_comment.dart';
import 'package:wedding/features/wedding/data/wedding_comment_repository.dart';
import 'package:wedding/l10n/generated/app_localizations.dart';
import 'package:wedding/widgets/comment_dialogs.dart';
import 'package:wedding/widgets/comment_form.dart';
import 'package:wedding/widgets/comment_item.dart';
import 'package:wedding/widgets/empty_state.dart';
import 'package:wedding/widgets/error_state.dart';
import 'package:wedding/widgets/loading_indicator.dart';

class WeddingInvitationPage extends StatefulWidget {
  const WeddingInvitationPage({super.key, required this.onToggleLocale});

  final void Function(String currentLanguageCode) onToggleLocale;

  @override
  State<WeddingInvitationPage> createState() => _WeddingInvitationPageState();
}

class _WeddingInvitationPageState extends State<WeddingInvitationPage> {
  final _commentsRepository = WeddingCommentRepository();
  final _nameController = TextEditingController();
  final _commentController = TextEditingController();
  final _accessCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<WeddingComment> _comments = [];
  bool _isLoadingComments = true;
  CommentFailure? _commentsError;
  bool _isSubmitting = false;
  String? _submitMessage;
  bool _submitSuccess = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _commentController.dispose();
    _accessCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    if (!mounted) return;
    setState(() {
      _isLoadingComments = true;
      _commentsError = null;
    });
    try {
      final result = await _commentsRepository.getCommentsOnce();
      if (!mounted) return;
      setState(() {
        _comments = result.comments;
        _isLoadingComments = false;
        _commentsError = result.failure;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingComments = false;
        _commentsError = CommentFailure.unknown;
      });
    }
  }

  Future<void> _submitComment() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }
    if (_isSubmitting) return;
    final l10n = AppLocalizations.of(context);
    final name = _nameController.text.trim();
    final comment = _commentController.text.trim();
    final code = _accessCodeController.text;
    setState(() {
      _isSubmitting = true;
      _submitMessage = null;
      _submitSuccess = false;
    });
    final result = await _commentsRepository.addComment(
      WeddingComment(
        fullName: name,
        comment: comment,
        avatarSeed: name.isNotEmpty ? name : 'Guest',
      ),
      code,
    );
    if (!mounted) return;
    if (result.isSuccess) {
      setState(() {
        _isSubmitting = false;
        _submitSuccess = true;
        _submitMessage = l10n.commentAdded;
        _commentController.clear();
        _nameController.clear();
        _accessCodeController.clear();
        _formKey.currentState?.reset();
      });
      await _loadComments();
    } else {
      setState(() {
        _isSubmitting = false;
        _submitSuccess = false;
        _submitMessage = messageForFailure(l10n, result.failure!);
      });
    }
  }

  Future<void> _editComment(WeddingComment comment) async {
    final l10n = AppLocalizations.of(context);
    final id = comment.id;
    if (id == null) return;
    final code = await showAccessCodeDialog(
      context,
      title: l10n.enterAccessCodeTitle,
      onVerify: (value) => _commentsRepository.verifyAccessCode(id, value),
    );
    if (code == null || !mounted) return;
    final updated = await showEditCommentDialog(
      context,
      initialText: comment.comment ?? '',
      onSave: (value) => _commentsRepository.updateComment(id, value, code),
    );
    if (updated == null || !mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.commentUpdated)));
    await _loadComments();
  }

  Future<void> _deleteComment(WeddingComment comment) async {
    final l10n = AppLocalizations.of(context);
    final id = comment.id;
    if (id == null) return;
    final code = await showAccessCodeDialog(
      context,
      title: l10n.enterAccessCodeTitle,
      onVerify: (value) => _commentsRepository.verifyAccessCode(id, value),
    );
    if (code == null || !mounted) return;
    final deleted = await showDeleteConfirmDialog(
      context,
      onConfirm: () => _commentsRepository.deleteComment(id, code),
    );
    if (deleted != true || !mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.commentDeleted)));
    await _loadComments();
  }

  Future<void> _openGoogleMaps() async {
    const url = 'https://maps.app.goo.gl/Aa2HcwvPYXmNtvdL7';
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;
    final isTablet = width >= 768 && width < 1024;
    final maxWidth = width >= 1024
        ? 900.0
        : (isTablet ? 700.0 : double.infinity);
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF7),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: maxWidth,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 32,
                vertical: isMobile ? 32 : 64,
              ),
              child: Column(
                children: [
                  _buildLanguageToggle(context),
                  const SizedBox(height: 8),
                  _buildHero(context, isMobile),
                  const SizedBox(height: 48),
                  _buildDetails(context),
                  const SizedBox(height: 48),
                  _buildCaption(context),
                  const SizedBox(height: 48),
                  _buildComments(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageToggle(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.localeName == 'ar';
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Tooltip(
        message: l10n.changeLanguage,
        child: TextButton.icon(
          onPressed: () => widget.onToggleLocale(l10n.localeName),
          icon: const Icon(Icons.language),
          label: Text(isArabic ? 'English' : 'العربية'),
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context, bool isMobile) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/wedding.jpg',
              width: isMobile ? double.infinity : 560,
              height: isMobile ? 280 : 360,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Adel',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: const Color(0xFF6B5B4F),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '&',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFF8B7355),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Rahma',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: const Color(0xFF6B5B4F),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.weddingInvitation,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            letterSpacing: 4,
            color: const Color(0xFF8B7355),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.heroSubtitle,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDetails(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Text(
            l10n.weddingDetails,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFF6B5B4F),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 32,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _detail(l10n.detailDate, l10n.weddingDate),
              _detail(l10n.detailTime, l10n.weddingTime),
              _detail(l10n.detailVenue, l10n.venueName),
              _detail(l10n.detailLocation, l10n.weddingCity),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _openGoogleMaps,
            icon: const Icon(Icons.location_on_outlined, size: 18),
            label: Text(l10n.openInGoogleMaps),
          ),
        ],
      ),
    );
  }

  Widget _detail(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            letterSpacing: 2,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildCaption(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        l10n.weddingMessage,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          height: 1.8,
          color: const Color(0xFF6B5B4F),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildComments(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.guestWishes,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFF6B5B4F),
          ),
        ),
        const SizedBox(height: 16),
        CommentForm(
          formKey: _formKey,
          nameController: _nameController,
          commentController: _commentController,
          accessCodeController: _accessCodeController,
          isSubmitting: _isSubmitting,
          submitMessage: _submitMessage,
          submitSuccess: _submitSuccess,
          onSubmit: _submitComment,
        ),
        const SizedBox(height: 24),
        if (_isLoadingComments)
          const Center(child: LoadingIndicator())
        else if (_commentsError != null)
          ErrorState(
            message: messageForFailure(l10n, _commentsError!),
            onRetry: _loadComments,
          )
        else if (_comments.isEmpty)
          const EmptyState()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _comments.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) => CommentItem(
              comment: _comments[i],
              onEdit: () => _editComment(_comments[i]),
              onDelete: () => _deleteComment(_comments[i]),
            ),
          ),
      ],
    );
  }
}
