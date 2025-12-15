import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/law_model.dart';
import '../repositories/law_repository.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<LegalDocument> results;
  final bool isAiMode;
  final List<ChatMessage> chatHistory;

  SearchLoaded({
    this.results = const [],
    this.isAiMode = false,
    this.chatHistory = const [],
  });
  
  SearchLoaded copyWith({
    List<LegalDocument>? results,
    bool? isAiMode,
    List<ChatMessage>? chatHistory,
  }) {
    return SearchLoaded(
      results: results ?? this.results,
      isAiMode: isAiMode ?? this.isAiMode,
      chatHistory: chatHistory ?? this.chatHistory,
    );
  }
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}

class ChatMessage {
  final String text;
  final bool isUser;
  final LegalDocument? attachedDoc;

  ChatMessage({required this.text, required this.isUser, this.attachedDoc});
}

class SearchCubit extends Cubit<SearchState> {
  final LawRepository _repository;

  SearchCubit(this._repository) : super(SearchInitial());

  void toggleMode(bool isAi) {
    if (state is SearchLoaded) {
      emit((state as SearchLoaded).copyWith(isAiMode: isAi));
    } else {
      emit(SearchLoaded(isAiMode: isAi));
    }
  }

  void search(String query) async {
    final currentState = state is SearchLoaded ? (state as SearchLoaded) : SearchLoaded();
    
    if (currentState.isAiMode) {
      // AI Search Mode
      // For demo: Show results related to query, and allow chatting.
      // This step just finds documents to start chatting about.
       emit(SearchLoading());
       try {
         final results = await _repository.searchArticles(query);
         emit(currentState.copyWith(results: results, isAiMode: true));
       } catch (e) {
         emit(SearchError("AI Search failed: $e"));
       }
    } else {
      // Normal Search
      emit(SearchLoading());
      try {
        final results = await _repository.searchArticles(query);
        emit(SearchLoaded(results: results, isAiMode: false));
      } catch (e) {
        emit(SearchError("Search failed: $e"));
      }
    }
  }

  void startChat(LegalDocument doc) {
    if (state is SearchLoaded) {
      final current = state as SearchLoaded;
      final history = List<ChatMessage>.from(current.chatHistory);
      
      // Initial message is the content of the listtile (summary or part of content)
      history.add(ChatMessage(
        text: "I want to ask about: ${doc.filename}",
        isUser: true,
      ));
      
      history.add(ChatMessage(
        text: "Sure, ask me anything about '${doc.filename}'. \n\nSnippet: ${doc.fullContent.substring(0, 100)}...",
        isUser: false,
        attachedDoc: doc,
      ));

      emit(current.copyWith(chatHistory: history, results: [], isAiMode: true)); 
      // Clear results to show chat view, or keep them? User said: "when a user click on 1 they can chat with the AI"
      // Suggestion: Full screen chat or replace list with chat.
    }
  }

  void sendMessage(String text) async {
    if (state is SearchLoaded) {
      final current = state as SearchLoaded;
      final history = List<ChatMessage>.from(current.chatHistory);
      
      history.add(ChatMessage(text: text, isUser: true));
      emit(current.copyWith(chatHistory: history));
      
      // Simulate AI response
      await Future.delayed(const Duration(seconds: 1));
      
      history.add(ChatMessage(
        text: "This is a simulated AI response to '$text' based on the legal document context.",
        isUser: false,
      ));
      emit(current.copyWith(chatHistory: history));
    }
  }
  
  void resetSearch() {
    emit(SearchInitial());
  }
}
