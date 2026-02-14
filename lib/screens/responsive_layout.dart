// import 'package:flutter/material.dart';

// /// 🎯 RESPONSIVE LAYOUT TEMPLATE
// /// 
// /// Template ini menggunakan 5 TEKNIK WAJIB:
// /// 1. MediaQuery - Device dimensions
// /// 2. LayoutBuilder - Constraint-based layout
// /// 3. SafeArea - Avoid system UI
// /// 4. SingleChildScrollView - Prevent overflow
// /// 5. Expanded/Flexible - Dynamic sizing
// ///
// /// USAGE:
// /// ```dart
// /// class MyScreen extends StatelessWidget {
// ///   @override
// ///   Widget build(BuildContext context) {
// ///     return ResponsiveLayout(
// ///       child: // Your content here
// ///     );
// ///   }
// /// }
// /// ```

// class ResponsiveLayout extends StatelessWidget {
//   final Widget child;
//   final Color? backgroundColor;
//   final bool enableRefresh;
//   final Future<void> Function()? onRefresh;
//   final EdgeInsets? padding;

//   const ResponsiveLayout({
//     super.key,
//     required this.child,
//     this.backgroundColor,
//     this.enableRefresh = false,
//     this.onRefresh,
//     this.padding,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // ✅ 1. MediaQuery - Get device info
//     final mediaQuery = MediaQuery.of(context);
//     final screenSize = mediaQuery.size;
//     final screenHeight = screenSize.height;
//     final screenWidth = screenSize.width;
    
//     // Device type detection
//     final isSmallDevice = screenHeight < 700;
//     final isMediumDevice = screenHeight >= 700 && screenHeight < 900;
//     final isLargeDevice = screenHeight >= 900;
//     final isTablet = screenWidth > 600;
    
//     // Responsive spacing
//     final verticalSpacing = isSmallDevice ? 12.0 : (isMediumDevice ? 16.0 : 20.0);
//     final horizontalPadding = isTablet ? 24.0 : 16.0;
    
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       // ✅ 3. SafeArea - Avoid notch, status bar, gesture bar
//       body: SafeArea(
//         child: enableRefresh && onRefresh != null
//             ? RefreshIndicator(
//                 onRefresh: onRefresh!,
//                 child: _buildScrollableContent(
//                   screenHeight,
//                   verticalSpacing,
//                   horizontalPadding,
//                 ),
//               )
//             : _buildScrollableContent(
//                 screenHeight,
//                 verticalSpacing,
//                 horizontalPadding,
//               ),
//       ),
//     );
//   }

//   Widget _buildScrollableContent(
//     double screenHeight,
//     double verticalSpacing,
//     double horizontalPadding,
//   ) {
//     // ✅ 2. LayoutBuilder - Get available space
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final availableHeight = constraints.maxHeight;
//         final availableWidth = constraints.maxWidth;
        
//         // ✅ 4. SingleChildScrollView - Prevent overflow
//         return SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           child: ConstrainedBox(
//             constraints: BoxConstraints(
//               minHeight: availableHeight, // Full height for pull-to-refresh
//             ),
//             child: Padding(
//               padding: padding ?? EdgeInsets.symmetric(
//                 horizontal: horizontalPadding,
//                 vertical: verticalSpacing,
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Content wrapper
//                   ConstrainedBox(
//                     constraints: BoxConstraints(
//                       maxWidth: availableWidth > 600 ? 600 : availableWidth,
//                     ),
//                     child: child,
//                   ),
                  
//                   // ✅ Bottom padding for BottomNavigationBar
//                   SizedBox(height: screenHeight < 700 ? 80 : 100),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// /// 🎯 RESPONSIVE COLUMN
// /// 
// /// Wrapper untuk Column yang otomatis responsive
// /// dengan Flexible/Expanded untuk children
// class ResponsiveColumn extends StatelessWidget {
//   final List<Widget> children;
//   final MainAxisAlignment mainAxisAlignment;
//   final CrossAxisAlignment crossAxisAlignment;
//   final MainAxisSize mainAxisSize;

//   const ResponsiveColumn({
//     super.key,
//     required this.children,
//     this.mainAxisAlignment = MainAxisAlignment.start,
//     this.crossAxisAlignment = CrossAxisAlignment.center,
//     this.mainAxisSize = MainAxisSize.min,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // ✅ 1. MediaQuery
//     final screenHeight = MediaQuery.of(context).size.height;
//     final isSmallDevice = screenHeight < 700;
    
//     return Column(
//       mainAxisAlignment: mainAxisAlignment,
//       crossAxisAlignment: crossAxisAlignment,
//       mainAxisSize: mainAxisSize,
//       children: children.map((child) {
//         // Auto-wrap dengan responsive spacing
//         return Padding(
//           padding: EdgeInsets.only(
//             bottom: isSmallDevice ? 8.0 : 12.0,
//           ),
//           child: child,
//         );
//       }).toList(),
//     );
//   }
// }

