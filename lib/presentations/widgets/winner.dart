import 'package:audioplayers/audioplayers.dart';
import 'package:dotlottie_flutter/dotlottie_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';
import 'package:inkbattle_frontend/utils/preferences/local_preferences.dart';

// ---------------- DATA MODEL ----------------
class Team {
  final String name;
  final int score;
  final String avatar;
  final bool isCurrentUser;

  Team({
    required this.name,
    required this.score,
    required this.avatar,
    this.isCurrentUser = false,
  });
}

// ---------------- MAIN POPUP ----------------
class TeamWinnerPopup extends StatefulWidget {
  final List<Team> teams;
  final Function()? onNext;
  final bool isWinner;

  const TeamWinnerPopup({
    super.key,
    required this.teams,
    this.onNext,
    this.isWinner = false,
  });

  @override
  State<TeamWinnerPopup> createState() => _TeamWinnerPopupState();
}

class _TeamWinnerPopupState extends State<TeamWinnerPopup> {
  static const String _celebrationLottieUrl =
      'https://lottie.host/6fe4fdb6-3ca3-4e3e-82c5-f90de4c0be04/xn7qPAIzcf.lottie';

  final AudioPlayer _soundPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playResultSound();
  }

  @override
  void dispose() {
    _soundPlayer.dispose();
    super.dispose();
  }

  Future<void> _playResultSound() async {
    try {
      final volume = await LocalStorageUtils.getVolume();
      await _soundPlayer.setVolume(volume.clamp(0.0, 1.0));
      await _soundPlayer.play(
        AssetSource(
          widget.isWinner
              ? 'sounds/winner-sound.mp3'
              : 'sounds/lose-sound.mp3',
        ),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;

    final modalHeightFactor = isTablet ? 0.72 : 0.85;
    final maxWidth = isTablet ? 700.0 : double.infinity;

    final sortedTeams = List<Team>.from(widget.teams)
      ..sort((a, b) => b.score.compareTo(a.score));

    final first = sortedTeams.isNotEmpty ? sortedTeams[0] : null;
    final second = sortedTeams.length > 1 ? sortedTeams[1] : null;
    final third = sortedTeams.length > 2 ? sortedTeams[2] : null;

    final basePodiumHeight = size.height * (isTablet ? 0.18 : 0.20);
    final rank1Height = basePodiumHeight;
    final rank2Height = basePodiumHeight * 0.75;
    final rank3Height = basePodiumHeight * 0.55;

    final availableWidth = isTablet ? 550.0 : size.width * 0.9;
    final podiumWidth = availableWidth / 3.45;

    return WillPopScope(
      onWillPop: () async => false,
      child: Stack(
        children: [
          Container(color: Colors.black.withOpacity(0.6)),

          /// ---------------- POPUP ----------------
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: FractionallySizedBox(
                heightFactor: modalHeightFactor,
                widthFactor: isTablet ? 0.92 : 0.95,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF0F0F1F),
                        Color(0xFF090917),
                        Color(0xFF050510),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: Colors.blueAccent, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                  child: Padding(
                    // padding: EdgeInsets.symmetric(
                    //     horizontal: isTablet ? 16 : 10, vertical: 12),
                    padding: EdgeInsets.fromLTRB(
                      isTablet ? 16 : 10,  8,   // reduce top gap
                      isTablet ? 16 : 10, 16),
                    child: Column(
                      children: [
                        /// ---------- EXISTING RIBBON ----------
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(18),
                            topRight: Radius.circular(18),
                          ),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: FractionallySizedBox(
                              // widthFactor: isTablet ? 1.8 : 1.2,
                              widthFactor: 1.8,
                              child: AspectRatio(
                                aspectRatio: 3.5,
                                child: Image.asset(
                                  AppImages.redflg,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const Spacer(),
                        // SizedBox(height: isTablet ? 18 : 12),

                        /// ---------- PODIUM ----------
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildPodiumColumn(
                                second, 2, rank2Height, podiumWidth, isTablet),
                            SizedBox(width: isTablet ? 20 : 8),
                            _buildPodiumColumn(
                                first, 1, rank1Height, podiumWidth, isTablet),
                            SizedBox(width: isTablet ? 20 : 8),
                            _buildPodiumColumn(
                                third, 3, rank3Height, podiumWidth, isTablet),
                          ],
                        ),

                        const Spacer(),

                        /// ---------- NEXT BUTTON ----------
                        GestureDetector(
                          onTap: () {
                            widget.onNext?.call();
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: isTablet ? 260 : 200,
                            height: isTablet ? 60 : 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF2BC0E4),
                                  Color(0xFF1B7BFF),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueAccent.withOpacity(0.5),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                )
                              ],
                            ),
                            child: Text(
                              "NEXT  >>",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: isTablet ? 18 : 15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// ---------- LOTTIE ----------
          if (widget.isWinner)
            Positioned.fill(
              child: IgnorePointer(
                child: DotLottieView(
                  sourceType: 'url',
                  source: _celebrationLottieUrl,
                  autoplay: true,
                  loop: false,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ---------- PODIUM COLUMN ----------
  Widget _buildPodiumColumn(
    Team? team,
    int rank,
    double height,
    double width,
    bool isTablet,
  ) {
    if (team == null) return SizedBox(width: width);

    final asset = rank == 1
        ? AppImages.podium_1
        : rank == 2
            ? AppImages.podium_2_left
            : AppImages.podium_3;

    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// ---------- AVATAR WITH GLOW ----------
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: rank == 1 ? Colors.amber : Colors.white24,
                width: rank == 1 ? 3 : 1.5,
              ),
              boxShadow: rank == 1
                  ? [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.6),
                        blurRadius: 15,
                        spreadRadius: 2,
                      )
                    ]
                  : [],
            ),
            child: CircleAvatar(
              radius: isTablet
                  ? (rank == 1 ? 40 : 30)
                  : (rank == 1 ? 32 : 22),
              backgroundImage: AssetImage(team.avatar),
            ),
          ),

          const SizedBox(height: 8),

          /// ---------- NAME ----------
          Text(
            team.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: isTablet ? 16 : 12,
            ),
          ),

          const SizedBox(height: 4),

          /// ---------- SCORE ----------
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.monetization_on,
                  color: Colors.amber,
                  size: isTablet ? 18 : 14),
              const SizedBox(width: 4),
              Text(
                "${team.score}",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: isTablet ? 16 : 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          /// ---------- PODIUM ----------
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: SizedBox(
              height: height,
              width: width,
              child: Image.asset(asset, fit: BoxFit.fill),
            ),
          ),
        ],
      ),
    );
  }
}