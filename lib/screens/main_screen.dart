import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/main_screen_cubit.dart';
import '../cubits/read_cubit.dart';
import '../repositories/law_repository.dart';
import 'discover_screen.dart';
import 'read_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => MainScreenCubit()),
        BlocProvider(create: (context) => ReadCubit(context.read<LawRepository>())),
      ],
      child: const MainScreenView(),
    );
  }
}

class MainScreenView extends StatelessWidget {
  const MainScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = const [
      DiscoverScreen(),
      ReadScreen(),
      SearchScreen(),
      ProfileScreen(),
    ];

    return BlocBuilder<MainScreenCubit, int>(
      builder: (context, currentIndex) {
        return Scaffold(
          body: IndexedStack(
            index: currentIndex,
            children: screens,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) {
              context.read<MainScreenCubit>().setIndex(index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(CupertinoIcons.compass),
                selectedIcon: Icon(CupertinoIcons.compass_fill),
                label: 'Discover',
              ),
              NavigationDestination(
                icon: Icon(CupertinoIcons.book),
                selectedIcon: Icon(CupertinoIcons.book_fill),
                label: 'Read',
              ),
              NavigationDestination(
                icon: Icon(CupertinoIcons.search),
                label: 'Search',
              ),
              NavigationDestination(
                icon: Icon(CupertinoIcons.person),
                selectedIcon: Icon(CupertinoIcons.person_fill),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
