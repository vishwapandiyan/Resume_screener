import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../models/ats_workflow_models.dart';
import '../../services/ats_service.dart';
import 'visualize_view.dart';

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

class _AtsResultsViewState extends State<AtsResultsView> {
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

  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _atsService = AtsService();
    final ts = DateTime.now().millisecondsSinceEpoch;
    _workspaceId = 'ws_${ts.toString()}';
    if (widget.initialProcessing != null && widget.initialRanking != null) {
      _safeSetState(() {
        _processing = widget.initialProcessing;
        _ranking = widget.initialRanking;
        _loading = false;
      });
      _postResultsSetup();
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

      final sorted = ranking.rankedResumes
          .where((r) => acceptedIds.contains(r.id))
          .toList()
        ..sort((a, b) => b.semanticScore.compareTo(a.semanticScore));

      _safeSetState(() {
        _processing = processing;
        _ranking = ranking;
      });
      await _postResultsSetup();
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
      print('Failed to store JD: $e');
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
      await _atsService.ragIngest(workspaceId: _workspaceId, resumes: resumesPayload);
    } catch (_) {}
  }

  List<RankedResume> _applyLocalFilters(List<RankedResume> base) {
    Iterable<RankedResume> items = base;

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

    return items.toList();
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

  Widget _buildChatPanel(BuildContext context) {
    return DragTarget<RankedResume>(
      onWillAccept: (_) {
        _safeSetState(() => _isDragOver = true);
        return true;
      },
      onLeave: (_) => _safeSetState(() => _isDragOver = false),
      onAccept: (data) async {
        _safeSetState(() {
          _isDragOver = false;
          _activeResume = data;
          _chatMode = true;
        });
        try {
          final res = await _atsService.ragSuggest(
            workspaceId: _workspaceId,
            resumeId: data.id,
          );
          _safeSetState(() => _suggested = List<String>.from(res['questions'] ?? const <String>[]));
        } catch (_) {}
      },
      builder: (context, candidate, rejects) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: AppTheme.backgroundWhite,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: const Color(0xFF10B981).withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF10B981).withOpacity(0.05),
                          const Color(0xFF34A853).withOpacity(0.02),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.chat_bubble_outline,
                            color: Color(0xFF10B981),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _activeResume != null ? 'Chat: ${_activeResume!.candidate}' : 'Chat with AI',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: AppTheme.primaryBlack,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _activeResume != null ? 'Ask questions about this candidate' : 'Get insights about candidates',
                                style: const TextStyle(
                                  color: AppTheme.secondaryGray,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() => _chatMode = false),
                          icon: const Icon(Icons.close, color: AppTheme.secondaryGray),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_suggested.isNotEmpty)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryBlack,
                              fontSize: 14,
                            ),
                            child: const Text('Suggested Questions'),
                          ),
                          const SizedBox(height: 8),
                          AnimatedList(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            initialItemCount: _suggested.take(4).length,
                            itemBuilder: (context, index, animation) {
                              final q = _suggested[index];
                              return SlideTransition(
                                position: animation.drive(
                                  Tween<Offset>(
                                    begin: const Offset(0, 0.5),
                                    end: Offset.zero,
                                  ).chain(CurveTween(curve: Curves.easeOutBack)),
                                ),
                                child: FadeTransition(
                                  opacity: animation,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF10B981).withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ActionChip(
                                      label: Text(
                                        q,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      onPressed: () => _sendQuery(q),
                                      backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
                                      labelStyle: const TextStyle(color: Color(0xFF10B981)),
                                      side: BorderSide(
                                        color: const Color(0xFF10B981).withOpacity(0.3),
                                        width: 1,
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  _buildGradientDivider(),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final m = _messages[index];
                        return TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 300 + (index * 100)),
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Opacity(
                                opacity: value,
                                child: Align(
                                  alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: m.isUser 
                                          ? const Offset(1.0, 0.0)
                                          : const Offset(-1.0, 0.0),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(
                                      parent: AlwaysStoppedAnimation(value),
                                      curve: Curves.easeOutBack,
                                    )),
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: m.isUser 
                                            ? const Color(0xFF4285F4).withOpacity(0.1)
                                            : const Color(0xFFF8F9FA),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: m.isUser 
                                              ? const Color(0xFF4285F4).withOpacity(0.2)
                                              : const Color(0xFFE5E7EB),
                                          width: 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        m.text,
                                        style: TextStyle(
                                          color: m.isUser ? const Color(0xFF4285F4) : AppTheme.primaryBlack,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
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
                  _ChatInput(onSend: (text) => _sendQuery(text)),
                ],
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
                                    duration: const Duration(milliseconds: 1000),
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    builder: (context, bounceValue, child) {
                                      return Transform.translate(
                                        offset: Offset(0, -10 * (1 - bounceValue)),
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
                                      color: const Color(0xFF10B981).withOpacity(0.8),
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
    try {
      final res = await _atsService.ragQuery(
        workspaceId: _workspaceId,
        message: text,
        resumeId: _activeResume?.id,
        chatId: _activeResume?.id,
      );
      final answer = (res['answer'] ?? '').toString();
      _safeSetState(() => _messages.add(_ChatMessage(text: answer, isUser: false)));
    } catch (e) {
      _safeSetState(() => _messages.add(_ChatMessage(text: 'Error: $e', isUser: false)));
    }
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
                            gradient: const SweepGradient(colors: [
                              Color(0xFF4285F4),
                              Color(0xFFEA4335),
                              Color(0xFFFBBC04),
                              Color(0xFF34A853),
                              Color(0xFF4285F4),
                            ]),
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
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentBlue),
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
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                            Expanded(
                              flex: 1,
                              child: Center(
                                child: SizedBox(
                                  width: 600,
                                  child: _chatMode ? _buildChatPanel(context) : _buildFilters(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1000),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: Opacity(
                      opacity: value,
                      child: Align(
                        alignment: Alignment.center,
                        child: _buildVisualizeButton(context),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVisualizeButton(BuildContext context) {
    final disabled = _processing == null || _ranking == null;
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 200),
      tween: Tween(begin: 1.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            decoration: BoxDecoration(
              gradient: disabled 
                  ? null 
                  : const LinearGradient(
                      colors: [Color(0xFF4285F4), Color(0xFF8B5CF6)],
                    ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: disabled 
                  ? null 
                  : [
                      BoxShadow(
                        color: const Color(0xFF4285F4).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: ElevatedButton.icon(
              onPressed: disabled
                  ? null
                  : () {
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
              style: ElevatedButton.styleFrom(
                backgroundColor: disabled ? AppTheme.secondaryGray : Colors.transparent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: disabled ? AppTheme.secondaryGray : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              icon: Icon(
                Icons.insights,
                color: disabled ? AppTheme.backgroundWhite : Colors.white,
              ),
              label: Text(
                'Visualize',
                style: TextStyle(
                  color: disabled ? AppTheme.backgroundWhite : Colors.white,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
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
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF4285F4).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4285F4).withOpacity(0.05),
                  const Color(0xFF8B5CF6).withOpacity(0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4285F4).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.people,
                    color: Color(0xFF4285F4),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filtered Candidates',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.primaryBlack,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${items.length} candidates found',
                        style: const TextStyle(
                          color: AppTheme.secondaryGray,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF34A853).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${items.length}',
                    style: const TextStyle(
                      color: Color(0xFF34A853),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildGradientDivider(),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              thickness: 6,
              radius: const Radius.circular(8),
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final r = items[index];
                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 300 + (index * 100)),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.9 + (0.1 * value),
                        child: Opacity(
                          opacity: value,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.3),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: AlwaysStoppedAnimation(value),
                              curve: Curves.easeOutBack,
                            )),
                            child: Draggable<RankedResume>(
                              data: r,
                              feedback: Material(
                                color: Colors.transparent,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
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
                                child: _CandidateTile(resume: r),
                              ),
                              child: _CandidateTile(resume: r),
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
    );
  }

  Widget _buildFilters(BuildContext context) {
    final jdSkills = _ranking?.jdSkills ?? const <String>[];
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF8B5CF6).withOpacity(0.05),
                    const Color(0xFFEA4335).withOpacity(0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.tune,
                      size: 20,
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filters & AI Chat',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.primaryBlack,
                                fontWeight: FontWeight.w700,
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
                    onPressed: () => setState(() => _chatMode = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4285F4),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline, size: 16),
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
            ),
            const SizedBox(height: 24),
            _buildGradientDivider(),
            const SizedBox(height: 20),
            Text(
              'Quick Filters',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.primaryBlack,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Switch(
                    value: _gmailOnly,
                    onChanged: (v) => setState(() => _gmailOnly = v),
                    activeColor: const Color(0xFF4285F4),
                    activeTrackColor: const Color(0xFF4285F4).withOpacity(0.3),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email Required',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryBlack,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Only show candidates with email addresses',
                          style: TextStyle(
                            color: AppTheme.secondaryGray,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Job Description Skills',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.primaryBlack,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
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
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: jdSkills.map((skill) {
                final selected = _skillFilters.contains(skill);
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF4285F4).withOpacity(0.3),
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
                    selectedColor: const Color(0xFF4285F4).withOpacity(0.15),
                    checkmarkColor: const Color(0xFF4285F4),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: selected
                          ? const Color(0xFF4285F4)
                          : const Color(0xFFE5E7EB),
                      width: 1.5,
                    ),
                    labelStyle: TextStyle(
                      color: selected
                          ? const Color(0xFF4285F4)
                          : AppTheme.primaryBlack,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientDivider() {
    return Container(
      height: 2,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [
          Color(0xFF4285F4),
          Color(0xFFEA4335),
          Color(0xFFFBBC04),
          Color(0xFF34A853),
        ]),
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
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 6)),
        ],
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.secondaryGray.withOpacity(0.15)),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 4,
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
                gradient: LinearGradient(colors: [
                  Color(0xFF4285F4),
                  Color(0xFFEA4335),
                  Color(0xFFFBBC04),
                  Color(0xFF34A853),
                ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
              ),
            ),
          ),
          Padding(
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
          ),
        ],
      ),
    );
  }
}

class _RatingStars extends StatelessWidget {
  final double atsScore;
  final double semanticScore;

  const _RatingStars({required this.atsScore, required this.semanticScore});

  double _combinedScore() {
    final semanticPct = (semanticScore.clamp(0.0, 1.0)) * 100.0;
    final atsPct = atsScore.clamp(0.0, 100.0);
    return semanticPct * 0.7 + atsPct * 0.3;
  }

  int _starsFilled() {
    final combined = _combinedScore();
    final outOfFive = combined / 20.0;
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
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Ask about the candidate...',
                  hintStyle: TextStyle(
                    color: AppTheme.secondaryGray,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4285F4), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4285F4).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                final text = _controller.text;
                _controller.clear();
                widget.onSend(text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Send',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.send, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}