import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_adaptive_colors.dart';
import 'package:pro_meca/core/features/visites/widgets/showVehicleSelectionModal.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/arb/app_localizations.dart';
import 'completeVehiculeCard.dart';

class HomeContent extends StatefulWidget {
  final Widget historyList;
  final Future<void> Function()? onRefresh;
  final BuildContext context;

  const HomeContent({
    super.key,
    required this.historyList,
    this.onRefresh,
    required this.context,
  });

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final appColors = Provider.of<AppAdaptiveColors>(context);

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: widget.onRefresh ?? () async {},
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: l10n.vehicleRegistrationHint,
                      suffixIcon: Icon(Icons.search, color: appColors.primary),
                    ),
                  ),
                ),
                _sectionTitle(l10n.completedVehicles, l10n, context),
                _buildVehicleRow(context),
                widget.historyList,
              ],
            ),
          ),
        ),
        Positioned(
          bottom: isMobile ? screenSize.height * 0.03 : 0.20,
          right: isMobile ? screenSize.width * 0.05 : screenSize.width * 0.07,
          child: FloatingActionButton(
            onPressed: () {
              showVehicleSelectionModal(widget.context);
            },
            backgroundColor: appColors.primary,
            shape: const CircleBorder(),
            child: Icon(Icons.add, size: screenSize.width * 0.09),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(
    String title,
    AppLocalizations l10n,
    BuildContext context,
  ) {
    final appColors = Provider.of<AppAdaptiveColors>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          l10n.viewMore,
          style: TextStyle(color: appColors.primary, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildVehicleRow(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 10),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(10, (index) => completedVehicleCard(context)),
      ),
    );
  }
}
