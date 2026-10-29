import 'package:flutter/material.dart';

import 'rota_colors.dart';
import 'rota_shadows.dart';

export 'rota_colors.dart';
export 'rota_shadows.dart';
export 'rota_spacing.dart';
export 'rota_typography.dart';

/// Atalhos para ler os tokens do tema atual.
extension RotaTokensContext on BuildContext {
  RotaColors get rotaColors => Theme.of(this).extension<RotaColors>()!;
  RotaShadows get rotaShadows => Theme.of(this).extension<RotaShadows>()!;
}