// /// 🎯 RESPONSIVE CARD
// /// 
// /// Card dengan padding & size responsive
// class ResponsiveCard extends StatelessWidget {
//   final Widget child;
//   final Color? color;
//   final double? elevation;
//   final EdgeInsets? padding;

//   const ResponsiveCard({
//     super.key,
//     required this.child,
//     this.color,
//     this.elevation,
//     this.padding,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // ✅ 1. MediaQuery
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isTablet = screenWidth > 600;
    
//     final cardPadding = padding ?? EdgeInsets.all(isTablet ? 20 : 16);
    
//     return Card(
//       color: color,
//       elevation: elevation ?? 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
//       ),
//       child: Padding(
//         padding: cardPadding,
//         child: child,
//       ),
//     );
//   }
// }

// /// 🎯 RESPONSIVE GRID
// /// 
// /// GridView yang otomatis adjust columns berdasarkan screen width
// class ResponsiveGrid extends StatelessWidget {
//   final List<Widget> children;
//   final double childAspectRatio;
//   final double spacing;

//   const ResponsiveGrid({
//     super.key,
//     required this.children,
//     this.childAspectRatio = 1.0,
//     this.spacing = 16.0,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // ✅ 1. MediaQuery
//     final screenWidth = MediaQuery.of(context).size.width;
    
//     // Auto-calculate columns
//     int columns = 2; // Default
//     if (screenWidth > 900) {
//       columns = 4; // Large tablet/desktop
//     } else if (screenWidth > 600) {
//       columns = 3; // Tablet
//     }
    
//     return GridView.count(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisCount: columns,
//       childAspectRatio: childAspectRatio,
//       mainAxisSpacing: spacing,
//       crossAxisSpacing: spacing,
//       children: children,
//     );
//   }
// }

// /// 🎯 RESPONSIVE TEXT
// /// 
// /// Text dengan size responsive
// class ResponsiveText extends StatelessWidget {
//   final String text;
//   final TextStyle? style;
//   final double baseFontSize;
//   final FontWeight? fontWeight;
//   final Color? color;
//   final TextAlign? textAlign;

//   const ResponsiveText(
//     this.text, {
//     super.key,
//     this.style,
//     this.baseFontSize = 14.0,
//     this.fontWeight,
//     this.color,
//     this.textAlign,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // ✅ 1. MediaQuery
//     final screenWidth = MediaQuery.of(context).size.width;
    
//     // Scale factor based on device
//     double scaleFactor = 1.0;
//     if (screenWidth > 600) {
//       scaleFactor = 1.1; // Tablet
//     } else if (screenWidth < 360) {
//       scaleFactor = 0.9; // Very small phone
//     }
    
//     final responsiveFontSize = baseFontSize * scaleFactor;
    
//     return Text(
//       text,
//       textAlign: textAlign,
//       style: style?.copyWith(
//         fontSize: responsiveFontSize,
//         fontWeight: fontWeight,
//         color: color,
//       ) ?? TextStyle(
//         fontSize: responsiveFontSize,
//         fontWeight: fontWeight,
//         color: color,
//       ),
//     );
//   }
// }

// /// 🎯 RESPONSIVE SPACING
// /// 
// /// Helper class for responsive spacing
// class ResponsiveSpacing {
//   final BuildContext context;
  
//   ResponsiveSpacing(this.context);
  
//   // ✅ 1. MediaQuery
//   double get screenHeight => MediaQuery.of(context).size.height;
//   double get screenWidth => MediaQuery.of(context).size.width;
  
//   bool get isSmallDevice => screenHeight < 700;
//   bool get isMediumDevice => screenHeight >= 700 && screenHeight < 900;
//   bool get isLargeDevice => screenHeight >= 900;
//   bool get isTablet => screenWidth > 600;
  
//   // Vertical spacing
//   double get tiny => isSmallDevice ? 4 : 8;
//   double get small => isSmallDevice ? 8 : 12;
//   double get medium => isSmallDevice ? 12 : 16;
//   double get large => isSmallDevice ? 16 : 24;
//   double get extraLarge => isSmallDevice ? 24 : 32;
  
//   // Horizontal spacing
//   double get horizontalPadding => isTablet ? 24 : 16;
  
//   // Bottom padding for BottomNav
//   double get bottomNavPadding => isSmallDevice ? 80 : 100;
  
//   // Card padding
//   EdgeInsets get cardPadding => EdgeInsets.all(isTablet ? 20 : 16);
  
//   // Section padding
//   EdgeInsets get sectionPadding => EdgeInsets.symmetric(
//     horizontal: horizontalPadding,
//     vertical: medium,
//   );
// }

