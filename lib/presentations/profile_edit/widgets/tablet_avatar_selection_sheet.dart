import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class TabletAvatarSelectionSheet extends StatefulWidget {
  final List<String> avatarsURLs;
  final int selectedAvatarIndex;
  final String? selectedProfilePhoto;
  final ValueChanged<int> onAvatarSelected;

  const TabletAvatarSelectionSheet({
    super.key,
    required this.avatarsURLs,
    required this.selectedAvatarIndex,
    required this.selectedProfilePhoto,
    required this.onAvatarSelected,
  });

  @override
  State<TabletAvatarSelectionSheet> createState() => _TabletAvatarSelectionSheetState();
}

class _TabletAvatarSelectionSheetState extends State<TabletAvatarSelectionSheet> {
  final int _itemsPerPage = 6;
  int _currentPage = 0;

  int get _totalPages => (widget.avatarsURLs.length / _itemsPerPage).ceil();

  List<String> get _currentAvatars {
    int start = _currentPage * _itemsPerPage;
    int end = start + _itemsPerPage;
    if (end > widget.avatarsURLs.length) end = widget.avatarsURLs.length;
    return widget.avatarsURLs.sublist(start, end);
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: isTablet ? MediaQuery.of(context).size.width * 0.15 : 20.w),
      child: Container(
        width: isTablet ? MediaQuery.of(context).size.width * 0.7 : double.infinity,
        height: isTablet ? MediaQuery.of(context).size.height * 0.7 : MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9), // Light grey background like reference
          borderRadius: BorderRadius.circular(20.r),
        ),
      child: Column(
        children: [
          SizedBox(height: 12.h),

          // Exit text with exit icon aligned to top-right
          Padding(
            padding: EdgeInsets.only(top: 16.h, right: 16.w),
            child: Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.close,
                  color: Colors.black87,
                  size: isTablet ? 28.sp : 24.sp,
                ),
              ),
            ),
          ),

          // Title Container "Choose Avatar for best start"
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1B1B), // Dark background
                borderRadius: BorderRadius.circular(15.r),
              ),
              alignment: Alignment.center,
              child: Text(
                'Choose Avatar for best start',
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: isTablet ? 18.sp : 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // Avatar Grid
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: GridView.builder(
                physics: const BouncingScrollPhysics(), // Scrollable properly
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: isTablet ? 20.h : 16.h,
                  crossAxisSpacing: isTablet ? 20.w : 16.w,
                  childAspectRatio: isTablet ? 1.25 : 1.35, // Adjusted to make cards taller and avatars larger
                ),
                itemCount: _currentAvatars.length,
                itemBuilder: (context, index) {
                  int actualIndex = _currentPage * _itemsPerPage + index;
                  final isSelected = actualIndex == widget.selectedAvatarIndex;

                  return GestureDetector(
                    onTap: () => widget.onAvatarSelected(actualIndex),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC4C4C4), // Grey card background
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.transparent, // Highlighting selected slightly
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Padding(
                          padding: EdgeInsets.all(isTablet ? 4.w : 6.w),
                          child: _currentAvatars[index].isNotEmpty
                              ? Image.asset(
                                  _currentAvatars[index],
                                  fit: BoxFit.contain,
                                )
                              : const SizedBox(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Pagination Controls
          Padding(
            padding: EdgeInsets.only(bottom: 24.h, top: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left Arrow
                GestureDetector(
                  onTap: _currentPage > 0 ? _prevPage : null,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    child: Opacity(
                      opacity: _currentPage > 0 ? 1.0 : 0.3,
                      child: Icon(
                        Icons.chevron_left,
                        color: Colors.black87,
                        size: isTablet ? 28.sp : 24.sp,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(width: 8.w),
                
                // Current Page Number
                Text(
                  '${_currentPage + 1}',
                  style: GoogleFonts.lato(
                    fontSize: isTablet ? 18.sp : 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                SizedBox(width: 8.w),

                // Right Arrow
                GestureDetector(
                  onTap: _currentPage < _totalPages - 1 ? _nextPage : null,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    child: Opacity(
                      opacity: _currentPage < _totalPages - 1 ? 1.0 : 0.3,
                      child: Icon(
                        Icons.chevron_right,
                        color: Colors.black87,
                        size: isTablet ? 28.sp : 24.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}

