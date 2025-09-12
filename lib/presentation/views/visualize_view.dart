import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../models/ats_workflow_models.dart';

class VisualizeView extends StatefulWidget {
  final ATSProcessingResult processing;
  final SemanticRankingResult ranking;
  final String jobTitle;
  final List<RankedResume> candidates;

  const VisualizeView({
    Key? key,
    required this.processing,
    required this.ranking,
    required this.jobTitle,
    required this.candidates,
  }) : super(key: key);

  @override
  State<VisualizeView> createState() => _VisualizeViewState();
}

class _VisualizeViewState extends State<VisualizeView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _chartAnimationController;
  late AnimationController _dataAnimationController;

  int _selectedCandidateIndex = 0;
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;

  // Real-time data
  List<Map<String, dynamic>> _realTimeStats = [];
  List<Map<String, dynamic>> _skillTrends = [];
  Map<String, dynamic> _jobMarketData = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadRealTimeData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _dataAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animationController.forward();
    _chartAnimationController.forward();
    _dataAnimationController.forward();
  }

  Future<void> _loadRealTimeData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetch real-time data from API
      await Future.wait([
        _fetchRealTimeStats(),
        _fetchSkillTrends(),
        _fetchJobMarketData(),
      ]);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load real-time data: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchRealTimeStats() async {
    // Simulate API call - replace with actual API endpoint
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _realTimeStats = [
        {
          'title': 'Total Applications',
          'value': widget.candidates.length,
          'change': '+12%',
          'trend': 'up',
          'color': const Color(0xFF4285F4),
        },
        {
          'title': 'High Matches',
          'value': widget.candidates.where((c) => c.semanticScore > 0.7).length,
          'change': '+8%',
          'trend': 'up',
          'color': const Color(0xFF34A853),
        },
        {
          'title': 'Avg Response Time',
          'value': '2.3h',
          'change': '-15%',
          'trend': 'down',
          'color': const Color(0xFFFBBC04),
        },
        {
          'title': 'Success Rate',
          'value':
              '${((widget.candidates.where((c) => c.semanticScore > 0.6).length / widget.candidates.length) * 100).toStringAsFixed(1)}%',
          'change': '+5%',
          'trend': 'up',
          'color': const Color(0xFF8B5CF6),
        },
      ];
    });
  }

  Future<void> _fetchSkillTrends() async {
    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _skillTrends = _extractSkillTrends();
    });
  }

  Future<void> _fetchJobMarketData() async {
    await Future.delayed(const Duration(milliseconds: 200));

    setState(() {
      _jobMarketData = {
        'demand': 'High',
        'competition': 'Medium',
        'avgSalary': '\$85,000',
        'growthRate': '+12%',
        'skillsInDemand': ['React', 'Python', 'AWS', 'Docker', 'Kubernetes'],
      };
    });
  }

  List<Map<String, dynamic>> _extractSkillTrends() {
    final skillCounts = <String, int>{};

    for (final candidate in widget.candidates) {
      for (final skill in candidate.skills) {
        skillCounts[skill] = (skillCounts[skill] ?? 0) + 1;
      }
    }

    return skillCounts.entries
        .map(
          (entry) => {
            'skill': entry.key,
            'count': entry.value,
            'percentage': (entry.value / widget.candidates.length * 100)
                .round(),
            'trend': _generateSkillTrend(),
          },
        )
        .toList()
      ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
  }

  List<double> _generateSkillTrend() {
    return List.generate(
      5,
      (index) => 0.2 + (index * 0.15) + (index % 3 == 0 ? 0.1 : -0.05),
    );
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });

    await _loadRealTimeData();

    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _chartAnimationController.dispose();
    _dataAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
          ? _buildErrorState()
          : _buildMainContent(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
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
          child: const Icon(Icons.arrow_back, color: AppTheme.primaryBlack),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Real-time ATS Analytics',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: AppTheme.primaryBlack,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _refreshData,
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4285F4), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4285F4).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : const Icon(Icons.refresh, color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color(0xFF4285F4)),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading real-time data...',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppTheme.secondaryGray),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.withOpacity(0.7),
          ),
          const SizedBox(height: 24),
          Text(
            _errorMessage ?? 'An error occurred',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppTheme.primaryBlack),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadRealTimeData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4285F4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        return SingleChildScrollView(
          padding: ResponsiveUtils.getResponsivePadding(context),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveUtils.getResponsiveContentMaxWidth(context),
            ),
            child: ResponsiveColumn(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: ResponsiveUtils.getResponsiveSpacing(
                context,
                mobile: 24.0,
                tablet: 28.0,
                desktop: 32.0,
              ),
              children: [
                _buildRealTimeStats(),
                _buildMainDashboard(),
                _buildCandidatesGrid(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRealTimeStats() {
    return AnimatedBuilder(
      animation: _dataAnimationController,
      builder: (context, child) {
        return ResponsiveScrollableRow(
          minWidth: 800.0, // Minimum width before switching to vertical
          children: _realTimeStats.asMap().entries.map((entry) {
            final index = entry.key;
            final stat = entry.value;
            return SizedBox(
              width: 200.0, // Fixed width for stat cards
              child: _buildStatCard(stat, index),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + (index * 200)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * animValue),
          child: Opacity(
            opacity: animValue,
            child: Container(
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
                    color: (stat['color'] as Color).withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: (stat['color'] as Color).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              (stat['color'] as Color).withOpacity(0.1),
                              (stat['color'] as Color).withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getStatIcon(stat['title'] as String),
                          color: stat['color'] as Color,
                          size: ResponsiveUtils.getResponsiveIconSize(
                            context,
                            mobile: 20.0,
                            tablet: 22.0,
                            desktop: 24.0,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: (stat['trend'] as String) == 'up'
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              (stat['trend'] as String) == 'up'
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              size: 16,
                              color: (stat['trend'] as String) == 'up'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              stat['change'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: (stat['trend'] as String) == 'up'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      mobile: 12.0,
                      tablet: 14.0,
                      desktop: 16.0,
                    ),
                  ),
                  Text(
                    stat['value'].toString(),
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        mobile: 24.0,
                        tablet: 26.0,
                        desktop: 28.0,
                      ),
                      fontWeight: FontWeight.w800,
                      color: stat['color'] as Color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stat['title'] as String,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        mobile: 12.0,
                        tablet: 13.0,
                        desktop: 14.0,
                      ),
                      fontWeight: FontWeight.w600,
                      color: AppTheme.secondaryGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getStatIcon(String title) {
    switch (title) {
      case 'Total Applications':
        return Icons.people;
      case 'High Matches':
        return Icons.star;
      case 'Avg Response Time':
        return Icons.schedule;
      case 'Success Rate':
        return Icons.trending_up;
      default:
        return Icons.analytics;
    }
  }

  Widget _buildMainDashboard() {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        final isMobile = ResponsiveUtils.isMobile(context);

        if (isMobile) {
          // Stack everything vertically on mobile
          return ResponsiveColumn(
            spacing: 24.0,
            children: [
              _buildCandidateProfile(),
              _buildSkillsAnalysis(),
              _buildPerformanceChart(),
              _buildJobMarketInsights(),
              _buildMatchScoreCard(),
              _buildSkillTrendsChart(),
              _buildQuickActions(),
            ],
          );
        } else {
          // Use side-by-side layout on larger screens
          return ResponsiveRow(
            spacing: 24.0,
            children: [
              // Left Side - 60% width
              Expanded(
                flex: 6,
                child: ResponsiveColumn(
                  spacing: 24.0,
                  children: [
                    _buildCandidateProfile(),
                    _buildSkillsAnalysis(),
                    _buildPerformanceChart(),
                  ],
                ),
              ),
              // Right Side - 40% width
              Expanded(
                flex: 4,
                child: ResponsiveColumn(
                  spacing: 24.0,
                  children: [
                    _buildJobMarketInsights(),
                    _buildMatchScoreCard(),
                    _buildSkillTrendsChart(),
                    _buildQuickActions(),
                  ],
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildCandidateProfile() {
    if (widget.candidates.isEmpty) return const SizedBox.shrink();

    final candidate = widget.candidates[_selectedCandidateIndex];

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Profile Picture
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1000),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.8 + (0.2 * value),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFEA4335),
                                    Color(0xFF8B5CF6),
                                    Color(0xFF4285F4),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: CircleAvatar(
                                backgroundColor: const Color(
                                  0xFF4285F4,
                                ).withOpacity(0.1),
                                child: Text(
                                  candidate.candidate.isNotEmpty
                                      ? candidate.candidate[0].toUpperCase()
                                      : 'C',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF4285F4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                  // Candidate Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          candidate.candidate.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryBlack,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.jobTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.secondaryGray,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF4285F4),
                                    Color(0xFF8B5CF6),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${(candidate.semanticScore * 100).toStringAsFixed(1)}% Match',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF34A853).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(
                                    0xFF34A853,
                                  ).withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                'ATS: ${candidate.atsScore}',
                                style: const TextStyle(
                                  color: Color(0xFF34A853),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Contact and Skills
              Row(
                children: [
                  Expanded(child: _buildContactInfo(candidate)),
                  const SizedBox(width: 20),
                  Expanded(child: _buildSkillsPreview(candidate)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactInfo(RankedResume candidate) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Info',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            Icons.email,
            candidate.email.isNotEmpty ? candidate.email : 'No email provided',
            const Color(0xFF4285F4),
          ),
          const SizedBox(height: 8),
          _buildContactItem(
            Icons.work,
            candidate.experience.isNotEmpty
                ? candidate.experience
                : 'Experience not specified',
            const Color(0xFF34A853),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsPreview(RankedResume candidate) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Skills',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: candidate.skills
                .take(4)
                .map(
                  (skill) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4285F4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF4285F4).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      skill,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4285F4),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryBlack,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsAnalysis() {
    return AnimatedBuilder(
      animation: _chartAnimationController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Skills Analysis',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryBlack,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.analytics, size: 16),
                    label: const Text('View Details'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF4285F4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ..._skillTrends
                  .take(6)
                  .map((skill) => _buildSkillProgressBar(skill))
                  .toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkillProgressBar(Map<String, dynamic> skill) {
    final progress =
        _chartAnimationController.value * ((skill['percentage'] as int) / 100);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                skill['skill'] as String,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlack,
                ),
              ),
              Row(
                children: [
                  Text(
                    '${skill['percentage']}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4285F4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${skill['count']}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 1000),
                  width: MediaQuery.of(context).size.width * 0.4 * progress,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4285F4), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Trends',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _generateChartSpots(),
                    isCurved: true,
                    color: const Color(0xFF4285F4),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF4285F4).withOpacity(0.1),
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

  List<FlSpot> _generateChartSpots() {
    return List.generate(7, (index) {
      return FlSpot(
        index.toDouble(),
        0.3 + (index * 0.1) + (index % 2 == 0 ? 0.1 : -0.05),
      );
    });
  }

  Widget _buildJobMarketInsights() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Job Market Insights',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: 20),
          _buildMarketInsightItem(
            'Demand Level',
            _jobMarketData['demand'] ?? 'N/A',
            const Color(0xFF34A853),
          ),
          _buildMarketInsightItem(
            'Competition',
            _jobMarketData['competition'] ?? 'N/A',
            const Color(0xFFFBBC04),
          ),
          _buildMarketInsightItem(
            'Avg Salary',
            _jobMarketData['avgSalary'] ?? 'N/A',
            const Color(0xFF4285F4),
          ),
          _buildMarketInsightItem(
            'Growth Rate',
            _jobMarketData['growthRate'] ?? 'N/A',
            const Color(0xFF8B5CF6),
          ),
          const SizedBox(height: 16),
          const Text(
            'Skills in Demand',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (_jobMarketData['skillsInDemand'] as List<dynamic>? ?? [])
                .take(5)
                .map(
                  (skill) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4285F4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF4285F4).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      skill.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4285F4),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketInsightItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryGray,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchScoreCard() {
    final candidate = widget.candidates.isNotEmpty
        ? widget.candidates[_selectedCandidateIndex]
        : null;
    if (candidate == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4285F4), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4285F4).withOpacity(0.3),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'Match Score',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1500),
                tween: Tween(begin: 0.0, end: candidate.semanticScore),
                builder: (context, value, child) {
                  return Text(
                    '${(value * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Text(
                candidate.candidate,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkillTrendsChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Skill Trends',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: _skillTrends.take(5).map((skill) {
                  final index = _skillTrends.indexOf(skill);
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: (skill['percentage'] as int).toDouble(),
                        color: const Color(0xFF4285F4),
                        width: 16,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: 20),
          _buildQuickActionButton(
            'Export Report',
            Icons.download,
            const Color(0xFF4285F4),
            () {},
          ),
          const SizedBox(height: 12),
          _buildQuickActionButton(
            'Schedule Interview',
            Icons.calendar_today,
            const Color(0xFF34A853),
            () {},
          ),
          const SizedBox(height: 12),
          _buildQuickActionButton(
            'Send Email',
            Icons.email,
            const Color(0xFFFBBC04),
            () {},
          ),
          const SizedBox(height: 12),
          _buildQuickActionButton(
            'View Full Profile',
            Icons.person,
            const Color(0xFF8B5CF6),
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCandidatesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'All Candidates',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryBlack,
              ),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.filter_list, size: 16),
              label: const Text('Filter'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4285F4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ResponsiveFlexibleGrid(
          crossAxisCount: ResponsiveUtils.getResponsiveGridColumns(context),
          crossAxisSpacing: ResponsiveUtils.getResponsiveSpacing(
            context,
            mobile: 12.0,
            tablet: 14.0,
            desktop: 16.0,
          ),
          mainAxisSpacing: ResponsiveUtils.getResponsiveSpacing(
            context,
            mobile: 12.0,
            tablet: 14.0,
            desktop: 16.0,
          ),
          childAspectRatio: ResponsiveUtils.getResponsiveAspectRatio(context),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemWidth: 200.0, // Fixed width for candidate cards
          children: List.generate(widget.candidates.length, (index) {
            final candidate = widget.candidates[index];
            final isSelected = index == _selectedCandidateIndex;

            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 300 + (index * 100)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.9 + (0.1 * value),
                  child: Opacity(
                    opacity: value,
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedCandidateIndex = index),
                      child: Container(
                        padding: ResponsiveUtils.getResponsivePadding(context),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF4285F4).withOpacity(0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtils.getResponsiveBorderRadius(
                              context,
                              mobile: 16.0,
                              tablet: 18.0,
                              desktop: 20.0,
                            ),
                          ),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF4285F4)
                                : const Color(0xFFE5E7EB),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? const Color(0xFF4285F4).withOpacity(0.2)
                                  : Colors.black.withOpacity(0.05),
                              blurRadius: isSelected ? 16 : 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: ResponsiveUtils.getResponsiveIconSize(
                                context,
                                mobile: 24.0,
                                tablet: 27.0,
                                desktop: 30.0,
                              ),
                              backgroundColor: const Color(
                                0xFF4285F4,
                              ).withOpacity(0.1),
                              child: Text(
                                candidate.candidate.isNotEmpty
                                    ? candidate.candidate[0].toUpperCase()
                                    : 'C',
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveUtils.getResponsiveFontSize(
                                        context,
                                        mobile: 20.0,
                                        tablet: 22.0,
                                        desktop: 24.0,
                                      ),
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF4285F4),
                                ),
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
                              candidate.candidate,
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
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(
                              height: ResponsiveUtils.getResponsiveSpacing(
                                context,
                                mobile: 6.0,
                                tablet: 7.0,
                                desktop: 8.0,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    ResponsiveUtils.getResponsiveSpacing(
                                      context,
                                      mobile: 10.0,
                                      tablet: 11.0,
                                      desktop: 12.0,
                                    ),
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF34A853).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${(candidate.semanticScore * 100).toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveUtils.getResponsiveFontSize(
                                        context,
                                        mobile: 10.0,
                                        tablet: 11.0,
                                        desktop: 12.0,
                                      ),
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF34A853),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
