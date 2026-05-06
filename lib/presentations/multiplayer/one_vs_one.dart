import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';
import 'package:inkbattle_frontend/models/room_model.dart';
import 'package:inkbattle_frontend/repositories/room_repository.dart';
import 'package:inkbattle_frontend/repositories/user_repository.dart';
import 'package:inkbattle_frontend/utils/lang.dart';
import 'package:inkbattle_frontend/widgets/blue_background_scaffold.dart';
import 'package:inkbattle_frontend/widgets/custom_svg.dart';
import 'package:inkbattle_frontend/widgets/persistent_banner_ad_widget.dart';

class OneVsOneScreen extends StatefulWidget {
  final List<String> categories;
  final int points;
  final String roomId;
  final RoomModel? roomModel;

  const OneVsOneScreen({
    super.key,
    required this.categories,
    required this.points,
    required this.roomId,
    this.roomModel,
  });

  @override
  State<OneVsOneScreen> createState() => _OneVsOneScreenState();
}

class _OneVsOneScreenState extends State<OneVsOneScreen> {
  bool isButtonPressed = false;
  Color gradientStartColor =
      const Color.fromRGBO(110, 136, 206, 1); // rgba(110, 136, 206, 1)
  Color gradientEndColor =
      const Color.fromRGBO(44, 61, 106, 1); // rgba(44, 61, 106, 1)

  double borderWidth = 1.2;

  final RoomRepository _roomRepository = RoomRepository();
  final UserRepository _userRepository = UserRepository();
  final TextEditingController _codeController = TextEditingController();

  bool _isLoading = false;
  String? selectedTeam;
  bool showTeamSelection = false;

  /// Current room data (refreshed on init so participantCount and targetPoints are up to date).
  RoomModel? _roomModel;

  int _entryCost() => (_roomModel ?? widget.roomModel)?.entryPoints ?? 250;

  /// Wallet balance for entry check (two-step join).
  int? _userCoins;

  Future<void> _loadUserCoins() async {
    final result = await _userRepository.getMe();
    result.fold(
      (_) {},
      (user) {
        if (mounted) setState(() => _userCoins = user.coins);
      },
    );
  }

