class LegalDocument {
  final String category;
  final String categoryCode;
  final String extractedAt;
  final String filename;
  final String fullContent;
  final List<String> keyTerms;
  final List<String> languages;
  final DocumentMetadata metadata;
  final List<DocumentStructure> structure;

  LegalDocument({
    required this.category,
    required this.categoryCode,
    required this.extractedAt,
    required this.filename,
    required this.fullContent,
    required this.keyTerms,
    required this.languages,
    required this.metadata,
    required this.structure,
  });

  factory LegalDocument.fromJson(Map<String, dynamic> json) {
    return LegalDocument(
      category: json['category'] ?? '',
      categoryCode: json['categoryCode'] ?? '',
      extractedAt: json['extractedAt'] ?? '',
      filename: json['filename'] ?? '',
      fullContent: json['fullContent'] ?? '',
      keyTerms: List<String>.from(json['keyTerms'] ?? []),
      languages: List<String>.from(json['languages'] ?? []),
      metadata: DocumentMetadata.fromJson(json['metadata'] ?? {}),
      structure: (json['structure'] as List?)
              ?.map((e) => DocumentStructure.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class DocumentMetadata {
  final int characterCount;
  final String extractionMethod;
  final int fileSize;
  final bool processed;
  final int wordCount;
  final int pages;

  DocumentMetadata({
    required this.characterCount,
    required this.extractionMethod,
    required this.fileSize,
    required this.processed,
    required this.wordCount,
    required this.pages,
  });

  factory DocumentMetadata.fromJson(Map<String, dynamic> json) {
    return DocumentMetadata(
      characterCount: json['characterCount'] ?? 0,
      extractionMethod: json['extractionMethod'] ?? '',
      fileSize: json['fileSize'] ?? 0,
      processed: json['processed'] ?? false,
      wordCount: json['wordCount'] ?? 0,
      pages: json['pages'] ?? 0,
    );
  }
}

class DocumentStructure {
  final String content;
  final int lineNumber;
  final String title;
  final String type;

  DocumentStructure({
    required this.content,
    required this.lineNumber,
    required this.title,
    required this.type,
  });

  factory DocumentStructure.fromJson(Map<String, dynamic> json) {
    return DocumentStructure(
      content: json['content'] ?? '',
      lineNumber: json['lineNumber'] ?? 0,
      title: json['title'] ?? '',
      type: json['type'] ?? '',
    );
  }
}
