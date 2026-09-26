import 'package:flutter_test/flutter_test.dart';

import 'package:campuscore/main.dart';

void main() {
  testWidgets('CampusCore opens the login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CampusCoreApp());

    expect(find.text('Welcome to CampusCore'), findsOneWidget);
  });
}
