import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'selection_bottom_sheet.dart';

/// Country picker for Random Match (room preferences) only.
/// Matches _buildGradientDropdown: same gradient border, height, font, icon size.
class RoomCountryPicker extends StatelessWidget {
  final String? selectedCountryCode; // ISO-2 e.g. "US", "IN"
  final ValueChanged<String?> onCountrySelected;
  final String hintText;

  const RoomCountryPicker({
    super.key,
    this.selectedCountryCode,
    required this.onCountrySelected,
    this.hintText = 'Country',
  });

  static String? _getCountryName(String? code) {
    if (code == null || code.isEmpty) return null;
    try {
      return Country.parse(code).name;
    } catch (_) {
      return null;
    }
  }

  static String _getCountryFlag(String? code) {
    if (code == null || code.isEmpty) return '🏳️';
    try {
      return Country.parse(code).flagEmoji;
    } catch (_) {
      return '🏳️';
    }
  }

  @override
  Widget build(BuildContext context) {
    final code = selectedCountryCode;
    final name = _getCountryName(code);
    final displayText = name != null ? '${_getCountryFlag(code)} $name' : null;
    final isFilled = displayText != null && displayText.isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.r),
        gradient: const LinearGradient(
          colors: [
            Color.fromRGBO(255, 255, 255, 0.8),
            Color.fromRGBO(9, 189, 255, 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(1.2),
      child: Container(
        height: 58.h,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(13.r),
            onTap: () => _showCountryPicker(context),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.public,
                    color: const Color(0xFF09BDFF),
                    size: 24.sp,
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: Text(
                      displayText ?? hintText,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: GoogleFonts.lato(
                        color: isFilled ? Colors.white : Colors.white54,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 24.sp,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showCountryPicker(BuildContext context) async {
    final countries = CountryService().getAll();
    final countryMap = <String, Country>{
      for (var c in countries) '${c.flagEmoji} ${c.name}': c
    };
    final items = countryMap.keys.toList()..sort((a, b) => a.compareTo(b));

    String? currentSelection;
    if (selectedCountryCode != null) {
      try {
        final c = Country.parse(selectedCountryCode!);
        currentSelection = '${c.flagEmoji} ${c.name}';
      } catch (_) {}
    }

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SelectionBottomSheet(
        title: hintText,
        items: items,
        selectedItem: currentSelection,
      ),
    );

    if (result != null) {
      final country = countryMap[result];
      if (country != null) {
        onCountrySelected(country.countryCode);
      }
    }
  }
}
