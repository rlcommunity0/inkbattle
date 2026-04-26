import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';
import 'package:inkbattle_frontend/utils/preferences/local_preferences.dart';
import 'package:inkbattle_frontend/widgets/custom_svg.dart';
import 'package:inkbattle_frontend/utils/lang.dart';
import 'package:inkbattle_frontend/widgets/persistent_banner_ad_widget.dart';
import 'package:inkbattle_frontend/services/native_log_service.dart';

class InstructionsScreen extends StatefulWidget {
  const InstructionsScreen({super.key});

  @override
  State<InstructionsScreen> createState() => _InstructionsScreenState();
}

class _InstructionsScreenState extends State<InstructionsScreen> {
  final String _logTag = 'InstructionsScreen';
  // REMOVED: Ad variables
  // BannerAd? _bannerAd;
  // bool _isBannerAdLoaded = false;
  
  bool isToggleOn = false;
  late String randomInstruction;

  @override
  void initState() {
    super.initState();
    // REMOVED: _loadBannerAd();
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Add your code here
      isToggleOn = (await LocalStorageUtils.showTutorial()) ?? true;
      setState(() {});
    });
    randomInstruction = AppLocalizations.instructionsText;
  }

  // REMOVED: _loadBannerAd() function

  @override
  void dispose() {
    // REMOVED: _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.shortestSide >= 600;
    final double horizontalPadding = isTablet ? 48.w : 24.w;
    final double contentMaxWidth = isTablet ? 560 : double.infinity;

    return Scaffold(
      key: ValueKey(AppLocalizations
          .getCurrentLanguage()), // Force rebuild on language change
      backgroundColor: const Color(0xFF1A2A44),
      body: SafeArea(
        bottom: true, // Protect bottom for ad visibility
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header: back button + title (responsive, no title wrap)
                    Padding(
                      padding: EdgeInsets.only(
                        top: 12.h,
                        bottom: 8.h,
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: EdgeInsets.all(4.w),
                              child: CustomSvgImage(
                                imageUrl: AppImages.arrow_back,
                                height: isTablet ? 32 : 24,
                                width: isTablet ? 32 : 24,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                AppLocalizations.instructions,
                                style: GoogleFonts.lato(
                                  color: Colors.white,
                                  fontSize: isTablet ? 22.sp : 21.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          SizedBox(width: isTablet ? 40 : 32), // Balance back button for visual center
                        ],
                      ),
                    ),
                    SizedBox(height: isTablet ? 32.h : 24.h),
                    // Scrollable instruction text with readable width
                    Expanded(
                      child: SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: contentMaxWidth),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Text(
                              randomInstruction,
                              style: GoogleFonts.lato(
                                color: Colors.white,
                                fontSize: isTablet ? 18.sp : 17.sp,
                                fontWeight: FontWeight.w400,
                                height: 1.6,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Tutorial guide button (responsive width, centered)
                    Padding(
                      padding: EdgeInsets.only(
                        top: 24.h,
                        bottom: 24.h,
                      ),
                      child: Center(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final double buttonWidth = isTablet
                                ? (constraints.maxWidth > 400 ? 380 : constraints.maxWidth * 0.85)
                                : constraints.maxWidth * 0.88;
                            final double buttonHeight = isTablet ? 64.h : 56.h;
                            return SizedBox(
                              width: buttonWidth,
                              height: buttonHeight,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    isToggleOn = !isToggleOn;
                                    NativeLogService.log('Toggle status changed: $isToggleOn', tag: _logTag, level: 'debug');
                                    LocalStorageUtils.setTutorialShown(isToggleOn);
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                ),
                                child: Material(
                                  type: MaterialType.transparency,
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12.r),
                                    splashColor: Colors.blue.withOpacity(0.3),
                                    highlightColor: Colors.blue.withOpacity(0.1),
                                    onTap: () {
                                      setState(() {
                                        isToggleOn = !isToggleOn;
                                        NativeLogService.log('Toggle status changed: $isToggleOn', tag: _logTag, level: 'debug');
                                        LocalStorageUtils.setTutorialShown(isToggleOn);
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20.w,
                                        vertical: 12.h,
                                      ),
                                      decoration: BoxDecoration(
                                        image: const DecorationImage(
                                          image: AssetImage(AppImages.bluebutton),
                                          fit: BoxFit.fill,
                                        ),
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                AppLocalizations.tutorialGuide,
                                                style: GoogleFonts.luckiestGuy(
                                                  color: Colors.white,
                                                  fontSize: isTablet ? 26.sp : 20.sp,
                                                  fontWeight: FontWeight.w400,
                                                  letterSpacing: 0.8,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          Container(
                                            width: isTablet ? 28 : 24,
                                            height: isTablet ? 28 : 24,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(6.r),
                                              border: Border.all(
                                                color: isToggleOn
                                                    ? Colors.green
                                                    : Colors.grey.shade400,
                                                width: 1.5,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child: isToggleOn
                                                ? Icon(
                                                    Icons.check,
                                                    size: isTablet ? 18 : 16,
                                                    color: Colors.green,
                                                  )
                                                : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Persistent Banner Ad (app-wide, loaded once)
            const PersistentBannerAdWidget(),
          ],
        ),
      ),
    );
  }
}
