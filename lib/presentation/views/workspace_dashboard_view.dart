import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glow_container/glow_container.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../controllers/auth_controller.dart';
import 'workspace_creation_view.dart';
import 'settings_view.dart';

class WorkspaceDashboardView extends StatefulWidget {
  const WorkspaceDashboardView({super.key});

  @override
  State<WorkspaceDashboardView> createState() => _WorkspaceDashboardViewState();
}

class _WorkspaceDashboardViewState extends State<WorkspaceDashboardView>
    with TickerProviderStateMixin {
  // Mock data for existing workspaces - in real app, this would come from backend
  final List<Map<String, dynamic>> _workspaces = [];

  // Navigation state
  String _currentView = 'Dashboard';

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;

  // Resume Library data
  final List<Map<String, dynamic>> _resumes = [
    {
      'id': '1',
      'name': 'John Doe - Software Engineer',
      'status': 'active',
      'uploadDate': DateTime.now().subtract(const Duration(days: 2)),
      'atsScore': 85,
      'fileSize': '2.3 MB',
      'format': 'PDF',
      'tags': ['React', 'Node.js', 'Python'],
    },
    {
      'id': '2',
      'name': 'Jane Smith - Product Manager',
      'status': 'processing',
      'uploadDate': DateTime.now().subtract(const Duration(hours: 5)),
      'atsScore': 0,
      'fileSize': '1.8 MB',
      'format': 'DOCX',
      'tags': ['Agile', 'Scrum', 'Analytics'],
    },
    {
      'id': '3',
      'name': 'Mike Johnson - Data Scientist',
      'status': 'completed',
      'uploadDate': DateTime.now().subtract(const Duration(days: 7)),
      'atsScore': 92,
      'fileSize': '3.1 MB',
      'format': 'PDF',
      'tags': ['Machine Learning', 'Python', 'SQL'],
    },
  ];

  // Analytics data
  final Map<String, dynamic> _analyticsData = {
    'totalResumes': 156,
    'avgAtsScore': 78.5,
    'processingTime': 2.3,
    'successRate': 94.2,
    'monthlyUploads': [12, 18, 25, 22, 30, 28, 35],
    'statusDistribution': [
      {'status': 'Active', 'count': 89, 'color': const Color(0xFF34A853)},
      {'status': 'Processing', 'count': 23, 'color': const Color(0xFFFBBC04)},
      {'status': 'Completed', 'count': 44, 'color': const Color(0xFF4285F4)},
    ],
  };

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _navigateToView(String view) {
    setState(() {
      _currentView = view;
    });
    _slideController.reset();
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: ResponsiveBuilder(
        builder: (context, screenSize) {
          if (screenSize == ScreenSize.mobile) {
            return _buildMobileLayout(context);
          } else if (screenSize == ScreenSize.tablet) {
            return _buildTabletLayout(context);
          } else {
            return _buildDesktopLayout(context);
          }
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _buildMobileHeader(context),
        Expanded(child: _buildMobileContent(context)),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      children: [
        _buildTabletSidebar(context),
        Expanded(child: _buildTabletContent(context)),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        _buildSidebar(context),
        Expanded(child: _buildMainContent(context)),
      ],
    );
  }

  Widget _buildMobileHeader(BuildContext context) {
    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
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
          Image.asset(
            'assets/images/img.png',
            height: ResponsiveUtils.getResponsiveIconSize(
              context,
              mobile: 28,
              tablet: 32,
              desktop: 36,
            ),
            fit: BoxFit.contain,
          ),
          const Spacer(),
          // User info
          Consumer<AuthController>(
            builder: (context, authController, child) {
              return Text(
                authController.authState.user?.name ?? 'User',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                    context,
                    mobile: 14,
                    tablet: 16,
                    desktop: 18,
                  ),
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlack,
                  fontFamily: 'Inter',
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          // Profile picture
          Container(
            width: ResponsiveUtils.getResponsiveIconSize(
              context,
              mobile: 28,
              tablet: 32,
              desktop: 36,
            ),
            height: ResponsiveUtils.getResponsiveIconSize(
              context,
              mobile: 28,
              tablet: 32,
              desktop: 36,
            ),
            decoration: const BoxDecoration(
              color: AppTheme.secondaryGray,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: AppTheme.backgroundWhite,
              size: ResponsiveUtils.getResponsiveIconSize(
                context,
                mobile: 16,
                tablet: 18,
                desktop: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletSidebar(BuildContext context) {
    final sidebarWidth = ResponsiveUtils.getResponsiveContainerWidth(
      context,
      mobile: 80,
      tablet: 180,
      desktop: 250,
      largeDesktop: 280,
      extraLargeDesktop: 300,
    );

    return Container(
      width: sidebarWidth,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildLogoSection(context),
          const SizedBox(height: 32),
          _buildNavigationItems(context),
          const Spacer(),
          _buildBottomNavigationItems(context),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
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
        color: AppTheme.backgroundWhite,
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
          _buildLogoSection(context),
          const SizedBox(height: 40),
          _buildNavigationItems(context),
          const Spacer(),
          _buildBottomNavigationItems(context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildLogoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Image.asset(
        'assets/images/img.png',
        height: 40,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildNavigationItems(BuildContext context) {
    final items = [
      {
        'title': 'Dashboard',
        'icon': Icons.dashboard_outlined,
        'isActive': _currentView == 'Dashboard',
      },
      {
        'title': 'Resume Library',
        'icon': Icons.description_outlined,
        'isActive': _currentView == 'Resume Library',
      },
      {
        'title': 'Analytics',
        'icon': Icons.analytics_outlined,
        'isActive': _currentView == 'Analytics',
      },
    ];

    return Column(
      children: items
          .map(
            (item) => _buildNavigationItem(
              context,
              title: item['title'] as String,
              icon: item['icon'] as IconData,
              isActive: item['isActive'] as bool,
            ),
          )
          .toList(),
    );
  }

  Widget _buildBottomNavigationItems(BuildContext context) {
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
              isActive: false,
            ),
          )
          .toList(),
    );
  }

  Widget _buildNavigationItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isActive,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? AppTheme.accentBlue : AppTheme.secondaryGray,
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? AppTheme.accentBlue : AppTheme.primaryBlack,
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        onTap: () {
          if (title == 'Settings') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsView()),
            );
          } else if (title == 'Dashboard' ||
              title == 'Resume Library' ||
              title == 'Analytics') {
            _navigateToView(title);
          }
        },
      ),
    );
  }

  Widget _buildTabletContent(BuildContext context) {
    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          Expanded(child: _buildCurrentView(context)),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 32),
          Expanded(child: _buildCurrentView(context)),
        ],
      ),
    );
  }

  Widget _buildMobileContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _currentView,
            style: TextStyle(
              color: AppTheme.primaryBlack,
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                mobile: 20,
                tablet: 22,
                desktop: 24,
                largeDesktop: 26,
                extraLargeDesktop: 28,
              ),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(child: _buildCurrentView(context)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _currentView,
          style: TextStyle(
            color: AppTheme.primaryBlack,
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              mobile: 20,
              tablet: 22,
              desktop: 24,
              largeDesktop: 26,
              extraLargeDesktop: 28,
            ),
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WorkspaceCreationView(),
              ),
            );
          },
          icon: const Icon(Icons.add, color: AppTheme.primaryBlack),
          label: const Text(
            'New Workspace',
            style: TextStyle(
              color: AppTheme.primaryBlack,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.backgroundWhite,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentView(BuildContext context) {
    switch (_currentView) {
      case 'Dashboard':
        return _buildWorkspaceContent(context);
      case 'Resume Library':
        return _buildResumeLibraryContent(context);
      case 'Analytics':
        return _buildAnalyticsContent(context);
      default:
        return _buildWorkspaceContent(context);
    }
  }

  Widget _buildWorkspaceContent(BuildContext context) {
    if (_workspaces.isEmpty) {
      return _buildEmptyState(context);
    }

    return ResponsiveBuilder(
      builder: (context, screenSize) {
        if (screenSize == ScreenSize.mobile) {
          return _buildMobileWorkspaceGrid(context);
        }
        return _buildDesktopWorkspaceGrid(context);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Main Glow Container Card
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WorkspaceCreationView(),
                ),
              );
            },
            child: Container(
              width: ResponsiveUtils.getResponsiveContainerWidth(
                context,
                mobile: 300,
                tablet: 400,
                desktop: 500,
                largeDesktop: 600,
                extraLargeDesktop: 700,
              ),
              height: ResponsiveUtils.getResponsiveContainerHeight(
                context,
                mobile: 200,
                tablet: 250,
                desktop: 300,
                largeDesktop: 350,
                extraLargeDesktop: 400,
              ),
              child: GlowContainer(
                gradientColors: [
                  AppTheme.accentBlue,
                  AppTheme.accentPurple,
                  AppTheme.accentRed,
                  AppTheme.accentOrange,
                  AppTheme.accentYellow,
                  AppTheme.accentGreen,
                ],
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundWhite,
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.getResponsiveBorderRadius(
                        context,
                        mobile: 16,
                        tablet: 18,
                        desktop: 20,
                        largeDesktop: 22,
                        extraLargeDesktop: 24,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title
                      Text(
                        'Create your workspace',
                        style: TextStyle(
                          color: AppTheme.primaryBlack,
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            mobile: 18,
                            tablet: 20,
                            desktop: 22,
                            largeDesktop: 24,
                            extraLargeDesktop: 26,
                          ),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      // Dashed Upload Area
                      Container(
                        width: ResponsiveUtils.getResponsiveContainerWidth(
                          context,
                          mobile: 200,
                          tablet: 250,
                          desktop: 300,
                          largeDesktop: 350,
                          extraLargeDesktop: 400,
                        ),
                        height: ResponsiveUtils.getResponsiveContainerHeight(
                          context,
                          mobile: 80,
                          tablet: 100,
                          desktop: 120,
                          largeDesktop: 140,
                          extraLargeDesktop: 160,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundWhite,
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtils.getResponsiveBorderRadius(
                              context,
                              mobile: 8,
                              tablet: 10,
                              desktop: 12,
                              largeDesktop: 14,
                              extraLargeDesktop: 16,
                            ),
                          ),
                          border: Border.all(
                            color: AppTheme.secondaryGray.withOpacity(0.3),
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add,
                              size: ResponsiveUtils.getResponsiveIconSize(
                                context,
                                mobile: 32,
                                tablet: 36,
                                desktop: 40,
                                largeDesktop: 44,
                                extraLargeDesktop: 48,
                              ),
                              color: AppTheme.secondaryGray.withOpacity(0.6),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'click to create',
                              style: TextStyle(
                                color: AppTheme.secondaryGray.withOpacity(0.6),
                                fontSize: ResponsiveUtils.getResponsiveFontSize(
                                  context,
                                  mobile: 12,
                                  tablet: 13,
                                  desktop: 14,
                                  largeDesktop: 15,
                                  extraLargeDesktop: 16,
                                ),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopWorkspaceGrid(BuildContext context) {
    final screenSize = ResponsiveUtils.getScreenSize(context);
    int crossAxisCount;
    double childAspectRatio;
    double spacing;

    switch (screenSize) {
      case ScreenSize.tablet:
        crossAxisCount = 2;
        childAspectRatio = 1.3;
        spacing = 16;
        break;
      case ScreenSize.desktop:
        crossAxisCount = 3;
        childAspectRatio = 1.2;
        spacing = 20;
        break;
      case ScreenSize.largeDesktop:
        crossAxisCount = 4;
        childAspectRatio = 1.1;
        spacing = 24;
        break;
      case ScreenSize.extraLargeDesktop:
        crossAxisCount = 5;
        childAspectRatio = 1.0;
        spacing = 28;
        break;
      default:
        crossAxisCount = 3;
        childAspectRatio = 1.2;
        spacing = 20;
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: _workspaces.length + 1, // +1 for add new workspace card
      itemBuilder: (context, index) {
        if (index == _workspaces.length) {
          return _buildAddWorkspaceCard(context);
        }
        return _buildWorkspaceCard(context, _workspaces[index]);
      },
    );
  }

  Widget _buildMobileWorkspaceGrid(BuildContext context) {
    return ListView.builder(
      itemCount: _workspaces.length + 1, // +1 for add new workspace card
      itemBuilder: (context, index) {
        if (index == _workspaces.length) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildAddWorkspaceCard(context),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildWorkspaceCard(context, _workspaces[index]),
        );
      },
    );
  }

  Widget _buildAddWorkspaceCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const WorkspaceCreationView(),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.backgroundWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.accentBlue,
            width: 2,
            style: BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.accentBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, size: 30, color: AppTheme.accentBlue),
            ),
            const SizedBox(height: 16),
            Text(
              'Add New Workspace',
              style: TextStyle(
                color: AppTheme.accentBlue,
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 15,
                  desktop: 16,
                  largeDesktop: 17,
                  extraLargeDesktop: 18,
                ),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkspaceCard(
    BuildContext context,
    Map<String, dynamic> workspace,
  ) {
    return GestureDetector(
      onTap: () {
        // Navigate to workspace details or continue processing
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const WorkspaceCreationView(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.backgroundWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.work_outline,
                    color: AppTheme.accentBlue,
                    size: 20,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: workspace['status'] == 'active'
                        ? AppTheme.accentGreen.withOpacity(0.1)
                        : AppTheme.accentOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    workspace['status'].toString().toUpperCase(),
                    style: TextStyle(
                      color: workspace['status'] == 'active'
                          ? AppTheme.accentGreen
                          : AppTheme.accentOrange,
                      fontSize: 10,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              workspace['title'],
              style: TextStyle(
                color: AppTheme.primaryBlack,
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 15,
                  desktop: 16,
                  largeDesktop: 17,
                  extraLargeDesktop: 18,
                ),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              workspace['description'],
              style: TextStyle(
                color: AppTheme.secondaryGray,
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  mobile: 12,
                  tablet: 13,
                  desktop: 14,
                  largeDesktop: 15,
                  extraLargeDesktop: 16,
                ),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                Icon(
                  Icons.description_outlined,
                  color: AppTheme.secondaryGray,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${workspace['resumeCount']} resumes',
                  style: TextStyle(
                    color: AppTheme.secondaryGray,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(workspace['createdAt']),
                  style: TextStyle(
                    color: AppTheme.secondaryGray,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // Resume Library Content
  Widget _buildResumeLibraryContent(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _slideController,
                  curve: Curves.easeInOut,
                ),
              ),
          child: FadeTransition(
            opacity: _slideController,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildResumeLibraryHeader(context),
                  const SizedBox(height: 24),
                  _buildResumeStats(context),
                  const SizedBox(height: 24),
                  _buildResumeFilters(context),
                  const SizedBox(height: 24),
                  _buildResumeList(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResumeLibraryHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4285F4).withOpacity(0.1),
            const Color(0xFF8B5CF6).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4285F4).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4285F4), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.description,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resume Library',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            mobile: 24,
                            tablet: 26,
                            desktop: 28,
                          ),
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryBlack,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage and organize your resumes',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            mobile: 14,
                            tablet: 15,
                            desktop: 16,
                          ),
                          color: AppTheme.secondaryGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4285F4), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4285F4).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Add new resume functionality
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.upload_file,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Upload Resume',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumeStats(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Total Resumes',
            _resumes.length.toString(),
            Icons.description_outlined,
            AppTheme.accentBlue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            'Active',
            _resumes.where((r) => r['status'] == 'active').length.toString(),
            Icons.check_circle_outline,
            AppTheme.accentGreen,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            'Processing',
            _resumes
                .where((r) => r['status'] == 'processing')
                .length
                .toString(),
            Icons.hourglass_empty,
            AppTheme.accentOrange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            'Completed',
            _resumes.where((r) => r['status'] == 'completed').length.toString(),
            Icons.task_alt,
            AppTheme.accentPurple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.secondaryGray,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumeFilters(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search resumes...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.secondaryGray.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.secondaryGray.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.accentBlue),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        DropdownButton<String>(
          value: 'All',
          items: ['All', 'Active', 'Processing', 'Completed']
              .map(
                (status) =>
                    DropdownMenuItem(value: status, child: Text(status)),
              )
              .toList(),
          onChanged: (value) {},
          underline: Container(),
          style: const TextStyle(color: AppTheme.primaryBlack),
        ),
        const SizedBox(width: 16),
        DropdownButton<String>(
          value: 'Recent',
          items: ['Recent', 'Oldest', 'Name A-Z', 'Name Z-A']
              .map((sort) => DropdownMenuItem(value: sort, child: Text(sort)))
              .toList(),
          onChanged: (value) {},
          underline: Container(),
          style: const TextStyle(color: AppTheme.primaryBlack),
        ),
      ],
    );
  }

  Widget _buildResumeList(BuildContext context) {
    return Column(
      children: _resumes
          .map((resume) => _buildResumeCard(context, resume))
          .toList(),
    );
  }

  Widget _buildResumeCard(BuildContext context, Map<String, dynamic> resume) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _getStatusColor(resume['status']).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.description_outlined,
              color: _getStatusColor(resume['status']),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resume['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlack,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatusChip(resume['status']),
                    const SizedBox(width: 12),
                    Text(
                      resume['fileSize'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.secondaryGray,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: TextStyle(
                        color: AppTheme.secondaryGray.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      resume['format'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.secondaryGray,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: (resume['tags'] as List<String>)
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.accentBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          Column(
            children: [
              if (resume['atsScore'] > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${resume['atsScore']}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentGreen,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                _formatDate(resume['uploadDate']),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.secondaryGray,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          PopupMenuButton<String>(
            onSelected: (value) {
              // Handle menu actions
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'view', child: Text('View')),
              const PopupMenuItem(value: 'download', child: Text('Download')),
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
            child: const Icon(Icons.more_vert, color: AppTheme.secondaryGray),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'active':
        color = AppTheme.accentGreen;
        break;
      case 'processing':
        color = AppTheme.accentOrange;
        break;
      case 'completed':
        color = AppTheme.accentBlue;
        break;
      default:
        color = AppTheme.secondaryGray;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return AppTheme.accentGreen;
      case 'processing':
        return AppTheme.accentOrange;
      case 'completed':
        return AppTheme.accentBlue;
      default:
        return AppTheme.secondaryGray;
    }
  }

  // Analytics Content
  Widget _buildAnalyticsContent(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _slideController,
                  curve: Curves.easeInOut,
                ),
              ),
          child: FadeTransition(
            opacity: _slideController,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAnalyticsHeader(context),
                  const SizedBox(height: 24),
                  _buildAnalyticsOverview(context),
                  const SizedBox(height: 24),
                  _buildAnalyticsCharts(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analytics Dashboard',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  mobile: 24,
                  tablet: 26,
                  desktop: 28,
                ),
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryBlack,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Insights and performance metrics',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 15,
                  desktop: 16,
                ),
                color: AppTheme.secondaryGray,
              ),
            ),
          ],
        ),
        DropdownButton<String>(
          value: 'Last 30 days',
          items: ['Last 7 days', 'Last 30 days', 'Last 90 days', 'Last year']
              .map(
                (period) =>
                    DropdownMenuItem(value: period, child: Text(period)),
              )
              .toList(),
          onChanged: (value) {},
          underline: Container(),
          style: const TextStyle(
            color: AppTheme.primaryBlack,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsOverview(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildAnalyticsCard(
            context,
            'Total Resumes',
            _analyticsData['totalResumes'].toString(),
            Icons.description_outlined,
            AppTheme.accentBlue,
            '+12% from last month',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildAnalyticsCard(
            context,
            'Avg ATS Score',
            '${_analyticsData['avgAtsScore']}%',
            Icons.trending_up,
            AppTheme.accentGreen,
            '+5.2% from last month',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildAnalyticsCard(
            context,
            'Processing Time',
            '${_analyticsData['processingTime']}h',
            Icons.schedule,
            AppTheme.accentOrange,
            '-0.3h from last month',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildAnalyticsCard(
            context,
            'Success Rate',
            '${_analyticsData['successRate']}%',
            Icons.check_circle,
            AppTheme.accentPurple,
            '+2.1% from last month',
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Icon(Icons.trending_up, color: AppTheme.accentGreen, size: 16),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.secondaryGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.accentGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCharts(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 2, child: _buildLineChart(context)),
        const SizedBox(width: 16),
        Expanded(child: _buildPieChart(context)),
      ],
    );
  }

  Widget _buildLineChart(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resume Uploads Trend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const months = [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun',
                          'Jul',
                        ];
                        if (value.toInt() < months.length) {
                          return Text(
                            months[value.toInt()],
                            style: const TextStyle(fontSize: 12),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: (_analyticsData['monthlyUploads'] as List<int>)
                        .asMap()
                        .entries
                        .map(
                          (e) => FlSpot(e.key.toDouble(), e.value.toDouble()),
                        )
                        .toList(),
                    isCurved: true,
                    color: AppTheme.accentBlue,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.accentBlue.withOpacity(0.1),
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

  Widget _buildPieChart(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections:
                    (_analyticsData['statusDistribution']
                            as List<Map<String, dynamic>>)
                        .map<PieChartSectionData>(
                          (item) => PieChartSectionData(
                            color: item['color'] as Color,
                            value: (item['count'] as int).toDouble(),
                            title: '${item['count']}',
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...(_analyticsData['statusDistribution']
                  as List<Map<String, dynamic>>)
              .map<Widget>(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: item['color'] as Color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item['status'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.primaryBlack,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${item['count']}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlack,
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
