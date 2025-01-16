import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/feature/auth/presentation/passowrd_screen.dart';
import 'package:coyotex/feature/auth/presentation/prefrence_dstance_screen.dart';
import 'package:coyotex/feature/auth/presentation/subscription_screen.dart';
import 'package:coyotex/feature/auth/presentation/weather_prefrences.dart';
import 'package:coyotex/feature/profile/presentation/FAQ_screen.dart';
import 'package:coyotex/feature/profile/presentation/edit_profile.dart';
import 'package:coyotex/feature/profile/presentation/linked_devices.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.black,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person),
                  // backgroundImage: AssetImage(
                  //     'assets/profile_picture.jpg'), // Replace with your image asset or network image.
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 40,
                    ),
                    Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Fedelica Toraka',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.verified,
                              color: Colors.orange,
                              size: 20,
                            ),
                          ],
                        ),
                        const Text(
                          '@Ella',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return EditProfile();
                        }));
                      },
                      child: Align(
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
                SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.all(16),
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
                  WeatherPrefernceScreen(),
                ),
                _buildListTile(
                  Icons.straighten,
                  'Change Distance Units',
                  context,
                  PrefernceDistanceScreen(),
                ),
                _buildListTile(Icons.devices, 'Manage Linked Devices', context,
                    LinkedDevicesScreen()),
                _buildListTile(
                  Icons.credit_card,
                  'Subscription',
                  context,
                  SubscriptionScreen(),
                ),
                _buildListTile(
                  Icons.lock,
                  'Change Password',
                  context,
                  PasswordScreen(),
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
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            if (badge != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor ?? Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
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
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
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
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Logout?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Are you sure you want to logout?',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: BrandedPrimaryButton(
                        isEnabled: true,
                        isUnfocus: true,
                        name: "Cancel",
                        onPressed: () {}),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: BrandedPrimaryButton(
                        isEnabled: true,
                        isUnfocus: false,
                        name: "Logout",
                        onPressed: () {}),
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// Dummy screens for demonstration


