import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';
import 'package:inkbattle_frontend/utils/lang.dart';

class SubmittedPopup extends StatelessWidget {
  const SubmittedPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 8, 8, 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AppImages.submitted,
            height: 80.h,
            width: 80.w,
          ),
          SizedBox(height: 40.h),
          Text(
            AppLocalizations.submitted,
            style: GoogleFonts.lato(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 30.sp,
            ),
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }
}
