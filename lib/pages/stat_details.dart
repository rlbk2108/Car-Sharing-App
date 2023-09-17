import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Padding buildStat(
    IconData icon, String title, String desc, Size size) {
  return Padding(
    padding: EdgeInsets.symmetric(
      horizontal: size.width * 0.016,
    ),
    child: SizedBox(
      height: size.width * 0.28,
      width: size.width * 0.27,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.deepPurple.withOpacity(0.25),
          borderRadius: const BorderRadius.all(
            Radius.circular(
              10,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: size.width * 0.03,
            left: size.width * 0.03,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: Colors.deepPurple.withOpacity(0.99),
                size: size.width * 0.08,
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: size.width * 0.02,
                ),
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withAlpha(230),
                    fontSize: size.width * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                desc,
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: size.width * 0.035,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
