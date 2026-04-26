import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';
import 'package:inkbattle_frontend/utils/lang.dart';

class SubmittedPopup extends StatefulWidget {
  const SubmittedPopup({super.key});

  @override
  State<SubmittedPopup> createState() => _SubmittedPopupState();
}

class _SubmittedPopupState extends State<SubmittedPopup> {

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final bool isTablet = mq.width > 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isTablet ? 320.w : mq.width * 0.85,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 24.w,
            vertical: 28.h,
          ),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 8, 8, 8),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// CHECK IMAGE
              Image.asset(
                AppImages.submitted,
                height: isTablet ? 120.h : 80.h,
                width: isTablet ? 120.w : 80.w,
                fit: BoxFit.contain,
              ),

              SizedBox(height: 30.h),

              /// TITLE
              Text(
                AppLocalizations.submitted,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: isTablet ? 28.sp : 20.sp,
                ),
              ),

              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}
