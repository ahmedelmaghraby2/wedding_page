import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wedding/features/wedding/presentation/controllers/cubits/comments/comments_cubit.dart';
import 'package:wedding/features/wedding/domain/wedding_comment.dart';
import 'package:wedding/features/wedding/presentation/ui/widgets/sections/wishes_section.dart';
import 'package:wedding/core/l10n/generated/app_localizations.dart';
import 'package:wedding/features/wedding/presentation/ui/widgets/comment_item.dart';
import 'package:wedding/core/presentation/widgets/empty_state.dart';

import 'support/fake_comments_repository.dart';

/// Integration-style flow over the real guest-wishes widget tree
/// (WishesSection → CommentForm → CommentsCubit → repository port → stream).
///
/// The page's own `_submitComment` wiring is mirrored here because the full
/// `WeddingInvitationPage` pulls in `url_launcher` and the `audioplayers`
/// platform plugin, which cannot run in a headless widget test.
void main() {
  late FakeCommentsRepository fake;
  late CommentsCubit cubit;
  late GlobalKey<FormState> formKey;
  late TextEditingController name;
  late TextEditingController comment;
  late TextEditingController code;

  setUp(() {
    fake = FakeCommentsRepository();
    formKey = GlobalKey<FormState>();
    name = TextEditingController();
    comment = TextEditingController();
    code = TextEditingController();
  });

  tearDown(() async {
    name.dispose();
    comment.dispose();
    code.dispose();
    await fake.closeStream();
  });

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    final result = await cubit.addComment(
      fullName: name.text,
      comment: comment.text,
      accessCode: code.text,
    );
    if (result.isSuccess) {
      name.clear();
      comment.clear();
      code.clear();
      formKey.currentState!.reset();
    }
  }

  Future<void> pumpFlow(WidgetTester tester) async {
    cubit = CommentsCubit(fake);
    addTearDown(cubit.close);
    await tester.binding.setSurfaceSize(const Size(900, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<CommentsCubit>.value(
          value: cubit,
          child: Scaffold(
            body: SingleChildScrollView(
              child: WishesSection(
                formKey: formKey,
                nameController: name,
                commentController: comment,
                accessCodeController: code,
                onSubmit: submit,
                onEdit: (_) {},
                onDelete: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('guest submits a wish: form → cubit → repo → live list', (
    tester,
  ) async {
    await pumpFlow(tester);

    fake.emitComments(const []);
    await tester.pump();
    await tester.pump();
    expect(find.byType(EmptyState), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Jane Doe');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Congratulations to you both!',
    );
    await tester.tap(find.text('Generate a new access code'));
    await tester.pump();
    expect(code.text, isNotEmpty);

    await tester.ensureVisible(find.text('Send Your Wish'));
    await tester.tap(find.text('Send Your Wish'));
    await tester.pump();
    await tester.pump();

    expect(fake.addCalls, 1);
    expect(name.text, isEmpty);
    expect(comment.text, isEmpty);
    expect(find.text('Comment added successfully'), findsOneWidget);

    fake.emitComments(const [
      WeddingComment(
        id: '1',
        fullName: 'Jane Doe',
        comment: 'Congratulations to you both!',
      ),
    ]);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(CommentItem), findsOneWidget);
    expect(find.text('Jane Doe'), findsOneWidget);
    expect(find.byType(EmptyState), findsNothing);
  });

  testWidgets('invalid submission is blocked before reaching the repository', (
    tester,
  ) async {
    await pumpFlow(tester);
    fake.emitComments(const []);
    await tester.pump();
    await tester.pump();

    await tester.ensureVisible(find.text('Send Your Wish'));
    await tester.tap(find.text('Send Your Wish'));
    await tester.pump();

    expect(fake.addCalls, 0);
    expect(find.text('Full name is required'), findsOneWidget);
    expect(find.text('Comment is required'), findsOneWidget);
    expect(find.text('Access code is required'), findsOneWidget);
  });
}
