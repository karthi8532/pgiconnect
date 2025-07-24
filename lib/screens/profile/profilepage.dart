import 'package:flutter/material.dart';
import 'package:pgiconnect/const/pref.dart';
import 'package:pgiconnect/service/appcolor.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Appcolor.primary,
        title: Text("Profile Page"),
      ),
      body: Column(
        children: [
          Container(
            height: 200,
            color: Appcolor.primary,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(
                      'assets/images/avataricon.png',
                      // Replace with your image URL
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    Prefs.getFullName("Name").toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                infoRow('Phone', '+5999-771-7171'),
                const SizedBox(height: 8),
                infoRow('Mail', 'rita@gmail.com'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Divider(thickness: 1),
          settingItem(
            icon: Icons.dark_mode_outlined,
            title: 'Dark mode',
            trailing: Switch(
              value: isDarkMode,
              onChanged: (val) {
                setState(() {
                  isDarkMode = val;
                });
              },
            ),
          ),
          settingItem(icon: Icons.person_outline, title: 'Profile details'),
          settingItem(icon: Icons.settings_outlined, title: 'Settings'),
          settingItem(icon: Icons.logout, title: 'Log out'),
        ],
      ),
    );
  }

  Widget infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:
              const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget settingItem({
    required IconData icon,
    required String title,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title),
      trailing: trailing,
      onTap: () {},
    );
  }
}
