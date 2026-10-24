import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Matches the panels, fields and actions in Entrada/Salida de Mercancías.
class TrasladoPanel extends StatelessWidget {
  const TrasladoPanel(
      {super.key,
      required this.child,
      this.title,
      this.titleSize = 18,
      this.titleAlign = TextAlign.center});

  final Widget child;
  final String? title;
  final double titleSize;
  final TextAlign titleAlign;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(15, 15, 15, 0),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.alternate),
        boxShadow: const [
          BoxShadow(
              blurRadius: 6, color: Color(0x1B090F13), offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(title!,
                  textAlign: titleAlign,
                  style: theme.bodyMedium.override(
                      font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0,
                      decoration: TextDecoration.underline)),
            ),
          child,
        ],
      ),
    );
  }
}

// Same flat, outlined actions used by CapturaArticulos/CapturaEntrada.
Widget trasladoCaptureButton(
    BuildContext context, String text, VoidCallback? onPressed,
    {Color? color, bool bold = false}) {
  final theme = FlutterFlowTheme.of(context);
  return FFButtonWidget(
    onPressed: onPressed,
    text: text,
    options: FFButtonOptions(
      height: 40,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
      color: color ?? theme.alternate,
      textStyle: theme.titleSmall.override(
        font: GoogleFonts.inter(),
        color: theme.primaryText,
        fontWeight: bold ? FontWeight.bold : theme.titleSmall.fontWeight,
        letterSpacing: 0,
      ),
      elevation: 0,
      borderSide: BorderSide(color: theme.secondaryText),
      borderRadius: BorderRadius.circular(8),
    ),
  );
}

InputDecoration trasladoField(BuildContext context, String label,
    {String? hint, Widget? suffix}) {
  final theme = FlutterFlowTheme.of(context);
  return InputDecoration(
    labelText: label,
    hintText: hint,
    suffixIcon: suffix,
    labelStyle: theme.labelMedium,
    hintStyle: theme.labelMedium,
    filled: true,
    fillColor: theme.secondaryBackground,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.alternate, width: 2),
        borderRadius: BorderRadius.circular(8)),
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.primary, width: 2),
        borderRadius: BorderRadius.circular(8)),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  );
}

Widget trasladoButton(
    BuildContext context, String text, VoidCallback? onPressed) {
  final theme = FlutterFlowTheme.of(context);
  return FFButtonWidget(
    onPressed: onPressed,
    text: text,
    options: FFButtonOptions(
        height: 40,
        color: theme.primary,
        textStyle: theme.titleSmall.override(
            font: GoogleFonts.inter(fontWeight: FontWeight.w600),
            color: Colors.white,
            letterSpacing: 0),
        elevation: 2,
        borderRadius: BorderRadius.circular(8)),
  );
}
