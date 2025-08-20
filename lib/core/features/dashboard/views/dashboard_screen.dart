import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/constants/app_adaptive_colors.dart';
import 'package:pro_meca/core/models/visite.dart';

import '../../visites/services/reception_services.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Visite>> _visitesFuture;
  int _sortiesCount = 0;
  int _enAttenteCount = 0;
  int _terminesCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _visitesFuture = ReceptionServices().fetchVisitesWithVehicle();
    });

    // Simuler des données pour les compteurs (à remplacer par vos appels API réels)
    _sortiesCount = 23;
    _enAttenteCount = 15;
    _terminesCount = 59;
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Provider.of<AppAdaptiveColors>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau de bord', style: AppStyles.titleLarge(context)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(AppStyles.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Aujourd\'hui', style: AppStyles.headline3(context)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(AppStyles.paddingMedium),
                      child: Column(
                        children: [
                          Text(
                            '$_sortiesCount',
                            style: AppStyles.headline2(context),
                          ),
                          Text('Sorties', style: AppStyles.bodyMedium(context)),
                          Text(
                            '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                            style: AppStyles.bodySmall(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(AppStyles.paddingMedium),
                      child: Column(
                        children: [
                          Text(
                            '$_enAttenteCount',
                            style: AppStyles.headline2(context),
                          ),
                          Text(
                            'En attente',
                            style: AppStyles.bodyMedium(context),
                          ),
                          Text('12', style: AppStyles.bodySmall(context)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Terminés', style: AppStyles.headline3(context)),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(AppStyles.paddingMedium),
                child: Column(
                  children: [
                    Text(
                      '$_terminesCount',
                      style: AppStyles.headline2(context),
                    ),
                    Text(
                      'Pièces sorties',
                      style: AppStyles.bodyMedium(context),
                    ),
                    Text('12', style: AppStyles.bodySmall(context)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Véhicules en attente', style: AppStyles.headline3(context)),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<Visite>>(
                future: _visitesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Aucune visite trouvée'));
                  }

                  final visites = snapshot.data!;

                  return ListView.builder(
                    itemCount: visites.length,
                    itemBuilder: (context, index) {
                      final visite = visites[index];
                      return ListTile(
                        leading: const Icon(Icons.car_repair),
                        title: Text(
                          visite.vehicle?.licensePlate ?? 'N/A',
                          style: AppStyles.bodyLarge(context),
                        ),
                        subtitle: Text(
                          visite.vehicle?.modelId ?? 'N/A',
                          style: AppStyles.bodyMedium(context),
                        ),
                        trailing: Chip(
                          label: Text(
                            visite.status,
                            style: AppStyles.bodySmall(
                              context,
                            ).copyWith(color: Colors.white),
                          ),
                          backgroundColor: visite.status == 'Avertissement'
                              ? Colors.orange
                              : Colors.red,
                        ),
                        onTap: () {
                          // Navigation vers le détail de la visite
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
