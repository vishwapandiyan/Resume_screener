import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/responsive_theme.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../controllers/auth_controller.dart';
import 'auth/login_view.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  String _selectedLanguage = 'English';
  String _selectedTheme = 'System';

  final List<String> _languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Italian',
    'Portuguese',
  ];

  final List<String> _themes = ['System', 'Light', 'Dark'];

  // Custom glow container widget
  Widget _buildGlowContainer({
    required Widget child,
    List<Color>? gradientColors,
    double glowRadius = 2.0,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: gradientColors != null
            ? [
                BoxShadow(
                  color: gradientColors.first.withOpacity(0.3),
                  blurRadius: glowRadius * 4,
                  spreadRadius: glowRadius,
                ),
                BoxShadow(
                  color: gradientColors.length > 1
                      ? gradientColors.last.withOpacity(0.2)
                      : gradientColors.first.withOpacity(0.1),
                  blurRadius: glowRadius * 2,
                  spreadRadius: glowRadius * 0.5,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
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
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppTheme.primaryBlack,
              size: ResponsiveUtils.getResponsiveIconSize(
                context,
                mobile: 20,
                tablet: 22,
                desktop: 24,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Settings',
            style: ResponsiveTheme.getResponsiveTextStyle(
              context,
              baseStyle: AppTheme.lightTheme.textTheme.headlineSmall!,
            ),
          ),
          const Spacer(),
          // Profile picture
          Container(
            width: ResponsiveUtils.getResponsiveIconSize(
              context,
              mobile: 32,
              tablet: 36,
              desktop: 40,
            ),
            height: ResponsiveUtils.getResponsiveIconSize(
              context,
              mobile: 32,
              tablet: 36,
              desktop: 40,
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
                mobile: 18,
                tablet: 20,
                desktop: 22,
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
      {'title': 'Workspaces', 'icon': Icons.work_outline, 'isActive': false},
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
      {'title': 'Settings', 'icon': Icons.settings_outlined, 'isActive': true},
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
          if (title == 'Workspaces') {
            Navigator.pushReplacementNamed(context, '/workspace-dashboard');
          } else if (title == 'Resume Library') {
            // Handle navigation to resume library
          } else if (title == 'Analytics') {
            // Handle navigation to analytics
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
          Expanded(child: _buildSettingsContent(context)),
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
          Expanded(child: _buildSettingsContent(context)),
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
            'Settings',
            style: ResponsiveTheme.getResponsiveTextStyle(
              context,
              baseStyle: AppTheme.lightTheme.textTheme.headlineSmall!,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(child: _buildSettingsContent(context)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Settings',
          style: ResponsiveTheme.getResponsiveTextStyle(
            context,
            baseStyle: AppTheme.lightTheme.textTheme.headlineSmall!,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileSection(context),
          const SizedBox(height: 32),
          _buildPreferencesSection(context),
          const SizedBox(height: 32),
          _buildNotificationSection(context),
          const SizedBox(height: 32),
          _buildAppearanceSection(context),
          const SizedBox(height: 32),
          _buildAccountSection(context),
          const SizedBox(height: 32),
          _buildSupportSection(context),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return _buildSectionCard(
      context,
      title: 'Profile',
      children: [
        Consumer<AuthController>(
          builder: (context, authController, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    // Handle profile edit
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.accentBlue.withOpacity(0.05),
                          AppTheme.accentPurple.withOpacity(0.02),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildGlowContainer(
                          gradientColors: [
                            AppTheme.accentBlue,
                            AppTheme.accentPurple,
                          ],
                          glowRadius: 4,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: AppTheme.accentBlue,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person,
                              color: AppTheme.backgroundWhite,
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authController.authState.user?.name ??
                                    'User Name',
                                style: AppTheme.lightTheme.textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primaryBlack,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                authController.authState.user?.email ??
                                    'user@example.com',
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(color: AppTheme.secondaryGray),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.accentBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.edit_outlined,
                            size: 20,
                            color: AppTheme.accentBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPreferencesSection(BuildContext context) {
    return _buildSectionCard(
      context,
      title: 'Preferences',
      children: [
        _buildDropdownTile(
          context,
          title: 'Language',
          value: _selectedLanguage,
          items: _languages,
          onChanged: (value) {
            setState(() {
              _selectedLanguage = value!;
            });
          },
        ),
        _buildDivider(),
        _buildDropdownTile(
          context,
          title: 'Theme',
          value: _selectedTheme,
          items: _themes,
          onChanged: (value) {
            setState(() {
              _selectedTheme = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildNotificationSection(BuildContext context) {
    return _buildSectionCard(
      context,
      title: 'Notifications',
      children: [
        _buildSwitchTile(
          context,
          title: 'Enable Notifications',
          subtitle: 'Receive notifications about your workspaces',
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
            });
          },
        ),
        _buildDivider(),
        _buildSwitchTile(
          context,
          title: 'Email Notifications',
          subtitle: 'Get updates via email',
          value: _emailNotifications,
          onChanged: (value) {
            setState(() {
              _emailNotifications = value;
            });
          },
        ),
        _buildDivider(),
        _buildSwitchTile(
          context,
          title: 'Push Notifications',
          subtitle: 'Receive push notifications on your device',
          value: _pushNotifications,
          onChanged: (value) {
            setState(() {
              _pushNotifications = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAppearanceSection(BuildContext context) {
    return _buildSectionCard(
      context,
      title: 'Appearance',
      children: [
        _buildSwitchTile(
          context,
          title: 'Dark Mode',
          subtitle: 'Switch between light and dark themes',
          value: _darkModeEnabled,
          onChanged: (value) {
            setState(() {
              _darkModeEnabled = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return _buildSectionCard(
      context,
      title: 'Account',
      children: [
        _buildActionTile(
          context,
          title: 'Change Password',
          subtitle: 'Update your account password',
          icon: Icons.lock_outline,
          onTap: () {
            // Handle change password
          },
        ),
        _buildDivider(),
        _buildActionTile(
          context,
          title: 'Privacy Settings',
          subtitle: 'Manage your privacy preferences',
          icon: Icons.privacy_tip_outlined,
          onTap: () {
            // Handle privacy settings
          },
        ),
        _buildDivider(),
        _buildActionTile(
          context,
          title: 'Data & Storage',
          subtitle: 'Manage your data and storage settings',
          icon: Icons.storage_outlined,
          onTap: () {
            // Handle data & storage
          },
        ),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return _buildSectionCard(
      context,
      title: 'Support',
      children: [
        _buildActionTile(
          context,
          title: 'Help Center',
          subtitle: 'Get help and support',
          icon: Icons.help_outline,
          onTap: () {
            // Handle help center
          },
        ),
        _buildDivider(),
        _buildActionTile(
          context,
          title: 'Contact Support',
          subtitle: 'Reach out to our support team',
          icon: Icons.support_agent,
          onTap: () {
            // Handle contact support
          },
        ),
        _buildDivider(),
        _buildActionTile(
          context,
          title: 'About',
          subtitle: 'App version and information',
          icon: Icons.info_outline,
          onTap: () {
            // Handle about
          },
        ),
        _buildDivider(),
        _buildActionTile(
          context,
          title: 'Sign Out',
          subtitle: 'Sign out of your account',
          icon: Icons.logout,
          isDestructive: true,
          onTap: () {
            _showSignOutDialog(context);
          },
        ),
      ],
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: _buildGlowContainer(
        gradientColors: [
          AppTheme.accentBlue.withOpacity(0.1),
          AppTheme.accentPurple.withOpacity(0.1),
          AppTheme.accentGreen.withOpacity(0.1),
        ],
        glowRadius: 2,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.accentBlue, AppTheme.accentPurple],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onChanged(!value),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTheme.lightTheme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTheme.lightTheme.textTheme.bodySmall
                            ?.copyWith(
                              color: AppTheme.secondaryGray.withOpacity(0.8),
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                _buildGlowContainer(
                  gradientColors: value
                      ? [AppTheme.accentBlue, AppTheme.accentPurple]
                      : [AppTheme.secondaryGray.withOpacity(0.3)],
                  glowRadius: value ? 3 : 0,
                  child: Switch(
                    value: value,
                    onChanged: onChanged,
                    activeColor: AppTheme.accentBlue,
                    activeTrackColor: AppTheme.accentBlue.withOpacity(0.3),
                    inactiveThumbColor: AppTheme.secondaryGray,
                    inactiveTrackColor: AppTheme.secondaryGray.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownTile(
    BuildContext context, {
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _buildGlowContainer(
                  gradientColors: [AppTheme.accentBlue.withOpacity(0.1)],
                  glowRadius: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentBlue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.accentBlue.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: DropdownButton<String>(
                      value: value,
                      onChanged: onChanged,
                      underline: const SizedBox(),
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: AppTheme.accentBlue,
                        size: 20,
                      ),
                      style: AppTheme.lightTheme.textTheme.titleMedium
                          ?.copyWith(
                            color: AppTheme.accentBlue,
                            fontWeight: FontWeight.w600,
                          ),
                      items: items.map((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(color: AppTheme.primaryBlack),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: isDestructive
                  ? LinearGradient(
                      colors: [
                        Colors.red.withOpacity(0.05),
                        Colors.red.withOpacity(0.02),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : LinearGradient(
                      colors: [
                        AppTheme.accentBlue.withOpacity(0.03),
                        AppTheme.accentPurple.withOpacity(0.01),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
            ),
            child: Row(
              children: [
                _buildGlowContainer(
                  gradientColors: isDestructive
                      ? [Colors.red.withOpacity(0.3)]
                      : [AppTheme.accentBlue.withOpacity(0.2)],
                  glowRadius: isDestructive ? 2 : 1,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDestructive
                          ? Colors.red.withOpacity(0.1)
                          : AppTheme.accentBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: isDestructive ? Colors.red : AppTheme.accentBlue,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTheme.lightTheme.textTheme.titleMedium
                            ?.copyWith(
                              color: isDestructive
                                  ? Colors.red
                                  : AppTheme.primaryBlack,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTheme.lightTheme.textTheme.bodySmall
                            ?.copyWith(
                              color: AppTheme.secondaryGray.withOpacity(0.8),
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppTheme.secondaryGray.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      color: AppTheme.secondaryGray,
      indent: 16,
      endIndent: 16,
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildGlowContainer(
          gradientColors: [
            Colors.red.withOpacity(0.1),
            Colors.orange.withOpacity(0.05),
          ],
          glowRadius: 3,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.logout, color: Colors.red, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  'Sign Out',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            content: Text(
              'Are you sure you want to sign out?',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.secondaryGray,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.secondaryGray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildGlowContainer(
                gradientColors: [Colors.red, Colors.red.withOpacity(0.7)],
                glowRadius: 2,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Handle sign out
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginView(),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Sign Out',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
