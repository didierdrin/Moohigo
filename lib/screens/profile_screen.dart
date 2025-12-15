import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../cubits/theme_cubit.dart';
import '../cubits/profile_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit(),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Profile",
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              
              BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                  if (state is ProfileLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ProfileLoaded) {
                    final user = state.userData;
                    return Column(
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            child: Icon(Icons.person, size: 50, color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            user['name'] ?? 'User',
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                         Center(
                          child: Text(
                            user['email'] ?? '',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        _buildProfileItem(context, 'Address', user['address'] ?? 'Not set', Icons.location_on),
                      ],
                    );
                  } else if (state is ProfileError) {
                    return Center(child: Text("Error: ${state.message}"));
                  }
                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              
              Text(
                "Preferences",
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, mode) {
                  return SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Dark Mode"),
                    secondary: const Icon(Icons.dark_mode),
                    value: mode == ThemeMode.dark,
                    onChanged: (val) {
                      context.read<ThemeCubit>().toggleTheme(val);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(BuildContext context, String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
