import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/feature/auth/data/view_model/user_view_model.dart';
import 'package:coyotex/feature/auth/screens/login_screen.dart';
import 'package:coyotex/feature/auth/screens/passowrd_screen.dart';
import 'package:coyotex/feature/auth/screens/prefrence_dstance_screen.dart';
import 'package:coyotex/feature/auth/screens/subscription_screen.dart';
import 'package:coyotex/feature/auth/screens/weather_prefrences.dart';
import 'package:coyotex/feature/profile/presentation/FAQ_screen.dart';
import 'package:coyotex/feature/profile/presentation/edit_profile.dart';
import 'package:coyotex/feature/profile/presentation/linked_devices.dart';
import 'package:coyotex/feature/profile/presentation/subscription_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, userViewModel, child) {
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  userViewModel.user.name,
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
                            Text(
                              '@${userViewModel.user.name}',
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
                      WeatherPrefernceScreen(
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
                      SubscriptionDetailsScreen(),
                    ),
                    _buildListTile(
                      Icons.lock,
                      'Change Password',
                      context,
                      PasswordScreen(
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
    final provider = Provider.of<UserViewModel>(context, listen: false);
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ChangeNotifierProvider.value(
          value: provider,
          child: Consumer<UserViewModel>(
            builder: (context, provider, child) {
              return Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (provider.isLoading)
                      Column(
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
                      Text(
                        'Logout?',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Are you sure you want to logout?',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
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
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          SizedBox(width: 10),
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
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginScreen()),
                                    (route) => false,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Logged out successfully.'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Logout failed. Please try again.'),
                                      backgroundColor: Colors.red,
                                    ),
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

  // void _showLogoutBottomSheet(BuildContext context) {
  //   final provider = Provider.of<UserViewModel>(context, listen: false);
  //   showModalBottomSheet(
  //     context: context,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) {
  //       return Container(
  //         padding: EdgeInsets.all(16),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Text(
  //               'Logout?',
  //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //             ),
  //             SizedBox(
  //               height: 20,
  //             ),
  //             Text(
  //               'Are you sure you want to logout?',
  //               style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
  //             ),
  //             SizedBox(height: 16),
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //               children: [
  //                 Expanded(
  //                   child: BrandedPrimaryButton(
  //                       isEnabled: true,
  //                       isUnfocus: true,
  //                       name: "Cancel",
  //                       onPressed: () {}),
  //                 ),
  //                 SizedBox(
  //                   width: 10,
  //                 ),
  //                 Expanded(
  //                   child: BrandedPrimaryButton(
  //                     isEnabled: true,
  //                     isUnfocus: false,
  //                     name: "Logout",
  //                     onPressed: () async {
  //                       var response = await provider.logout();
  //                       if (response.success) {
  //                         // Clear any user session data
  //                         // Ensure you implement this in your UserViewModel.

  //                         // Navigate to the login screen
  //                         Navigator.pushAndRemoveUntil(
  //                           context,
  //                           MaterialPageRoute(
  //                               builder: (context) =>
  //                                   LoginScreen()), // Replace with your login screen
  //                           (route) =>
  //                               false, // Removes all previous routes from the stack
  //                         );

  //                         // Optionally show a confirmation message
  //                         ScaffoldMessenger.of(context).showSnackBar(
  //                           SnackBar(
  //                             content: Text('Logged out successfully.'),
  //                             backgroundColor: Colors.green,
  //                           ),
  //                         );
  //                       } else {
  //                         // Handle the error (e.g., network issue, server error)
  //                         ScaffoldMessenger.of(context).showSnackBar(
  //                           SnackBar(
  //                             content: Text('Logout failed. Please try again.'),
  //                             backgroundColor: Colors.red,
  //                           ),
  //                         );
  //                       }
  //                     },
  //                   ),
  //                 )
  //               ],
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
}

// Dummy screens for demonstration