  /// Step 1: require sufficient coins, then show "Let's go!". Step 2: call API join.
  Future<void> _onPrimaryJoinTap() async {
    if (_isLoading) return;
    final cost = _entryCost();

    if (!isButtonPressed) {
      if (_userCoins == null) await _loadUserCoins();
      if (!mounted) return;
      final coins = _userCoins;
      if (coins == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not load your balance. Try again.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      if (coins < cost) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Not enough coins. This room costs $cost coins (you have $coins).',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      setState(() => isButtonPressed = true);
      return;
    }

    await _handleJoinRoom(widget.roomId);
  }

  Future<void> _handleJoinRoom(String code) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final result = await _roomRepository.joinRoomById(
        roomId: int.parse(code),
      );

      result.fold(
        (failure) {
          if (mounted) {
            setState(() => isButtonPressed = false);
            final msg = failure.message.isNotEmpty
                ? failure.message
                : AppLocalizations.pleaseCheckCode;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${AppLocalizations.failedToJoinRoom}$msg'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (roomResponse) async {
          if (mounted) {
            final paid = _entryCost();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${AppLocalizations.successfullyJoinedRoomEntryCost}$paid ${AppLocalizations.coins}',
                ),
                backgroundColor: Colors.green,
              ),
            );
            context.push('/game-room/${roomResponse.room?.id}');
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => isButtonPressed = false);
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
  void initState() {
    super.initState();
    _roomModel = widget.roomModel;
    _refreshRoom();
    _loadUserCoins();
  }

  Future<void> _refreshRoom() async {
    if (widget.roomId.isEmpty || widget.roomId == 'Unknown') return;
    final result = await _roomRepository.getRoomDetails(roomId: widget.roomId);
    result.fold(
      (_) {},
      (room) {
        if (mounted) setState(() => _roomModel = room);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        final isTablet = MediaQuery.of(context).size.shortestSide > 600;
        final entryCost = _entryCost();

        return BlueBackgroundScaffold(
          child: SafeArea(
            bottom: true, // Protect bottom for ad visibility
            child: Padding(
              padding: EdgeInsets.only(
                left: 25.w,
                right: 25.w,
                top: isTablet ? 20.h : 15.h,
                bottom: 0,
              ),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const CustomSvgImage(
                        imageUrl: AppImages.arrow_back,
                        height: 25,
                        width: 25,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 10.h),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(50.r + borderWidth),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [gradientStartColor, gradientEndColor],
                          ),
                        ),
                        padding: EdgeInsets.all(borderWidth),
                        child: CircleAvatar(
                          backgroundColor: const Color.fromRGBO(26, 42, 81, 1),
                          radius: 50.r,
                          child: Image.asset(
                            _getCategoryIcon(
                                widget.categories.isNotEmpty
                                    ? widget.categories.first
                                    : 'Animals'),
                            width: 70.w,
                            height: 70.h,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        widget.categories.isEmpty
                            ? 'Animals'
                            : widget.categories.length == 1
                                ? widget.categories.first
                                : widget.categories.join(', '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width > 600 ? 26.sp : 20.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Are you ready to join Individual Game?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF94AFE7),
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 14.h),
                      FittedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person, color: Colors.white, size: 25.sp),
                            SizedBox(width: 6.w),
                            Text(
                              "${(_roomModel ?? widget.roomModel)?.participantCount ?? 0}/${(_roomModel ?? widget.roomModel)?.maxPlayers ?? 0}",
                              style: GoogleFonts.lato(
                                color: const Color(0xFFB9C7E5),
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isTablet ? 40.h : 30.h),
                      FittedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Row(children: [
                                  Icon(Icons.language,
                                      color: Colors.white, size: 28.sp),
                                  SizedBox(width: isTablet ? 6.w : 4.w),
                                  Text(
                                    (_roomModel ?? widget.roomModel)?.language?.isNotEmpty == true
                                        ? (_roomModel ?? widget.roomModel)!.language!
                                        : 'EN',
                                    style: GoogleFonts.lato(
                                      color: Colors.white,
                                      fontSize: isTablet ? 18.sp : 15.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ]),
                              ],
                            ),
                            Container(
                              height: 50.h,
                              width: 1.w,
                              color: Colors.white.withOpacity(0.5),
                              margin: EdgeInsets.symmetric(horizontal: 16.w),
                            ),
                            Column(
                              children: [
                                Row(children: [
                                Icon(Icons.people,
                                    color: Colors.white, size: 21.sp),
                                SizedBox(width: isTablet ? 6.w : 4.w),
                                Text(
                                  "${(_roomModel ?? widget.roomModel)?.participantCount ?? 0}/${(_roomModel ?? widget.roomModel)?.maxPlayers ?? 0}",
                                  style: GoogleFonts.lato(
                                    color: Colors.white,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ]),
                              ],
                            ),
                            Container(
                              height: 50.h,
                              width: 1.w,
                              color: Colors.white.withOpacity(0.5),
                              margin: EdgeInsets.symmetric(horizontal: 16.w),
                            ),
                            Column(
                              children: [
                                Row(children: [
                                  Icon(Icons.flag,
                                      color: Colors.amber, size: 21.sp),
                                  SizedBox(width: isTablet ? 6.w : 4.w),
                                  Text(
                                    "${(_roomModel ?? widget.roomModel)?.pointsTarget ?? 100}",
                                    style: GoogleFonts.lato(
                                      color: Colors.white,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ]),
                              ],
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: isTablet ? 60.h : 40.h),
                      GestureDetector(
                        onTap: _isLoading ? null : () => _onPrimaryJoinTap(),
                        child: Container(
                          width: double.infinity,
                          height: 50.h,
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          decoration: BoxDecoration(
                            color: _isLoading
                                ? Colors.grey
                                : isButtonPressed
                                    ? Colors.green
                                    : const Color.fromARGB(255, 189, 16, 4),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _isLoading
                                  ? SizedBox(
                                      width: 22.w,
                                      height: 22.h,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : isButtonPressed
                                      ? Text(
                                          "🚀  Let's go!",
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Image.asset(
                                              AppImages.coin,
                                              height: 30.h,
                                              width: 30.w,
                                            ),
                                            Text(
                                              '$entryCost',
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Persistent Banner Ad (app-wide, loaded once)
                const PersistentBannerAdWidget(),
              ],
            ),
          ),
        ),
        );
      },
    );
  }

  String _getCategoryIcon(String category) {
    switch (category) {
      case "Fruits":
        return AppImages.fruit;
      case "Animals":
        return AppImages.animal;
      case "Food":
        return AppImages.food;
      case "Movies":
        return AppImages.movies;
      default:
        return AppImages.food;
    }
  }
}
