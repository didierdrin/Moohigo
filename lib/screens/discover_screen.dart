import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../cubits/discover_cubit.dart';
import '../repositories/law_repository.dart';
import '../models/law_model.dart';
import '../cubits/main_screen_cubit.dart';
import '../cubits/read_cubit.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DiscoverCubit(context.read<LawRepository>()),
      child: const DiscoverView(),
    );
  }
}

class DiscoverView extends StatelessWidget {
  const DiscoverView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logoAsset = isDark
        ? 'assets/images/moohigo_dark.png'
        : 'assets/images/moohigo_light.png';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.transparent,
                  child: Image.asset(
                    logoAsset,
                    height: 40,
                    errorBuilder: (context, error, stackTrace) => Text(
                      "Moohigo",
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              BlocBuilder<DiscoverCubit, DiscoverState>(
                builder: (context, state) {
                  if (state is DiscoverLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is DiscoverError) {
                    return Center(child: Text(state.message));
                  } else if (state is DiscoverLoaded) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Today's Reading
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            "Today's Reading",
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 220,
                          child: PageView.builder(
                            controller: PageController(viewportFraction: 0.85),
                            itemCount: state.dailyReadings.isNotEmpty ? state.dailyReadings.length : 3,
                            itemBuilder: (context, index) {
                              final doc = state.dailyReadings.isNotEmpty ? state.dailyReadings[index] : null;
                              return GestureDetector(
                                onTap: () {
                                  if (doc != null) {
                                    context.read<ReadCubit>().selectDocument(doc);
                                    context.read<MainScreenCubit>().setIndex(1); // Navigate to Read tab
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                    image: const DecorationImage(
                                      image: NetworkImage('https://source.unsplash.com/random/800x600?law,book'), // Placeholder
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.8),
                                        ],
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(20),
                                    alignment: Alignment.bottomLeft,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          doc?.metadata.extractionMethod ?? "Constitution of Rwanda",
                                          style: GoogleFonts.outfit(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "Read Article >",
                                          style: GoogleFonts.outfit(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Recent Reads
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            "Recent Reads",
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 160,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            scrollDirection: Axis.horizontal,
                            itemCount: state.recentReads.isNotEmpty ? state.recentReads.length : 5,
                            itemBuilder: (context, index) {
                              final doc = state.recentReads.isNotEmpty ? state.recentReads[index] : null;
                              return GestureDetector(
                                onTap: () {
                                   if (doc != null) {
                                     context.read<ReadCubit>().selectDocument(doc);
                                     context.read<MainScreenCubit>().setIndex(1);
                                   }
                                },
                                child: Container(
                                  width: 140,
                                  margin: const EdgeInsets.only(right: 16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Theme.of(context).cardColor,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            color: Theme.of(context).colorScheme.surfaceVariant,
                                          ),
                                          alignment: Alignment.center,
                                          child: Icon(Icons.history_edu, color: Theme.of(context).colorScheme.primary),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        doc?.filename ?? "Legal Document $index",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Categories
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            "Legal Domains",
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          shrinkWrap: true,
                          primary: false,
                          children: [
                            _buildCategoryTile(context, "Startups & Business", Icons.business),
                            _buildCategoryTile(context, "Intellectual Property", Icons.lightbulb_outline),
                            _buildCategoryTile(context, "Labor & Employment", Icons.work_outline),
                            _buildCategoryTile(context, "Tech & Data Privacy", Icons.security),
                          ],
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTile(BuildContext context, String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {},
      ),
    );
  }
}
