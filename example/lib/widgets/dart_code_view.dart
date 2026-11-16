import 'package:material_ui/material_ui.dart';

import '../theme_model.dart';

/// Renders a Dart snippet with clean, selectable token syntax highlighting.
class DartCodeView extends StatelessWidget {
  const DartCodeView({super.key, required this.code});

  final String code;

  static final _tokenPattern = RegExp(
    r'0x[0-9a-fA-F]+'
    r'|\b\d+(?:\.\d+)?\b'
    r'|\b[a-zA-Z_][a-zA-Z0-9_]*:'
    r'|\.[a-zA-Z_][a-zA-Z0-9_]*'
    r'|\b[A-Z][a-zA-Z0-9_]*\b'
    r'|\b[a-z_][a-zA-Z0-9_]*(?=\()'
    r'|[(),.:]'
    r'|\s+'
    r'|.',
  );

  static const _typeColor = Color(0xFF7DD3FC);
  static const _funcColor = Color(0xFFFDE68A);
  static const _paramColor = Color(0xFFC4B5FD);
  static const _numberColor = Color(0xFFFCA5A5);
  static const _memberColor = Color(0xFF86EFAC);
  static const _punctColor = Color(0xFF94A3B8);

  List<TextSpan> _tokenize(String source) {
    final spans = <TextSpan>[];
    for (final match in _tokenPattern.allMatches(source)) {
      final token = match.group(0)!;
      if (token.startsWith('0x') || RegExp(r'^\d').hasMatch(token)) {
        spans.add(
          TextSpan(
            text: token,
            style: const TextStyle(color: _numberColor),
          ),
        );
      } else if (token.endsWith(':') && token.length > 1) {
        final name = token.substring(0, token.length - 1);
        spans.add(
          TextSpan(
            text: name,
            style: const TextStyle(color: _paramColor),
          ),
        );
        spans.add(
          const TextSpan(
            text: ':',
            style: TextStyle(color: _punctColor),
          ),
        );
      } else if (token.startsWith('.') && token.length > 1) {
        spans.add(
          const TextSpan(
            text: '.',
            style: TextStyle(color: _punctColor),
          ),
        );
        final member = token.substring(1);
        final isCall = match.end < source.length && source[match.end] == '(';
        spans.add(
          TextSpan(
            text: member,
            style: TextStyle(color: isCall ? _funcColor : _memberColor),
          ),
        );
      } else if (RegExp(r'^[A-Z]').hasMatch(token)) {
        spans.add(
          TextSpan(
            text: token,
            style: const TextStyle(color: _typeColor),
          ),
        );
      } else if (RegExp(r'^[a-z_]').hasMatch(token) &&
          match.end < source.length &&
          source[match.end] == '(') {
        spans.add(
          TextSpan(
            text: token,
            style: const TextStyle(color: _funcColor),
          ),
        );
      } else if (token.length == 1 && '(),.:'.contains(token)) {
        spans.add(
          TextSpan(
            text: token,
            style: const TextStyle(color: _punctColor),
          ),
        );
      } else {
        spans.add(TextSpan(text: token));
      }
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: StudioColors.codeSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SelectableText.rich(
          TextSpan(
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12.5,
              height: 1.55,
              color: StudioColors.codeInk,
            ),
            children: _tokenize(code),
          ),
        ),
      ),
    );
  }
}
