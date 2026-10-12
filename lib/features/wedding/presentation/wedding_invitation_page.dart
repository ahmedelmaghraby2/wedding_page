import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wedding/core/config/wedding_scope.dart';
import 'package:wedding/core/motion/reveal.dart';
import 'package:wedding/core/theme/app_colors.dart';
import 'package:wedding/features/wedding/application/comments_cubit.dart';
import 'package:wedding/features/wedding/application/music_cubit.dart';
import 'package:wedding/features/wedding/domain/wedding_comment.dart';
import 'package:wedding/features/wedding/presentation/sections/closing_section.dart';
import 'package:wedding/features/wedding/presentation/sections/countdown_section.dart';
import 'package:wedding/features/wedding/presentation/sections/details_section.dart';
import 'package:wedding/features/wedding/presentation/sections/hero_section.dart';
import 'package:wedding/features/wedding/presentation/sections/story_section.dart';
import 'package:wedding/features/wedding/presentation/sections/wishes_section.dart';
import 'package:wedding/l10n/generated/app_localizations.dart';
import 'package:wedding/widgets/comment_dialogs.dart';
import 'package:wedding/widgets/invitation_gate.dart';
import 'package:wedding/widgets/site_header.dart';

class WeddingInvitationPage extends StatefulWidget {
  const WeddingInvitationPage({
    super.key,
    required this.onToggleLocale,
    required this.music,
  });

  final void Function(String currentLanguageCode) onToggleLocale;
  final MusicCubit music;

  @override
  State<WeddingInvitationPage> createState() => _WeddingInvitationPageState();
}

class _WeddingInvitationPageState extends State<WeddingInvitationPage>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _commentController = TextEditingController();
  final _accessCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _detailsKey = GlobalKey();
  final _storyKey = GlobalKey();
  final _wishesKey = GlobalKey();

  late final AnimationController _gateOpacity = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
    value: 1,
  );
  bool _showGate = true;
  bool _gateOpening = false;
  bool _scrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _commentController.dispose();
    _accessCodeController.dispose();
    _gateOpacity.dispose();
    super.dispose();
  }

  CommentsCubit get _comments => context.read<CommentsCubit>();

  void _onScroll() {
    final scrolled =
        _scrollController.hasClients && _scrollController.offset > 12;
    if (scrolled != _scrolled) {
      setState(() => _scrolled = scrolled);
    }
  }

  void _openGate() {
    if (!_showGate || _gateOpening) return;
    _gateOpening = true;
    widget.music.play();
    _gateOpacity.reverse().whenComplete(() {
      if (mounted) setState(() => _showGate = false);
    });
  }

  Future<void> _submitComment() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }
    final cubit = _comments;
    if (cubit.state.isSubmitting) return;
    final result = await cubit.addComment(
      fullName: _nameController.text,
      comment: _commentController.text,
      accessCode: _accessCodeController.text,
    );
    if (!mounted) return;
    if (result.isSuccess) {
      _commentController.clear();
      _nameController.clear();
      _accessCodeController.clear();
      _formKey.currentState?.reset();
    }
  }

  Future<void> _editComment(WeddingComment comment) async {
    final l10n = AppLocalizations.of(context);
    final cubit = _comments;
    final id = comment.id;
    if (id == null) return;
    final code = await showAccessCodeDialog(
      context,
      title: l10n.enterAccessCodeTitle,
      onVerify: (value) => cubit.verifyAccessCode(id, value),
    );
    if (code == null || !mounted) return;
    final updated = await showEditCommentDialog(
      context,
      initialText: comment.comment,
      onSave: (value) => cubit.updateComment(id, value, code),
    );
    if (updated == null || !mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.commentUpdated)));
  }

  Future<void> _deleteComment(WeddingComment comment) async {
    final l10n = AppLocalizations.of(context);
    final cubit = _comments;
    final id = comment.id;
    if (id == null) return;
    final code = await showAccessCodeDialog(
      context,
      title: l10n.enterAccessCodeTitle,
      onVerify: (value) => cubit.verifyAccessCode(id, value),
    );
    if (code == null || !mounted) return;
    final deleted = await showDeleteConfirmDialog(
      context,
      onConfirm: () => cubit.deleteComment(id, code),
    );
    if (deleted != true || !mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.commentDeleted)));
  }

  Future<void> _openGoogleMaps() async {
    final url = context.wedding.event.mapsUrl;
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
    final wedding = context.wedding;
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
          music: widget.music,
          onToggleLocale: () =>
              widget.onToggleLocale(AppLocalizations.of(context).localeName),
          onNavigate: (section) {
            final wedding = context.wedding;
            switch (section) {
              case 'details':
                _navigateTo(_detailsKey);
                break;
              case 'story':
                if (wedding.hasStory) _navigateTo(_storyKey);
                break;
              case 'wishes':
                if (wedding.showComments) _navigateTo(_wishesKey);
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
              if (wedding.showCountdown)
                SliverToBoxAdapter(
                  child: _frame(
                    maxContent: maxContent,
                    hPad: hPad,
                    background: AppColors.beige.withValues(alpha: 0.4),
                    child: CountdownSection(isMobile: isMobile),
                  ),
                ),
              if (wedding.hasStory)
                SliverToBoxAdapter(
                  child: _frame(
                    sectionKey: _storyKey,
                    maxContent: maxContent,
                    hPad: hPad,
                    child: StorySection(isMobile: isMobile),
                  ),
                ),
              if (wedding.showComments)
                SliverToBoxAdapter(
                  child: _frame(
                    sectionKey: _wishesKey,
                    maxContent: maxContent,
                    hPad: hPad,
                    child: WishesSection(
                      formKey: _formKey,
                      nameController: _nameController,
                      commentController: _commentController,
                      accessCodeController: _accessCodeController,
                      onSubmit: _submitComment,
                      onEdit: _editComment,
                      onDelete: _deleteComment,
                    ),
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

}
