import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/theme_provider.dart';
import '../widgets/custom_text.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomText.heading2('Settings'),
        elevation: 1,
      ),
      body: ListView(
        children: [
          // Profile Section
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText.heading2('John Doe'),
                      CustomText.caption('john.doe@example.com'),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edit profile coming soon!')),
                    );
                  },
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Appearance Section
          _SettingsSection(
            title: 'Appearance',
            children: [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return _SettingsItem(
                    icon: themeProvider.isDarkMode 
                        ? Icons.dark_mode 
                        : Icons.light_mode,
                    title: 'Dark Mode',
                    subtitle: themeProvider.isDarkMode 
                        ? 'Dark theme enabled' 
                        : 'Light theme enabled',
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme();
                      },
                    ),
                  );
                },
              ),
              _SettingsItem(
                icon: Icons.text_fields,
                title: 'Font Size',
                subtitle: 'Medium',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showFontSizeDialog(context);
                },
              ),
            ],
          ),
          
          // Notifications Section
          _SettingsSection(
            title: 'Notifications',
            children: [
              _SettingsItem(
                icon: Icons.notifications,
                title: 'Push Notifications',
                subtitle: 'Receive notifications from the app',
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value ? 'Notifications enabled' : 'Notifications disabled',
                        ),
                      ),
                    );
                  },
                ),
              ),
              _SettingsItem(
                icon: Icons.email,
                title: 'Email Notifications',
                subtitle: 'Receive email updates',
                trailing: Switch(
                  value: false,
                  onChanged: (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value ? 'Email notifications enabled' : 'Email notifications disabled',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          
          // Privacy Section
          _SettingsSection(
            title: 'Privacy',
            children: [
              _SettingsItem(
                icon: Icons.privacy_tip,
                title: 'Privacy Policy',
                subtitle: 'View our privacy policy',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening privacy policy...')),
                  );
                },
              ),
              _SettingsItem(
                icon: Icons.security,
                title: 'Account Security',
                subtitle: 'Manage your account security',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening security settings...')),
                  );
                },
              ),
              _SettingsItem(
                icon: Icons.visibility,
                title: 'Data & Privacy',
                subtitle: 'Control your data and privacy',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening data settings...')),
                  );
                },
              ),
            ],
          ),
          
          // Account Section
          _SettingsSection(
            title: 'Account',
            children: [
              _SettingsItem(
                icon: Icons.backup,
                title: 'Backup & Restore',
                subtitle: 'Backup your data',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening backup settings...')),
                  );
                },
              ),
              _SettingsItem(
                icon: Icons.storage,
                title: 'Storage',
                subtitle: 'Manage app storage',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening storage settings...')),
                  );
                },
              ),
            ],
          ),
          
          // Support Section
          _SettingsSection(
            title: 'Support',
            children: [
              _SettingsItem(
                icon: Icons.help,
                title: 'Help Center',
                subtitle: 'Get help and support',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening help center...')),
                  );
                },
              ),
              _SettingsItem(
                icon: Icons.feedback,
                title: 'Send Feedback',
                subtitle: 'Help us improve the app',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening feedback form...')),
                  );
                },
              ),
              _SettingsItem(
                icon: Icons.info,
                title: 'About',
                subtitle: 'App version and information',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showAboutDialog(context);
                },
              ),
            ],
          ),
          
          // Logout Section
          Container(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () {
                _showLogoutDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 8),
                  CustomText.body('Logout', color: Colors.white),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showFontSizeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Font Size'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Small'),
                leading: Radio(value: 0, groupValue: 1, onChanged: (value) {}),
              ),
              ListTile(
                title: const Text('Medium'),
                leading: Radio(value: 1, groupValue: 1, onChanged: (value) {}),
              ),
              ListTile(
                title: const Text('Large'),
                leading: Radio(value: 2, groupValue: 1, onChanged: (value) {}),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Font size updated!')),
                );
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('About Facebook Replication'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Version: 1.0.0'),
              SizedBox(height: 8),
              Text('Build: 2024.03.01'),
              SizedBox(height: 16),
              Text(
                'A Flutter app that replicates Facebook\'s core features with modern design and functionality.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged out successfully!')),
                );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: CustomText.caption(
            title.toUpperCase(),
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        ...children,
        const SizedBox(height: 8),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: CustomText.body(title, fontWeight: FontWeight.w500),
      subtitle: subtitle != null 
          ? CustomText.caption(subtitle!) 
          : null,
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}