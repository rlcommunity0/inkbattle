import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';
import 'package:inkbattle_frontend/utils/lang.dart';

class ExitPopUp extends StatelessWidget {
  final String? imagePath;
  final VoidCallback? onExit;
  final VoidCallback? continueWaiting;
  final String? text;

  const ExitPopUp({
    this.imagePath,
    this.onExit,
    this.continueWaiting,
    this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width > 600;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          // Prevents popup from becoming too wide on tablets
          maxWidth:
              isTablet ? 420.w : MediaQuery.of(context).size.width * 0.9,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 24.h,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF1C1C30),
                Color(0xFF0E0E1A),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: Colors.blueAccent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// HEADER
              Text(
                AppLocalizations.leaveRoom,
                textAlign: TextAlign.center,
                style: GoogleFonts.luckiestGuy(
                  color: Colors.amber,
                  fontSize: isTablet ? 22.sp : 18.sp,
                  decoration: TextDecoration.none,
                ),
              ),

              SizedBox(height: 18.h),

              /// MESSAGE
              Text(
                text ?? AppLocalizations.doYouReallyWantToLeaveRoom,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: isTablet ? 16.sp : 14.sp,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
              ),

              SizedBox(height: 26.h),

              /// BUTTONS
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        continueWaiting?.call();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        minimumSize: Size(
                          isTablet ? 140.w : 120.w,
                          45.h,
                        ),
                      ),
                      child: Text(
                        AppLocalizations.cancel.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onExit?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        minimumSize: Size(
                          isTablet ? 140.w : 120.w,
                          45.h,
                        ),
                      ),
                      child: Text(
                        AppLocalizations.exitButton,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
