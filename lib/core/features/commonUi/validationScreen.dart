import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/utils/responsive.dart';

class ConfirmationScreen extends StatelessWidget {
  final String message;
  const ConfirmationScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.responsiveValue(
                context,
                mobile: width * 0.02,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                /// Logo ProMeca
                Image.asset(
                  'assets/images/promeca_logo.png',
                  width: Responsive.responsiveValue(
                    context,
                    mobile: width * 0.4,
                    tablet: width * 0.5,
                  ),
                  height: Responsive.responsiveValue(
                    context,
                    mobile: height * 0.3,
                    tablet: height * 0.4,
                  ),
                ),

                /// Message
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),

                /// GIF de validation
                Container(
                  height: Responsive.responsiveValue(
                    context,
                    mobile: height * 0.3,
                  ),
                  width: Responsive.responsiveValue(
                    context,
                    mobile: width * 0.5,
                  ),
                  padding: EdgeInsets.all(
                    Responsive.responsiveValue(context, mobile: 12, tablet: 20),
                  ),
                  child: Image.asset(
                    'assets/images/verified.gif',
                    fit: BoxFit.fill,
                  ),
                ),

                /// Bouton Accueil
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Action de retour à l'accueil
                      Navigator.pushNamed(context, '/technician_home');
                    },
                    style: AppStyles.primaryButton(context),
                    child: Text(
                      "Accueil",
                      style: AppStyles.buttonText(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
