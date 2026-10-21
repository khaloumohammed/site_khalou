import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:attendance_app/data/models/spreadsheet_info.dart';

final sl = GetIt.I;

class SheetSelectionDialog extends StatelessWidget {
  final List<SpreadsheetInfo> sheets;

  const SheetSelectionDialog({super.key, required this.sheets});

  static Future<SpreadsheetInfo?> show(
    BuildContext context,
    List<SpreadsheetInfo> availableSheets,
  ) {
    return showDialog<SpreadsheetInfo>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SheetSelectionDialog(sheets: availableSheets),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Sélectionner la Feuille de Présence',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.6,
        child: sheets.isEmpty
            ? _buildEmptyState()
            : _buildSheetList(context, sheets),
      ),
      actions: [
        TextButton(
          // Retourne null si Annuler
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Annuler'),
        ),
      ],
    );
  }

  // --- Widgets de Construction d'État ---

  Widget _buildEmptyState() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.cloud_off, color: Colors.redAccent, size: 50),
        SizedBox(height: 15),
        Text(
          'Aucune feuille Google trouvée.',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        SizedBox(height: 5),
        Text(
          'Vérifiez que des feuilles sont partagées avec votre compte.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSheetList(BuildContext context, List<SpreadsheetInfo> sheets) {
    return ListView.builder(
      itemCount: sheets.length,
      itemBuilder: (context, index) {
        final sheet = sheets[index];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                // Retourne la SpreadsheetInfo sélectionnée
                Navigator.of(context).pop(sheet);
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.grid_on,
                      color: Color(0xFF002366),
                      size: 28,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sheet.title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${sheet.id.substring(0, 10)}...',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
