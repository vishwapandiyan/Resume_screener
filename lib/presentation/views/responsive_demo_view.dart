import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/widgets/responsive_layout.dart';

class ResponsiveDemoView extends StatelessWidget {
  const ResponsiveDemoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundWhite,
        elevation: 0,
        title: Text(
          'Responsive Design Demo',
          style: TextStyle(
            color: AppTheme.primaryBlack,
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              mobile: 18,
              tablet: 20,
              desktop: 22,
            ),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ResponsiveBuilder(
        builder: (context, screenSize) {
          return SingleChildScrollView(
            padding: ResponsiveUtils.getResponsivePadding(context),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveUtils.getResponsiveContentMaxWidth(context),
              ),
              child: Column(
                children: [
                  _buildScreenInfoCard(context),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      mobile: 24.0,
                      tablet: 28.0,
                      desktop: 32.0,
                    ),
                  ),
                  _buildResponsiveGridDemo(context),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      mobile: 24.0,
                      tablet: 28.0,
                      desktop: 32.0,
                    ),
                  ),
                  _buildResponsiveStatsDemo(context),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      mobile: 24.0,
                      tablet: 28.0,
                      desktop: 32.0,
                    ),
                  ),
                  _buildLayoutComparison(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScreenInfoCard(BuildContext context) {
    final screenSize = ResponsiveUtils.getScreenSize(context);
    final isWeb = ResponsiveUtils.isWeb();
    final isMobile = ResponsiveUtils.isMobile(context);
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(
            context,
            mobile: 16.0,
            tablet: 18.0,
            desktop: 20.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF4285F4).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
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
                child: Icon(
                  Icons.devices,
                  color: Colors.white,
                  size: ResponsiveUtils.getResponsiveIconSize(
                    context,
                    mobile: 20.0,
                    tablet: 22.0,
                    desktop: 24.0,
                  ),
                ),
              ),
              SizedBox(
                width: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  mobile: 12.0,
                  tablet: 14.0,
                  desktop: 16.0,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Screen Info',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 18.0,
                          tablet: 20.0,
                          desktop: 22.0,
                        ),
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryBlack,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Platform: ${isWeb ? 'Web' : 'Mobile/Desktop'}',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 14.0,
                          tablet: 15.0,
                          desktop: 16.0,
                        ),
                        color: AppTheme.secondaryGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ResponsiveGrid(
            crossAxisCount: ResponsiveUtils.getResponsiveGridColumns(context),
            children: [
              _buildInfoItem('Screen Size', screenSize.name.toUpperCase()),
              _buildInfoItem('Is Mobile', isMobile.toString()),
              _buildInfoItem('Is Desktop', isDesktop.toString()),
              _buildInfoItem('Is Web', isWeb.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryGray,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveGridDemo(BuildContext context) {
    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(
            context,
            mobile: 16.0,
            tablet: 18.0,
            desktop: 20.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF34A853).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF34A853).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.grid_view,
                  color: const Color(0xFF34A853),
                  size: ResponsiveUtils.getResponsiveIconSize(
                    context,
                    mobile: 20.0,
                    tablet: 22.0,
                    desktop: 24.0,
                  ),
                ),
              ),
              SizedBox(
                width: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  mobile: 12.0,
                  tablet: 14.0,
                  desktop: 16.0,
                ),
              ),
              Text(
                'Responsive Grid Demo',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                    context,
                    mobile: 18.0,
                    tablet: 20.0,
                    desktop: 22.0,
                  ),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryBlack,
                ),
              ),
            ],
          ),
          ResponsiveGrid(
            crossAxisCount: ResponsiveUtils.getResponsiveGridColumns(context),
            children: List.generate(6, (index) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF4285F4).withOpacity(0.1),
                      const Color(0xFF8B5CF6).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF4285F4).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star,
                      color: const Color(0xFF4285F4),
                      size: ResponsiveUtils.getResponsiveIconSize(
                        context,
                        mobile: 24.0,
                        tablet: 28.0,
                        desktop: 32.0,
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        mobile: 8.0,
                        tablet: 10.0,
                        desktop: 12.0,
                      ),
                    ),
                    Text(
                      'Item ${index + 1}',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 14.0,
                          tablet: 15.0,
                          desktop: 16.0,
                        ),
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlack,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveStatsDemo(BuildContext context) {
    final stats = [
      {
        'title': 'Mobile Users',
        'value': '65%',
        'color': const Color(0xFF4285F4),
      },
      {
        'title': 'Tablet Users',
        'value': '20%',
        'color': const Color(0xFF34A853),
      },
      {
        'title': 'Desktop Users',
        'value': '15%',
        'color': const Color(0xFF8B5CF6),
      },
    ];

    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(
            context,
            mobile: 16.0,
            tablet: 18.0,
            desktop: 20.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFFBBC04).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBBC04).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.analytics,
                  color: const Color(0xFFFBBC04),
                  size: ResponsiveUtils.getResponsiveIconSize(
                    context,
                    mobile: 20.0,
                    tablet: 22.0,
                    desktop: 24.0,
                  ),
                ),
              ),
              SizedBox(
                width: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  mobile: 12.0,
                  tablet: 14.0,
                  desktop: 16.0,
                ),
              ),
              Text(
                'Responsive Stats Demo',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                    context,
                    mobile: 18.0,
                    tablet: 20.0,
                    desktop: 22.0,
                  ),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryBlack,
                ),
              ),
            ],
          ),
          ResponsiveBuilder(
            builder: (context, screenSize) {
              final isMobile = ResponsiveUtils.isMobile(context);

              if (isMobile) {
                return Column(
                  children: stats.map((stat) => _buildStatCard(stat)).toList(),
                );
              } else {
                return Row(
                  children: stats
                      .map((stat) => Expanded(child: _buildStatCard(stat)))
                      .toList(),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (stat['color'] as Color).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (stat['color'] as Color).withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (stat['color'] as Color).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.trending_up,
              color: stat['color'] as Color,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            stat['value'] as String,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: stat['color'] as Color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat['title'] as String,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutComparison(BuildContext context) {
    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(
            context,
            mobile: 16.0,
            tablet: 18.0,
            desktop: 20.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFEA4335).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEA4335).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.compare_arrows,
                  color: const Color(0xFFEA4335),
                  size: ResponsiveUtils.getResponsiveIconSize(
                    context,
                    mobile: 20.0,
                    tablet: 22.0,
                    desktop: 24.0,
                  ),
                ),
              ),
              SizedBox(
                width: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  mobile: 12.0,
                  tablet: 14.0,
                  desktop: 16.0,
                ),
              ),
              Text(
                'Layout Comparison',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                    context,
                    mobile: 18.0,
                    tablet: 20.0,
                    desktop: 22.0,
                  ),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryBlack,
                ),
              ),
            ],
          ),
          ResponsiveBuilder(
            builder: (context, screenSize) {
              final isMobile = ResponsiveUtils.isMobile(context);

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.1),
                      Colors.purple.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF4285F4).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      isMobile ? Icons.phone_android : Icons.desktop_windows,
                      size: 48,
                      color: const Color(0xFF4285F4),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isMobile
                          ? 'Mobile Layout Active\n(Stacked vertically)'
                          : 'Desktop Layout Active\n(Side-by-side)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlack,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Screen size: ${screenSize.name}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.secondaryGray,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
