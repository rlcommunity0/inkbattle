import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:country_picker/country_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:inkbattle_frontend/constants/app_images.dart';
import 'package:inkbattle_frontend/widgets/text_widget.dart';

import 'package:inkbattle_frontend/widgets/country_picker_widget.dart';
import 'package:inkbattle_frontend/utils/lang.dart';

/// Profile-edit–specific country field with aligned UI and custom dropdown icon.
/// Uses [AppImages.dropdownIcon] for the dropdown indicator and matches
/// profile_edit_screen styling (dark background, bright blue rounded border).
class ProfileCountryField extends StatelessWidget {
  final String? selectedCountryCode;
  final ValueChanged<String?> onCountrySelected;
  final String hintText;
  final bool isTablet;

  const ProfileCountryField({
    super.key,
    this.selectedCountryCode,
    required this.onCountrySelected,
    this.hintText = 'Country',
    this.isTablet = false,
  });

  Future<void> _showCountryPicker(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final countries = CountryService().getAll();
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProfileCountrySelectionBottomSheet(
        title: hintText,
        countries: countries,
        selectedCountryCode: selectedCountryCode,
      ),
    );
    if (result != null) {
      onCountrySelected(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final countryCode = selectedCountryCode;
    final countryName = countryCode != null
        ? CountryPickerWidget.getCountryName(countryCode)
        : null;
    final displayText = countryName ?? hintText;
    final isFilled = countryCode != null && countryCode.isNotEmpty;

    return Container(
      height: isTablet ? 60.h : 50.h,
      alignment: Alignment.center,
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.r),
        gradient: const LinearGradient(
          colors: [
            Color.fromRGBO(255, 255, 255, 1),
            Color.fromRGBO(9, 189, 255, 1),
          ],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(13.r),
          onTap: () => _showCountryPicker(context),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13.r),
              color: Colors.black,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (!isFilled) ...[
                  Container(
                    width: isTablet ? 52.w : 48.w,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.public,
                      color: const Color.fromRGBO(255, 255, 255, 0.52),
                      size: isTablet ? 24.sp : 20.sp,
                    ),
                  ),
                ],
                if (isFilled) ...[
                  Container(
                    width: isTablet ? 52.w : 48.w,
                    alignment: Alignment.center,
                    child: Text(
                      CountryPickerWidget.getCountryFlag(countryCode),
                      style: TextStyle(fontSize: isTablet ? 24.sp : 20.sp),
                    ),
                  ),
                ],
                Expanded(
                  child: Text(
                    displayText,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: isFilled ? Colors.white : const Color.fromRGBO(255, 255, 255, 0.52),
                      fontSize: isTablet ? 20.sp : 18.sp,
                    ),
                  ),
                ),
                Container(
                  width: isTablet ? 52.w : 48.w,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: isTablet ? 24.sp : 20.sp,
                    color: const Color(0xFF09BDFF),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Country selection bottom sheet for profile edit; returns country code.
class _ProfileCountrySelectionBottomSheet extends StatefulWidget {
  final String title;
  final List<Country> countries;
  final String? selectedCountryCode;

  const _ProfileCountrySelectionBottomSheet({
    required this.title,
    required this.countries,
    this.selectedCountryCode,
  });

  @override
  State<_ProfileCountrySelectionBottomSheet> createState() =>
      _ProfileCountrySelectionBottomSheetState();
}

class _ProfileCountrySelectionBottomSheetState
    extends State<_ProfileCountrySelectionBottomSheet> {
  late List<Country> _filteredCountries;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredCountries = List.from(widget.countries);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCountries = widget.countries
          .where((c) => c.name.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20.h,
        left: 15.w,
        right: 15.w,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 15.h),
          TextWidget(
            text: widget.title,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          SizedBox(height: 15.h),
          TextField(
            controller: _searchController,
            style: GoogleFonts.lato(color: Colors.white, fontSize: 16.sp),
            decoration: InputDecoration(
              labelText: AppLocalizations.search,
              labelStyle:
                  GoogleFonts.lato(color: Colors.white70, fontSize: 14.sp),
              hintText: AppLocalizations.searchCountry,
              hintStyle: GoogleFonts.lato(
                  color: const Color.fromRGBO(255, 255, 255, 0.52),
                  fontSize: 14.sp),
              prefixIcon: const Icon(Icons.search,
                  color: Color.fromRGBO(9, 189, 255, 1)),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              filled: true,
              fillColor: Colors.black,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.r),
                  borderSide: const BorderSide(
                      color: Color.fromRGBO(255, 255, 255, 0.2), width: 1.5)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.r),
                  borderSide: const BorderSide(
                      color: Color.fromRGBO(255, 255, 255, 0.2), width: 1.5)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.r),
                  borderSide: const BorderSide(
                      color: Color.fromRGBO(9, 189, 255, 1), width: 1.5)),
            ),
          ),
          SizedBox(height: 15.h),
          Expanded(
            child: _filteredCountries.isEmpty
                ? Center(
                    child: TextWidget(
                        text: AppLocalizations.noMatchesFound,
                        color: Colors.grey,
                        fontSize: 14.sp))
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _filteredCountries.length,
                    separatorBuilder: (_, __) => Divider(
                        color: Colors.white.withValues(alpha: 0.1), height: 1),
                    itemBuilder: (context, index) {
                      final country = _filteredCountries[index];
                      final isSelected =
                          country.countryCode == widget.selectedCountryCode;
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () =>
                              Navigator.pop(context, country.countryCode),
                          borderRadius: BorderRadius.circular(10.r),
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 4.h),
                            padding: EdgeInsets.symmetric(
                                vertical: 13.h, horizontal: 12.w),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color.fromRGBO(9, 189, 255, 0.1)
                                  : null,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              children: [
                                Text(country.flagEmoji,
                                    style: TextStyle(fontSize: 18.sp)),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    country.name,
                                    style: GoogleFonts.lato(
                                      color: isSelected
                                          ? const Color.fromRGBO(9, 189, 255, 1)
                                          : Colors.white,
                                      fontSize: 16.sp,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check_circle,
                                      color: const Color.fromRGBO(9, 189, 255, 1),
                                      size: 26.sp),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
