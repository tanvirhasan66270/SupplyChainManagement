import 'package:flutter/material.dart';

/// Mirrors the Bootstrap and SCM Enterprise design system
class AppTheme
{
  AppTheme._();

  static const Color primary = Color(0xFF0D6EFD); // Bootstrap primary blue
  static const Color success = Color(0xFF198754); // Success green
  static const Color danger = Color(0xFFDC3545);  // Danger/Error red
  static const Color warning = Color(0xFFFFC107); // Warning yellow
  static const Color info = Color(0xFF0DCAF0);    // Info cyan/blue
  static const Color secondary = Color(0xFF6C757D); // Secondary grey
  static const Color dark = Color(0xFF212529);    // Dark text/bg
  static const Color light = Color(0xFFF8F9FA);   // Light background

  // ── নতুন ও আধুনিক এন্টারপ্রাইজ কালার যোগ করা হলো ──
  static const Color teal = Color(0xFF20C997);      // Teal color for line items/reports
  static const Color tealDark = Color(0xFF0F766E);  // Dark Teal
  static const Color tealPrimary = Color(0xFF0D9488); // Primary Teal
  static const Color tealLight = Color(0xFF14B8A6); // Light Teal
  static const Color tealBackground = Color(0xFFCCFBF1); // Background Teal
  static const Color purple = Color(0xFF6F42C1);    // Purple for messages/special badges
  static const Color orange = Color(0xFFFD7E14);    // Orange for LCs or alerts
  static const Color pink = Color(0xFFD63384);      // Pink for archives/special tags
  static const Color indigo = Color(0xFF6610F2);    // Indigo for secondary accents

  // UI ব্যাকগ্রাউন্ড ও বর্ডার কালার
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF6C757D);
  static const Color borderGrey = Color(0xFFCED4DA);
  static const Color cardShadow = Color(0x1A000000);

  // ── Core Palette & Custom Shading ───────────────────────
  static const Color primaryDark = Color(0xFF1D4ED8);  // Dark Blue
  static const Color primaryLight = Color(0xFF3B82F6); // Light Blue
  static const Color blue = Color(0xFF2563EB);
  static const Color blueLight = Color(0xFFE0E7FF);
  static const Color indigoDark = Color(0xFF4338CA);
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color textMuted = Color(0xFF64748B);



  // ── Status & Semantic Colors ───────────────────────────
  static const Color successLight = Color(0xFFDCFCE7);

  static const Color infoLight = Color(0xFFE0F2FE);

  static const Color warningLight = Color(0xFFFEF3C7);

  static const Color dangerLight = Color(0xFFFEE2E2);

  static const Color purpleLight = Color(0xFFF3E8FF);


  static ThemeData get light_ => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
    ),
    scaffoldBackgroundColor: light,
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderGrey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  static Color statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'DELIVERED':
      case 'APPROVED':
      case 'RECEIVED':
        return success;
      case 'CANCELLED':
      case 'REJECTED':
      case 'RETURNED':
      case 'FAILED_OR_REJECTED':
        return danger;
      case 'OUT_FOR_DELIVERY':
      case 'SHIPPED':
      case 'OPEN':
      case 'AMENDED':
        return info;
      case 'PROCESSING':
      case 'CONFIRMED':
      case 'PENDING_VERIFICATION':
      case 'PENDING':
        return warning;
      case 'REFUNDED':
        return purple;
      case 'DRAFT':
        return secondary;
      default:
        return secondary;
    }
  }


  // ── Dynamic Status Color Helper ────────────────────────
  static Color statusSupplierColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
      case 'RECEIVED':
      case 'COMPLETE':
        return success;
      case 'ISSUED':
      case 'PARTIALLY_RECEIVED':
      case 'PROCESSING':
      case 'SHIPPED':
        return info;
      case 'PENDING':
      case 'DRAFT':
      case 'OPENED':
        return warning;
      case 'CANCELLED':
      case 'REJECTED':
        return danger;
      default:
        return secondary;
    }
  }

  static Color statusLightColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
      case 'RECEIVED':
      case 'COMPLETE':
        return successLight;
      case 'ISSUED':
      case 'PARTIALLY_RECEIVED':
      case 'PROCESSING':
      case 'SHIPPED':
        return infoLight;
      case 'PENDING':
      case 'DRAFT':
      case 'OPENED':
        return warningLight;
      case 'CANCELLED':
      case 'REJECTED':
        return dangerLight;
      default:
        return borderGrey;
    }
  }

  static Color procourmentStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return success;
      case 'PENDING':
        return warning;
      case 'REJECTED':
      case 'CANCELLED':
        return danger;
      case 'PROCESSING':
      case 'SHIPPED':
        return info;
      default:
        return secondary;
    }
  }
}