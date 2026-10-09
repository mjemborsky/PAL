import 'package:flutter_test/flutter_test.dart';
import 'package:pal/main.dart';
import 'package:pal/ui/standby_view.dart';

void main() {
  testWidgets('PALApp renders StandbyView successfully',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PALApp());
    await tester.pumpAndSettle();

    // Verify StandbyView loaded correctly
    expect(find.byType(StandbyView), findsOneWidget);
  });
}
