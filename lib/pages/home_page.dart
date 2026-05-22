import 'package:flutter/material.dart';
import '../models/user.dart';
import '../widgets/custom_button.dart';
import 'profile_page.dart';
import 'quiz_page.dart';
import 'multi_quiz_page.dart';
import 'calculator_page.dart';
import 'poll_page.dart';
import 'max_min_page.dart';
import 'discount_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF082052);
    const bgColor = Color(0xFFF8F0E5);
    final user = User.defaultUser();
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: bgColor,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Index 0: Home Page
          _buildHomePage(user, primaryColor, bgColor, screenWidth),
          // Index 1: Profile Page
          const ProfilePage(),
          // Index 2: Quiz Page
          const QuizPage(),
          // Index 3: Categories Page
          _buildCategoriesPage(primaryColor, bgColor, screenWidth),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: bgColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey[400],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Quiz'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Categories'),
        ],
      ),
    );
  }


  Widget _buildHomePage(final user, Color primaryColor, Color bgColor, double screenWidth) {
    final padding = screenWidth < 400 ? 16.0 : 20.0;
    final heading1 = screenWidth < 400 ? 22.0 : 24.0;
    final heading2 = screenWidth < 400 ? 14.0 : 16.0;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: primaryColor,
              padding: EdgeInsets.fromLTRB(padding, 12, padding, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Learning Hub',
                          style: TextStyle(
                            fontSize: heading1,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () {},
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search features...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        prefixIcon: Icon(Icons.search, color: primaryColor),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Hi, ${user.name}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.menu_book_rounded,
                          iconColor: primaryColor,
                          title: 'Course',
                          value: '${user.completedCourses}',
                          subtitle: 'Completed',
                          primaryColor: primaryColor,
                          bgColor: bgColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.quiz_rounded,
                          iconColor: primaryColor,
                          title: 'Quiz',
                          value: '${user.completedQuizzes}',
                          subtitle: 'Completed',
                          primaryColor: primaryColor,
                          bgColor: bgColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Learning Progress',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF374151),
                                ),
                              ),
                              Text(
                                '${user.learningProgress.toInt()}%',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: user.learningProgress / 100,
                              minHeight: 8,
                              backgroundColor: const Color(0xFFE5E7EB),
                              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '#Categories',
                        style: TextStyle(
                          fontSize: heading2,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _selectedIndex = 3),
                        child: Text(
                          'See All',
                          style: TextStyle(
                            fontSize: 12,
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _CategoryIcon(
                          icon: Icons.quiz_rounded,
                          label: 'Quiz',
                          color: primaryColor,
                          onTap: () => setState(() => _selectedIndex = 2),
                        ),
                        _CategoryIcon(
                          icon: Icons.menu_book_rounded,
                          label: 'Course',
                          color: primaryColor,
                          onTap: () {},
                        ),
                        _CategoryIcon(
                          icon: Icons.checklist_rounded,
                          label: 'Multi',
                          color: primaryColor,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MultiQuizPage()),
                          ),
                        ),
                        _CategoryIcon(
                          icon: Icons.calculate_rounded,
                          label: 'Calc',
                          color: primaryColor,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CalculatorPage()),
                          ),
                        ),
                        _CategoryIcon(
                          icon: Icons.poll_rounded,
                          label: 'Poll',
                          color: primaryColor,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PollPage()),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Features for you!',
                        style: TextStyle(
                          fontSize: heading2,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _selectedIndex = 3),
                        child: Text(
                          'See All',
                          style: TextStyle(
                            fontSize: 12,
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: screenWidth < 400 ? 2 : 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                    children: [
                      _FeatureCard(
                        icon: Icons.person_rounded,
                        title: 'Profile',
                        color: primaryColor,
                        onTap: () => setState(() => _selectedIndex = 1),
                        primaryColor: primaryColor,
                      ),
                      _FeatureCard(
                        icon: Icons.maximize_rounded,
                        title: 'Max & Min',
                        color: primaryColor,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MaxMinPage()),
                        ),
                        primaryColor: primaryColor,
                      ),
                      _FeatureCard(
                        icon: Icons.discount_rounded,
                        title: 'Discount',
                        color: primaryColor,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const DiscountPage()),
                        ),
                        primaryColor: primaryColor,
                      ),
                      _FeatureCard(
                        icon: Icons.checklist_rounded,
                        title: 'Multi Quiz',
                        color: primaryColor,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MultiQuizPage()),
                        ),
                        primaryColor: primaryColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesPage(Color primaryColor, Color bgColor, double screenWidth) {
    final padding = screenWidth < 400 ? 16.0 : 20.0;
    final heading1 = screenWidth < 400 ? 22.0 : 24.0;

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'All Categories',
                style: TextStyle(
                  fontSize: heading1,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: screenWidth < 400 ? 2 : 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
                children: [
                  _FeatureCard(
                    icon: Icons.person_rounded,
                    title: 'Profile',
                    color: primaryColor,
                    onTap: () => setState(() => _selectedIndex = 1),
                    primaryColor: primaryColor,
                  ),
                  _FeatureCard(
                    icon: Icons.quiz_rounded,
                    title: 'Quiz',
                    color: primaryColor,
                    onTap: () => setState(() => _selectedIndex = 2),
                    primaryColor: primaryColor,
                  ),
                  _FeatureCard(
                    icon: Icons.checklist_rounded,
                    title: 'Multi Quiz',
                    color: primaryColor,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MultiQuizPage()),
                    ),
                    primaryColor: primaryColor,
                  ),
                  _FeatureCard(
                    icon: Icons.calculate_rounded,
                    title: 'Calculator',
                    color: primaryColor,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CalculatorPage()),
                    ),
                    primaryColor: primaryColor,
                  ),
                  _FeatureCard(
                    icon: Icons.poll_rounded,
                    title: 'Polling',
                    color: primaryColor,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PollPage()),
                    ),
                    primaryColor: primaryColor,
                  ),
                  _FeatureCard(
                    icon: Icons.maximize_rounded,
                    title: 'Max & Min',
                    color: primaryColor,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MaxMinPage()),
                    ),
                    primaryColor: primaryColor,
                  ),
                  _FeatureCard(
                    icon: Icons.discount_rounded,
                    title: 'Discount',
                    color: primaryColor,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DiscountPage()),
                    ),
                    primaryColor: primaryColor,
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;
  final Color primaryColor;
  final Color bgColor;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.primaryColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: primaryColor, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CategoryIcon({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  final Color primaryColor;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: primaryColor, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
