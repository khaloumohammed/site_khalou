import 'package:flutter/material.dart';
import 'eleve_model.dart';

class GestionElevesScreen extends StatefulWidget {
  final Eleve? eleve;

  const GestionElevesScreen({super.key, this.eleve});

  @override
  State<GestionElevesScreen> createState() => _GestionElevesScreenState();
}

class _GestionElevesScreenState extends State<GestionElevesScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nomCtrl;
  late TextEditingController genreCtrl;
  late TextEditingController naissanceCtrl;

  @override
  void initState() {
    super.initState();
    nomCtrl = TextEditingController(text: widget.eleve?.nom ?? '');
    genreCtrl = TextEditingController(text: widget.eleve?.genre ?? '');
    naissanceCtrl = TextEditingController(text: widget.eleve?.naissance ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.eleve != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: Container(
          margin: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: Color(0xFF1E3A8A),
            ),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        title: Container(
          padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
          child: Text(
            isEdit ? 'Modifier Élève' : 'Ajouter Élève',
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nomCtrl,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: genreCtrl,
                decoration: const InputDecoration(labelText: 'Genre (F ou G)'),
              ),
              TextFormField(
                controller: naissanceCtrl,
                decoration: const InputDecoration(
                  labelText: 'Date de naissance',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Enregistrer ou modifier l'élève dans Google Sheets
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('Enregistrer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
