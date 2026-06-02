import 'package:flutter_test/flutter_test.dart';

import 'package:service_manager/main.dart';

void main() {
  testWidgets('Smoke test App Load', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ServiceManagerApp());

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Clientes'), findsOneWidget);
    expect(find.text('Serviços'), findsOneWidget);
  });
}
