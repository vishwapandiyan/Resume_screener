import 'dart:convert';
import 'package:http/http.dart' as http;

class LlamaService {
  static const String _baseUrl = 'https://9f8d9cdbebdd.ngrok.app'; // Same as ATS service
  
  /// Generate job title using LLaMA API via Flask backend
  static Future<String> generateJobTitle(String jobDescription) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/generate_job_title'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'job_description': jobDescription,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['job_title'] ?? 'Generated Job Title';
      } else {
        throw Exception('Failed to generate job title: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to mock generation if API fails
      return _generateMockTitle(jobDescription);
    }
  }

  /// Generate job description using LLaMA API via Flask backend
  static Future<String> generateJobDescription(String jobTitle) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/generate_job_description'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'job_title': jobTitle,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['job_description'] ?? 'Generated job description';
      } else {
        throw Exception('Failed to generate job description: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to mock generation if API fails
      return _generateMockDescription(jobTitle);
    }
  }

  /// Enhanced job title generation using LLaMA API
  static Future<String> generateEnhancedJobTitle(String jobDescription) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/generate_enhanced_job_title'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'job_description': jobDescription,
          'include_seniority': true,
          'include_skills': true,
          'format': 'professional',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['job_title'] ?? 'Generated Job Title';
      } else {
        throw Exception('Failed to generate enhanced job title: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to mock generation if API fails
      return _generateMockTitle(jobDescription);
    }
  }

  /// Generate multiple job title suggestions
  static Future<List<String>> generateJobTitleSuggestions(String jobDescription) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/generate_job_title_suggestions'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'job_description': jobDescription,
          'count': 3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['suggestions'] ?? []);
      } else {
        throw Exception('Failed to generate job title suggestions: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to mock generation if API fails
      return [_generateMockTitle(jobDescription)];
    }
  }

  /// Fallback mock title generation
  static String _generateMockTitle(String description) {
    final keywords = description.toLowerCase();
    
    // Enhanced keyword matching for better titles
    if (keywords.contains('flutter') || keywords.contains('mobile')) {
      if (keywords.contains('senior') || keywords.contains('lead')) {
        return 'Senior Flutter Developer';
      } else if (keywords.contains('junior') || keywords.contains('entry')) {
        return 'Junior Flutter Developer';
      } else {
        return 'Flutter Developer';
      }
    } else if (keywords.contains('react') || keywords.contains('frontend')) {
      if (keywords.contains('senior') || keywords.contains('lead')) {
        return 'Senior Frontend Developer';
      } else {
        return 'Frontend Developer';
      }
    } else if (keywords.contains('python') || keywords.contains('backend')) {
      if (keywords.contains('senior') || keywords.contains('lead')) {
        return 'Senior Backend Developer';
      } else {
        return 'Backend Developer';
      }
    } else if (keywords.contains('full stack') || keywords.contains('fullstack')) {
      return 'Full Stack Developer';
    } else if (keywords.contains('data') && keywords.contains('scientist')) {
      return 'Data Scientist';
    } else if (keywords.contains('data') && keywords.contains('engineer')) {
      return 'Data Engineer';
    } else if (keywords.contains('machine learning') || keywords.contains('ml')) {
      return 'Machine Learning Engineer';
    } else if (keywords.contains('devops') || keywords.contains('cloud')) {
      return 'DevOps Engineer';
    } else if (keywords.contains('product') && keywords.contains('manager')) {
      return 'Product Manager';
    } else if (keywords.contains('designer') || keywords.contains('ui') || keywords.contains('ux')) {
      return 'UI/UX Designer';
    } else if (keywords.contains('marketing')) {
      return 'Marketing Specialist';
    } else if (keywords.contains('sales')) {
      return 'Sales Representative';
    } else if (keywords.contains('analyst')) {
      return 'Business Analyst';
    } else {
      return 'Software Engineer';
    }
  }

  /// Fallback mock description generation
  static String _generateMockDescription(String jobTitle) {
    final title = jobTitle.toLowerCase();
    
    if (title.contains('flutter')) {
      return 'We are looking for a Flutter Developer to join our team. You will be responsible for developing cross-platform mobile applications using Flutter framework. Experience with Dart, Firebase, and state management is required.';
    } else if (title.contains('frontend')) {
      return 'We are seeking a Frontend Developer to create user-friendly web applications. You will work with modern JavaScript frameworks, HTML, CSS, and collaborate with design teams to implement responsive interfaces.';
    } else if (title.contains('backend')) {
      return 'We need a Backend Developer to build and maintain server-side applications. You will work with databases, APIs, and cloud services to ensure scalable and efficient backend systems.';
    } else if (title.contains('full stack')) {
      return 'We are looking for a Full Stack Developer who can work on both frontend and backend development. You will be involved in the complete development lifecycle from concept to deployment.';
    } else if (title.contains('data scientist')) {
      return 'We are seeking a Data Scientist to analyze complex datasets and build machine learning models. You will work with statistical analysis, data visualization, and predictive modeling.';
    } else {
      return 'We are looking for a qualified professional to join our team. The ideal candidate should have relevant experience and skills in the field.';
    }
  }
}
