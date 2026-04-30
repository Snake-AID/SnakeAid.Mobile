import 'package:flutter/material.dart';
import '../models/detailed_incident_response.dart';

/// Reusable badge components for displaying snake risk information
/// Used across member and rescuer emergency screens
class SnakeRiskBadges {
  /// Build risk level badge with appropriate color (1-10 scale)
  static Widget buildRiskLevelBadge(int riskLevel, {bool compact = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: getRiskColor(riskLevel),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            riskLevel >= 5 ? Icons.warning_rounded : Icons.speed,
            size: compact ? 12 : 14,
            color: Colors.white,
          ),
          SizedBox(width: compact ? 4 : 6),
          Text(
            'Mức $riskLevel/10',
            style: TextStyle(
              fontSize: compact ? 11 : 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Build venom type badge with appropriate color
  static Widget buildVenomTypeBadge(
    VenomType venomType, {
    bool compact = false,
  }) {
    if (venomType == VenomType.none) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 10,
          vertical: compact ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF43A047),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: compact ? 11 : 12,
              color: Colors.white,
            ),
            SizedBox(width: compact ? 4 : 6),
            Text(
              'Không độc',
              style: TextStyle(
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.orange[700],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.water_drop, size: compact ? 11 : 12, color: Colors.white),
          SizedBox(width: compact ? 4 : 6),
          Text(
            venomType.displayText,
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Build venomous status badge (Độc/Không độc) - simple version
  static Widget buildVenomousStatusBadge(
    bool isVenomous, {
    bool compact = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: isVenomous ? const Color(0xFFE53935) : const Color(0xFF43A047),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVenomous ? Icons.warning : Icons.check,
            size: compact ? 11 : 12,
            color: Colors.white,
          ),
          SizedBox(width: compact ? 4 : 6),
          Text(
            isVenomous ? 'Độc' : 'Không độc',
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // RISK COLOR HELPERS
  // ═══════════════════════════════════════════════════════════════

  /// Get risk color based on risk level (1-10 scale)
  static Color getRiskColor(int riskLevel) {
    if (riskLevel >= 8) {
      return const Color(0xFFB71C1C); // Đỏ đậm - Cực kỳ nguy hiểm
    }
    if (riskLevel >= 6) {
      return const Color(0xFFE53935); // Đỏ - Rất nguy hiểm
    }
    if (riskLevel >= 5) {
      return const Color(0xFFFF6F00); // Cam đậm - Nguy hiểm
    }
    if (riskLevel > 3) {
      return const Color(0xFFFFA726); // Cam nhạt - Trung bình
    }
    return const Color(0xFF43A047); // Xanh lá - Thấp
  }

  /// Get risk gradient colors based on risk level
  static List<Color> getRiskGradient(int riskLevel) {
    if (riskLevel >= 8) {
      return [const Color(0xFFFFEBEE), const Color(0xFFEF9A9A)];
    }
    if (riskLevel >= 6) {
      return [const Color(0xFFFFEBEE), const Color(0xFFFFCDD2)];
    }
    if (riskLevel >= 5) {
      return [const Color(0xFFFFF3E0), const Color(0xFFFFCC80)];
    }
    if (riskLevel > 3) {
      return [const Color(0xFFFFF8E1), const Color(0xFFFFE082)];
    }
    return [
      const Color(0xFFE8F5E9),
      const Color(0xFFC8E6C9),
    ]; // Xanh lá cho an toàn
  }

  /// Get risk level text description (Vietnamese)
  static String getRiskLevelText(int riskLevel) {
    if (riskLevel >= 8) return 'Cực kỳ nguy hiểm';
    if (riskLevel >= 6) return 'Rất nguy hiểm';
    if (riskLevel >= 5) return 'Nguy hiểm';
    if (riskLevel > 3) return 'Trung bình';
    return 'Thấp';
  }

  /// Get risk icon based on risk level
  static IconData getRiskIcon(int riskLevel) {
    if (riskLevel >= 5) return Icons.dangerous;
    return Icons.check_circle;
  }
}
