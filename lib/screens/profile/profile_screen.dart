import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<String> _userNameFuture;
  final authService = AuthService();

  @override
  void initState() {
    super.initState();
    _userNameFuture = authService.getUserName();
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFEBEAE5), // Cream background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: FutureBuilder<String>(
            future: _userNameFuture,
            builder: (context, snapshot) {
              final displayName = snapshot.data ?? 'No Name Set';
              final initialLetter =
                  displayName != 'No Name Set' && displayName.isNotEmpty
                      ? displayName[0]
                      : (user?.email?[0] ?? 'U');

              return Column(
                children: [
                  // Title
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Profile',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Avatar
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF9C8A8), // Peach
                        border: Border.all(color: Colors.black, width: 2),
                        boxShadow: const [
                          BoxShadow(color: Colors.black, offset: Offset(4, 4))
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.transparent,
                        child: Text(
                          initialLetter.toUpperCase(),
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 40,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    displayName,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.email ?? 'No email',
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Info cards
                  _ProfileInfoCard(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: user?.email ?? '—',
                  ),
                  const SizedBox(height: 16),
                  _ProfileInfoCard(
                    icon: Icons.verified_user_outlined,
                    label: 'Email Verified',
                    value: user?.emailVerified == true ? 'Yes' : 'No',
                  ),
                  const SizedBox(height: 16),
                  _ProfileInfoCard(
                    icon: Icons.calendar_today_outlined,
                    label: 'Member Since',
                    value: user?.metadata.creationTime != null
                        ? _formatDate(user!.metadata.creationTime!)
                        : '—',
                  ),

                  const Spacer(),

                  // Log out Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => AuthService().signOut(),
                      icon:
                          const Icon(Icons.logout_rounded, color: Colors.white),
                      label: Text(
                        'Log Out',
                        style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF18698), // Pink Pop
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(color: Colors.black, width: 2),
                        ),
                        elevation: 0,
                      ).copyWith(
                        shadowColor:
                            WidgetStateProperty.all(Colors.transparent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100), // Padding for dock
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _ProfileInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.lato(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
