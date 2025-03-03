import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/feature/auth/data/view_model/user_view_model.dart';
import 'package:coyotex/feature/auth/screens/login_screen.dart';
import 'package:coyotex/feature/auth/screens/prefrence_dstance_screen.dart';
import 'package:coyotex/feature/auth/screens/weather_prefrences.dart';
import 'package:coyotex/feature/profile/presentation/FAQ_screen.dart';
import 'package:coyotex/feature/profile/presentation/change_password.dart';
import 'package:coyotex/feature/profile/presentation/edit_profile.dart';
import 'package:coyotex/feature/profile/presentation/linked_devices.dart';
import 'package:coyotex/feature/profile/presentation/subscription_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utills/shared_pref.dart';
import '../../auth/screens/passowrd_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, userViewModel, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
          ),
          body: Column(
            children: [
              Container(
                color: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      child: Icon(Icons.person),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 40,
                        ),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  userViewModel.user.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.verified,
                                  color: Colors.orange,
                                  size: 20,
                                ),
                              ],
                            ),
                            Text(
                              '@${userViewModel.user.name}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return const EditProfile();
                            }));
                          },
                          child: const Align(
                            alignment: Alignment.centerRight,
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatCard('Trips', '7', '+8', Colors.orange),
                          _buildStatCard('Locations', '10', null, null),
                          _buildStatCard('Total Killed', '43', null, null),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    _buildListTile(
                      Icons.wb_sunny,
                      'Change Weather Preference',
                      context,
                      WeatherPreferenceScreen(
                        isProfile: true,
                      ),
                    ),
                    _buildListTile(
                      Icons.straighten,
                      'Change Distance Units',
                      context,
                      PrefernceDistanceScreen(
                        isProfile: true,
                      ),
                    ),
                    _buildListTile(Icons.devices, 'Manage Linked Devices',
                        context, LinkedDevicesScreen()),
                    _buildListTile(
                      Icons.credit_card,
                      'Subscription',
                      context,
                      const SubscriptionDetailsScreen(),
                    ),
                    _buildListTile(
                      Icons.lock,
                      'Change Password',
                      context,
                      const ChangePasswordScreen(
                        isResetPassward: false,
                        email: '',
                        otp: '',
                      ),
                    ),
                    _buildListTile(
                      Icons.help_outline,
                      'Help',
                      context,
                      FAQScreen(),
                    ),
                    _buildListTile(
                      Icons.logout,
                      'Logout',
                      context,
                      null,
                      isLogout: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
      String label, String value, String? badge, Color? badgeColor) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor ?? Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildListTile(
      IconData icon, String title, BuildContext context, Widget? targetScreen,
      {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        if (isLogout) {
          _showLogoutBottomSheet(context);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => targetScreen!),
          );
        }
      },
    );
  }

  void _showLogoutBottomSheet(BuildContext context) {
    final provider = Provider.of<UserViewModel>(context, listen: false);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ChangeNotifierProvider.value(
          value: provider,
          child: Consumer<UserViewModel>(
            builder: (context, provider, child) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (provider.isLoading)
                      const Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Logging out...',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    else ...[
                      const Text(
                        'Logout?',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Are you sure you want to logout?',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: BrandedPrimaryButton(
                              isEnabled: true,
                              isUnfocus: true,
                              name: "Cancel",
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: BrandedPrimaryButton(
                              isEnabled: true,
                              isUnfocus: false,
                              name: "Logout",
                              onPressed: () async {
                                // Start loading
                                var response = await provider.logout();
                                // Stop loading
                                if (response.success) {
                                  SharedPrefUtil.preferences.clear();
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginScreen()),
                                    (route) => false,
                                  );
                                } else {
                                  SharedPrefUtil.preferences.clear();
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginScreen()),
                                    (route) => false,
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// Dummy screens for demonstration
