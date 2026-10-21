import 'package:attendance_app/domain/entities/attendance_eleve.dart';
import 'package:attendance_app/domain/repositories/eleve_repository.dart';

class UpdateNumerosEnMasse {
  final EleveRepository repository;

  UpdateNumerosEnMasse(this.repository);

  /// [nouveauxNumeros] : ID élève -> nouveau N°. Retourne null si succès,
  /// sinon un message d'erreur détaillé (aucune modification n'est alors écrite).
  Future<String?> call(
    String spreadsheetId,
    String classe,
    List<AttendanceEleve> elevesClasse,
    Map<String, String> nouveauxNumeros,
  ) async {
    final vides = <String>[];
    final parNumero = <String, List<String>>{};

    for (final e in elevesClasse) {
      final numero = (nouveauxNumeros[e.id] ?? e.numero).trim();
      if (numero.isEmpty) {
        vides.add(e.nom);
        continue;
      }
      parNumero.putIfAbsent(numero, () => []).add(e.nom);
    }

    final doublons = parNumero.entries.where((en) => en.value.length > 1);
    if (vides.isNotEmpty || doublons.isNotEmpty) {
      final buf = StringBuffer('Modifications refusées (classe $classe) :');
      if (vides.isNotEmpty) {
        buf.write('\n• N° vide pour : ${vides.join(', ')}');
      }
      for (final d in doublons) {
        buf.write(
          '\n• N° ${d.key} attribué à ${d.value.length} élèves : '
          '${d.value.join(', ')}',
        );
      }
      return buf.toString();
    }

    final changes = <String, String>{
      for (final e in elevesClasse)
        if (nouveauxNumeros.containsKey(e.id) &&
            nouveauxNumeros[e.id]!.trim() != e.numero.trim())
          e.id: nouveauxNumeros[e.id]!.trim(),
    };
    if (changes.isEmpty) return null;

    try {
      await repository.updateNumerosBatch(spreadsheetId, changes);
      return null;
    } catch (e) {
      return 'Erreur lors de la mise à jour : $e';
    }
  }
}
