import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../models/ats_workflow_models.dart';
import '../../services/ats_service.dart';

class AtsResultsView extends StatefulWidget {
  final List<PlatformFile> files;
  final String jobTitle;
  final String jobDescription;
  final int atsThreshold;

  const AtsResultsView({
    super.key,
    required this.files,
    required this.jobTitle,
    required this.jobDescription,
    required this.atsThreshold,
  });

  @override
  State<AtsResultsView> createState() => _AtsResultsViewState();
}

class _AtsResultsViewState extends State<AtsResultsView> {
  late final AtsService _atsService;
  bool _loading = false;
  String? _error;
  ATSProcessingResult? _processing;
  SemanticRankingResult? _ranking;
  final Set<String> _skillFilters = <String>{};
  bool _gmailOnly = true; // default Gmail filter as requested

  @override
  void initState() {
    super.initState();
    _atsService = AtsService();
    _startPipeline();
  }

  Future<void> _startPipeline() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // 1) Process resumes with ATS
      final processedJson = await _atsService.processResumes(
        files: widget.files,
        threshold: widget.atsThreshold,
      );
      final processing = ATSProcessingResult.fromJson(processedJson);

      // limit to accepted IDs
      final acceptedIds = processing.resumes
          .where((r) => r.status.toLowerCase() == 'accepted')
          .map((r) => r.id)
          .toSet();

      // 2) Semantic ranking with JD
      final rankingJson = await _atsService.semanticRanking(
        jobDescription: widget.jobDescription,
        resumes: processing.resumes,
      );
      final ranking = SemanticRankingResult.fromJson(rankingJson);

      // Keep only ATS-accepted resumes, sorted by semantic score desc
      final sorted = ranking.rankedResumes
          .where((r) => acceptedIds.contains(r.id))
          .toList()
        ..sort((a, b) => b.semanticScore.compareTo(a.semanticScore));

      setState(() {
        _processing = processing;
        _ranking = ranking;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  List<RankedResume> _applyLocalFilters(List<RankedResume> base) {
    Iterable<RankedResume> items = base;

    // Gmail default filter: filter out resumes without email id if enabled
    if (_gmailOnly) {
      // Treat only strings that look like real emails as valid (must contain '@')
      items = items.where((r) => r.email.contains('@'));
    }

    // JD skills filter (all selected must be present as substring)
    if (_skillFilters.isNotEmpty) {
      items = items.where((r) {
        final resumeSkills = r.skills.map((s) => s.toLowerCase()).toList();
        for (final req in _skillFilters) {
          final reqLower = req.toLowerCase();
          final hasSkill = resumeSkills.any((s) => s.contains(reqLower));
          if (!hasSkill) return false;
        }
        return true;
      });
    }

    return items.toList();
  }

  void _toggleSkill(String skill, bool selected) {
    setState(() {
      if (selected) {
        _skillFilters.add(skill);
      } else {
        _skillFilters.remove(skill);
      }
    });
  }

  List<RankedResume> _baseAcceptedSorted() {
    if (_ranking == null || _processing == null) return const <RankedResume>[];
    final acceptedIds = _processing!.resumes
        .where((r) => r.status.toLowerCase() == 'accepted')
        .map((r) => r.id)
        .toSet();
    final sorted = _ranking!.rankedResumes
        .where((r) => acceptedIds.contains(r.id))
        .toList()
      ..sort((a, b) => b.semanticScore.compareTo(a.semanticScore));
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryBlack),
        ),
        title: Text(
          'Analysis Results',
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
        ),
        centerTitle: true,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: AppTheme.accentRed),
        ),
      );
    }
    if (_processing == null || _ranking == null) {
      return const SizedBox.shrink();
    }

    return ResponsiveBuilder(
      builder: (context, screenSize) {
        return Padding(
          padding: ResponsiveUtils.getResponsivePadding(context),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: candidates list (scrollable)
              Expanded(
                flex: 2,
                child: _buildCandidatesList(context),
              ),
              SizedBox(
                width: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  mobile: 12,
                  tablet: 16,
                  desktop: 24,
                  largeDesktop: 28,
                  extraLargeDesktop: 32,
                ),
              ),
              // Right: filters from JD
              Expanded(
                flex: 1,
                child: _buildFilters(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCandidatesList(BuildContext context) {
    final items = _applyLocalFilters(_baseAcceptedSorted());
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Filtered Candidates (${items.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryBlack,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final r = items[index];
                  return _CandidateTile(resume: r);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    final jdSkills = _ranking?.jdSkills ?? const <String>[];
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filters',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryBlack,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            // Gmail default toggle
            Row(
              children: [
                Switch(
                  value: _gmailOnly,
                  onChanged: (v) {
                    setState(() {
                      _gmailOnly = v;
                    });
                  },
                  activeColor: AppTheme.accentBlue,
                ),
                const SizedBox(width: 8),
                const Text('Only resumes with email'),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'JD Skills',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.primaryBlack,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: jdSkills.map((skill) {
                final selected = _skillFilters.contains(skill);
                return FilterChip(
                  label: Text(skill),
                  selected: selected,
                  onSelected: (v) => _toggleSkill(skill, v),
                  selectedColor: AppTheme.accentBlue.withOpacity(0.15),
                  checkmarkColor: AppTheme.accentBlue,
                  labelStyle: TextStyle(
                    color: selected ? AppTheme.accentBlue : AppTheme.primaryBlack,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CandidateTile extends StatelessWidget {
  final RankedResume resume;
  const _CandidateTile({required this.resume});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.secondaryGray.withOpacity(0.25)),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.accentBlue,
            child: Text(
              resume.rank.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        resume.candidate,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    _RatingStars(
                      atsScore: resume.atsScore.toDouble(),
                      semanticScore: resume.semanticScore,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  resume.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppTheme.secondaryGray),
                ),
                const SizedBox(height: 8),
                Text(
                  resume.skills.join(', '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingStars extends StatelessWidget {
  final double atsScore; // 0..100
  final double semanticScore; // 0..1

  const _RatingStars({required this.atsScore, required this.semanticScore});

  // Weighted score: semantic 70%, ATS 30%
  double _combinedScore() {
    final semanticPct = (semanticScore.clamp(0.0, 1.0)) * 100.0;
    final atsPct = atsScore.clamp(0.0, 100.0);
    return semanticPct * 0.7 + atsPct * 0.3; // 0..100
  }

  int _starsFilled() {
    final combined = _combinedScore();
    final outOfFive = combined / 20.0; // 0..5
    return outOfFive.floor().clamp(0, 5);
  }

  bool _hasHalfStar() {
    final combined = _combinedScore();
    final outOfFive = combined / 20.0;
    final fractional = outOfFive - outOfFive.floor();
    return fractional >= 0.25 && fractional < 0.75;
  }

  @override
  Widget build(BuildContext context) {
    final filled = _starsFilled();
    final half = _hasHalfStar();
    final total = 5;

    List<Widget> icons = [];
    for (int i = 0; i < total; i++) {
      if (i < filled) {
        icons.add(const Icon(Icons.star, color: AppTheme.accentGreen, size: 18));
      } else if (i == filled && half) {
        icons.add(const Icon(Icons.star_half, color: AppTheme.accentGreen, size: 18));
      } else {
        icons.add(Icon(Icons.star_border, color: AppTheme.secondaryGray.withOpacity(0.8), size: 18));
      }
    }

    return Row(children: icons);
  }
}


