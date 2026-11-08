import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakeup_desktop/ds/ds_button.dart';
import 'package:wakeup_desktop/ds/ds_theme.dart';
import 'package:wakeup_ds_tokens/wakeup_ds_tokens.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: DsTheme.light(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('bấm chuột gọi onPressed', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(DsButton(label: 'Lưu', onPressed: () => taps++)),
    );
    await tester.tap(find.text('Lưu'));
    expect(taps, 1);
  });

  testWidgets('disabled hoặc onPressed null thì không bấm được', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(
        Column(
          children: [
            DsButton(label: 'A', disabled: true, onPressed: () => taps++),
            const DsButton(label: 'B', onPressed: null),
          ],
        ),
      ),
    );
    await tester.tap(find.text('A'));
    await tester.tap(find.text('B'));
    expect(taps, 0);
    expect(
      tester.getSemantics(find.text('A')),
      isSemantics(isButton: true, hasEnabledState: true, isEnabled: false),
    );
  });

  testWidgets('Enter và Space kích hoạt nút đang focus', (tester) async {
    var taps = 0;
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      _wrap(DsButton(label: 'Lưu', focusNode: focus, onPressed: () => taps++)),
    );
    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(taps, 2);
  });

  testWidgets('semantics: là nút, bật, đọc được nhãn', (tester) async {
    await tester.pumpWidget(_wrap(DsButton(label: 'Lưu', onPressed: () {})));
    expect(
      tester.getSemantics(find.text('Lưu')),
      isSemantics(
        label: 'Lưu',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
      ),
    );
  });

  testWidgets('giá trị mặc định theo Figma: primary, md, không disabled', (
    tester,
  ) async {
    final button = DsButton(label: 'Lưu', onPressed: () {});
    expect(button.variant, DsButtonVariant.primary);
    expect(button.size, DsButtonSize.md);
    expect(button.disabled, isFalse);
    expect(button.enabled, isTrue);
  });
}
