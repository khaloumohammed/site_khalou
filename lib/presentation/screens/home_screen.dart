import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:attendance_app/core/api/google_sheets_client.dart'; // Assurez-vous que le chemin est correct
import 'package:attendance_app/data/models/spreadsheet_info.dart';

final locator = GetIt.instance;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GoogleSheetsClient _sheetsService = locator<GoogleSheetsClient>();

  // L'état de l'écran
  Future<List<SpreadsheetInfo>>? _spreadsheetsFuture;

  @override
  void initState() {
    super.initState();
    // Lance le chargement des feuilles au démarrage de l'écran
    _loadSpreadsheets();
  }

  void _loadSpreadsheets() {
    setState(() {
      _spreadsheetsFuture = _sheetsService.getSpreadsheets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feuilles Google disponibles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSpreadsheets, // Bouton pour rafraîchir
          ),
          // Bouton de déconnexion (à implémenter si nécessaire, il dépend de votre AuthService)
        ],
      ),
      body: FutureBuilder<List<SpreadsheetInfo>>(
        future: _spreadsheetsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Affichage pendant le chargement
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // Affichage en cas d'erreur
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 40,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Erreur de chargement: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loadSpreadsheets,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          final spreadsheets = snapshot.data;

          if (spreadsheets == null || spreadsheets.isEmpty) {
            // Aucune feuille trouvée
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Aucune feuille Google Sheets trouvée.'),
                  const SizedBox(height: 10),
                  Text(
                    'Vérifiez votre Google Drive pour les fichiers de type "Feuille de calcul".',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          // Affichage de la liste des feuilles
          return ListView.builder(
            itemCount: spreadsheets.length,
            itemBuilder: (context, index) {
              final sheet = spreadsheets[index];
              return ListTile(
                leading: const Icon(Icons.grid_on, color: Colors.green),
                title: Text(sheet.title),
                subtitle: Text('ID: ${sheet.id}'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Feuille sélectionnée : ${sheet.title}'),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
