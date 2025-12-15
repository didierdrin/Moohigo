import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/law_model.dart';
import '../repositories/law_repository.dart';

abstract class ReadState {}

class ReadInitial extends ReadState {}

class ReadLoading extends ReadState {}

class ReadLoaded extends ReadState {
  final LegalDocument document;
  final bool isPlaying;
  final int currentIndex;
  final int totalDocs;

  ReadLoaded({
    required this.document, 
    this.isPlaying = false,
    required this.currentIndex,
    required this.totalDocs,
  });
  
  ReadLoaded copyWith({
    LegalDocument? document, 
    bool? isPlaying,
    int? currentIndex,
    int? totalDocs,
  }) {
    return ReadLoaded(
      document: document ?? this.document,
      isPlaying: isPlaying ?? this.isPlaying,
      currentIndex: currentIndex ?? this.currentIndex,
      totalDocs: totalDocs ?? this.totalDocs,
    );
  }
}

class ReadError extends ReadState {
  final String message;
  ReadError(this.message);
}

class ReadCubit extends Cubit<ReadState> {
  final LawRepository _repository;
  final FlutterTts flutterTts = FlutterTts();
  List<LegalDocument> _allDocs = [];

  ReadCubit(this._repository) : super(ReadInitial()) {
    _initTts();
    loadInitialData();
  }

  void _initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    
    flutterTts.setCompletionHandler(() {
      if (state is ReadLoaded) {
        emit((state as ReadLoaded).copyWith(isPlaying: false));
      }
    });

    flutterTts.setErrorHandler((msg) {
       if (state is ReadLoaded) {
        emit((state as ReadLoaded).copyWith(isPlaying: false));
      }
    });
  }

  void loadInitialData() async {
    emit(ReadLoading());
    try {
      _allDocs = await _repository.fetchDailyReading();
      if (_allDocs.isNotEmpty) {
        emit(ReadLoaded(
          document: _allDocs.first, 
          currentIndex: 0,
          totalDocs: _allDocs.length
        ));
      } else {
        emit(ReadError("No content available"));
      }
    } catch (e) {
      emit(ReadError("Error loading content: $e"));
    }
  }

  void nextArticle() {
    if (state is ReadLoaded) {
      final current = state as ReadLoaded;
      if (current.currentIndex < _allDocs.length - 1) {
        stopTts();
        final newIndex = current.currentIndex + 1;
        emit(ReadLoaded(
          document: _allDocs[newIndex],
          currentIndex: newIndex,
          totalDocs: _allDocs.length,
        ));
      }
    }
  }

  void previousArticle() {
    if (state is ReadLoaded) {
      final current = state as ReadLoaded;
      if (current.currentIndex > 0) {
        stopTts();
        final newIndex = current.currentIndex - 1;
        emit(ReadLoaded(
          document: _allDocs[newIndex],
          currentIndex: newIndex,
          totalDocs: _allDocs.length,
        ));
      }
    }
  }

  void stopTts() async {
    await flutterTts.stop();
    if (state is ReadLoaded) {
       emit((state as ReadLoaded).copyWith(isPlaying: false));
    }
  }

  void toggleTts() async {
    if (state is ReadLoaded) {
      final loadedState = state as ReadLoaded;
      if (loadedState.isPlaying) {
        await flutterTts.stop();
        emit(loadedState.copyWith(isPlaying: false));
      } else {
        String textToRead = "Title: ${loadedState.document.filename}. Content: ${loadedState.document.fullContent}";
        if (textToRead.length > 4000) {
           textToRead = textToRead.substring(0, 4000); 
        }
        await flutterTts.speak(textToRead);
        emit(loadedState.copyWith(isPlaying: true));
      }
    }
  }
  
  void selectDocument(LegalDocument doc) {
    stopTts();
    // find index if exists in _allDocs
    int index = _allDocs.indexWhere((element) => element.filename == doc.filename); // simplistic check
    if (index == -1) {
       // if not in current list, maybe add it or just show it as single
       index = 0; 
       _allDocs = [doc]; // Reset list or append? For now, simplistic.
    }
    
    emit(ReadLoaded(
      document: doc,
      currentIndex: index,
      totalDocs: _allDocs.length,
    ));
  }

  @override
  Future<void> close() {
    flutterTts.stop();
    return super.close();
  }
}
