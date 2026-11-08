import 'package:flutter/material.dart';
import 'package:wakeup_desktop/ds/ds_theme.dart';
import 'package:widgetbook/widgetbook.dart';

import 'use_cases/ds_button.dart';

void main() => runApp(const WakeupWidgetbook());

/// Widgetbook của thư viện widget design system (ADR-0008). Mỗi component
/// Figma là một component ở đây; golden test chụp đúng các use case này.
class WakeupWidgetbook extends StatelessWidget {
  const WakeupWidgetbook({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: [
        WidgetbookFolder(
          name: 'Button',
          children: [
            WidgetbookComponent(
              name: 'DsButton',
              useCases: [
                WidgetbookUseCase(
                  name: 'Playground',
                  builder: dsButtonPlayground,
                  designLink: dsButtonFigma,
                ),
                WidgetbookUseCase(
                  name: 'Tất cả biến thể',
                  builder: (_) => const DsButtonGallery(),
                  designLink: dsButtonFigma,
                ),
              ],
            ),
          ],
        ),
      ],
      addons: [
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(name: 'Sáng', data: DsTheme.light()),
            WidgetbookTheme(name: 'Tối', data: DsTheme.dark()),
          ],
        ),
        // DS-08: bố cục không vỡ khi Windows phóng chữ 150%.
        TextScaleAddon(min: 1, max: 2, divisions: 4),
        AlignmentAddon(),
      ],
    );
  }
}
