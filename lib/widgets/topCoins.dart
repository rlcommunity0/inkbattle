import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';

class CoinContainer extends StatelessWidget {
  final int coins;

  const CoinContainer({super.key, this.coins = 0});

  @override
  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide > 600;

    final containerHeight = isTablet ? 42.h : 36.h;
    final containerWidth = isTablet ? 120.w : 105.w;
    final coinSize = isTablet ? 48.h : 40.h;

    return Row(
      children: [
        const Spacer(),
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.centerLeft,
          children: [
            // Rectangle
            Container(
              width: containerWidth,
              height: containerHeight,
              padding: EdgeInsets.only(
                right: 16.w,
                left: coinSize * 0.55, // important for correct spacing
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.r), // fully rounded
                border: Border.all(
                  color: const Color.fromRGBO(0, 133, 182, 1),
                  width: 2.w,
                ),
              ),
              alignment: Alignment.centerRight,
              child: Text(
                coins.toString(),
                style: GoogleFonts.poppins(
                  fontSize: isTablet ? 18.sp : 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),

            // Coin
            Positioned(
              left: -coinSize * 0.35, // perfect overlap
              child: SizedBox(
                height: coinSize,
                width: coinSize,
                child: Image.asset(
                  AppImages.coin,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

}
