import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inkbattle_frontend/utils/lang.dart';
import 'package:inkbattle_frontend/widgets/text_widget.dart';

/// Category multi-select bottom sheet matching country picker (SelectionBottomSheet) UI.
/// Includes "Select All" and "Done" buttons aligned in the header.
class RoomCategoryPickerSheet extends StatefulWidget {
  final String title;
  final List<String> items;
  final List<String> selectedItems;

  const RoomCategoryPickerSheet({
    super.key,
    required this.title,
    required this.items,
    required this.selectedItems,
  });

  @override
  State<RoomCategoryPickerSheet> createState() => _RoomCategoryPickerSheetState();
}

class _RoomCategoryPickerSheetState extends State<RoomCategoryPickerSheet> {
  late List<String> _filteredItems;
  late List<String> _tempSelectedItems;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = List.from(widget.items);
    _tempSelectedItems = List.from(widget.selectedItems);
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
      _filteredItems = widget.items
          .where((item) => item.toLowerCase().contains(query))
          .toList();
    });
  }

  void _toggleItem(String item) {
    setState(() {
      if (_tempSelectedItems.contains(item)) {
        _tempSelectedItems.remove(item);
      } else {
        _tempSelectedItems.add(item);
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (_tempSelectedItems.length == widget.items.length) {
        _tempSelectedItems.clear();
      } else {
        _tempSelectedItems = List.from(widget.items);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final allSelected = _tempSelectedItems.length == widget.items.length;

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
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 15.h),

          // Header: Category (left) | Select All | Done (right) — single row, vertically centered
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lato(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              TextButton(
                onPressed: _selectAll,
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  allSelected
                      ? AppLocalizations.deselectAll
                      : AppLocalizations.selectAll,
                  style: GoogleFonts.lato(
                    color: const Color.fromRGBO(9, 189, 255, 1),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              TextButton(
                onPressed: () => Navigator.pop(context, _tempSelectedItems),
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  AppLocalizations.done,
                  style: GoogleFonts.lato(
                    color: const Color.fromRGBO(9, 189, 255, 1),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),

          // Search Field (same as SelectionBottomSheet / country UI)
          TextField(
            controller: _searchController,
            style: GoogleFonts.lato(color: Colors.white, fontSize: 16.sp),
            decoration: InputDecoration(
              labelText: AppLocalizations.search,
              labelStyle: GoogleFonts.lato(
                color: Colors.white70,
                fontSize: 14.sp,
              ),
              hintText: AppLocalizations.startTypingToSearch,
              hintStyle: GoogleFonts.lato(
                color: const Color.fromRGBO(255, 255, 255, 0.52),
                fontSize: 14.sp,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Color.fromRGBO(9, 189, 255, 1),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              filled: true,
              fillColor: Colors.black,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: const BorderSide(
                  color: Color.fromRGBO(255, 255, 255, 0.2),
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: const BorderSide(
                  color: Color.fromRGBO(255, 255, 255, 0.2),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: const BorderSide(
                  color: Color.fromRGBO(9, 189, 255, 1),
                  width: 1.5,
                ),
              ),
            ),
          ),
          SizedBox(height: 15.h),

          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
                    child: TextWidget(
                      text: AppLocalizations.noMatchesFound,
                      color: Colors.grey,
                      fontSize: 14.sp,
                    ),
                  )
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _filteredItems.length,
                    separatorBuilder: (c, i) => Divider(
                      color: Colors.white.withOpacity(0.1),
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      final isSelected = _tempSelectedItems.contains(item);
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _toggleItem(item),
                          borderRadius: BorderRadius.circular(10.r),
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 4.h),
                            padding: EdgeInsets.symmetric(
                              vertical: 13.h,
                              horizontal: 12.w,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color.fromRGBO(9, 189, 255, 0.1)
                                  : null,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item,
                                    style: GoogleFonts.lato(
                                      color: isSelected
                                          ? const Color.fromRGBO(
                                              9, 189, 255, 1)
                                          : Colors.white,
                                      fontSize: 16.sp,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: const Color.fromRGBO(9, 189, 255, 1),
                                    size: 26.sp,
                                  ),
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
