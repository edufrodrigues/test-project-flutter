import 'package:flutter/material.dart';

import '../../api/models.dart';

/// Ilustração vetorial gerada a partir da paleta da experiência.
///
/// Substitui fotos para o projeto funcionar offline e sem assets externos.
/// As formas usam o mesmo desenho (viewBox 400 x 240) da versão React.
class ExperienceArt extends StatelessWidget {
  const ExperienceArt({super.key, required this.art, this.label});

  final ArtPalette art;

  /// Texto alternativo. Omita quando a imagem for decorativa.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final painting = CustomPaint(painter: ExperienceArtPainter(art), child: const SizedBox.expand());
    if (label == null) return ExcludeSemantics(child: painting);
    return Semantics(image: true, label: label, child: painting);
  }
}

class ExperienceArtPainter extends CustomPainter {
  ExperienceArtPainter(this.art);

  final ArtPalette art;

  static const _viewBox = Size(400, 240);

  static const _scenes = {
    ArtScene.montanha: (
      far: 'M0 150 L70 80 L120 120 L190 50 L260 115 L320 70 L400 130 L400 240 L0 240 Z',
      near: 'M0 190 L90 130 L160 175 L240 120 L330 180 L400 150 L400 240 L0 240 Z',
    ),
    ArtScene.mar: (
      far: 'M0 140 Q60 110 120 135 T240 130 T400 125 L400 240 L0 240 Z',
      near: 'M0 175 Q50 160 100 175 T200 175 T300 175 T400 172 L400 240 L0 240 Z',
    ),
    ArtScene.cidade: (
      far:
          'M0 150 L30 150 L30 110 L60 110 L60 130 L95 130 L95 90 L115 70 L135 90 L135 140 L175 140 L175 100 L215 100 L215 125 L250 125 L250 80 L290 80 L290 135 L330 135 L330 105 L370 105 L370 140 L400 140 L400 240 L0 240 Z',
      near: 'M0 195 Q100 170 200 190 T400 185 L400 240 L0 240 Z',
    ),
    ArtScene.vinhedo: (
      far: 'M0 140 Q100 90 200 125 T400 110 L400 240 L0 240 Z',
      near: 'M0 180 Q120 140 240 170 T400 160 L400 240 L0 240 Z',
    ),
  };

  @override
  void paint(Canvas canvas, Size size) {
    // Equivale a preserveAspectRatio="xMidYMid slice": cobre a área e corta o excesso.
    final scale = [size.width / _viewBox.width, size.height / _viewBox.height].reduce((a, b) => a > b ? a : b);
    final dx = (size.width - _viewBox.width * scale) / 2;
    final dy = (size.height - _viewBox.height * scale) / 2;

    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.translate(dx, dy);
    canvas.scale(scale);

    final bounds = Offset.zero & _viewBox;
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [art.skyTop, art.skyBottom],
        ).createShader(bounds),
    );
    canvas.drawCircle(const Offset(300, 70), 30, Paint()..color = art.sun.withValues(alpha: 0.9));

    final shapes = _scenes[art.scene]!;
    canvas.drawPath(parseSvgPath(shapes.far), Paint()..color = art.far.withValues(alpha: 0.85));

    if (art.scene == ArtScene.vinhedo) {
      final rows = Paint()
        ..color = art.near.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      for (var i = 0; i < 7; i++) {
        final path = Path()
          ..moveTo(-20.0 + i * 70, 240)
          ..quadraticBezierTo(40.0 + i * 60, 175, 120.0 + i * 55, 150);
        canvas.drawPath(path, rows);
      }
    }

    canvas.drawPath(parseSvgPath(shapes.near), Paint()..color = art.near);
    canvas.restore();
  }

  @override
  bool shouldRepaint(ExperienceArtPainter oldDelegate) => oldDelegate.art != art;
}

/// Lê o subconjunto de SVG usado nas cenas: comandos absolutos M, L, Q, T e Z.
Path parseSvgPath(String data) {
  final tokens = RegExp(r'[MLQTZ]|-?\d+(?:\.\d+)?').allMatches(data).map((match) => match.group(0)!).toList();
  final path = Path();
  var index = 0;
  var current = Offset.zero;
  Offset? lastControl;

  double next() => double.parse(tokens[index++]);

  while (index < tokens.length) {
    final command = tokens[index++];
    switch (command) {
      case 'M':
        current = Offset(next(), next());
        path.moveTo(current.dx, current.dy);
        lastControl = null;
      case 'L':
        current = Offset(next(), next());
        path.lineTo(current.dx, current.dy);
        lastControl = null;
      case 'Q':
        final control = Offset(next(), next());
        current = Offset(next(), next());
        path.quadraticBezierTo(control.dx, control.dy, current.dx, current.dy);
        lastControl = control;
      case 'T':
        // Curva suave: o ponto de controle é o reflexo do anterior.
        final control = lastControl == null ? current : current * 2 - lastControl;
        current = Offset(next(), next());
        path.quadraticBezierTo(control.dx, control.dy, current.dx, current.dy);
        lastControl = control;
      case 'Z':
        path.close();
        lastControl = null;
      default:
        throw FormatException('Comando SVG não suportado: $command');
    }
  }
  return path;
}
