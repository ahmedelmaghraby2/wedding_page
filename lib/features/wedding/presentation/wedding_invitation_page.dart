import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wedding/core/failure_message.dart';
import 'package:wedding/core/motion/reveal.dart';
import 'package:wedding/core/music/music_controller.dart';
import 'package:wedding/core/theme/app_colors.dart';
import 'package:wedding/features/wedding/data/wedding_comment.dart';
import 'package:wedding/features/wedding/data/wedding_comment_repository.dart';
import 'package:wedding/features/wedding/presentation/sections/closing_section.dart';
import 'package:wedding/features/wedding/presentation/sections/countdown_section.dart';
import 'package:wedding/features/wedding/presentation/sections/details_section.dart';
import 'package:wedding/features/wedding/presentation/sections/hero_section.dart';
import 'package:wedding/features/wedding/presentation/sections/story_section.dart';
import 'package:wedding/l10n/generated/app_localizations.dart';
import 'package:wedding/widgets/comment_dialogs.dart';
import 'package:wedding/widgets/comment_form.dart';
import 'package:wedding/widgets/comment_item.dart';
import 'package:wedding/widgets/empty_state.dart';
import 'package:wedding/widgets/error_state.dart';
import 'package:wedding/widgets/invitation_gate.dart';
import 'package:wedding/widgets/loading_indicator.dart';
import 'package:wedding/widgets/section.dart';
import 'package:wedding/widgets/site_header.dart';

class WeddingInvitationPage extends StatefulWidget {
  const WeddingInvitationPage({
    super.key,
    required this.onToggleLocale,
    required this.music,
  });

  final void Function(String currentLanguageCode) onToggleLocale;
  final MusicController music;

  @override
  State<WeddingInvitationPage> createState() => _WeddingInvitationPageState();
}

