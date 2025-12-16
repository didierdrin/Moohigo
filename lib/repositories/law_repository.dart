import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/law_model.dart';

class LawRepository {
  final FirebaseFirestore _firestore;

  LawRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Cache or localized list for demo navigation
  List<LegalDocument> _cachedDocs = [];

  Future<List<LegalDocument>> fetchDailyReading() async {
    if (_cachedDocs.isNotEmpty) return _cachedDocs;
    
    // Simulating data if firestore is empty or for initial dev
    List<LegalDocument> docs = [];
    
    // Create some dummy data based on user structure if fetch fails or for demo  example_legal_documents
    try {
      final snapshot = await _firestore
          .collection('legal_documents')
          .limit(10)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        docs = snapshot.docs.map((doc) => LegalDocument.fromJson(doc.data())).toList();
      }
    } catch (e) {
      print("Error fetching from Firestore: $e");
    }

    if (docs.isEmpty) {
      docs = _generateMockDocs();
    }
    
    _cachedDocs = docs;
    return docs;
  }

  Future<List<LegalDocument>> fetchRecentReads() async {
    return fetchDailyReading();
  }

  Future<List<LegalDocument>> searchArticles(String query) async {
    final all = await fetchDailyReading();
    if (query.isEmpty) return [];
    return all.where((doc) => 
      doc.filename.toLowerCase().contains(query.toLowerCase()) || 
      doc.fullContent.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // Mock Generation
  List<LegalDocument> _generateMockDocs() {
    return List.generate(5, (index) {
      return LegalDocument(
        category: "Domestic_Laws/Constitution",
        categoryCode: "1.1.1.$index",
        extractedAt: DateTime.now().toIso8601String(),
        filename: "Constitution_Article_${index + 1}.pdf",
        fullContent: "Article ${index + 1}: The Republic of Rwanda. \nThis is the detailed content of article ${index + 1}. \nIt establishes the sovereignty of the people and the supremacy of the Constitution. The user can read this text or listen to it using the AI text to speech feature.",
        keyTerms: ["Constitution", "Article", "Rwanda"],
        languages: ["English", "Kinyarwanda"],
        metadata: DocumentMetadata(
          characterCount: 500,
          extractionMethod: "cli-upload",
          fileSize: 1024,
          processed: true,
          wordCount: 100,
          pages: 1,
        ),
        structure: [
          DocumentStructure(content: "Article Content...", lineNumber: 1, title: "Article ${index+1}", type: "article")
        ],
      );
    });
  }
}
