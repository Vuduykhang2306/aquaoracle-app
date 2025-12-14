import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/responsive.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color iconColor;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(Responsive.w(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: Responsive.sp(18),
              backgroundColor: iconColor.withOpacity(0.1),
              child: Icon(
                icon,
                color: iconColor,
                size: Responsive.sp(20),
              ),
            ),
            SizedBox(height: Responsive.h(12)),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(12),
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            SizedBox(height: Responsive.h(4)),
            RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(20),
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.headlineMedium?.color,
                ),
                children: [
                  TextSpan(text: value),
                  TextSpan(
                    text: " $unit",
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(12),
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
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