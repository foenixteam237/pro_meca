import 'package:flutter/material.dart';
class InterventionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NO567AZ - COROLLA LE'),
        backgroundColor: Colors.blue,
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage('https://via.placeholder.com/40'), // Remplacez par l'image du technicien
              child: Text('EA'), // Initiales si image absente
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Eric Anderson', style: TextStyle(fontSize: 14)),
                Text('Technicien', style: TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Informations supplémentaires (M. Martin Peter)
          Text('M MARTIN PETER', style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
          SizedBox(height: 16),

          // Section Interventions en attente
          Text('Interventions en attente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          _buildInterventionCard(
            imageUrl: 'https://via.placeholder.com/80', // Remplacez par l'image d'entretien
            title: 'Entretien et révision 2501-1',
            priority: 'Priorité normale',
            buttons: [
              {'text': 'Rapport', 'color': Colors.green},
              {'text': 'Voir plus', 'color': Colors.grey},
            ],
          ),
          SizedBox(height: 8),
          _buildInterventionCard(
            imageUrl: 'https://via.placeholder.com/80', // Remplacez par l'image de direction
            title: 'Direction',
            priority: 'Priorité avertissement',
            priorityColor: Colors.orange,
            buttons: [
              {'text': 'Rapport', 'color': Colors.green},
              {'text': 'Voir plus', 'color': Colors.grey},
            ],
          ),
          SizedBox(height: 16),

          // Section Interventions terminées
          Text('Interventions terminées', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          _buildInterventionCard(
            imageUrl: 'https://via.placeholder.com/80', // Remplacez par l'image de pneumatique
            title: 'Pneumatique',
            buttons: [
              {'text': 'Détail', 'color': Colors.green},
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInterventionCard({
    required String imageUrl,
    required String title,
    String? priority,
    Color? priorityColor,
    List<Map<String, dynamic>> buttons = const [],
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(width: 12),
            // Texte et boutons
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (priority != null) ...[
                    SizedBox(height: 4),
                    Text(
                      priority,
                      style: TextStyle(fontSize: 14, color: priorityColor ?? Colors.black),
                    ),
                  ],
                  SizedBox(height: 8),
                  Row(
                    children: buttons.map((button) {
                      return Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: button['color'],
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(button['text'], style: TextStyle(fontSize: 12, color: Colors.white)),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}