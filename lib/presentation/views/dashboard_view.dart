import 'package:flutter/material.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/widgets/responsive_layout.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F4),
      body: ResponsiveBuilder(
        builder: (context, screenSize) {
          // Mobile layout - vertical stacking
          if (screenSize == ScreenSize.mobile) {
            return _buildMobileLayout(context, screenSize);
          }

          // Web/Desktop layout - horizontal with sidebar
          return _buildWebLayout(context, screenSize);
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, ScreenSize screenSize) {
    return Column(
      children: [
        // Mobile Header
        _buildMobileHeader(context, screenSize),

        // Mobile Navigation Tabs
        _buildMobileNavigationTabs(context, screenSize),

        // Main Content for Mobile
        Expanded(child: _buildMobileMainContent(context, screenSize)),
      ],
    );
  }

  Widget _buildWebLayout(BuildContext context, ScreenSize screenSize) {
    return Row(
      children: [
        // Left Sidebar
        _buildSidebar(context, screenSize),

        // Main Content Area
        Expanded(child: _buildMainContent(context, screenSize)),
      ],
    );
  }

  Widget _buildMobileHeader(BuildContext context, ScreenSize screenSize) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo
          Image.asset('assets/images/img.png', height: 32, fit: BoxFit.contain),

          const Spacer(),

          // Notification bell
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF202124),
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          // Profile picture
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
              image: const DecorationImage(
                image: NetworkImage("https://placehold.co/32x32"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileNavigationTabs(
    BuildContext context,
    ScreenSize screenSize,
  ) {
    final tabs = [
      {
        'title': 'Dashboard',
        'icon': Icons.dashboard_outlined,
        'hasBadge': false,
        'badgeCount': null,
      },
      {
        'title': 'Resumes',
        'icon': Icons.description_outlined,
        'hasBadge': true,
        'badgeCount': 12,
      },
      {
        'title': 'Job Matches',
        'icon': Icons.work_outline,
        'hasBadge': true,
        'badgeCount': 5,
      },
      {
        'title': 'AI Screening',
        'icon': Icons.psychology_outlined,
        'hasBadge': false,
        'badgeCount': null,
      },
      {
        'title': 'Account',
        'icon': Icons.person_outline,
        'hasBadge': false,
        'badgeCount': null,
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs
              .map(
                (tab) => _buildMobileTab(
                  context,
                  title: tab['title'] as String,
                  icon: tab['icon'] as IconData,
                  hasBadge: tab['hasBadge'] as bool,
                  badgeCount: tab['badgeCount'] as int?,
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildMobileTab(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool hasBadge,
    int? badgeCount,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF202124), size: 24),
              ),
              if (hasBadge && badgeCount != null)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4285F4),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      badgeCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF202124),
              fontSize: 12,
              fontFamily: 'Raleway',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileMainContent(BuildContext context, ScreenSize screenSize) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mobile Title
          Text(
            'Dashboard',
            style: TextStyle(
              color: const Color(0xFF202124),
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                mobile: 20,
                tablet: 22,
                desktop: 24,
                largeDesktop: 26,
                extraLargeDesktop: 28,
              ),
              fontFamily: 'Raleway',
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 24),

          // Main Card for Mobile
          Expanded(child: _buildMobileMainCard(context, screenSize)),
        ],
      ),
    );
  }

  Widget _buildMobileMainCard(BuildContext context, ScreenSize screenSize) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Add your Document',
            style: TextStyle(
              color: const Color(0xFF202124),
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                mobile: 18,
                tablet: 20,
                desktop: 22,
                largeDesktop: 24,
                extraLargeDesktop: 26,
              ),
              fontFamily: 'Raleway',
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Drag and Drop Zone for Mobile
          _buildMobileDragDropZone(context, screenSize),
        ],
      ),
    );
  }

  Widget _buildMobileDragDropZone(BuildContext context, ScreenSize screenSize) {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFDADCE0),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EAED),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, size: 28, color: Color(0xFF5F6368)),
          ),

          const SizedBox(height: 12),

          Text(
            'Tap to upload document',
            style: TextStyle(
              color: const Color(0xFF5F6368),
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                mobile: 13,
                tablet: 14,
                desktop: 15,
                largeDesktop: 16,
                extraLargeDesktop: 17,
              ),
              fontFamily: 'Raleway',
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, ScreenSize screenSize) {
    final sidebarWidth = ResponsiveUtils.getResponsiveContainerWidth(
      context,
      mobile: 80,
      tablet: 200,
      desktop: 250,
      largeDesktop: 280,
      extraLargeDesktop: 300,
    );

    return Container(
      width: sidebarWidth,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo Section
          _buildLogoSection(context, screenSize),

          const SizedBox(height: 40),

          // Navigation Items
          _buildNavigationItems(context, screenSize),

          const Spacer(),

          // Bottom Navigation Items
          _buildBottomNavigationItems(context, screenSize),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildLogoSection(BuildContext context, ScreenSize screenSize) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Image.asset(
        'assets/images/img.png',
        height: 40,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildNavigationItems(BuildContext context, ScreenSize screenSize) {
    final items = [
      {
        'title': 'Dashboard',
        'icon': Icons.dashboard_outlined,
        'hasBadge': false,
        'badgeCount': null,
      },
      {
        'title': 'Resume Library',
        'icon': Icons.description_outlined,
        'hasBadge': true,
        'badgeCount': 24,
      },
      {
        'title': 'Job Postings',
        'icon': Icons.work_outline,
        'hasBadge': true,
        'badgeCount': 8,
      },
      {
        'title': 'AI Matching',
        'icon': Icons.psychology_outlined,
        'hasBadge': false,
        'badgeCount': null,
      },
      {
        'title': 'Analytics',
        'icon': Icons.analytics_outlined,
        'hasBadge': false,
        'badgeCount': null,
      },
    ];

    return Column(
      children: items
          .map(
            (item) => _buildNavigationItem(
              context,
              title: item['title'] as String,
              icon: item['icon'] as IconData,
              hasBadge: item['hasBadge'] as bool,
              badgeCount: item['badgeCount'] as int?,
            ),
          )
          .toList(),
    );
  }

  Widget _buildBottomNavigationItems(
    BuildContext context,
    ScreenSize screenSize,
  ) {
    final items = [
      {'title': 'Account', 'icon': Icons.person_outline},
      {'title': 'Settings', 'icon': Icons.settings_outlined},
    ];

    return Column(
      children: items
          .map(
            (item) => _buildNavigationItem(
              context,
              title: item['title'] as String,
              icon: item['icon'] as IconData,
              hasBadge: false,
            ),
          )
          .toList(),
    );
  }

  Widget _buildNavigationItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool hasBadge,
    int? badgeCount,
  }) {
    final List<Widget> stackChildren = [
      Icon(icon, color: const Color(0xFF202124), size: 28),
    ];

    if (hasBadge && badgeCount != null) {
      stackChildren.add(
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Color(0xFF4285F4),
              shape: BoxShape.circle,
            ),
            child: Text(
              badgeCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Stack(children: stackChildren),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF202124),
            fontSize: 14,
            fontFamily: 'Raleway',
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: () {
          // Handle navigation
          print('Navigating to: $title');
        },
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, ScreenSize screenSize) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(context, screenSize),

          const SizedBox(height: 40),

          // Main Content Card
          Expanded(child: _buildMainCard(context, screenSize)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ScreenSize screenSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Dashboard',
          style: TextStyle(
            color: const Color(0xFF202124),
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              mobile: 18,
              tablet: 20,
              desktop: 22,
              largeDesktop: 24,
              extraLargeDesktop: 26,
            ),
            fontFamily: 'Raleway',
            fontWeight: FontWeight.w600,
          ),
        ),

        // Right side - notifications and profile
        Row(
          children: [
            // Notification bell
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: Color(0xFF202124),
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            // Profile picture
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
                image: const DecorationImage(
                  image: NetworkImage("https://placehold.co/40x40"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainCard(BuildContext context, ScreenSize screenSize) {
    return Center(
      child: Container(
        width: ResponsiveUtils.getResponsiveContainerWidth(
          context,
          mobile: 300,
          tablet: 400,
          desktop: 500,
          largeDesktop: 600,
          extraLargeDesktop: 700,
        ),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Upload Resume or Job Description',
              style: TextStyle(
                color: const Color(0xFF202124),
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  mobile: 20,
                  tablet: 22,
                  desktop: 24,
                  largeDesktop: 26,
                  extraLargeDesktop: 28,
                ),
                fontFamily: 'Raleway',
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 30),

            // Drag and Drop Zone
            _buildDragDropZone(context, screenSize),
          ],
        ),
      ),
    );
  }

  Widget _buildDragDropZone(BuildContext context, ScreenSize screenSize) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFDADCE0),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EAED),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, size: 32, color: Color(0xFF5F6368)),
          ),

          const SizedBox(height: 16),

          Text(
            'Drag and drop your document',
            style: TextStyle(
              color: const Color(0xFF5F6368),
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                mobile: 14,
                tablet: 15,
                desktop: 16,
                largeDesktop: 17,
                extraLargeDesktop: 18,
              ),
              fontFamily: 'Raleway',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
