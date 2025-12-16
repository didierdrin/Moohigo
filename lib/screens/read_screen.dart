import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import '../cubits/read_cubit.dart';
import '../repositories/law_repository.dart';
import '../models/law_model.dart';

class ReadScreen extends StatelessWidget {
  const ReadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ReadView();
  }
}

class ReadView extends StatelessWidget {
  const ReadView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ReadCubit, ReadState>(
        builder: (context, state) {
          if (state is ReadLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ReadError) {
            return Center(child: Text(state.message));
          } else if (state is ReadLoaded) {
            return Stack(
              children: [
                // Main Content with Collapsible AppBar
                CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 120.0,
                      floating: true,
                      pinned: true,
                      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                      flexibleSpace: FlexibleSpaceBar(
                        title: Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                          child: Text(
                            state.document.filename,
                            style: GoogleFonts.outfit(
                               color: Theme.of(context).colorScheme.onSurface,
                               fontSize: 16,
                               fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        centerTitle: true,
                        background: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                          ),
                          child: Icon(CupertinoIcons.book, size: 48, color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
                        ),
                      ),
                      leading: Icon(CupertinoIcons.book_fill, color: Theme.of(context).colorScheme.primary),
                      actions: [
                        IconButton(
                          icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurface),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                        child: _buildDocumentContent(context, state.document),
                      ),
                    ),
                  ],
                ),

                // Floating Navigation Buttons (Left/Right)
                if (state.currentIndex > 0)
                  Positioned(
                    left: 16,
                    top: MediaQuery.of(context).size.height / 2,
                    child: FloatingActionButton.small(
                      heroTag: "prev_btn",
                      onPressed: () => context.read<ReadCubit>().previousArticle(),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      child: const Icon(Icons.arrow_back_ios_new, size: 16),
                    ),
                  ),

                if (state.currentIndex < state.totalDocs - 1)
                  Positioned(
                    right: 16,
                    top: MediaQuery.of(context).size.height / 2,
                    child: FloatingActionButton.small(
                      heroTag: "next_btn",
                      onPressed: () => context.read<ReadCubit>().nextArticle(),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      child: const Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  ),

                // Play Button (Above Bottom Navigation)
                Positioned(
                  bottom: 24,
                  right: 24,
                  child: FloatingActionButton.extended(
                    heroTag: "play_btn",
                    onPressed: () => context.read<ReadCubit>().toggleTts(),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    icon: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow),
                    label: Text(state.isPlaying ? "" : ""),
                    // label: Text(state.isPlaying ? "Pause" : "Listen"),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDocumentContent(BuildContext context, LegalDocument document) {
    // Handle structured document
    if (document.structure.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...document.structure.map<Widget>((item) => _buildStructureItem(context, item)).toList(),
        ],
      );
    }
    
    // Fallback to fullContent if available
    return Text(
      document.fullContent,
      style: GoogleFonts.merriweather(
        fontSize: 18,
        height: 1.8,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
    );
  }

  Widget _buildStructureItem(BuildContext context, DocumentStructure item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            width: 3,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
        ),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.title.isNotEmpty)
            Text(
              item.title,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          
          const SizedBox(height: 8),
          
          if (item.content.isNotEmpty)
            Text(
              item.content,
              style: GoogleFonts.merriweather(
                fontSize: 16,
                height: 1.7,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
        ],
      ),
    );
  }

}
