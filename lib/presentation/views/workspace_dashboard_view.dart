import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glow_container/glow_container.dart';
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

class _WorkspaceDashboardViewState extends State<WorkspaceDashboardView> {
  // Mock data for existing workspaces - in real app, this would come from backend
  final List<Map<String, dynamic>> _workspaces = [];

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
      {'title': 'Workspaces', 'icon': Icons.work_outline, 'isActive': true},
      {
        'title': 'Resume Library',
        'icon': Icons.description_outlined,
        'isActive': false,
      },
      {
        'title': 'Analytics',
        'icon': Icons.analytics_outlined,
        'isActive': false,
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
          Expanded(child: _buildWorkspaceContent(context)),
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
          Expanded(child: _buildWorkspaceContent(context)),
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
            'Dashboard',
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
          Expanded(child: _buildWorkspaceContent(context)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Dashboard',
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
}
