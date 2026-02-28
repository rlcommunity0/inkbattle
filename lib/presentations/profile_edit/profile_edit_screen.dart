import 'dart:math';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inkbattle_frontend/constants/app_colors.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';
import 'package:inkbattle_frontend/models/user_model.dart';
import 'package:inkbattle_frontend/utils/preferences/local_preferences.dart';
import 'package:inkbattle_frontend/widgets/backgroun_scafold.dart';
import 'package:inkbattle_frontend/widgets/text_widget.dart';
import 'package:inkbattle_frontend/widgets/textformfield_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:inkbattle_frontend/utils/routes/routes.dart';
import 'package:inkbattle_frontend/widgets/topCoins.dart';
import 'package:inkbattle_frontend/repositories/user_repository.dart';
import 'package:video_player/video_player.dart';
import 'package:inkbattle_frontend/utils/lang.dart';
import 'package:inkbattle_frontend/presentations/profile_edit/widgets/profile_country_field.dart';
import 'package:inkbattle_frontend/presentations/room_preferences/widgets/selection_bottom_sheet.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({
    super.key,
  });

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen>
    with TickerProviderStateMixin {
  final String _logTag = 'ProfileEditScreen';
  final UserRepository _userRepository = UserRepository();
  bool nameLoaded = false;
  bool profileLoaded = false;
  late final TextEditingController _usernameController;
  final FocusNode _usernameFocusNode = FocusNode();
  UserModel? _user;
  String? selectedLanguage;
  String? selectedCountry;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int selectedAvatarIndex = 0;
  String? selectedProfilePhoto;
  bool _isSubmitting = false;
  bool _showFieldErrors = false;
  List<String> avatarsURLs = [
    AppImages.av1,
    AppImages.av2,
    AppImages.av3,
    AppImages.av4,
    AppImages.av5,
  ];

  late AnimationController _controller;
  late AnimationController _avatarMoveController;
  late List<Animation<Offset>> _coinDrops;
  late Animation<double> _textOpacity;
  VideoPlayerController? _videoController;
  final random = Random();

  // Avatar swipe animation variables
  late AnimationController _avatarSwipeController;
  int _previousAvatarIndex = 0;
  double _swipeOffset = 0.0;
  bool _isSwiping = false;

// Countries are now handled via CountryPickerWidget with ISO-2 codes

  void _onAvatarSwipeLeft() {
    if (_isSwiping) return;
    
    setState(() {
      _isSwiping = true;
      _previousAvatarIndex = selectedAvatarIndex;
      selectedAvatarIndex = (selectedAvatarIndex + 1) % avatarsURLs.length;
      selectedProfilePhoto = avatarsURLs[selectedAvatarIndex];
    });
    
    _avatarSwipeController.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() {
          _isSwiping = false;
          _swipeOffset = 0.0;
        });
      }
    });
  }

  void _onAvatarSwipeRight() {
    if (_isSwiping) return;
    
    setState(() {
      _isSwiping = true;
      _previousAvatarIndex = selectedAvatarIndex;
      selectedAvatarIndex = (selectedAvatarIndex - 1 + avatarsURLs.length) % avatarsURLs.length;
      selectedProfilePhoto = avatarsURLs[selectedAvatarIndex];
    });
    
    _avatarSwipeController.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() {
          _isSwiping = false;
          _swipeOffset = 0.0;
        });
      }
    });
  }

  void _loadLanguage() {
    final savedLanguage = LocalStorageUtils.getLanguage();
    selectedLanguage = AppLocalizations.languageDisplayName(savedLanguage);
  }

  Future<void> _changeLanguage(String? language) async {
    if (language == null) return;

    setState(() {
      selectedLanguage = language;
    });
    if (mounted) setState(() {});

    final languageCode = AppLocalizations.languageCodeFromDisplayName(language);
    await LocalStorageUtils.saveLanguage(languageCode);
    AppLocalizations.setLanguage(languageCode);

    if (mounted) setState(() {});
  }

  void _selectAvatar(int index) {
    setState(() {
      selectedAvatarIndex = index;
      selectedProfilePhoto = avatarsURLs[index];
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      setState(() {
        selectedProfilePhoto = image.path;
        selectedAvatarIndex = -1;
      });
    }
  }

  void _showTabletAvatarSelectionSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TabletAvatarSelectionSheet(
        avatarsURLs: avatarsURLs,
        selectedAvatarIndex: selectedAvatarIndex >= 0 && selectedAvatarIndex < avatarsURLs.length ? selectedAvatarIndex : 0,
        selectedProfilePhoto: selectedProfilePhoto,
        onAvatarSelected: (index) {
          setState(() {
            selectedAvatarIndex = index;
            selectedProfilePhoto = avatarsURLs[index];
          });
          Navigator.pop(context);
        },
        onChoosePhoto: () {
          Navigator.pop(context);
          _pickImage();
        },
        onBack: () => Navigator.pop(context),
      ),
    );
  }

  Future<void> _showLanguageBottomSheet() async {
    FocusScope.of(context).unfocus();
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectionBottomSheet(
        title: AppLocalizations.language,
        items: AppLocalizations.supportedLanguageDisplayNames,
        selectedItem: selectedLanguage,
      ),
    );
    if (result != null && mounted) _changeLanguage(result);
  }

  Widget _buildAvatarImage(bool isTablet) {
    if (selectedProfilePhoto == null) {
      return Center(
        child: Icon(Icons.person, size: isTablet ? 60.sp : 50.sp, color: Colors.grey),
      );
    }
    bool isLocalFile = !avatarsURLs.contains(selectedProfilePhoto);
    if (isLocalFile) {
      return Padding(
        padding: EdgeInsets.all(isTablet ? 0.0 : 0.0),
        child: Image.file(File(selectedProfilePhoto!), fit: BoxFit.cover),
      );
    }
    return Padding(
      padding: EdgeInsets.all(isTablet ? 30.0 : 20.0),
      child: Image.asset(selectedProfilePhoto!, fit: BoxFit.contain),
    );
  }

  @override
  void initState() {
    super.initState();

    // Load saved language
    _loadLanguage();

    _usernameController = TextEditingController(
      text: 'Guest_${random.nextInt(99999).toString().padLeft(5, '0')}',
    );

    // Main animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) context.go(Routes.homeScreen);
        });
      }
    });

    // Avatar swipe animation controller
    _avatarSwipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _coinDrops = [];
    _textOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.80, 1.0, curve: Curves.easeIn),
    );
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.asset(
      'asset/animationVideos/coin_reward_animation.mp4',
    );
    await _videoController!.initialize();
    _videoController!.setLooping(false);
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final random = Random();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final stackWidth = screenWidth * 0.6;
    final stackHeight = screenHeight * 0.4;
    final childSize = screenWidth * 0.1;
    final radius = min(stackWidth, stackHeight) * 0.15;

    _coinDrops = List.generate(20, (i) {
      final angle =
          (i * 2 * pi / 20) + (random.nextDouble() * pi / 10 - pi / 20);
      final endDx = (radius * cos(angle)) / childSize;
      final endDy = (radius * sin(angle)) / childSize;
      final beginDx = random.nextDouble() * 4 - 2;
      final beginDy = -(stackHeight / childSize) - (random.nextDouble() * 2);

      return Tween<Offset>(
        begin: Offset(beginDx, beginDy),
        end: Offset(endDx, endDy),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(i * 0.05, 1.0, curve: Curves.easeOut),
      ));
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _usernameFocusNode.dispose();
    _pageController.dispose();
    _controller.dispose();
    _avatarSwipeController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!profileLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        _user = await _userRepository.getUserLocally();
        if (!mounted) return;

        if (!nameLoaded && _user?.name != null) {
          _usernameController.text = _user!.name!;
          nameLoaded = true;
        }
        if (!profileLoaded) {
          if (mounted) {
            setState(() {
              // Default to av3.png if no avatar exists (same as home screen)
              selectedProfilePhoto =
                  _user?.avatar ?? _user?.profilePicture ?? AppImages.av3;
              selectedCountry = _user?.country ?? selectedCountry;
              if (_user?.language != null) {
                selectedLanguage = AppLocalizations.languageDisplayName(_user!.language!);
              }

              // Set selectedAvatarIndex based on current avatar
              if (selectedProfilePhoto != null) {
                int index = avatarsURLs.indexOf(selectedProfilePhoto!);
                if (index >= 0) {
                  selectedAvatarIndex = index;
                } else {
                  // If avatar not found in list, default to av3 (index 2)
                  selectedAvatarIndex = 2;
                  selectedProfilePhoto = AppImages.av3;
                }
              } else {
                // Fallback to av3 if still null
                selectedProfilePhoto = AppImages.av3;
                selectedAvatarIndex = 2;
              }

              profileLoaded = true;
            });
          }
        }
      });
    }
    return BackgroundScaffold(
      child: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 2,
        onPageChanged: (index) {
          setState(() => _currentPage = index);
          if (index == 1) {
            _controller.forward(from: 0);
            if (_videoController != null &&
                _videoController!.value.isInitialized) {
              _videoController!.seekTo(Duration.zero);
              _videoController!.play();
            }
          }
        },
        itemBuilder: (context, index) {
          if (index == 0) return _buildFirstPage();
          return _buildSecondPage();
        },
      ),
    );
  }

  static const double _kTabletMaxWidth = 600;

  Widget _buildFirstPage() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    double contentWidth = isTablet ? _kTabletMaxWidth : screenWidth;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 10.h),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: isTablet ? 52.w : 40.w,
                    height: isTablet ? 52.w : 40.w,
                    color: Colors.transparent,
                    child: Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: isTablet ? 28.sp : 22.sp,
                    ),
                  ),
                ),
                const CoinContainer(coins: 0),
              ],
            ),
          ),
          const Spacer(flex: 1),
          Flexible(
            flex: 8,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 700 : double.infinity,
                    maxHeight: MediaQuery.of(context).size.height * 0.85,
                  ),
                  child: SizedBox(
                    width: contentWidth,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: isTablet ? 0.0 : 20.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Stack(
                                  alignment: Alignment.center,
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: _showTabletAvatarSelectionSheet,
                                        child: Container(
                                          clipBehavior: Clip.hardEdge,
                                          height: isTablet ? 160.h : 120.h,
                                          width: isTablet ? 160.w : 120.w,
                                          padding: EdgeInsets.all(2.w),
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFF09BDFF),
                                                Color(0xFF6FE4FF),
                                                Color(0xFFFFFFFF),
                                              ],
                                            ),
                                          ),
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.black,
                                            ),
                                            child: ClipOval(
                                              clipBehavior: Clip.hardEdge,
                                              child: SizedBox(
                                                width: isTablet ? 150.r : 110.r,
                                                height: isTablet ? 150.r : 110.r,
                                                child: _buildAvatarImage(isTablet),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: isTablet ? 10.h : 0.h,
                                      right: isTablet ? 0 : 0.w,
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: _showTabletAvatarSelectionSheet,
                                        child: Container(
                                          height: isTablet ? 45.h : 40.h,
                                          width: isTablet ? 45.w : 40.w,
                                          decoration: const BoxDecoration(
                                            color: Color.fromRGBO(217, 217, 217, 1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Image.asset(
                                              AppImages.pencil,
                                              height: isTablet ? 30.h : 24.h,
                                              width: isTablet ? 30.w : 24.w,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            SizedBox(height: isTablet ? 40.h : 20.h),
                            if (_showFieldErrors && selectedProfilePhoto == null) ...[
                              Padding(
                                padding: EdgeInsets.only(left: 4.w),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.error_outline, color: Colors.red, size: 16.sp),
                                    SizedBox(width: 6.w),
                                    Text(AppLocalizations.pleaseSelectAnAvatar, style: TextStyle(color: Colors.red, fontSize: 12.sp)),
                                  ],
                                ),
                              ),
                              SizedBox(height: 8.h),
                            ],
                            SizedBox(
                              width: contentWidth,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextformFieldWidget(
                                    readOnly: false,
                                    controller: _usernameController,
                                    focusNode: _usernameFocusNode,
                                    height: isTablet ? 60.h : 50.h,
                                    rouneded: 15.r,
                                    fontSize: isTablet ? 20.sp : 18.sp,
                                    hintTextColor: const Color.fromRGBO(255, 255, 255, 0.52),
                                    hintText: AppLocalizations.enterUsername,
                                    prefixIcon: Padding(
                                      padding: EdgeInsets.all(10.w),
                                      child: Icon(
                                        Icons.person_outline,
                                        color: const Color.fromRGBO(255, 255, 255, 0.52),
                                        size: isTablet ? 24.sp : 21.sp,
                                      ),
                                    ),
                                  ),
                                  if (_showFieldErrors && _usernameController.text.trim().isEmpty) ...[
                                    SizedBox(height: 4.h),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.error_outline, color: Colors.red, size: 16.sp),
                                        SizedBox(width: 6.w),
                                        Text(AppLocalizations.pleaseEnterUsername, style: TextStyle(color: Colors.red, fontSize: 12.sp)),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            SizedBox(height: isTablet ? 25.h : 15.h),
                            SizedBox(
                              width: contentWidth,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildGradientDropdown(
                                    hint: AppLocalizations.language,
                                    value: selectedLanguage,
                                    items: AppLocalizations.supportedLanguageDisplayNames,
                                    isTablet: isTablet,
                                    prefixIcon: Padding(
                                      padding: EdgeInsets.all(12.w),
                                      child: Icon(
                                        Icons.language,
                                        color: const Color.fromRGBO(255, 255, 255, 0.52),
                                        size: isTablet ? 24.sp : 21.sp,
                                      ),
                                    ),
                                    onChanged: (val) => _changeLanguage(val),
                                  ),
                                  if (_showFieldErrors && selectedLanguage == null) ...[
                                    SizedBox(height: 4.h),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.error_outline, color: Colors.red, size: 16.sp),
                                        SizedBox(width: 6.w),
                                        Text(AppLocalizations.pleaseSelectAnyLanguage, style: TextStyle(color: Colors.red, fontSize: 12.sp)),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            SizedBox(height: isTablet ? 25.h : 15.h),
                            isTablet
                                ? SizedBox(
                                    width: contentWidth,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ProfileCountryField(
                                          selectedCountryCode: selectedCountry,
                                          onCountrySelected: (code) {
                                            setState(() => selectedCountry = code);
                                            if (mounted) setState(() {});
                                          },
                                          hintText: AppLocalizations.country,
                                          isTablet: true,
                                        ),
                                        if (_showFieldErrors && selectedCountry == null) ...[
                                          SizedBox(height: 4.h),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.error_outline, color: Colors.red, size: 16.sp),
                                              SizedBox(width: 6.w),
                                              Text(AppLocalizations.pleaseSelectAnyCountry, style: TextStyle(color: Colors.red, fontSize: 12.sp)),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  )
                                : SizedBox(
                                    width: double.infinity,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ProfileCountryField(
                                          selectedCountryCode: selectedCountry,
                                          onCountrySelected: (countryCode) {
                                            setState(() => selectedCountry = countryCode);
                                            if (mounted) setState(() {});
                                          },
                                          hintText: AppLocalizations.country,
                                          isTablet: isTablet,
                                        ),
                                        if (_showFieldErrors && selectedCountry == null) ...[
                                          SizedBox(height: 4.h),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.error_outline, color: Colors.red, size: 16.sp),
                                              SizedBox(width: 6.w),
                                              Text(AppLocalizations.pleaseSelectAnyCountry, style: TextStyle(color: Colors.red, fontSize: 12.sp)),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                            SizedBox(height: isTablet ? 40.h : 25.h),
                            InkWell(
                              onTap: (_isSubmitting || !_areAllFieldsFilled()) ? null : _handleGuestSignup,
                              child: Opacity(
                                opacity: (_isSubmitting || !_areAllFieldsFilled()) ? 0.5 : 1.0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const Spacer(),
                                    _isSubmitting
                                        ? SizedBox(
                                            width: isTablet ? 20.sp : 18.sp,
                                            height: isTablet ? 20.sp : 18.sp,
                                            child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                          )
                                        : Flexible(
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: TextWidget(
                                                text: AppLocalizations.next,
                                                fontSize: isTablet ? 22.sp : 18.sp,
                                                color: AppColors.whiteColor,
                                              ),
                                            ),
                                          ),
                                    SizedBox(width: 5.w),
                                    Icon(Icons.navigate_next_outlined, color: AppColors.whiteColor, size: isTablet ? 28.sp : 22.sp),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(flex: 1),
          ],
        ),
    );
  }

  Widget _buildAvatarCircle(String avatarPath, bool isTablet, double contentWidth) {
    return Container(
      height: isTablet ? 180.h : 150.h,
      width: isTablet ? 180.w : 150.w,
      padding: EdgeInsets.all(2.w),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Color(0xFF09BDFF),
            Color(0xFF6FE4FF),
            Color(0xFFFFFFFF),
          ],
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black,
        ),
        child: ClipOval(
          child: SizedBox(
            width: isTablet ? 170.r : 140.r,
            height: isTablet ? 170.r : 140.r,
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 30.0 : 24.0),
              child: Image.asset(
                avatarPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to av3.png if image fails to load
                  return Image.asset(
                    AppImages.av3,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Check if all required fields are filled
  bool _areAllFieldsFilled() {
    final nameInput = _usernameController.text.trim();
    return nameInput.isNotEmpty &&
        selectedLanguage != null &&
        selectedCountry != null &&
        selectedProfilePhoto != null;
  }

  Future<void> _handleGuestSignup() async {
    if (!_areAllFieldsFilled()) {
      if (mounted) setState(() => _showFieldErrors = true);
      return;
    }
    setState(() => _showFieldErrors = false);

    final nameInput = _usernameController.text.trim();
    final username = nameInput;

    setState(() => _isSubmitting = true);

    try {
      // Save language to shared preferences if changed
      final languageCode = selectedLanguage != null
          ? AppLocalizations.languageCodeFromDisplayName(selectedLanguage!)
          : 'en';
      if (selectedLanguage != null) {
        await LocalStorageUtils.saveLanguage(languageCode);
        AppLocalizations.setLanguage(languageCode);
      }

      final result = await _userRepository.updateProfile(
        name: username,
        avatar: selectedProfilePhoto,
        language: languageCode,
        country: selectedCountry,
      );

      result.fold(
        (failure) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message)),
          );
        },
        (authResponse) {
          if (!mounted) return;
          // Pop with a flag to trigger rebuild
          context.pushReplacement(Routes.homeScreen);
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.error}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildGradientDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required Widget prefixIcon,
    required ValueChanged<String?> onChanged,
    bool isTablet = false,
  }) {
    final GlobalKey tapKey = GlobalKey();
    return Builder(
      builder: (context) {
        return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.r),
            gradient: const LinearGradient(
              colors: [
                Color.fromRGBO(255, 255, 255, 1),
                Color.fromRGBO(9, 189, 255, 1)
              ],
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: tapKey,
              borderRadius: BorderRadius.circular(13.r),
              onTap: () async {
                if (isTablet) {
                  await _showLanguageBottomSheet();
                  return;
                }
                final box =
                    tapKey.currentContext!.findRenderObject() as RenderBox;
                final Offset pos = box.localToGlobal(Offset.zero);
                final Size size = box.size;
                const double gap = -2.0;
                final selected = await showMenu<String>(
                  context: context,
                  position: RelativeRect.fromLTRB(
                      pos.dx,
                      pos.dy + size.height + gap,
                      pos.dx + size.width,
                      pos.dy + size.height + gap),
                  color: Colors.transparent,
                  constraints: BoxConstraints(
                    minWidth: size.width,
                    maxWidth: size.width,
                  ),
                  items: [
                    PopupMenuItem<String>(
                      enabled: false,
                      padding: EdgeInsets.zero,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.r),
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromRGBO(255, 255, 255, 1),
                              Color.fromRGBO(9, 189, 255, 1)
                            ],
                          ),
                        ),
                        padding: EdgeInsets.all(2.w),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.r),
                            color: Colors.black,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: items.asMap().entries.map((entry) {
                              final index = entry.key;
                              final e = entry.value;
                              return Container(
                                decoration: BoxDecoration(
                                  border: index < items.length - 1
                                      ? const Border(
                                          bottom: BorderSide(
                                              color: Color.fromRGBO(
                                                  255, 255, 255, 0.2),
                                              width: 3))
                                      : null,
                                ),
                                child: InkWell(
                                  onTap: () => Navigator.pop(context, e),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 12.h,
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          e,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
                if (selected != null) onChanged(selected);
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13.r),
                  color: Colors.black,
                ),
                child: Row(
                  children: [
                    prefixIcon,
                    SizedBox(width: 8.w),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          value ?? hint,
                          style: TextStyle(
                            color: value == null
                                ? const Color.fromRGBO(255, 255, 255, 0.52)
                                : Colors.white,
                            fontSize: 18.sp,
                          ),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 35.sp,
                      color: const Color.fromRGBO(9, 189, 255, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSecondPage() {
    const int coinReward = 1000;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Full screen video
        Center(
          child:
              _videoController != null && _videoController!.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    )
                  : const CircularProgressIndicator(
                      color: Colors.white,
                    ),
        ),
        // Overlay content
        Positioned.fill(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Column(
                children: [
                  const CoinContainer(coins: coinReward),
                  const Spacer(),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final count = (coinReward * _controller.value)
                          .round()
                          .clamp(0, coinReward);
                      return TextWidget(
                        text: "+ $count Coins",
                        fontSize: 25.sp,
                        color: AppColors.whiteColor,
                        fontWeight: FontWeight.bold,
                      );
                    },
                  ),
                  const Spacer(),
                  // Skip button at bottom
                  TextButton(
                    onPressed: () => context.go(Routes.homeScreen),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("${AppLocalizations.skip} ",
                            style: TextStyle(
                                color: Colors.white70, fontSize: 14.sp)),
                        Icon(Icons.arrow_forward_ios,
                            size: 16.sp, color: Colors.white70),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Figma-style avatar selection bottom sheet: Avatars tab + Choose photos tab, grid layout.
class _TabletAvatarSelectionSheet extends StatefulWidget {
  final List<String> avatarsURLs;
  final int selectedAvatarIndex;
  final String? selectedProfilePhoto;
  final ValueChanged<int> onAvatarSelected;
  final VoidCallback onChoosePhoto;
  final VoidCallback onBack;

  const _TabletAvatarSelectionSheet({
    required this.avatarsURLs,
    required this.selectedAvatarIndex,
    required this.selectedProfilePhoto,
    required this.onAvatarSelected,
    required this.onChoosePhoto,
    required this.onBack,
  });

  @override
  State<_TabletAvatarSelectionSheet> createState() => _TabletAvatarSelectionSheetState();
}

class _TabletAvatarSelectionSheetState extends State<_TabletAvatarSelectionSheet> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5E5),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 12.h),
          // Back text aligned to top-right (matches guest_signup)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            child: Row(
              children: [
                const Spacer(),
                GestureDetector(
                  onTap: widget.onBack,
                  child: Text(
                    'Back',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          // Tabs row (Avatars / Choose photos) centered under back
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tabIndex = 0),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: _tabIndex == 0 ? Colors.black : Colors.transparent,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: Text(
                          'Avatars',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _tabIndex == 0 ? Colors.white : Colors.black87,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tabIndex = 1),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: _tabIndex == 1 ? Colors.black : Colors.transparent,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: Text(
                          AppLocalizations.choosePhotos,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _tabIndex == 1 ? Colors.white : Colors.black87,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          // Divider under tabs
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            height: 1.h,
            color: Colors.black26,
          ),
          SizedBox(height: 16.h),
          // Content area
          Expanded(
            child: _tabIndex == 0
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12.h,
                        crossAxisSpacing: 12.w,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: widget.avatarsURLs.length,
                      itemBuilder: (context, index) {
                        final isSelected = index == widget.selectedAvatarIndex;
                        return GestureDetector(
                          onTap: () => widget.onAvatarSelected(index),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: isSelected
                                  ? Border.all(
                                      color: const Color(0xFF09BDFF),
                                      width: 3,
                                    )
                                  : null,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.r),
                              child: Padding(
                                padding: EdgeInsets.all(8.w),
                                child: Image.asset(
                                  widget.avatarsURLs[index],
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          size: 48.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          AppLocalizations.chooseFromGallery,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        TextButton(
                          onPressed: widget.onChoosePhoto,
                          child: Text(
                            AppLocalizations.openGallery,
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
