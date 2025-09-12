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
  int _selectedCandidateIndex = 0;
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animationController.forward();
    _chartAnimationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _chartAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
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
          'ATS Analysis Visualization',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.primaryBlack,
                fontWeight: FontWeight.w700,
              ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showCandidateHistory(),
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
              child: const Icon(Icons.history, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ResponsiveBuilder(
        builder: (context, screenSize) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverviewCards(),
                const SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildCandidateProfile(),
                          const SizedBox(height: 24),
                          _buildSkillsAnalysis(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          _buildProjectStatistics(),
                          const SizedBox(height: 24),
                          _buildMatchScoreCard(),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildCandidatesGrid(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCards() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Row(
          children: [
            Expanded(
              child: _buildStatsCard(
                'Total Candidates',
                '${widget.candidates.length}',
                const Color(0xFF4285F4),
                Icons.people,
                delay: 0,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatsCard(
                'High Matches',
                '${widget.candidates.where((c) => c.semanticScore > 0.7).length}',
                const Color(0xFF34A853),
                Icons.star,
                delay: 200,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatsCard(
                'Avg Score',
                '${(widget.candidates.fold(0.0, (sum, c) => sum + c.semanticScore) / widget.candidates.length * 100).toStringAsFixed(1)}%',
                const Color(0xFFFBBC04),
                Icons.trending_up,
                delay: 400,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatsCard(
                'Job Title',
                widget.jobTitle,
                const Color(0xFF8B5CF6),
                Icons.work,
                delay: 600,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsCard(String title, String value, Color color, IconData icon, {int delay = 0}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * animValue),
          child: Opacity(
            opacity: animValue,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: color.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
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
              // Profile Picture with Gradient Ring
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
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFEA4335), Color(0xFF8B5CF6), Color(0xFF4285F4)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: CircleAvatar(
                            backgroundColor: const Color(0xFF4285F4).withOpacity(0.1),
                            child: Text(
                              candidate.candidate.isNotEmpty 
                                  ? candidate.candidate[0].toUpperCase()
                                  : 'C',
                              style: const TextStyle(
                                fontSize: 36,
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
              const SizedBox(height: 24),
              
              // Name with Gradient Background
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEA4335), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  candidate.candidate.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Job Title
              Text(
                widget.jobTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlack,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Contact Information
              _buildContactInfo(candidate),
              const SizedBox(height: 24),
              
              // Social Media Links
              _buildSocialLinks(),
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
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildContactItem(
            Icons.email,
            'Email',
            candidate.email.isNotEmpty ? candidate.email : 'No email provided',
            const Color(0xFF4285F4),
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            Icons.phone,
            'Phone',
            'Contact not provided',
            const Color(0xFF34A853),
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            Icons.location_on,
            'Location',
            'Location not specified',
            const Color(0xFFFBBC04),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
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
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryBlack,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLinks() {
    final socialLinks = [
      {'icon': Icons.facebook, 'color': const Color(0xFF1877F2)},
      {'icon': Icons.share, 'color': const Color(0xFFBD081C)},
      {'icon': Icons.work, 'color': const Color(0xFF0077B5)},
      {'icon': Icons.alternate_email, 'color': const Color(0xFF1DA1F2)},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: socialLinks.map((link) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 800 + (socialLinks.indexOf(link) * 200)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Opacity(
                  opacity: value,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          link['color'] as Color,
                          (link['color'] as Color).withOpacity(0.7),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (link['color'] as Color).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      link['icon'] as IconData,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSkillsAnalysis() {
    final skills = _extractSkills();
    
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
              const Text(
                'Skills Analysis',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryBlack,
                ),
              ),
              const SizedBox(height: 24),
              ...skills.take(6).map((skill) => _buildSkillProgressBar(skill)).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkillProgressBar(Map<String, dynamic> skill) {
    final progress = _chartAnimationController.value * (skill['level'] / 100);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                skill['name'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlack,
                ),
              ),
              Text(
                '${skill['level']}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4285F4),
                ),
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
                  width: MediaQuery.of(context).size.width * 0.3 * progress,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4285F4), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: -2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBBC04),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectStatistics() {
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
              const Text(
                'Project Statistics',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryBlack,
                ),
              ),
              const SizedBox(height: 24),
              
              // Total Projects
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFFEA4335)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      '1,735',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Completed Projects',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlack,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Success Rate
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF34A853), Color(0xFF4285F4)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      '97%',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Success Rate',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlack,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Donut Charts
              _buildDonutCharts(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDonutCharts() {
    final chartData = [
      {'name': 'Web Design', 'value': 450, 'color': const Color(0xFF8B5CF6)},
      {'name': 'Mobile Apps', 'value': 350, 'color': const Color(0xFF4285F4)},
      {'name': 'UI/UX Design', 'value': 300, 'color': const Color(0xFFEA4335)},
      {'name': 'Backend Dev', 'value': 200, 'color': const Color(0xFF34A853)},
      {'name': 'Others', 'value': 435, 'color': const Color(0xFFFBBC04)},
    ];

    return Column(
      children: chartData.map((data) {
        final index = chartData.indexOf(data);
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 1000 + (index * 200)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: Stack(
                      children: [
                        CircularProgressIndicator(
                          value: value * ((data['value'] as int) / 1000),
                          strokeWidth: 6,
                          backgroundColor: const Color(0xFFF0F0F0),
                          valueColor: AlwaysStoppedAnimation(data['color'] as Color),
                        ),
                        Center(
                          child: Text(
                            '${data['value']}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryBlack,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      data['name'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlack,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildMatchScoreCard() {
    final candidate = widget.candidates.isNotEmpty ? widget.candidates[_selectedCandidateIndex] : null;
    if (candidate == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(32),
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
                      fontSize: 48,
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
                  fontSize: 16,
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

  Widget _buildCandidatesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'All Candidates',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppTheme.primaryBlack,
          ),
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _getResponsiveGridColumns(context),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: widget.candidates.length,
          itemBuilder: (context, index) {
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
                      onTap: () => setState(() => _selectedCandidateIndex = index),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF4285F4).withOpacity(0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF4285F4) : const Color(0xFFE5E7EB),
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
                              radius: 30,
                              backgroundColor: const Color(0xFF4285F4).withOpacity(0.1),
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
                            const SizedBox(height: 12),
                            Text(
                              candidate.candidate,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryBlack,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF34A853).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${(candidate.semanticScore * 100).toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF34A853),
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
          },
        ),
      ],
    );
  }

  void _showCandidateHistory() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4285F4), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.history, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    const Text(
                      'Candidate History',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: widget.candidates.length,
                    itemBuilder: (context, index) {
                      final candidate = widget.candidates[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: const Color(0xFF4285F4).withOpacity(0.1),
                              child: Text(
                                candidate.candidate.isNotEmpty 
                                    ? candidate.candidate[0].toUpperCase()
                                    : 'C',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF4285F4),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              candidate.candidate,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryBlack,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(candidate.semanticScore * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF34A853),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _extractSkills() {
    // Extract skills from the ranking data
    final skills = <String, int>{};
    
    for (final candidate in widget.candidates) {
      final candidateSkills = candidate.skills ?? [];
      for (final skill in candidateSkills) {
        skills[skill] = (skills[skill] ?? 0) + 1;
      }
    }
    
    // Convert to list and sort by frequency
    return skills.entries
        .map((entry) => {
              'name': entry.key,
              'level': (entry.value / widget.candidates.length * 100).round().clamp(20, 95),
            })
        .toList()
        ..sort((a, b) => (b['level'] as int).compareTo(a['level'] as int));
  }

  int _getResponsiveGridColumns(BuildContext context) {
    final screenSize = ResponsiveUtils.getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.mobile:
        return 1;
      case ScreenSize.tablet:
        return 2;
      case ScreenSize.desktop:
      case ScreenSize.largeDesktop:
      case ScreenSize.extraLargeDesktop:
        return 3;
    }
  }
}
