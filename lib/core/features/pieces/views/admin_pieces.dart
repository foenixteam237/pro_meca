import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_colors.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/features/pieces/services/pieces_services.dart';
import 'package:pro_meca/core/features/pieces/views/categoriePageScreen.dart';
import 'package:pro_meca/core/features/stock_mvt/views/list_movement_screen.dart';
import 'package:pro_meca/core/utils/formatting.dart';
import 'package:pro_meca/core/widgets/statutCardWithImage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/app_adaptive_colors.dart';

class PartsInventoryScreen extends StatefulWidget {
  const PartsInventoryScreen({super.key});

  @override
  State<PartsInventoryScreen> createState() => _PartsInventoryScreenState();
}

class _PartsInventoryScreenState extends State<PartsInventoryScreen> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  bool _isLoading = true;
  late String _accessToken;
  int catCount = -1;

  int totalParts = 0;
  int totalInventoryValue = -1;
  int lowStockItems = 0;
  int outOfStockItems = 0;

  // Données factices pour la liste des pièces
  List<PieceCritical> parts = [
    PieceCritical(
      name: 'Piston hydraulique',
      category: 'Moteur',
      date: 'Ajouté le 12/05/2023',
      compatibility: ['Tous modèles XJ'],
      quantity: 3,
      reference: 'REF-001',
      critical: true,
      sellingPrice: 125,
      // logo: 'assets/icons/piston.png',
    ),
    PieceCritical(
      name: 'Joint d\'étanchéité',
      category: 'Transmission',
      date: 'Ajouté le 08/05/2023',
      compatibility: ['Série ZT 2020+'],
      quantity: 15,
      reference: 'REF-002',
      critical: false,
      sellingPrice: 45,
      // logo: 'assets/icons/joint.png',
    ),
    PieceCritical(
      name: 'Filtre à air',
      category: 'Filtration',
      date: 'Ajouté le 15/05/2023',
      compatibility: ['Tous modèles'],
      quantity: 2,
      reference: 'REF-003',
      critical: true,
      sellingPrice: 35,
      // logo: 'assets/icons/filter.png',
    ),
    PieceCritical(
      name: 'Bougie d\'allumage',
      category: 'Moteur',
      date: 'Ajouté le 22/05/2023',
      compatibility: ['Essence uniquement'],
      quantity: 45,
      reference: 'REF-004',
      critical: false,
      sellingPrice: 15,
      // logo: 'assets/icons/sparkplug.png',
    ),
    PieceCritical(
      name: 'Disque de frein',
      category: 'Freinage',
      date: 'Ajouté le 18/05/2023',
      compatibility: ['Modèles 2015-2022'],
      quantity: 8,
      reference: 'REF-005',
      critical: false,
      sellingPrice: 89,
      // logo: 'assets/icons/brake.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _accessToken =
        (await SharedPreferences.getInstance()).getString('accessToken') ?? '';
    setState(() {
      _isLoading = true;
    });

    parts = await PiecesService().getCriticalStock(context);

    // Récupération des statistiques catégorie/pièces
    final stats = await PiecesService().getCategoryPieceCount(context);
    catCount = stats['cat'] ?? -1;
    totalParts = stats['pie'] ?? -1;
    totalInventoryValue = stats['inv'] ?? 0;

    // Calcul des nouvelles métriques
    _calculateMetrics();

    setState(() {
      _isLoading = false;
    });
  }

  void _calculateMetrics() {
    // Calcul des nouvelles statistiques
    // totalParts = parts.fold(0, (sum, part) => sum + part.quantity);
    // totalInventoryValue = parts.fold(
    //   0.0,
    //   (sum, part) => sum + (part.quantity * (part.sellingPrice ?? 0)),
    // );
    lowStockItems = parts.where((part) => part.critical).length;
    outOfStockItems = parts.where((part) => part.quantity == 0).length;
  }

  @override
  Widget build(BuildContext context) {
    final appColor = Provider.of<AppAdaptiveColors>(context);
    final filteredParts = parts.where((part) {
      return (part.name.toString().toLowerCase().contains(
            searchQuery.toLowerCase(),
          ) ||
          part.reference.toString().toLowerCase().contains(
            searchQuery.toLowerCase(),
          ));
    }).toList();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.only(top: 20),
            child: Column(
              children: [
                _buildSectionHeader(appColor),

                buildStatusCardWithImage(
                  context,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CategoriesPage(parentContext: context),
                      ),
                    );
                  },
                  "Toutes catégories de pièces",
                  catCount,
                ),

                // Mouvements de stock
                const SizedBox(height: 10),
                _buildStockMovementCard(context),

                // Cards statistiques
                _buildStatsGrid(),

                const SizedBox(height: 24),

                // Section pièces en rupture
                if (parts.isNotEmpty) ...[
                  _buildOutOfStockSection(),
                  SizedBox(height: 12),
                  // Barre de recherche
                  _buildSearchBar(appColor),
                  ...filteredParts.map((part) {
                    return _buildPartItem(part);
                  }),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(AppAdaptiveColors appColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 44,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Nom ou référence de la pièce',
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(width: 12),
          Icon(Icons.search, color: appColor.primary),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(AppAdaptiveColors appColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Text('Gestion des pièces', style: AppStyles.titleLarge(context)),
          const Spacer(),
          // Container(
          //   width: 32,
          //   height: 32,
          //   decoration: BoxDecoration(
          //     color: appColor.primary,
          //     borderRadius: BorderRadius.circular(8),
          //   ),
          //   child: Icon(Icons.more_vert, color: Colors.white, size: 20),
          // ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
        children: [
          _buildStatCard(
            title: 'Valeur Totale',
            value: '${formatAmount(totalInventoryValue)} FCFA',
            icon: Icons.attach_money,
            color: Colors.green,
          ),
          _buildStatCard(
            title: 'Pièces en Stock',
            value: totalParts.toString(),
            icon: Icons.inventory_2,
            color: Colors.blue,
          ),
          _buildStatCard(
            title: 'Stock Faible',
            value: lowStockItems.toString(),
            icon: Icons.warning,
            color: Colors.orange,
          ),
          _buildStatCard(
            title: 'Rupture de Stock',
            value: outOfStockItems.toString(),
            icon: Icons.error,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: AppColors.secondary),
        borderRadius: BorderRadius.circular(16),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey.withOpacity(0.2),
        //     spreadRadius: 2,
        //     // blurRadius: 8,
        //     offset: const Offset(0, 3),
        //   ),
        // ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Center(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            Center(
              child: Text(
                title,
                style: const TextStyle(fontSize: 14 /* color: Colors.grey */),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockMovementCard(BuildContext condition) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StockMovementScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Icon(Icons.inventory_2, size: 60, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Mouvements de Stock',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Historique des entrées/sorties',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  // Widget _buildStockMovementCard(BuildContext context) {
  //   return InkWell(
  //     onTap: () {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(builder: (context) => StockMovementScreen()),
  //       );
  //     },
  //     child: Container(
  //       padding: const EdgeInsets.all(12),
  //       decoration: BoxDecoration(
  //         border: Border.all(color: Colors.grey),
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Icon(Icons.inventory_2, size: 40, color: Colors.blue),
  //           const SizedBox(height: 8),
  //           Text(
  //             'Mouvements Stock',
  //             style: Theme.of(context).textTheme.titleMedium,
  //           ),
  //           const SizedBox(height: 4),
  //           Text(
  //             'Historique des entrées/sorties',
  //             style: Theme.of(context).textTheme.bodySmall,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildOutOfStockSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '⚠️ Stock faible / en rupture',
            style: AppStyles.titleLarge(context),
          ),
          // Text('voir plus', style: AppStyles.bodyMedium(context)),
        ],
      ),
    );
  }

  Widget _buildPartItem(PieceCritical part) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: (part.logo != null && part.logo != '')
                ? CachedNetworkImage(
                    imageUrl: part.logo!.toString(),
                    fit: BoxFit.cover,
                    height: 80,
                    httpHeaders: {'Authorization': 'Bearer $_accessToken'},
                    placeholder: (context, url) => Container(
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) {
                      debugPrint("Image loading error: $error for URL: $url");
                      return Icon(Icons.settings, color: Colors.grey[600]);
                    },
                  )
                : Icon(Icons.settings, color: Colors.grey[600]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  part.name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
                ...[
                  const SizedBox(height: 2),
                  Text(
                    part.reference,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  part.category,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
                // if (part.compatibility.length > 0) ...[
                //   const SizedBox(height: 2),
                //   Text(
                //     part.compatibility.toString(),
                //     style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                //     softWrap: true,
                //     overflow: TextOverflow.visible,
                //   ),
                // ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: part.critical ? Colors.red[100] : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Quantité: ${part.quantity}',
                  style: TextStyle(
                    fontSize: 12,
                    color: part.critical ? Colors.red[700] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Text(
                  'Prix: ${part.sellingPrice ?? "NIL"}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
