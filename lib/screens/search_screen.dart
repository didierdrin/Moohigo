import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import '../cubits/search_cubit.dart';
import '../repositories/law_repository.dart';
import '../models/law_model.dart';
import '../cubits/main_screen_cubit.dart';
import '../cubits/read_cubit.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchCubit(context.read<LawRepository>()),
      child: const SearchView(),
    );
  }
}

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _chatController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    "Search",
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search laws, articles...",
                      prefixIcon: const Icon(CupertinoIcons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                    ),
                    onSubmitted: (val) {
                      context.read<SearchCubit>().search(val);
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Mode Toggle
                  BlocBuilder<SearchCubit, SearchState>(
                    builder: (context, state) {
                      bool isAi = false;
                      if (state is SearchLoaded) isAi = state.isAiMode;
                      
                      return Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => context.read<SearchCubit>().toggleMode(false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: !isAi ? Theme.of(context).colorScheme.primary : Colors.transparent,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Normal Search",
                                      style: TextStyle(
                                        color: !isAi ? Colors.white : Theme.of(context).colorScheme.onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => context.read<SearchCubit>().toggleMode(true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isAi ? Theme.of(context).colorScheme.primary : Colors.transparent,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.auto_awesome, size: 16, color: isAi ? Colors.white : Theme.of(context).colorScheme.onSurface),
                                      const SizedBox(width: 8),
                                      Text(
                                        "AI Chat",
                                        style: TextStyle(
                                          color: isAi ? Colors.white : Theme.of(context).colorScheme.onSurface,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            // Search Content / Results / Chat
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  if (state is SearchLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is SearchError) {
                    return Center(child: Text(state.message));
                  } else if (state is SearchLoaded) {
                    // Chat View
                    if (state.isAiMode && state.chatHistory.isNotEmpty) {
                      return Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: state.chatHistory.length,
                              itemBuilder: (context, index) {
                                final msg = state.chatHistory[index];
                                return Align(
                                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    constraints: const BoxConstraints(maxWidth: 300),
                                    decoration: BoxDecoration(
                                      color: msg.isUser 
                                          ? Theme.of(context).colorScheme.primary 
                                          : Theme.of(context).colorScheme.surfaceVariant,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          msg.text,
                                          style: TextStyle(
                                            color: msg.isUser ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _chatController,
                                    decoration: InputDecoration(
                                      hintText: "Ask follow up...",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    onSubmitted: (val) {
                                      if (val.isNotEmpty) {
                                        context.read<SearchCubit>().sendMessage(val);
                                        _chatController.clear();
                                      }
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.send),
                                  onPressed: () {
                                     if (_chatController.text.isNotEmpty) {
                                        context.read<SearchCubit>().sendMessage(_chatController.text);
                                        _chatController.clear();
                                      }
                                  },
                                )
                              ],
                            ),
                          )
                        ],
                      );
                    }
                    
                    // Results View (ListTiles)
                    if (state.results.isEmpty) {
                      return Center(child: Text("No results found. Start typing to search.", style: TextStyle(color: Colors.grey)));
                    }
                    
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.results.length,
                      itemBuilder: (context, index) {
                        final doc = state.results[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                                state.isAiMode ? Icons.chat_bubble_outline : Icons.article_outlined,
                                color: Theme.of(context).colorScheme.primary
                            ),
                            title: Text(doc.filename, maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text(
                              doc.fullContent, 
                              maxLines: 2, 
                              overflow: TextOverflow.ellipsis
                            ),
                            onTap: () {
                              if (state.isAiMode) {
                                context.read<SearchCubit>().startChat(doc);
                              } else {
                                context.read<ReadCubit>().selectDocument(doc);
                                context.read<MainScreenCubit>().setIndex(1); // Navigate to Read tab
                              }
                            },
                          ),
                        );
                      },
                    );
                  }
                  return const Center(child: Text("Start searching..."));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
