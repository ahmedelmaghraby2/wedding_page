import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wedding/features/wedding/presentation/controllers/cubits/comments/comments_cubit.dart';
import 'package:wedding/features/wedding/domain/wedding_comment.dart';
import 'package:wedding/features/wedding/presentation/ui/widgets/sections/wishes_section.dart';
import 'package:wedding/core/l10n/generated/app_localizations.dart';
import 'package:wedding/features/wedding/presentation/ui/widgets/comment_form.dart';
import 'package:wedding/features/wedding/presentation/ui/widgets/comment_item.dart';
import 'package:wedding/core/presentation/widgets/empty_state.dart';
import 'package:wedding/core/presentation/widgets/error_state.dart';
import 'package:wedding/core/presentation/widgets/loading_indicator.dart';

import 'support/fake_comments_repository.dart';

void main() {
  late FakeCommentsRepository fake;
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

  /// Builds the section inside the [CommentsCubit]'s own zone so stream events
  /// emitted from the test body are delivered by subsequent pumps.
  Future<void> pumpSection(WidgetTester tester) async {
    final cubit = CommentsCubit(fake);
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
                onSubmit: () {},
                onEdit: (_) {},
                onDelete: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders the heading, form and first loading state', (
    tester,
  ) async {
    await pumpSection(tester);

    expect(find.text('Guest Wishes'), findsOneWidget);
    expect(find.byType(CommentForm), findsOneWidget);
    expect(find.byType(LoadingIndicator), findsOneWidget);
  });

  testWidgets('shows the empty state once the stream returns no comments', (
    tester,
  ) async {
    await pumpSection(tester);

    fake.emitComments(const []);
    await tester.pump();
    await tester.pump();

    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.byType(LoadingIndicator), findsNothing);
    expect(find.byType(CommentItem), findsNothing);
  });

  testWidgets('shows the error state and retrying returns to loading', (
    tester,
  ) async {
    await pumpSection(tester);

    fake.emitError(StateError('boom'));
    await tester.pump();
    await tester.pump();

    expect(find.byType(ErrorState), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);

    await tester.tap(find.text('Try Again'));
    await tester.pump();

    expect(find.byType(LoadingIndicator), findsOneWidget);
    expect(find.byType(ErrorState), findsNothing);
  });

  testWidgets('renders a comment card for every loaded comment', (
    tester,
  ) async {
    await pumpSection(tester);

    fake.emitComments(const [
      WeddingComment(
        id: '1',
        fullName: 'Jane Doe',
        comment: 'Congratulations!',
      ),
      WeddingComment(id: '2', fullName: 'Omar', comment: 'Best wishes'),
    ]);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(CommentItem), findsNWidgets(2));
    expect(find.text('Jane Doe'), findsOneWidget);
    expect(find.text('Congratulations!'), findsOneWidget);
    expect(find.text('Omar'), findsOneWidget);
    expect(find.byType(EmptyState), findsNothing);
    expect(find.byType(LoadingIndicator), findsNothing);
  });
}