class _WeddingInvitationPageState extends State<WeddingInvitationPage>
    with SingleTickerProviderStateMixin {
  final _commentsRepository = WeddingCommentRepository();
  final _nameController = TextEditingController();
  final _commentController = TextEditingController();
  final _accessCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _detailsKey = GlobalKey();
  final _storyKey = GlobalKey();
  final _wishesKey = GlobalKey();

  StreamSubscription<List<WeddingComment>>? _commentsSub;
  List<WeddingComment> _comments = [];
  bool _isLoadingComments = true;
  CommentFailure? _commentsError;
  bool _isSubmitting = false;
  String? _submitMessage;
  bool _submitSuccess = false;

  late final AnimationController _gateOpacity = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
    value: 1,
  );
  bool _showGate = true;
  bool _scrolled = false;

  @override
  void initState() {
    super.initState();
    _subscribeComments();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _commentsSub?.cancel();
    _scrollController.dispose();
    _nameController.dispose();
    _commentController.dispose();
    _accessCodeController.dispose();
    _gateOpacity.dispose();
    super.dispose();
  }

  void _onScroll() {
    final scrolled = _scrollController.hasClients &&
        _scrollController.offset > 12;
    if (scrolled != _scrolled) {
      setState(() => _scrolled = scrolled);
    }
  }

  void _openGate() {
    if (!_showGate) return;
    widget.music.play();
    _gateOpacity.reverse().whenComplete(() {
      if (mounted) setState(() => _showGate = false);
    });
  }

  void _subscribeComments() {
    _commentsSub?.cancel();
    setState(() {
      _isLoadingComments = true;
      _commentsError = null;
    });
    var received = false;
    _commentsSub = _commentsRepository.getCommentsStream().listen(
      (comments) {
        received = true;
        if (!mounted) return;
        setState(() {
          _comments = comments;
          _isLoadingComments = false;
          _commentsError = null;
        });
      },
      onError: (_) {
        if (!mounted) return;
        setState(() {
          _isLoadingComments = false;
          _commentsError = CommentFailure.unknown;
        });
      },
      onDone: () {
        if (!mounted || received) return;
        setState(() {
          _isLoadingComments = false;
          _commentsError = CommentFailure.firebaseUnavailable;
        });
      },
    );
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
  }

  Future<void> _openGoogleMaps() async {
    const url = 'https://maps.app.goo.gl/Aa2HcwvPYXmNtvdL7';
    final l10n = AppLocalizations.of(context);
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.mapsOpenFailed)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.mapsOpenFailed)));
      }
    }
  }

  void _navigateTo(GlobalKey key) {
    final target = key.currentContext;
    if (target == null) return;
    final reduce = prefersReducedMotion(context);
    Scrollable.ensureVisible(
      target,
      duration: reduce ? Duration.zero : const Duration(milliseconds: 750),
      curve: Curves.easeInOutCubic,
      alignment: 0.08,
    );
  }

  void _scrollToTop() {
    final reduce = prefersReducedMotion(context);
    _scrollController.animateTo(
      0,
      duration: reduce ? Duration.zero : const Duration(milliseconds: 700),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;
    final isTablet = size.width >= 768 && size.width < 1024;
    final maxContent = size.width >= 1024
        ? 1160.0
        : (isTablet ? 760.0 : double.infinity);
    final hPad = isMobile ? 20.0 : 40.0;
    final heroHeight = size.height.clamp(560.0, 960.0);

    return Scaffold(
      backgroundColor: AppColors.ivory,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(68 + MediaQuery.of(context).padding.top),
        child: SiteHeader(
          musicController: widget.music,
          onToggleLocale: () =>
              widget.onToggleLocale(AppLocalizations.of(context).localeName),
          onNavigate: (section) {
            switch (section) {
              case 'details':
                _navigateTo(_detailsKey);
                break;
              case 'story':
                _navigateTo(_storyKey);
                break;
              case 'wishes':
                _navigateTo(_wishesKey);
                break;
            }
          },
          isMobile: isMobile,
          scrolled: _scrolled,
          onHome: _scrollToTop,
        ),
      ),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: HeroSection(
                  key: ValueKey(_showGate ? 'gated' : 'open'),
                  isMobile: isMobile,
                  height: heroHeight,
                ),
              ),
              SliverToBoxAdapter(
                child: _frame(
                  sectionKey: _detailsKey,
                  maxContent: maxContent,
                  hPad: hPad,
                  child: DetailsSection(
                    onOpenMaps: _openGoogleMaps,
                    isMobile: isMobile,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _frame(
                  maxContent: maxContent,
                  hPad: hPad,
                  background: AppColors.beige.withValues(alpha: 0.4),
                  child: CountdownSection(isMobile: isMobile),
                ),
              ),
              SliverToBoxAdapter(
                child: _frame(
                  sectionKey: _storyKey,
                  maxContent: maxContent,
                  hPad: hPad,
                  child: StorySection(isMobile: isMobile),
                ),
              ),
              SliverToBoxAdapter(
                child: _frame(
                  sectionKey: _wishesKey,
                  maxContent: maxContent,
                  hPad: hPad,
                  child: _buildWishes(context),
                ),
              ),
              SliverToBoxAdapter(
                child: ClosingSection(isMobile: isMobile),
              ),
            ],
          ),
          if (_showGate)
            Positioned.fill(
              child: InvitationGate(
                onOpen: _openGate,
                opacity: _gateOpacity,
                isMobile: isMobile,
              ),
            ),
        ],
      ),
    );
  }

  Widget _frame({
    required Widget child,
    required double maxContent,
    required double hPad,
    GlobalKey? sectionKey,
    Color? background,
  }) {
    return Container(
      key: sectionKey,
      width: double.infinity,
      color: background,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContent),
          child: Padding(
            padding: EdgeInsets.fromLTRB(hPad, 72, hPad, 72),
            child: RevealOnScroll(child: child),
          ),
        ),
      ),
    );
  }

  Widget _buildWishes(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
            formKey: _formKey,
            nameController: _nameController,
            commentController: _commentController,
            accessCodeController: _accessCodeController,
            isSubmitting: _isSubmitting,
            submitMessage: _submitMessage,
            submitSuccess: _submitSuccess,
            onSubmit: _submitComment,
          ),
        ),
        const SizedBox(height: 36),
        _buildCommentsList(context),
      ],
    );
  }

  Widget _buildCommentsList(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_isLoadingComments) {
      return const Center(child: LoadingIndicator());
    }
    if (_commentsError != null) {
      return ErrorState(
        message: messageForFailure(l10n, _commentsError!),
        onRetry: _subscribeComments,
      );
    }
    if (_comments.isEmpty) {
      return const EmptyState();
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _comments.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (_, i) => FadeSlideIn(
        delay: Duration(milliseconds: (i.clamp(0, 6)) * 80),
        child: CommentItem(
          comment: _comments[i],
          onEdit: () => _editComment(_comments[i]),
          onDelete: () => _deleteComment(_comments[i]),
        ),
      ),
    );
  }
}
