import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/widgets/responsive_layout.dart';
import 'ats_results_view.dart';
import '../../services/ats_service.dart';
import '../../models/ats_workflow_models.dart';

class ProcessingView extends StatefulWidget {
  final List<PlatformFile> files;
  final String jobTitle;
  final String jobDescription;
  final int atsThreshold;

  const ProcessingView({
    super.key,
    required this.files,
    required this.jobTitle,
    required this.jobDescription,
    required this.atsThreshold,
  });

  @override
  State<ProcessingView> createState() => _ProcessingViewState();
}

class _ProcessingViewState extends State<ProcessingView>
    with TickerProviderStateMixin {
  static const List<Map<String, dynamic>> _processingSteps = [
    {
      'title': 'Uploading Files',
      'description': 'Preparing your resume files for analysis',
      'icon': Icons.upload_file,
      'duration': 2,
    },
    {
      'title': 'Analyzing Resumes',
      'description': 'Extracting text and parsing document structure',
      'icon': Icons.description,
      'duration': 3,
    },
    {
      'title': 'Extracting Skills',
      'description': 'Identifying technical skills and experience',
      'icon': Icons.psychology,
      'duration': 4,
    },
    {
      'title': 'Matching Job Description',
      'description': 'Comparing against job requirements',
      'icon': Icons.work,
      'duration': 3,
    },
    {
      'title': 'Semantic Ranking',
      'description': 'Calculating compatibility scores',
      'icon': Icons.analytics,
      'duration': 4,
    },
    {
      'title': 'Finalizing Results',
      'description': 'Preparing your analysis dashboard',
      'icon': Icons.dashboard,
      'duration': 2,
    },
  ];

  int _currentStep = 0;
  double _currentProgress = 0.0;
  Timer? _progressTimer;
  Timer? _stepTimer;
  late final AtsService _atsService;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _atsService = AtsService();
    _initializeAnimations();
    _startProgressSimulation();
    _runPipeline();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
    _fadeController.forward();
  }

  void _startProgressSimulation() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) return;
      setState(() {
        _currentProgress += 0.01;
        if (_currentProgress >= 1.0) {
          _currentProgress = 1.0;
          timer.cancel();
        }
      });
    });

    _stepTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) return;
      setState(() {
        if (_currentStep < _processingSteps.length - 1) {
          _currentStep++;
          _currentProgress = 0.0;
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _stepTimer?.cancel();
    _pulseController.dispose();
    _rotationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: ResponsiveBuilder(
        builder: (context, screenSize) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF8FAFC), Color(0xFFFFFFFF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildMainLoader(context),
                            const SizedBox(height: 48),
                            _buildProgressSection(context),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
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
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4285F4).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Resume Analysis',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 20,
                          tablet: 24,
                          desktop: 28,
                          largeDesktop: 32,
                          extraLargeDesktop: 36,
                        ),
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryBlack,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Processing ${widget.files.length} resume${widget.files.length > 1 ? 's' : ''} for ${widget.jobTitle}',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 14,
                          tablet: 16,
                          desktop: 18,
                          largeDesktop: 20,
                          extraLargeDesktop: 22,
                        ),
                        color: AppTheme.secondaryGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainLoader(BuildContext context) {
    final double size = ResponsiveUtils.getResponsiveSpacing(
      context,
      mobile: 200,
      tablet: 240,
      desktop: 280,
      largeDesktop: 320,
      extraLargeDesktop: 360,
    );

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF4285F4),
                  Color(0xFF8B5CF6),
                  Color(0xFFEA4335),
                  Color(0xFF34A853),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4285F4).withOpacity(0.3),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.2),
                  blurRadius: 60,
                  offset: const Offset(0, 30),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer rotating ring
                AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationAnimation.value * 2 * 3.14159,
                      child: Container(
                        width: size * 0.9,
                        height: size * 0.9,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 4,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Inner rotating ring
                AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: -_rotationAnimation.value * 2 * 3.14159,
                      child: Container(
                        width: size * 0.7,
                        height: size * 0.7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 3,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Center content
                Container(
                  width: size * 0.5,
                  height: size * 0.5,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _processingSteps[_currentStep]['icon'],
                          size: size * 0.15,
                          color: const Color(0xFF4285F4),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${((_currentStep + _currentProgress) * 100 / _processingSteps.length).toInt()}%',
                          style: TextStyle(
                            fontSize: size * 0.08,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF4285F4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFE5E7EB).withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _processingSteps[_currentStep]['title'],
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      mobile: 18,
                      tablet: 20,
                      desktop: 22,
                      largeDesktop: 24,
                      extraLargeDesktop: 26,
                    ),
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryBlack,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4285F4), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${((_currentStep + _currentProgress) * 100 / _processingSteps.length).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _processingSteps[_currentStep]['description'],
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 16,
                  desktop: 18,
                  largeDesktop: 20,
                  extraLargeDesktop: 22,
                ),
                color: AppTheme.secondaryGray,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            // Progress bar
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width:
                    MediaQuery.of(context).size.width * 0.6 * _currentProgress,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4285F4), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runPipeline() async {
    try {
      // Health check first
      try {
        await _atsService.health();
      } catch (e) {
        // Still continue to attempt to process; AtsResultsView will show error if fails
      }

      final processedJson = await _atsService.processResumes(
        files: widget.files,
        threshold: widget.atsThreshold,
      );
      final processing = ATSProcessingResult.fromJson(processedJson);

      final rankingJson = await _atsService.semanticRanking(
        jobDescription: widget.jobDescription,
        resumes: processing.resumes,
      );
      final ranking = SemanticRankingResult.fromJson(rankingJson);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AtsResultsView(
            files: widget.files,
            jobTitle: widget.jobTitle,
            jobDescription: widget.jobDescription,
            atsThreshold: widget.atsThreshold,
            initialProcessing: processing,
            initialRanking: ranking,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AtsResultsView(
            files: widget.files,
            jobTitle: widget.jobTitle,
            jobDescription: widget.jobDescription,
            atsThreshold: widget.atsThreshold,
          ),
        ),
      );
    }
  }
}
