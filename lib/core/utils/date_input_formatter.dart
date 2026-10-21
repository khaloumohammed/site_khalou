import 'package:flutter/services.dart';

/// Formatte automatiquement une saisie de date au format JJ/MM/AAAA.
///
/// L'utilisateur peut taper uniquement des chiffres (ex: "12102010") et le
/// masque insère automatiquement les "/" au bon endroit pour afficher
/// "12/10/2010". Les séparateurs tapés manuellement sont ignorés puisqu'ils
/// sont régénérés automatiquement.
class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // On ne garde que les chiffres, dans la limite de JJMMAAAA (8 chiffres).
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final digits = digitsOnly.length > 8
        ? digitsOnly.substring(0, 8)
        : digitsOnly;

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      final nextIndex = i + 1;
      if ((nextIndex == 2 || nextIndex == 4) && nextIndex != digits.length) {
        buffer.write('/');
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
