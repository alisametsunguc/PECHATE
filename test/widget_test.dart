import 'package:flutter_test/flutter_test.dart';
import 'package:pechate/main.dart';

void main() {
  testWidgets('PECHATE açılış ekranı yüklenir', (tester) async {
    await tester.pumpWidget(const PechateApp());
    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
