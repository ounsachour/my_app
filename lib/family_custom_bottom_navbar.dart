// family_custom_bottom_navbar.dart (مع نبض فقط للتنبيهات - إشعارات ثابتة)

import 'package:flutter/material.dart';
import 'family_home_page.dart';
import 'family_profile.dart';
import 'family_alert.dart';
import 'family_notification.dart';
import 'badge_service.dart';

class FamilyCustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final String firstName;
  final int patientId;
  final int? familyUserId;

  const FamilyCustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.firstName,
    required this.patientId,
    this.familyUserId,
  });

  @override
  State<FamilyCustomBottomNavBar> createState() => _FamilyCustomBottomNavBarState();
}

class _FamilyCustomBottomNavBarState extends State<FamilyCustomBottomNavBar>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    BadgeService.refreshBadgeCounts(widget.patientId).then((_) {
      if (mounted) setState(() {});
    }).catchError((error) {
      debugPrint('Error refreshing badge counts: $error');
    });
    BadgeService.checkVitalsAndUpdateAlerts().then((_) {
      BadgeService.refreshBadgeCounts(widget.patientId);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF005B5B),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, icon: Icons.home_rounded, index: 0),
          // التنبيهات - مع نبض
          _buildNavItem(
            context, 
            icon: Icons.warning_rounded, 
            index: 1, 
            badgeCount: BadgeService.alertCount,
            disableAnimation: false,  // ✅ نبض
          ),
          // الإشعارات - بدون نبض (ثابتة)
          _buildNavItem(
            context, 
            icon: Icons.notifications_rounded, 
            index: 2, 
            badgeCount: BadgeService.notificationCount,
            disableAnimation: true,   // ✅ ثابتة
          ),
          _buildNavItem(context, icon: Icons.person_rounded, index: 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required int index,
    int badgeCount = 0,
    bool disableAnimation = false,  // ✅ معامل جديد
  }) {
    final bool isActive = widget.currentIndex == index;

    return GestureDetector(
      onTap: () {
        if (index == widget.currentIndex) return;

        Widget page;
        switch (index) {
          case 0:
            page = FamilyHomePage(
              firstName: widget.firstName,
              patientId: widget.patientId,
              familyUserId: widget.familyUserId,
            );
            break;
          case 1:
            page = FamilyAlertPage(
              firstName: widget.firstName,
              patientId: widget.patientId,
              familyUserId: widget.familyUserId,
            );
            break;
          case 2:
            page = FamilyNotificationPage(
              firstName: widget.firstName,
              patientId: widget.patientId,
              familyUserId: widget.familyUserId,
            );
            break;
          case 3:
            page = FamilyProfilePage(
              firstName: widget.firstName,
              patientId: widget.patientId,
              familyUserId: widget.familyUserId,
            );
            break;
          default:
            page = FamilyHomePage(
              firstName: widget.firstName,
              patientId: widget.patientId,
              familyUserId: widget.familyUserId,
            );
        }

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: isActive ? 60 : 50,
            height: isActive ? 60 : 50,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.transparent,
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? [BoxShadow(color: Colors.white.withOpacity(0.35), blurRadius: 15, spreadRadius: 2)]
                  : [],
            ),
            child: Icon(
              icon,
              size: isActive ? 30 : 26,
              color: isActive ? const Color(0xFF005B5B) : Colors.white70,
            ),
          ),
          // العلامة الحمراء
          if (badgeCount > 0)
            Positioned(
              right: 2,
              top: 2,
              child: disableAnimation
                  ? _buildStaticBadge(badgeCount)        // ✅ ثابتة (للإشعارات)
                  : _buildAnimatedBadge(badgeCount),     // ✅ متحركة (للتنبيهات)
            ),
        ],
      ),
    );
  }

  // ✅ دالة للعلامة الثابتة (بدون نبض)
  Widget _buildStaticBadge(int badgeCount) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      constraints: const BoxConstraints(
        minWidth: 18,
        minHeight: 18,
      ),
      child: Text(
        badgeCount > 99 ? '99+' : badgeCount.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ✅ دالة للعلامة المتحركة (مع نبض)
  Widget _buildAnimatedBadge(int badgeCount) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.6 * (1 - (_pulseAnimation.value - 0.7).abs())),
                  blurRadius: 12 * _pulseAnimation.value,
                  spreadRadius: 2 * (_pulseAnimation.value - 0.7).abs(),
                ),
              ],
            ),
            constraints: const BoxConstraints(
              minWidth: 18,
              minHeight: 18,
            ),
            child: Text(
              badgeCount > 99 ? '99+' : badgeCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}