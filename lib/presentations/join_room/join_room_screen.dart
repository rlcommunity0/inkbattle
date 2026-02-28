import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:inkbattle_frontend/constants/app_colors.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';
import 'package:inkbattle_frontend/repositories/room_repository.dart';
import 'package:inkbattle_frontend/repositories/user_repository.dart';
import 'package:inkbattle_frontend/widgets/blue_background_scaffold.dart';
import 'package:inkbattle_frontend/widgets/custom_svg.dart';
import 'package:inkbattle_frontend/widgets/text_widget.dart';
import 'package:inkbattle_frontend/widgets/textformfield_widget.dart';
import 'package:inkbattle_frontend/utils/lang.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final RoomRepository _roomRepository = RoomRepository();
  final UserRepository _userRepository = UserRepository();
  final TextEditingController _codeController = TextEditingController();

  bool _isLoading = false;
  String? selectedTeam; // For team rooms
  bool showTeamSelection = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleJoinRoom() async {
    final code = _codeController.text.trim().toUpperCase();

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.enterRoomCode),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // First, fetch room details to get actual entry cost
      final roomDetailsResult =
          await _roomRepository.getRoomByCode(roomCode: code);

      int entryCost = 100; // Default
      roomDetailsResult.fold(
        (failure) {
          // If we can't fetch room, use default
          entryCost = 100;
        },
        (room) {
          entryCost = room.entryPoints ?? 250;
        },
      );

      // Check if user has enough coins
      final userResult = await _userRepository.getMe();
      final hasEnoughCoins = userResult.fold(
        (failure) => false,
        (user) => (user.coins ?? 0) >= entryCost,
      );

      if (!hasEnoughCoins) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '${AppLocalizations.insufficientCoinsJoin} ($entryCost)'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Join room
      final result = await _roomRepository.joinRoomByCode(
        roomCode: code,
        team: selectedTeam,
      );

      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${AppLocalizations.failedToJoinRoom}: '
                    '${failure.message.isNotEmpty ? failure.message : AppLocalizations.pleaseCheckCode}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (roomResponse) async {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    '${AppLocalizations.successfullyJoinedRoom} ($entryCost ${AppLocalizations.coins})'),
                backgroundColor: Colors.green,
              ),
            );

            // Navigate to game room
            context.push('/game-room/${roomResponse.room?.id}');
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.error}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlueBackgroundScaffold(
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width > 600
                          ? 600
                          : MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          // Header
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const CustomSvgImage(
                                  imageUrl: AppImages.arrow_back,
                                  height: 25,
                                  width: 25,
                                ),
                              ),
                              SizedBox(width: 15.w),
                              TextWidget(
                                text: AppLocalizations.joinRoom,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.whiteColor,
                              ),
                            ],
                          ),
                          SizedBox(height: 50.h),

                          // Room code illustration
                          Container(
                            width: 150.w,
                            height: 150.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.5),
                                width: 3,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.meeting_room,
                                size: 80.sp,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          SizedBox(height: 40.h),

                          // Instructions
                          TextWidget(
                            text: AppLocalizations.enterRoomCode,
                            fontSize: 14.sp,
                            color: Colors.grey,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 30.h),

                          // Code input
                          TextformFieldWidget(
                            controller: _codeController,
                            height: 60.h,
                            rouneded: 15.r,
                            fontSize: 20.sp,
                            hintText: AppLocalizations.roomCodePlaceholder,
                            hintTextColor:
                                const Color.fromRGBO(255, 255, 255, 0.52),
                          ),
                          SizedBox(height: 20.h),

                          // Team selection (if needed)
                          if (showTeamSelection) ...[
                            TextWidget(
                              text: AppLocalizations.selectYourTeam,
                              fontSize: 16.sp,
                              color: AppColors.whiteColor,
                            ),
                            SizedBox(height: 15.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildTeamButton(AppLocalizations.teamA, "A"),
                                SizedBox(width: 20.w),
                                _buildTeamButton(AppLocalizations.teamB, "B"),
                              ],
                            ),
                            SizedBox(height: 20.h),
                          ],

                          const Spacer(),

                          // Join button
                          Container(
                            width: double.infinity,
                            height: 55.h,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color.fromRGBO(83, 128, 246, 1),
                                  Color.fromRGBO(79, 62, 207, 1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.r),
                                ),
                              ),
                              onPressed: _isLoading ? null : _handleJoinRoom,
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : TextWidget(
                                      text:
                                          "${AppLocalizations.joinRoom} (100 ${AppLocalizations.coins})",
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.whiteColor,
                                    ),
                            ),
                          ),
                          SizedBox(height: 20.h),
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
    );
  }

  Widget _buildTeamButton(String label, String team) {
    final isSelected = selectedTeam == team;
    return GestureDetector(
      onTap: () => setState(() => selectedTeam = team),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 15.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
            width: 2,
          ),
        ),
        child: TextWidget(
          text: label,
          fontSize: 16.sp,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: AppColors.whiteColor,
        ),
      ),
    );
  }
}
