import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wedding/core/l10n/generated/app_localizations.dart';
import 'package:wedding/features/wedding/presentation/ui/widgets/comment_form.dart';

void main() {
  late GlobalKey<FormState> formKey;
  late TextEditingController name;
  late TextEditingController comment;
  late TextEditingController code;
  var submits = 0;

  setUp(() {
    formKey = GlobalKey<FormState>();
    name = TextEditingController();
    comment = TextEditingController();
    code = TextEditingController();
    submits = 0;
  });

  tearDown(() {
    name.dispose();
    comment.dispose();
    code.dispose();
  });

  Future<void> pumpForm(
    WidgetTester tester, {
    bool submitting = false,
    String? submitMessage,
    bool submitSuccess = false,
  }) async {
    await tester.binding.setSurfaceSize(const Size(900, 2200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: CommentForm(
              formKey: formKey,
              nameController: name,
              commentController: comment,
              accessCodeController: code,
              isSubmitting: submitting,
              submitMessage: submitMessage,
              submitSuccess: submitSuccess,
              onSubmit: () {
                if (formKey.currentState!.validate()) submits++;
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> tapSend(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, 'Send Your Wish'));
    await tester.pump();
  }

  testWidgets('requires a name, a comment and an access code', (tester) async {
    await pumpForm(tester);

    await tapSend(tester);

    expect(find.text('Full name is required'), findsOneWidget);
    expect(find.text('Comment is required'), findsOneWidget);
    expect(find.text('Access code is required'), findsOneWidget);
    expect(submits, 0);
  });

  testWidgets('rejects a too-short name and access code', (tester) async {
    await pumpForm(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'J');
    await tester.enterText(find.byType(TextFormField).at(1), 'Best wishes');
    await tester.enterText(find.byType(TextFormField).at(2), 'abc');
    await tapSend(tester);

    expect(
      find.text('Full name must be at least 2 characters'),
      findsOneWidget,
    );
    expect(
      find.text('Access code must be at least 8 characters'),
      findsOneWidget,
    );
    expect(submits, 0);
  });

  testWidgets('generates an eight-character access code', (tester) async {
    await pumpForm(tester);

    await tester.tap(
      find.widgetWithText(TextButton, 'Generate a new access code'),
    );
    await tester.pump();

    expect(code.text, hasLength(8));
  });

  testWidgets('submits when every field is valid', (tester) async {
    await pumpForm(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'Jane Doe');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Congratulations!',
    );
    await tester.enterText(find.byType(TextFormField).at(2), 'A7m#K2p!');
    await tapSend(tester);

    expect(submits, 1);
    expect(find.text('Full name is required'), findsNothing);
  });

  testWidgets('shows the success message returned by the cubit', (
    tester,
  ) async {
    await pumpForm(
      tester,
      submitMessage: 'Comment added successfully',
      submitSuccess: true,
    );

    expect(find.text('Comment added successfully'), findsOneWidget);
  });

  testWidgets('disables the submit button while a request is in flight', (
    tester,
  ) async {
    await pumpForm(tester, submitting: true);

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });
}
