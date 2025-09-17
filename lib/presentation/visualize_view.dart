import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
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
  late AnimationController _carouselController;
  late PageController _pageController;

  int _selectedCandidateIndex = 0;
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;
  int _currentCarouselIndex = 0;
  Timer? _carouselTimer;

  // Real-time data
  List<Map<String, dynamic>> _realTimeStats = [];
  List<Map<String, dynamic>> _skillTrends = [];
  Map<String, dynamic> _jobMarketData = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadRealTimeData();
    _startCarouselTimer();
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
    _carouselController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _pageController = PageController();

    _animationController.forward();
    _chartAnimationController.forward();
    _dataAnimationController.forward();
  }

  void _startCarouselTimer() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        _currentCarouselIndex =
            (_currentCarouselIndex + 1) % _realTimeStats.length;
        _pageController.animateToPage(
          _currentCarouselIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _loadRealTimeData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
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
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _realTimeStats = [
        {
          'title': 'Total Applications',
          'value': widget.candidates.length,
          'change': '+12%',
          'trend': 'up',
          'color': const Color(0xFF4285F4),
          'icon': Icons.people,
        },
        {
          'title': 'High Matches',
          'value': widget.candidates.where((c) => c.semanticScore > 0.7).length,
          'change': '+8%',
          'trend': 'up',
          'color': const Color(0xFF34A853),
          'icon': Icons.star,
        },
        {
          'title': 'Avg Response Time',
          'value': '2.3h',
          'change': '-15%',
          'trend': 'down',
          'color': const Color(0xFFFBBC04),
          'icon': Icons.schedule,
        },
        {
          'title': 'Success Rate',
          'value':
              '${((widget.candidates.where((c) => c.semanticScore > 0.6).length / widget.candidates.length) * 100).toStringAsFixed(1)}%',
          'change': '+5%',
          'trend': 'up',
          'color': const Color(0xFF8B5CF6),
          'icon': Icons.trending_up,
        },
        {
          'title': 'Processing Speed',
          'value': '1.2s',
          'change': '+20%',
          'trend': 'up',
          'color': const Color(0xFF00BCD4),
          'icon': Icons.speed,
        },
        {
          'title': 'Quality Score',
          'value': '8.7/10',
          'change': '+3%',
          'trend': 'up',
          'color': const Color(0xFFE91E63),
          'icon': Icons.verified,
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
    _carouselController.dispose();
    _pageController.dispose();
    _carouselTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          _buildModernAppBar(),
          SliverToBoxAdapter(
            child: _isLoading
                ? _buildLoadingState()
                : _errorMessage != null
                ? _buildErrorState()
                : _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF4285F4).withOpacity(0.1),
                const Color(0xFF8B5CF6).withOpacity(0.1),
                const Color(0xFF00BCD4).withOpacity(0.1),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppTheme.primaryBlack,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Real-time ATS Analytics',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: AppTheme.primaryBlack,
                                fontWeight: FontWeight.w800,
                                fontSize: 24,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Advanced candidate insights & performance metrics',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppTheme.secondaryGray,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
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
                    child: _isRefreshing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : InkWell(
                            onTap: _refreshData,
                            child: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF4285F4)),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading real-time data...',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.secondaryGray,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 400,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _errorMessage ?? 'An error occurred',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.primaryBlack,
                  fontWeight: FontWeight.w600,
                ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCarousel(),
          const SizedBox(height: 32),
          _buildModernDashboard(),
          const SizedBox(height: 32),
          _buildModernCandidatesList(),
        ],
      ),
    );
  }

  Widget _buildStatsCarousel() {
    return Container(
      height: 200,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentCarouselIndex = index;
          });
        },
        itemCount: _realTimeStats.length,
        itemBuilder: (context, index) {
          final stat = _realTimeStats[index];
          return _buildModernStatCard(stat, index);
        },
      ),
    );
  }

  Widget _buildModernStatCard(Map<String, dynamic> stat, int index) {
    return AnimatedBuilder(
      animation: _dataAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * _dataAnimationController.value),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (stat['color'] as Color).withOpacity(0.1),
                  (stat['color'] as Color).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: (stat['color'] as Color).withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: (stat['color'] as Color).withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: (stat['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        stat['icon'] as IconData,
                        color: stat['color'] as Color,
                        size: 32,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: (stat['trend'] as String) == 'up'
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
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
                              fontWeight: FontWeight.w700,
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
                const Spacer(),
                Text(
                  stat['value'].toString(),
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: stat['color'] as Color,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  stat['title'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondaryGray,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernDashboard() {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        final isMobile = ResponsiveUtils.isMobile(context);

        if (isMobile) {
          return Column(
            children: [
              _buildModernCandidateProfile(),
              const SizedBox(height: 20),
              _buildModernSkillsAnalysis(),
              const SizedBox(height: 20),
              _buildModernPerformanceChart(),
            ],
          );
        } else {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    _buildModernCandidateProfile(),
                    const SizedBox(height: 20),
                    _buildModernSkillsAnalysis(),
                    const SizedBox(height: 20),
                    _buildModernPerformanceChart(),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    _buildModernJobMarketInsights(),
                    const SizedBox(height: 20),
                    _buildModernMatchScoreCard(),
                  ],
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildModernCandidateProfile() {
    if (widget.candidates.isEmpty) return const SizedBox.shrink();

    final selectedCandidate = widget.candidates[_selectedCandidateIndex];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4285F4), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Candidate',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondaryGray,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedCandidate.candidate,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryBlack,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF34A853).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(selectedCandidate.semanticScore * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF34A853),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Skills Match',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryGray,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedCandidate.skills.take(6).map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF4285F4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  skill,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4285F4),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSkillsAnalysis() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Color(0xFF8B5CF6),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Skills Analysis',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ..._skillTrends.take(5).map((skill) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      skill['skill'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlack,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (skill['percentage'] as int) / 100,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4285F4), Color(0xFF8B5CF6)],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${skill['percentage']}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.secondaryGray,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildModernPerformanceChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BCD4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Color(0xFF00BCD4),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Performance Trends',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryBlack,
                ),
              ),
            ],
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
                    spots: [
                      const FlSpot(0, 3),
                      const FlSpot(1, 1),
                      const FlSpot(2, 4),
                      const FlSpot(3, 2),
                      const FlSpot(4, 5),
                      const FlSpot(5, 3),
                    ],
                    isCurved: true,
                    color: const Color(0xFF4285F4),
                    barWidth: 4,
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

  Widget _buildModernJobMarketInsights() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF34A853).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.work,
                  color: Color(0xFF34A853),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Market Insights',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInsightItem(
            'Demand Level',
            _jobMarketData['demand'] as String,
            Icons.trending_up,
          ),
          _buildInsightItem(
            'Competition',
            _jobMarketData['competition'] as String,
            Icons.people,
          ),
          _buildInsightItem(
            'Avg Salary',
            _jobMarketData['avgSalary'] as String,
            Icons.attach_money,
          ),
          _buildInsightItem(
            'Growth Rate',
            _jobMarketData['growthRate'] as String,
            Icons.trending_up,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.secondaryGray),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBlack,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.secondaryGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernMatchScoreCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4285F4), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4285F4).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Overall Match Score',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${((widget.candidates.where((c) => c.semanticScore > 0.6).length / widget.candidates.length) * 100).toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Based on ATS analysis',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCandidatesList() {
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF4285F4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.filter_list,
                    size: 16,
                    color: Color(0xFF4285F4),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Filter',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4285F4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.candidates.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: const Color(0xFFE5E7EB).withOpacity(0.5),
            ),
            itemBuilder: (context, index) {
              final candidate = widget.candidates[index];
              final isSelected = index == _selectedCandidateIndex;

              return _buildModernCandidateListItem(
                candidate,
                index,
                isSelected,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildModernCandidateListItem(
    RankedResume candidate,
    int index,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCandidateIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4285F4).withOpacity(0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSelected
                      ? [const Color(0xFF4285F4), const Color(0xFF8B5CF6)]
                      : [const Color(0xFFE5E7EB), const Color(0xFFF3F4F6)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  candidate.candidate.isNotEmpty
                      ? candidate.candidate[0].toUpperCase()
                      : 'C',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : AppTheme.secondaryGray,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    candidate.candidate,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? const Color(0xFF4285F4)
                          : AppTheme.primaryBlack,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: const Color(0xFFFBBC04),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${(candidate.semanticScore * 100).toStringAsFixed(1)}% Match',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.secondaryGray,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.work, size: 16, color: AppTheme.secondaryGray),
                      const SizedBox(width: 4),
                      Text(
                        '${candidate.skills.length} Skills',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.secondaryGray,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: candidate.skills.take(4).map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF4285F4).withOpacity(0.1)
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          skill,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? const Color(0xFF4285F4)
                                : AppTheme.secondaryGray,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getScoreColor(
                      candidate.semanticScore,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(candidate.semanticScore * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _getScoreColor(candidate.semanticScore),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4285F4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 0.8) return const Color(0xFF34A853);
    if (score >= 0.6) return const Color(0xFFFBBC04);
    return const Color(0xFFEA4335);
  }
}
