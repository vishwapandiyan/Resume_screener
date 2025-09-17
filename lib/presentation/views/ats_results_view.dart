import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../models/ats_workflow_models.dart';
import '../../services/ats_service.dart';
import '../visualize_view.dart';

class AtsResultsView extends StatefulWidget {
  final List<PlatformFile> files;
  final String jobTitle;
  final String jobDescription;
  final int atsThreshold;
  final ATSProcessingResult? initialProcessing;
  final SemanticRankingResult? initialRanking;

  const AtsResultsView({
    super.key,
    required this.files,
    required this.jobTitle,
    required this.jobDescription,
    required this.atsThreshold,
    this.initialProcessing,
    this.initialRanking,
  });

  @override
  State<AtsResultsView> createState() => _AtsResultsViewState();
}

class _AtsResultsViewState extends State<AtsResultsView>
    with TickerProviderStateMixin {
  late final AtsService _atsService;
  bool _loading = false;
  String? _error;
  ATSProcessingResult? _processing;
  SemanticRankingResult? _ranking;
  final Set<String> _skillFilters = <String>{};
  bool _gmailOnly = true;
  late final String _workspaceId;
  bool _chatMode = false;
  RankedResume? _activeResume;
  final List<_ChatMessage> _messages = <_ChatMessage>[];
  List<String> _suggested = <String>[];
  bool _isDragOver = false;
  final ScrollController _chatScrollController = ScrollController();
  bool _showScrollToBottomButton = false;

  // Enhanced UI state
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'semantic'; // 'semantic', 'ats', 'name'
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Selection state for email functionality
  final Set<String> _selectedCandidateIds = <String>{};
  final List<RankedResume> _sentCandidates = <RankedResume>[];

  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  // Selection management methods
  void _toggleCandidateSelection(String candidateId) {
    setState(() {
      if (_selectedCandidateIds.contains(candidateId)) {
        _selectedCandidateIds.remove(candidateId);
      } else {
        _selectedCandidateIds.add(candidateId);
      }
    });
  }

  void _selectAllCandidates() {
    final items = _applyLocalFilters(_baseAcceptedSorted());
    setState(() {
      _selectedCandidateIds.clear();
      _selectedCandidateIds.addAll(items.map((r) => r.id));
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedCandidateIds.clear();
    });
  }

  List<RankedResume> _getSelectedCandidates() {
    final items = _applyLocalFilters(_baseAcceptedSorted());
    return items.where((r) => _selectedCandidateIds.contains(r.id)).toList();
  }

  // Email functionality
  Future<void> _sendEmailsToSelectedCandidates() async {
    final selectedCandidates = _getSelectedCandidates();
    if (selectedCandidates.isEmpty) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Simulate email sending delay
    await Future.delayed(const Duration(seconds: 2));

    // Close loading dialog
    if (mounted) Navigator.of(context).pop();

    // Show success dialog
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF34A853).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF34A853),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Email Sent Successfully!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlack,
                ),
              ),
            ],
          ),
          content: Text(
            'Emails have been sent to ${selectedCandidates.length} selected candidate${selectedCandidates.length > 1 ? 's' : ''}.',
            style: const TextStyle(fontSize: 14, color: AppTheme.secondaryGray),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleEmailSent(selectedCandidates);
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF34A853),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _handleEmailSent(List<RankedResume> sentCandidates) {
    setState(() {
      // Add to sent candidates list
      _sentCandidates.addAll(sentCandidates);
      // Remove from selected candidates
      _selectedCandidateIds.clear();
    });
  }

  void _showCandidateDetails(RankedResume candidate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4285F4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.person,
                color: Color(0xFF4285F4),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                candidate.candidate,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlack,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Email', candidate.email),
              _buildDetailRow('Rank', '#${candidate.rank}'),
              _buildDetailRow('ATS Score', '${candidate.atsScore}%'),
              _buildDetailRow(
                'Semantic Score',
                '${(candidate.semanticScore * 100).toStringAsFixed(1)}%',
              ),
              const SizedBox(height: 16),
              const Text(
                'Skills:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlack,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: candidate.skills
                    .map(
                      (skill) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4285F4).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF4285F4).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          skill,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF4285F4),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF4285F4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Close',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.secondaryGray,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.primaryBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _removeCandidate(String candidateId) {
    setState(() {
      _selectedCandidateIds.remove(candidateId);
      // Add to sent candidates to remove from the list
      final candidate = _ranking?.rankedResumes.firstWhere(
        (r) => r.id == candidateId,
        orElse: () => throw StateError('Candidate not found'),
      );
      if (candidate != null) {
        _sentCandidates.add(candidate);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _atsService = AtsService();
    final ts = DateTime.now().millisecondsSinceEpoch;
    _workspaceId = 'ws_${ts.toString()}';

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
        );

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });

    _chatScrollController.addListener(() {
      if (_chatScrollController.hasClients) {
        final isAtBottom =
            _chatScrollController.position.pixels >=
            _chatScrollController.position.maxScrollExtent - 100;
        if (_showScrollToBottomButton != !isAtBottom) {
          setState(() {
            _showScrollToBottomButton = !isAtBottom;
          });
        }
      }
    });

    if (widget.initialProcessing != null && widget.initialRanking != null) {
      _safeSetState(() {
        _processing = widget.initialProcessing;
        _ranking = widget.initialRanking;
        _loading = false;
      });
      _postResultsSetup();
      _fadeController.forward();
      _slideController.forward();
    } else {
      _startPipeline();
    }
  }

  Future<void> _startPipeline() async {
    _safeSetState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Quick reachability check to surface backend/network issues early
      try {
        await _atsService.health();
      } catch (e) {
        _safeSetState(() => _error = 'Backend unreachable: $e');
        return;
      }

      final processedJson = await _atsService.processResumes(
        files: widget.files,
        threshold: widget.atsThreshold,
      );
      final processing = ATSProcessingResult.fromJson(processedJson);

      final acceptedIds = processing.resumes
          .where((r) => r.status.toLowerCase() == 'accepted')
          .map((r) => r.id)
          .toSet();

      final rankingJson = await _atsService.semanticRanking(
        jobDescription: widget.jobDescription,
        resumes: processing.resumes,
      );
      final ranking = SemanticRankingResult.fromJson(rankingJson);

      // Sort candidates by semantic score for better ranking
      ranking.rankedResumes.where((r) => acceptedIds.contains(r.id)).toList()
        ..sort((a, b) => b.semanticScore.compareTo(a.semanticScore));

      _safeSetState(() {
        _processing = processing;
        _ranking = ranking;
      });
      await _postResultsSetup();
      _fadeController.forward();
      _slideController.forward();
    } catch (e) {
      _safeSetState(() => _error = e.toString());
    } finally {
      _safeSetState(() => _loading = false);
    }
  }

  Future<void> _postResultsSetup() async {
    if (_processing == null || _ranking == null) return;
    // Store job description for RAG context
    try {
      await _atsService.ragStoreJd(
        workspaceId: _workspaceId,
        jobDescription: widget.jobDescription,
      );
    } catch (e) {
      // Log error for debugging
      debugPrint('Failed to store JD: $e');
    }
    await _ingestAcceptedToRag();
  }

  Future<void> _ingestAcceptedToRag() async {
    if (_processing == null || _ranking == null) return;
    final accepted = _baseAcceptedSorted();

    final idToProcessed = {for (final p in _processing!.resumes) p.id: p};

    final resumesPayload = <Map<String, dynamic>>[];
    for (final r in accepted) {
      final p = idToProcessed[r.id];
      if (p == null || (p.fullText == null || p.fullText!.isEmpty)) continue;
      resumesPayload.add({
        'id': r.id,
        'text': p.fullText,
        'candidate': r.candidate,
        'email': r.email,
        'skills': r.skills,
        'experience': r.experience,
        'rank': r.rank,
      });
    }
    if (resumesPayload.isEmpty) return;
    try {
      await _atsService.ragIngest(
        workspaceId: _workspaceId,
        resumes: resumesPayload,
      );
    } catch (_) {}
  }

  List<RankedResume> _applyLocalFilters(List<RankedResume> base) {
    Iterable<RankedResume> items = base;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      items = items.where((r) {
        final searchLower = _searchQuery.toLowerCase();
        return r.candidate.toLowerCase().contains(searchLower) ||
            r.email.toLowerCase().contains(searchLower) ||
            r.skills.any((skill) => skill.toLowerCase().contains(searchLower));
      });
    }

    if (_gmailOnly) {
      items = items.where((r) => r.email.contains('@'));
    }

    if (_skillFilters.isNotEmpty) {
      items = items.where((r) {
        final resumeSkills = r.skills.map((s) => s.toLowerCase()).toList();
        for (final req in _skillFilters) {
          final reqLower = req.toLowerCase();
          if (!resumeSkills.any((s) => s.contains(reqLower))) return false;
        }
        return true;
      });
    }

    // Apply sorting
    final sorted = items.toList();
    switch (_sortBy) {
      case 'semantic':
        sorted.sort((a, b) => b.semanticScore.compareTo(a.semanticScore));
        break;
      case 'ats':
        sorted.sort((a, b) => b.atsScore.compareTo(a.atsScore));
        break;
      case 'name':
        sorted.sort((a, b) => a.candidate.compareTo(b.candidate));
        break;
    }

    return sorted;
  }

  void _toggleSkill(String skill, bool selected) {
    _safeSetState(() {
      if (selected) {
        _skillFilters.add(skill);
      } else {
        _skillFilters.remove(skill);
      }
    });
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _skillFilters.clear();
      _gmailOnly = true;
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  List<RankedResume> _baseAcceptedSorted() {
    if (_ranking == null || _processing == null) return const <RankedResume>[];
    final acceptedIds = _processing!.resumes
        .where((r) => r.status.toLowerCase() == 'accepted')
        .map((r) => r.id)
        .toSet();
    final sentIds = _sentCandidates.map((r) => r.id).toSet();
    final sorted =
        _ranking!.rankedResumes
            .where((r) => acceptedIds.contains(r.id) && !sentIds.contains(r.id))
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

  Widget _buildChatPanel(BuildContext context) {
    return DragTarget<RankedResume>(
      onWillAcceptWithDetails: (_) {
        _safeSetState(() => _isDragOver = true);
        return true;
      },
      onLeave: (_) => _safeSetState(() => _isDragOver = false),
      onAcceptWithDetails: (details) async {
        final data = details.data;
        _safeSetState(() {
          _isDragOver = false;
          _activeResume = data;
          _chatMode = true;
        });
        _scrollToBottom();
        try {
          final res = await _atsService.ragSuggest(
            workspaceId: _workspaceId,
            resumeId: data.id,
          );
          _safeSetState(
            () => _suggested = List<String>.from(
              res['questions'] ?? const <String>[],
            ),
          );
          _scrollToBottom();
        } catch (_) {}
      },
      builder: (context, candidate, rejects) {
        return Container(
          height: ResponsiveUtils.isMobile(context) ? 500 : 600,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF8FAFC), Color(0xFFFFFFFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF34A853)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.smart_toy_outlined,
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
                                _activeResume != null
                                    ? 'AI Assistant - ${_activeResume!.candidate}'
                                    : 'AI Assistant',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _activeResume != null
                                    ? 'Ask questions about this candidate'
                                    : 'Get insights about candidates',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                            onPressed: () => setState(() => _chatMode = false),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_suggested.isNotEmpty)
                    Container(
                      height: 200, // Fixed height to prevent overflow
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF10B981,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.lightbulb_outline,
                                  color: Color(0xFF10B981),
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Suggested Questions',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryBlack,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: AnimatedList(
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              initialItemCount: _suggested.take(4).length,
                              itemBuilder: (context, index, animation) {
                                final q = _suggested[index];
                                return SlideTransition(
                                  position: animation.drive(
                                    Tween<Offset>(
                                      begin: const Offset(0, 0.5),
                                      end: Offset.zero,
                                    ).chain(
                                      CurveTween(curve: Curves.easeOutBack),
                                    ),
                                  ),
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFF0FDF4),
                                            Color(0xFFFFFFFF),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: const Color(
                                            0xFF10B981,
                                          ).withOpacity(0.2),
                                          width: 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF10B981,
                                            ).withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => _sendQuery(q),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFF10B981,
                                                    ).withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.psychology_outlined,
                                                    color: Color(0xFF10B981),
                                                    size: 18,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    q,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          AppTheme.primaryBlack,
                                                    ),
                                                  ),
                                                ),
                                                const Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: Color(0xFF10B981),
                                                  size: 16,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  _buildGradientDivider(),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFAFAFA), Color(0xFFF8F9FA)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Scrollbar(
                        controller: _chatScrollController,
                        thumbVisibility: true,
                        thickness: 6,
                        radius: const Radius.circular(8),
                        child: ListView.builder(
                          controller: _chatScrollController,
                          padding: const EdgeInsets.all(24),
                          physics: const BouncingScrollPhysics(),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final m = _messages[index];
                            return TweenAnimationBuilder<double>(
                              duration: Duration(
                                milliseconds: 300 + (index * 100),
                              ),
                              tween: Tween(begin: 0.0, end: 1.0),
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: 0.95 + (0.05 * value),
                                  child: Opacity(
                                    opacity: value,
                                    child: Align(
                                      alignment: m.isUser
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      child: SlideTransition(
                                        position:
                                            Tween<Offset>(
                                              begin: m.isUser
                                                  ? const Offset(1.0, 0.0)
                                                  : const Offset(-1.0, 0.0),
                                              end: Offset.zero,
                                            ).animate(
                                              CurvedAnimation(
                                                parent: AlwaysStoppedAnimation(
                                                  value,
                                                ),
                                                curve: Curves.easeOutBack,
                                              ),
                                            ),
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 16,
                                          ),
                                          constraints: BoxConstraints(
                                            maxWidth:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.7,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (!m.isUser) ...[
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    gradient:
                                                        const LinearGradient(
                                                          colors: [
                                                            Color(0xFF10B981),
                                                            Color(0xFF34A853),
                                                          ],
                                                        ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.smart_toy_outlined,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                              ],
                                              Flexible(
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    16,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    gradient: m.isUser
                                                        ? const LinearGradient(
                                                            colors: [
                                                              Color(0xFF4285F4),
                                                              Color(0xFF8B5CF6),
                                                            ],
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                          )
                                                        : const LinearGradient(
                                                            colors: [
                                                              Color(0xFFFFFFFF),
                                                              Color(0xFFF8F9FA),
                                                            ],
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                          ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                    border: Border.all(
                                                      color: m.isUser
                                                          ? const Color(
                                                              0xFF4285F4,
                                                            ).withOpacity(0.2)
                                                          : const Color(
                                                              0xFFE5E7EB,
                                                            ),
                                                      width: 1,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: m.isUser
                                                            ? const Color(
                                                                0xFF4285F4,
                                                              ).withOpacity(0.2)
                                                            : Colors.black
                                                                  .withOpacity(
                                                                    0.05,
                                                                  ),
                                                        blurRadius: 12,
                                                        offset: const Offset(
                                                          0,
                                                          4,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Text(
                                                    m.text,
                                                    style: TextStyle(
                                                      color: m.isUser
                                                          ? Colors.white
                                                          : AppTheme
                                                                .primaryBlack,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 14,
                                                      height: 1.4,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              if (m.isUser) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    gradient:
                                                        const LinearGradient(
                                                          colors: [
                                                            Color(0xFF4285F4),
                                                            Color(0xFF8B5CF6),
                                                          ],
                                                        ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.person_outline,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  _ChatInput(onSend: (text) => _sendQuery(text)),
                ],
              ),
              // Scroll to bottom button
              if (_showScrollToBottomButton && _messages.isNotEmpty)
                Positioned(
                  bottom: 80,
                  right: 20,
                  child: AnimatedOpacity(
                    opacity: _showScrollToBottomButton ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: FloatingActionButton.small(
                      onPressed: _scrollToBottom,
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      elevation: 8,
                      child: const Icon(Icons.keyboard_arrow_down, size: 20),
                    ),
                  ),
                ),
              if (_isDragOver)
                Positioned.fill(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF10B981),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Center(
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 500),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 0.8 + (0.2 * value),
                            child: Opacity(
                              opacity: value,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TweenAnimationBuilder<double>(
                                    duration: const Duration(
                                      milliseconds: 1000,
                                    ),
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    builder: (context, bounceValue, child) {
                                      return Transform.translate(
                                        offset: Offset(
                                          0,
                                          -10 * (1 - bounceValue),
                                        ),
                                        child: Icon(
                                          Icons.drag_indicator,
                                          color: const Color(0xFF10B981),
                                          size: 48 + (8 * bounceValue),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Drop candidate here',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF10B981),
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'to start chatting about them',
                                    style: TextStyle(
                                      color: const Color(
                                        0xFF10B981,
                                      ).withOpacity(0.8),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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

  Future<void> _sendQuery(String text) async {
    if (text.trim().isEmpty) return;
    _safeSetState(() => _messages.add(_ChatMessage(text: text, isUser: true)));
    _scrollToBottom();
    try {
      final res = await _atsService.ragQuery(
        workspaceId: _workspaceId,
        message: text,
        resumeId: _activeResume?.id,
        chatId: _activeResume?.id,
      );
      final answer = (res['answer'] ?? '').toString();
      _safeSetState(
        () => _messages.add(_ChatMessage(text: answer, isUser: false)),
      );
      _scrollToBottom();
    } catch (e) {
      _safeSetState(
        () => _messages.add(_ChatMessage(text: 'Error: $e', isUser: false)),
      );
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
        setState(() {
          _showScrollToBottomButton = false;
        });
      }
    });
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 2000),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: value * 2 * 3.14159,
                  child: SizedBox(
                    width: 84,
                    height: 84,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const SweepGradient(
                              colors: [
                                Color(0xFF4285F4),
                                Color(0xFFEA4335),
                                Color(0xFFFBBC04),
                                Color(0xFF34A853),
                                Color(0xFF4285F4),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 64,
                          height: 64,
                          child: CircularProgressIndicator(
                            strokeWidth: 5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.accentBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1000),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Text(
                      'Analyzing resumes…',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryBlack,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 6),
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1200),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: const Text(
                      'This will only take a moment',
                      style: TextStyle(color: AppTheme.secondaryGray),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Text(_error!, style: const TextStyle(color: AppTheme.accentRed)),
      );
    }
    if (_processing == null || _ranking == null) {
      return const SizedBox.shrink();
    }

    return ResponsiveBuilder(
      builder: (context, screenSize) {
        final isMobile = ResponsiveUtils.isMobile(context);

        return Padding(
          padding: ResponsiveUtils.getResponsivePadding(context),
          child: Column(
            children: [
              Expanded(
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 30 * (1 - value)),
                        child: isMobile
                            ? _buildMobileLayout(context)
                            : _buildDesktopLayout(context),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileControls(BuildContext context) {
    return Row(
      children: [
        // Sort dropdown
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.getResponsiveSpacing(
                context,
                mobile: 12.0,
                tablet: 14.0,
                desktop: 16.0,
              ),
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _sortBy,
                isExpanded: true,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                    context,
                    mobile: 12.0,
                    tablet: 13.0,
                    desktop: 14.0,
                  ),
                  color: AppTheme.primaryBlack,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'semantic',
                    child: Text('Best Match'),
                  ),
                  DropdownMenuItem(value: 'ats', child: Text('ATS Score')),
                  DropdownMenuItem(value: 'name', child: Text('Name')),
                ],
                onChanged: (value) =>
                    setState(() => _sortBy = value ?? 'semantic'),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Filter button
        Container(
          padding: EdgeInsets.all(
            ResponsiveUtils.getResponsiveSpacing(
              context,
              mobile: 8.0,
              tablet: 10.0,
              desktop: 12.0,
            ),
          ),
          decoration: BoxDecoration(
            color: _skillFilters.isNotEmpty
                ? const Color(0xFF4285F4).withOpacity(0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _skillFilters.isNotEmpty
                  ? const Color(0xFF4285F4)
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Icon(
            Icons.filter_list,
            size: ResponsiveUtils.getResponsiveIconSize(
              context,
              mobile: 16.0,
              tablet: 18.0,
              desktop: 20.0,
            ),
            color: _skillFilters.isNotEmpty
                ? const Color(0xFF4285F4)
                : AppTheme.secondaryGray,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        // Filters section at the top on mobile
        Container(
          constraints: const BoxConstraints(maxHeight: 300),
          child: _chatMode ? _buildChatPanel(context) : _buildFilters(context),
        ),
        const SizedBox(height: 16),
        // Candidates list takes the rest of the space
        Expanded(child: _buildCandidatesList(context)),
        const SizedBox(height: 16),
        // Send email button (if candidates are selected)
        if (_selectedCandidateIds.isNotEmpty) ...[
          _buildSendEmailButton(context),
          const SizedBox(height: 12),
        ],
        // Visualize button at the bottom
        _buildVisualizeButton(context),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Candidates list takes 2/3 of the space
        Expanded(flex: 2, child: _buildCandidatesList(context)),
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
        // Filters/chat panel takes 1/3 of the space
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: ResponsiveUtils.isWeb()
                        ? ResponsiveUtils.getResponsiveContentMaxWidth(
                                context,
                              ) *
                              0.3
                        : 600,
                    child: _chatMode
                        ? _buildChatPanel(context)
                        : _buildFilters(context),
                  ),
                ),
              ),
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  mobile: 16,
                  tablet: 20,
                  desktop: 24,
                ),
              ),
              // Send email button (if candidates are selected)
              if (_selectedCandidateIds.isNotEmpty) ...[
                _buildSendEmailButton(context),
                const SizedBox(height: 12),
              ],
              // Visualize button below the right side container
              _buildVisualizeButton(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSendEmailButton(BuildContext context) {
    final selectedCount = _selectedCandidateIds.length;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF34A853), Color(0xFF2E7D32)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF34A853).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _sendEmailsToSelectedCandidates,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.email, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Send Email to $selectedCount Candidate${selectedCount > 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisualizeButton(BuildContext context) {
    final disabled = _processing == null || _ranking == null;
    debugPrint(
      'Visualize button - disabled: $disabled, processing: ${_processing != null}, ranking: ${_ranking != null}',
    );
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * value),
          child: Opacity(
            opacity: value,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: disabled
                    ? null
                    : const LinearGradient(
                        colors: [
                          Color(0xFF4285F4),
                          Color(0xFF8B5CF6),
                          Color(0xFFEA4335),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: disabled
                    ? [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: const Color(0xFF4285F4).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: disabled
                      ? null
                      : () {
                          debugPrint('Navigating to VisualizeView...');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VisualizeView(
                                processing: _processing!,
                                ranking: _ranking!,
                                jobTitle: widget.jobTitle,
                                candidates: _baseAcceptedSorted(),
                              ),
                            ),
                          );
                        },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: disabled
                                ? Colors.grey.withOpacity(0.3)
                                : Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.analytics_outlined,
                            color: disabled ? Colors.grey : Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Advanced Analytics',
                              style: TextStyle(
                                color: disabled ? Colors.grey : Colors.white,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'View detailed insights & trends',
                              style: TextStyle(
                                color: disabled
                                    ? Colors.grey.withOpacity(0.7)
                                    : Colors.white.withOpacity(0.9),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: disabled
                                ? Colors.grey.withOpacity(0.3)
                                : Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: disabled ? Colors.grey : Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCandidatesList(BuildContext context) {
    final items = _applyLocalFilters(_baseAcceptedSorted());
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundWhite,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4285F4).withOpacity(0.08),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: const Color(0xFF4285F4).withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Professional header with search and controls
              Container(
                padding: ResponsiveUtils.getResponsivePadding(context),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundWhite,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                ),
                child: Column(
                  children: [
                    ResponsiveBuilder(
                      builder: (context, screenSize) {
                        final isMobile = ResponsiveUtils.isMobile(context);

                        if (isMobile) {
                          // Stack elements vertically on mobile
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF4285F4,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.people_outline,
                                      color: const Color(0xFF4285F4),
                                      size:
                                          ResponsiveUtils.getResponsiveIconSize(
                                            context,
                                            mobile: 18.0,
                                            tablet: 19.0,
                                            desktop: 20.0,
                                          ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: ResponsiveUtils.getResponsiveSpacing(
                                      context,
                                      mobile: 8.0,
                                      tablet: 10.0,
                                      desktop: 12.0,
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Filtered Candidates',
                                          style: TextStyle(
                                            color: AppTheme.primaryBlack,
                                            fontWeight: FontWeight.w600,
                                            fontSize:
                                                ResponsiveUtils.getResponsiveFontSize(
                                                  context,
                                                  mobile: 16.0,
                                                  tablet: 17.0,
                                                  desktop: 18.0,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${items.length} candidates found',
                                          style: TextStyle(
                                            color: AppTheme.secondaryGray,
                                            fontSize:
                                                ResponsiveUtils.getResponsiveFontSize(
                                                  context,
                                                  mobile: 12.0,
                                                  tablet: 13.0,
                                                  desktop: 14.0,
                                                ),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Sort and filter controls for mobile
                              _buildMobileControls(context),
                            ],
                          );
                        } else {
                          // Show in a row on larger screens
                          return Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF4285F4,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.people_outline,
                                  color: const Color(0xFF4285F4),
                                  size: ResponsiveUtils.getResponsiveIconSize(
                                    context,
                                    mobile: 18.0,
                                    tablet: 19.0,
                                    desktop: 20.0,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Filtered Candidates',
                                      style: TextStyle(
                                        color: AppTheme.primaryBlack,
                                        fontWeight: FontWeight.w600,
                                        fontSize:
                                            ResponsiveUtils.getResponsiveFontSize(
                                              context,
                                              mobile: 16.0,
                                              tablet: 17.0,
                                              desktop: 18.0,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${items.length} candidates found',
                                      style: TextStyle(
                                        color: AppTheme.secondaryGray,
                                        fontSize:
                                            ResponsiveUtils.getResponsiveFontSize(
                                              context,
                                              mobile: 12.0,
                                              tablet: 13.0,
                                              desktop: 14.0,
                                            ),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Selection controls
                              if (_selectedCandidateIds.isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF4285F4,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF4285F4,
                                      ).withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '${_selectedCandidateIds.length} selected',
                                    style: const TextStyle(
                                      color: Color(0xFF4285F4),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: _clearSelection,
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Color(0xFFEA4335),
                                    size: 18,
                                  ),
                                  tooltip: 'Clear selection',
                                ),
                                const SizedBox(width: 8),
                              ],
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      ResponsiveUtils.getResponsiveSpacing(
                                        context,
                                        mobile: 10.0,
                                        tablet: 11.0,
                                        desktop: 12.0,
                                      ),
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF34A853,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${items.length}',
                                  style: TextStyle(
                                    color: const Color(0xFF34A853),
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        ResponsiveUtils.getResponsiveFontSize(
                                          context,
                                          mobile: 14.0,
                                          tablet: 15.0,
                                          desktop: 16.0,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    // Search bar
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: AppTheme.primaryBlack),
                        decoration: InputDecoration(
                          hintText: 'Search candidates, skills, or emails...',
                          hintStyle: const TextStyle(
                            color: AppTheme.secondaryGray,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          prefixIcon: Container(
                            padding: const EdgeInsets.all(12),
                            child: const Icon(
                              Icons.search,
                              color: AppTheme.secondaryGray,
                              size: 20,
                            ),
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                  icon: const Icon(
                                    Icons.clear,
                                    color: AppTheme.secondaryGray,
                                    size: 20,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Sort and filter controls
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                                width: 1,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _sortBy,
                                isExpanded: true,
                                dropdownColor: Colors.white,
                                style: const TextStyle(
                                  color: AppTheme.primaryBlack,
                                  fontWeight: FontWeight.w500,
                                ),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: AppTheme.secondaryGray,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'semantic',
                                    child: Text('Sort by Relevance'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'ats',
                                    child: Text('Sort by ATS Score'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'name',
                                    child: Text('Sort by Name'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _sortBy = value);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Select All button
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                            onPressed: _selectAllCandidates,
                            icon: const Icon(
                              Icons.select_all,
                              color: Color(0xFF4285F4),
                              size: 20,
                            ),
                            tooltip: 'Select all candidates',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                            onPressed: _clearFilters,
                            icon: const Icon(
                              Icons.refresh,
                              color: AppTheme.secondaryGray,
                              size: 20,
                            ),
                            tooltip: 'Clear all filters',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildGradientDivider(),
              Expanded(
                child: items.isEmpty
                    ? _buildEmptyState()
                    : Scrollbar(
                        thumbVisibility: true,
                        thickness: 6,
                        radius: const Radius.circular(8),
                        child: ListView.separated(
                          padding: ResponsiveUtils.getResponsivePadding(
                            context,
                          ),
                          itemCount: items.length,
                          separatorBuilder: (_, __) => SizedBox(
                            height: ResponsiveUtils.getResponsiveSpacing(
                              context,
                              mobile: 12.0,
                              tablet: 14.0,
                              desktop: 16.0,
                            ),
                          ),
                          itemBuilder: (context, index) {
                            final r = items[index];
                            return TweenAnimationBuilder<double>(
                              duration: Duration(
                                milliseconds: 300 + (index * 100),
                              ),
                              tween: Tween(begin: 0.0, end: 1.0),
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: 0.9 + (0.1 * value),
                                  child: Opacity(
                                    opacity: value,
                                    child: SlideTransition(
                                      position:
                                          Tween<Offset>(
                                            begin: const Offset(0, 0.3),
                                            end: Offset.zero,
                                          ).animate(
                                            CurvedAnimation(
                                              parent: AlwaysStoppedAnimation(
                                                value,
                                              ),
                                              curve: Curves.easeOutBack,
                                            ),
                                          ),
                                      child: Draggable<RankedResume>(
                                        data: r,
                                        feedback: Material(
                                          color: Colors.transparent,
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(
                                                0.8,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              r.candidate,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                        childWhenDragging: Opacity(
                                          opacity: 0.4,
                                          child: _CandidateTile(
                                            resume: r,
                                            isSelected: _selectedCandidateIds
                                                .contains(r.id),
                                            onToggleSelection: () =>
                                                _toggleCandidateSelection(r.id),
                                            onView: () =>
                                                _showCandidateDetails(r),
                                            onRemove: () =>
                                                _removeCandidate(r.id),
                                          ),
                                        ),
                                        child: _CandidateTile(
                                          resume: r,
                                          isSelected: _selectedCandidateIds
                                              .contains(r.id),
                                          onToggleSelection: () =>
                                              _toggleCandidateSelection(r.id),
                                          onView: () =>
                                              _showCandidateDetails(r),
                                          onRemove: () =>
                                              _removeCandidate(r.id),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
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

  Widget _buildFilters(BuildContext context) {
    final jdSkills = _ranking?.jdSkills ?? const <String>[];
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFFFFF), Color(0xFFFAFAFA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withOpacity(0.08),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Professional header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.tune_rounded,
                              color: Color(0xFF8B5CF6),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Filters & AI Chat',
                                  style: TextStyle(
                                    color: AppTheme.primaryBlack,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Refine your search',
                                  style: TextStyle(
                                    color: AppTheme.secondaryGray,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() => _chatMode = true);
                              _scrollToBottom();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4285F4),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(
                              Icons.chat_bubble_outline,
                              size: 16,
                            ),
                            label: const Text(
                              'Chat with AI',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildGradientDivider(),
                const SizedBox(height: 24),

                // Quick Filters Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF8FAFC), Color(0xFFFFFFFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB).withOpacity(0.5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4285F4).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.filter_list_rounded,
                              color: Color(0xFF4285F4),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Quick Filters',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: AppTheme.primaryBlack,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE5E7EB).withOpacity(0.8),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Switch(
                              value: _gmailOnly,
                              onChanged: (v) => setState(() => _gmailOnly = v),
                              activeColor: const Color(0xFF4285F4),
                              activeTrackColor: const Color(
                                0xFF4285F4,
                              ).withOpacity(0.3),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Email Required',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryBlack,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Only show candidates with email addresses',
                                    style: TextStyle(
                                      color: AppTheme.secondaryGray,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Skills Filter Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF0FDF4), Color(0xFFFFFFFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF10B981).withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.psychology_outlined,
                              color: Color(0xFF10B981),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Job Description Skills',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: AppTheme.primaryBlack,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Filter by required skills from job description',
                                  style: TextStyle(
                                    color: AppTheme.secondaryGray,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_skillFilters.isNotEmpty)
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(
                                    0xFF10B981,
                                  ).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  setState(() => _skillFilters.clear());
                                },
                                icon: Icon(
                                  Icons.clear,
                                  color: const Color(0xFF10B981),
                                  size: 18,
                                ),
                                tooltip: 'Clear skill filters',
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (jdSkills.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB).withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppTheme.secondaryGray.withOpacity(0.7),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'No skills extracted from job description',
                                style: TextStyle(
                                  color: AppTheme.secondaryGray,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: jdSkills.map((skill) {
                            final selected = _skillFilters.contains(skill);
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: selected
                                    ? [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF10B981,
                                          ).withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: FilterChip(
                                label: Text(
                                  skill,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                selected: selected,
                                onSelected: (v) => _toggleSkill(skill, v),
                                selectedColor: const Color(
                                  0xFF10B981,
                                ).withOpacity(0.15),
                                checkmarkColor: const Color(0xFF10B981),
                                backgroundColor: Colors.white,
                                side: BorderSide(
                                  color: selected
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFE5E7EB),
                                  width: 1.5,
                                ),
                                labelStyle: TextStyle(
                                  color: selected
                                      ? const Color(0xFF10B981)
                                      : AppTheme.primaryBlack,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Clear All Filters Button
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF8FAFC), Color(0xFFFFFFFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB).withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _clearFilters,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.refresh_rounded,
                              color: AppTheme.secondaryGray,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Clear All Filters',
                              style: TextStyle(
                                color: AppTheme.secondaryGray,
                                fontWeight: FontWeight.w600,
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
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF8FAFC), Color(0xFFFFFFFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFE5E7EB).withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4285F4), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.search_off,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No candidates found',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryBlack,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your search criteria or filters',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.secondaryGray,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _clearFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4285F4),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text(
                    'Clear Filters',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientDivider() {
    return Container(
      height: 2,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF4285F4),
            Color(0xFFEA4335),
            Color(0xFFFBBC04),
            Color(0xFF34A853),
          ],
        ),
      ),
    );
  }
}

class _CandidateTile extends StatelessWidget {
  final RankedResume resume;
  final bool isSelected;
  final VoidCallback onToggleSelection;
  final VoidCallback onView;
  final VoidCallback onRemove;

  const _CandidateTile({
    required this.resume,
    this.isSelected = false,
    required this.onToggleSelection,
    required this.onView,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final combinedScore =
        (resume.semanticScore * 0.7 + (resume.atsScore / 100) * 0.3) * 100;

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF4285F4).withOpacity(0.05)
            : AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? const Color(0xFF4285F4).withOpacity(0.1)
                : Colors.black.withOpacity(0.04),
            blurRadius: isSelected ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isSelected ? const Color(0xFF4285F4) : const Color(0xFFE5E7EB),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          // Score indicator bar
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 4,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                color: combinedScore >= 80
                    ? const Color(0xFF34A853)
                    : combinedScore >= 60
                    ? const Color(0xFFFBBC04)
                    : const Color(0xFFEA4335),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Selection checkbox
                    GestureDetector(
                      onTap: onToggleSelection,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF4285F4)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF4285F4)
                                : const Color(0xFFE5E7EB),
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 14,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Rank badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4285F4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#${resume.rank}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Action buttons
                    Row(
                      children: [
                        // View button
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF34A853).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFF34A853).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                            onPressed: onView,
                            icon: const Icon(
                              Icons.visibility,
                              color: Color(0xFF34A853),
                              size: 16,
                            ),
                            tooltip: 'View details',
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Remove button
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFEA4335).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFFEA4335).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                            onPressed: onRemove,
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Color(0xFFEA4335),
                              size: 16,
                            ),
                            tooltip: 'Remove candidate',
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Score display
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: combinedScore >= 80
                                ? const Color(0xFF34A853).withOpacity(0.1)
                                : combinedScore >= 60
                                ? const Color(0xFFFBBC04).withOpacity(0.1)
                                : const Color(0xFFEA4335).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: combinedScore >= 80
                                  ? const Color(0xFF34A853)
                                  : combinedScore >= 60
                                  ? const Color(0xFFFBBC04)
                                  : const Color(0xFFEA4335),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '${combinedScore.toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: combinedScore >= 80
                                  ? const Color(0xFF34A853)
                                  : combinedScore >= 60
                                  ? const Color(0xFFFBBC04)
                                  : const Color(0xFFEA4335),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Candidate name
                Text(
                  resume.candidate,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppTheme.primaryBlack,
                  ),
                ),
                const SizedBox(height: 4),
                // Email
                Text(
                  resume.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.secondaryGray,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                // Skills section
                Text(
                  resume.skills.take(3).join(', '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.primaryBlack,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
                if (resume.skills.length > 3) ...[
                  const SizedBox(height: 4),
                  Text(
                    '+${resume.skills.length - 3} more skills',
                    style: TextStyle(
                      color: AppTheme.secondaryGray.withOpacity(0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}

class _ChatInput extends StatefulWidget {
  final Function(String) onSend;
  const _ChatInput({required this.onSend});
  @override
  State<_ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<_ChatInput> {
  final TextEditingController _controller = TextEditingController();
  bool _isTyping = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8FAFC), Color(0xFFFFFFFF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE5E7EB).withOpacity(0.5),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFFFFF), Color(0xFFFAFAFA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFE5E7EB).withOpacity(0.8),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                onChanged: (value) {
                  setState(() {
                    _isTyping = value.isNotEmpty;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Ask about the candidate...',
                  hintStyle: TextStyle(
                    color: AppTheme.secondaryGray.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  prefixIcon: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.message_outlined,
                      color: const Color(0xFF10B981).withOpacity(0.7),
                      size: 20,
                    ),
                  ),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryBlack,
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    _controller.clear();
                    widget.onSend(value);
                    setState(() {
                      _isTyping = false;
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: _isTyping
                  ? const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF34A853)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : const LinearGradient(
                      colors: [Color(0xFFE5E7EB), Color(0xFFD1D5DB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: _isTyping
                  ? [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isTyping
                    ? () {
                        final text = _controller.text;
                        if (text.trim().isNotEmpty) {
                          _controller.clear();
                          widget.onSend(text);
                          setState(() {
                            _isTyping = false;
                          });
                        }
                      }
                    : null,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _isTyping
                        ? const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                            key: ValueKey('send'),
                          )
                        : Icon(
                            Icons.send_rounded,
                            color: Colors.grey.withOpacity(0.6),
                            size: 20,
                            key: ValueKey('disabled'),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
