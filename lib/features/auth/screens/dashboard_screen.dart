// features/dashboard/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_styles.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau de bord', style: AppStyles.titleLarge(context)),
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
                          Text('23', style: AppStyles.headline2(context)),
                          Text('Sorties', style: AppStyles.bodyMedium(context)),
                          Text(
                            '12/07/2025',
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
                          Text('15', style: AppStyles.headline2(context)),
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
                    Text('59', style: AppStyles.headline2(context)),
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
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('NO567AZ', style: AppStyles.bodyLarge(context)),
                    subtitle: Text(
                      'COROLLA LE',
                      style: AppStyles.bodyMedium(context),
                    ),
                    trailing: Chip(
                      label: Text(
                        index % 2 == 0 ? 'Avertissement' : 'Critique',
                        style: AppStyles.bodySmall(context),
                      ),
                      backgroundColor: index % 2 == 0
                          ? Colors.orange
                          : Colors.red,
                    ),
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
