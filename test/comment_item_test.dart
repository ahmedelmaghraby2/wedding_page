import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wedding/features/wedding/domain/wedding_comment.dart';
import 'package:wedding/l10n/generated/app_localizations.dart';
import 'package:wedding/widgets/comment_item.dart';

Future<void> pumpItem(WidgetTester tester, Widget item) async {
  await tester.binding.setSurfaceSize(const Size(700, 500));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: item),
    ),
  );
}

void main() {
  testWidgets('renders the name, message and initials', (tester) async {
    await pumpItem(
      tester,
      const CommentItem(
        comment: WeddingComment(
          id: '1',
          fullName: 'Jane Doe',
          comment: 'Congratulations!',
        ),
      ),
    );

    expect(find.text('Jane Doe'), findsOneWidget);
    expect(find.text('Congratulations!'), findsOneWidget);
    expect(find.text('JD'), findsOneWidget);
  });

  testWidgets('falls back to the localized guest label for a blank name', (
    tester,
  ) async {
    await pumpItem(
      tester,
      const CommentItem(
        comment: WeddingComment(id: '1', fullName: '   ', comment: 'Welcome'),
      ),
    );

    expect(find.text('Guest'), findsOneWidget);
  });

  testWidgets('exposes edit and delete through the popup menu', (
    tester,
  ) async {
    var edited = false;
    var deleted = false;

    await pumpItem(
      tester,
      CommentItem(
        comment: const WeddingComment(id: '1', fullName: 'Jane', comment: 'Hi'),
        onEdit: () => edited = true,
        onDelete: () => deleted = true,
      ),
    );

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(edited, isTrue);
    expect(deleted, isFalse);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(deleted, isTrue);
  });

  testWidgets('hides the menu when no actions are provided', (tester) async {
    await pumpItem(
      tester,
      const CommentItem(
        comment: WeddingComment(id: '1', fullName: 'Jane', comment: 'Hi'),
      ),
    );

    expect(find.byIcon(Icons.more_vert), findsNothing);
  });
}
