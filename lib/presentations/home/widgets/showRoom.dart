import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';
import 'package:inkbattle_frontend/presentations/home/widgets/button.dart';
import 'package:inkbattle_frontend/presentations/home/widgets/joinRoom.dart';
import 'package:inkbattle_frontend/utils/lang.dart';

class RoomPopup extends StatelessWidget {
  const RoomPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final bool isTablet = mq.width > 600;

    final double dialogWidth = isTablet ? mq.width * 0.70 : mq.width * 0.85;
    final double closeSize = 30.w;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: dialogWidth,
          decoration: BoxDecoration(
            color: const Color(0xFF1A2A44),
            borderRadius: BorderRadius.circular(25.r),
            border: Border.all(color: Colors.blue, width: 3.0),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: EdgeInsets.all(50.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomRoomButton(
                      text: AppLocalizations.createRoom.toUpperCase(),
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/create-room');
                      },
                    ),
                    SizedBox(height: 35.h),
                    CustomRoomButton(
                      text: AppLocalizations.joinRoom.toUpperCase(),
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierColor: Colors.black,
                          builder: (_) => const JoinRoomPopup(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -closeSize * 0.5,
                left: -closeSize * 0.25,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Image.asset(
                    AppImages.closepopup,
                    width: closeSize,
                    height: closeSize,
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
