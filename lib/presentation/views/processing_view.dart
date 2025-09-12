import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:glow_container/glow_container.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_utils.dart';
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

class _ProcessingViewState extends State<ProcessingView> {
  static const List<String> _messages = <String>[
    'Analyzing resumes…',
    'Extracting skills and experience…',
    'Matching to job description…',
    'Ranking candidates by fit…',
    'Almost there…',
  ];

  int _messageIndex = 0;
  Timer? _messageTimer;
  late final AtsService _atsService;

  @override
  void initState() {
    super.initState();
    _atsService = AtsService();

    // Cycle status messages
    _messageTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _messageIndex = (_messageIndex + 1) % _messages.length;
      });
    });

    // Run real pipeline against backend and navigate when complete
    _runPipeline();
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildRotatingLoader(context),
            const SizedBox(height: 24),
            Text(
              _messages[_messageIndex],
              style: TextStyle(
                color: AppTheme.primaryBlack,
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 16,
                  desktop: 18,
                  largeDesktop: 20,
                  extraLargeDesktop: 22,
                ),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Fetching results from server…',
              style: TextStyle(color: AppTheme.secondaryGray),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRotatingLoader(BuildContext context) {
    final double size = ResponsiveUtils.getResponsiveSpacing(
      context,
      mobile: 160,
      tablet: 200,
      desktop: 220,
      largeDesktop: 240,
      extraLargeDesktop: 260,
    );

    return GlowContainer(
      gradientColors: const [
        Color(0xFF4285F4), // Blue
        Color(0xFFEA4335), // Red
        Color(0xFFFBBC04), // Yellow
        Color(0xFF34A853), // Green
      ],
      rotationDuration: const Duration(seconds: 2),
      glowRadius: ResponsiveUtils.getResponsiveSpacing(
        context,
        mobile: 4,
        tablet: 5,
        desktop: 6,
        largeDesktop: 7,
        extraLargeDesktop: 8,
      ),
      containerOptions: ContainerOptions(
        width: size,
        height: size,
        borderRadius: size / 2,
        backgroundColor: Colors.transparent,
        borderSide: const BorderSide(width: 6, color: AppTheme.accentBlue),
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppTheme.backgroundWhite,
          borderRadius: BorderRadius.circular(size / 2),
        ),
        child: Center(
          child: SizedBox(
            width: size * 0.35,
            height: size * 0.35,
            child: const CircularProgressIndicator(
              strokeWidth: 6,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentBlue),
            ),
          ),
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


