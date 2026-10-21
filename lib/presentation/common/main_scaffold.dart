import 'package:flutter/material.dart';
// Pour SpreadsheetInfo
import 'package:attendance_app/presentation/dialogs/sheet_selection_dialog.dart';
import 'package:attendance_app/data/models/spreadsheet_info.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  SpreadsheetInfo? _selectedSheet;

  // Liste de simulation temporaire :
  // Dans une vraie application, vous obtiendriez cette liste via un service ou un Cubit.
  final List<SpreadsheetInfo> _tempSheets = [
    SpreadsheetInfo(id: 'test_id_01', title: 'Feuille Temporaire 1'),
    SpreadsheetInfo(id: 'test_id_02', title: 'Feuille Temporaire 2'),
    SpreadsheetInfo(id: 'test_id_03', title: 'Feuille Temporaire 3'),
  ];

  @override
  void initState() {
    super.initState();
    // DÉCLENCHEUR : Afficher la boîte de dialogue après le rendu initial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSheetSelection();
    });
  }

  void _showSheetSelection() async {
    final selectedSheet = await SheetSelectionDialog.show(context, _tempSheets);
    if (!mounted) return;

    if (selectedSheet != null) {
      setState(() {
        _selectedSheet = selectedSheet;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Feuille sélectionnée : ${_selectedSheet!.title}'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sélection de feuille annulée. Impossible de charger les données.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedSheet != null ? _selectedSheet!.title : 'Chargement...',
        ),
        actions: [
          // Bouton pour ouvrir la sélection à nouveau
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _showSheetSelection,
            tooltip: 'Changer de feuille',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_selectedSheet == null)
              const Text('Veuillez sélectionner une feuille Google Sheets.')
            else
              // Ici s'affichera le contenu de votre application
              Text(
                'Contenu de la feuille : ${_selectedSheet!.title} (ID: ${_selectedSheet!.id})',
              ),
          ],
        ),
      ),
    );
  }
}
