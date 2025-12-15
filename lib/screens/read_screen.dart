import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import '../cubits/read_cubit.dart';
import '../repositories/law_repository.dart';

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
                        title: Text(
                          state.document.filename,
                          style: GoogleFonts.outfit(
                             color: Theme.of(context).colorScheme.onSurface,
                             fontSize: 16,
                             fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                         child: Text(
                          state.document.fullContent,
                          style: GoogleFonts.merriweather(
                            fontSize: 18,
                            height: 1.8,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
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
                    label: Text(state.isPlaying ? "Pause" : "Listen"),
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

}
