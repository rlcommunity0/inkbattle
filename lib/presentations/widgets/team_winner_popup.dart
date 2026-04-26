import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inkbattle_frontend/presentations/widgets/winner.dart';
import 'package:inkbattle_frontend/utils/lang.dart';

class TeamWinnerPopup extends StatelessWidget {
  final List<Team> teams;

  const TeamWinnerPopup({
    super.key,
    required this.teams,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final bool isTablet = mq.width > 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isTablet ? 420.w : mq.width * 0.92,
        ),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2942),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: const Color(0xFF4A90E2),
              width: 2.w,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10.r,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// TITLE
              Text(
                AppLocalizations.teamWinners,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: isTablet ? 26.sp : 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 20.h),

              /// TEAM LIST
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: mq.height * 0.35,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: teams.map((team) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: isTablet ? 24.r : 20.r,
                              backgroundImage:
                                  NetworkImage(team.avatar),
                            ),

                            SizedBox(width: 10.w),

                            Expanded(
                              child: Text(
                                team.name,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.lato(
                                  color: Colors.white,
                                  fontSize:
                                      isTablet ? 20.sp : 18.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            Text(
                              '${AppLocalizations.score}${team.score}',
                              style: GoogleFonts.lato(
                                color: Colors.amber,
                                fontSize:
                                    isTablet ? 20.sp : 18.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              /// CLOSE BUTTON
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  padding: EdgeInsets.symmetric(
                    horizontal: 30.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                ),
                child: Text(
                  AppLocalizations.close,
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: isTablet ? 20.sp : 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
