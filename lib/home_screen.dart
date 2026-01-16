import 'package:flutter/material.dart';
import 'widgets.dart';

/// Sample data matching design/ui-examples/home.json
final Map<String, dynamic> sampleHomeData = {
  "appBar": {
    "title": "Good Morning, Alex!",
    "avatarUrl": null,
  },
  "workoutCard": {
    "title": "Upper Body Strength",
    "subtitle": "Chest, Shoulders, Triceps",
    "progress": 0.0,
    "ctaLabel": "Start Workout",
    "variant": "notStarted",
  },
  "templates": [
    {"title": "Full Body", "icon": "fitness_center"},
    {"title": "Cardio", "icon": "directions_run"},
    {"title": "Yoga", "icon": "self_improvement"},
  ],
  "recentWorkouts": [
    {"title": "Leg Day", "date": "Yesterday", "detail": "45 min"},
    {"title": "HIIT Session", "date": "2 days ago", "detail": "30 min"},
    {"title": "Core Workout", "date": "3 days ago", "detail": "20 min"},
  ],
};

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final appBar = sampleHomeData['appBar'] as Map<String, dynamic>;
    final workoutCard = sampleHomeData['workoutCard'] as Map<String, dynamic>;
    final templates = sampleHomeData['templates'] as List<dynamic>;
    final recentWorkouts = sampleHomeData['recentWorkouts'] as List<dynamic>;

    return Scaffold(
      appBar: GymAppBar(
        title: appBar['title'] as String,
        avatarUrl: appBar['avatarUrl'] as String?,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's Workout Card
            WorkoutCard(
              title: workoutCard['title'] as String,
              subtitle: workoutCard['subtitle'] as String,
              progress: (workoutCard['progress'] as num).toDouble(),
              ctaLabel: workoutCard['ctaLabel'] as String,
              variant: WorkoutCardVariant.values.firstWhere(
                (v) => v.name == workoutCard['variant'],
                orElse: () => WorkoutCardVariant.notStarted,
              ),
              onCtaPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Starting workout...')),
                );
              },
            ),
            const SizedBox(height: 24),

            // Quick Templates
            Text(
              'Quick Start',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: templates.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final template = templates[index] as Map<String, dynamic>;
                  return TemplateCard(
                    title: template['title'] as String,
                    iconName: template['icon'] as String,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Selected: ${template['title']}')),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Recent Workouts
            Text(
              'Recent Workouts',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...recentWorkouts.map((workout) {
              final w = workout as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: RecentRow(
                  title: w['title'] as String,
                  date: w['date'] as String,
                  detail: w['detail'] as String,
                ),
              );
            }),
          ],
        ),
      ),
      bottomNavigationBar: GymBottomNav(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
