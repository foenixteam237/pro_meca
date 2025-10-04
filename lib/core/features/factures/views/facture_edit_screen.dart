import 'package:flutter/material.dart';
import 'package:pro_meca/core/features/factures/services/facture_services.dart';
import 'package:pro_meca/core/models/facture.dart';

class FactureEditScreen extends StatefulWidget {
  final Facture facture;

  const FactureEditScreen({super.key, required this.facture});

  @override
  State<FactureEditScreen> createState() => _FactureEditScreenState();
}

class _FactureEditScreenState extends State<FactureEditScreen> {
  final FactureService _factureService = FactureService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _referenceController;
  late TextEditingController _dateController;
  late TextEditingController _dueDateController;
  late TextEditingController _notesController;
  late String _selectedStatus;

  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _referenceController = TextEditingController(
      text: widget.facture.reference,
    );
    _dateController = TextEditingController(
      text: _formatDateForInput(widget.facture.date),
    );
    _dueDateController = TextEditingController(
      text: widget.facture.dueDate != null
          ? _formatDateForInput(widget.facture.dueDate!)
          : '',
    );
    _notesController = TextEditingController(text: widget.facture.notes ?? '');
    _selectedStatus = widget.facture.status;

    // Écouter les changements
    _referenceController.addListener(_markChanges);
    _dateController.addListener(_markChanges);
    _dueDateController.addListener(_markChanges);
    _notesController.addListener(_markChanges);
  }

  void _markChanges() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  String _formatDateForInput(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      controller.text = _formatDateForInput(picked);
      _markChanges();
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedFacture = await _factureService
          .updateFacture(widget.facture.id, {
            'reference': _referenceController.text,
            'date': DateTime.parse(_dateController.text),
            'dueDate': _dueDateController.text.isNotEmpty
                ? DateTime.parse(_dueDateController.text)
                : null,
            'notes': _notesController.text,
            'status': _selectedStatus,
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Facture mise à jour avec succès')),
      );

      Navigator.pop(context, updatedFacture);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmDiscard() async {
    if (!_hasChanges) {
      Navigator.pop(context);
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifications non enregistrées'),
        content: const Text(
          'Voulez-vous vraiment quitter sans enregistrer les modifications ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Quitter', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (result == true) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _confirmDiscard();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Modifier ${widget.facture.reference}'),
          actions: [
            if (_hasChanges)
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _isLoading ? null : _saveChanges,
                tooltip: 'Enregistrer',
              ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      // Référence
                      TextFormField(
                        controller: _referenceController,
                        decoration: const InputDecoration(
                          labelText: 'Référence',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La référence est obligatoire';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Date
                      TextFormField(
                        controller: _dateController,
                        decoration: const InputDecoration(
                          labelText: 'Date de facturation',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(context, _dateController),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La date est obligatoire';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Date d'échéance
                      TextFormField(
                        controller: _dueDateController,
                        decoration: const InputDecoration(
                          labelText: 'Date d\'échéance (optionnelle)',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(context, _dueDateController),
                      ),
                      const SizedBox(height: 16),

                      // Statut
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Statut',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            [
                              'DRAFT',
                              'OK',
                              'SENT',
                              'PARTIAL',
                              'PAID',
                              'OVERDUE',
                              'CANCELLED',
                            ].map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(Facture.statusLabel(status)),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                            _hasChanges = true;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Notes
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes (optionnelles)',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 4,
                        textAlignVertical: TextAlignVertical.top,
                      ),
                      const SizedBox(height: 24),

                      // Boutons d'action
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _confirmDiscard,
                              child: const Text('Annuler'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _hasChanges ? _saveChanges : null,
                              child: const Text('Enregistrer'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _dateController.dispose();
    _dueDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
