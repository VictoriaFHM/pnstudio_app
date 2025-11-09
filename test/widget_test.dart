import 'package:flutter_test/flutter_test.dart';
import 'package:pnstudio_app/app.dart';

void main() {
  testWidgets('smoke test: app monta', (tester) async {
    await tester.pumpWidget(const PnStudioApp());
    expect(find.byType(PnStudioApp), findsOneWidget);
  });
}
