import 'package:cached_network_image/cached_network_image.dart';
import 'package:coyotex/core/services/call_halper.dart';
import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/core/utills/constant.dart';
import 'package:coyotex/feature/auth/data/view_model/user_view_model.dart';
import 'package:coyotex/feature/auth/screens/login_screen.dart';
import 'package:coyotex/feature/auth/screens/prefrence_dstance_screen.dart';
import 'package:coyotex/feature/auth/screens/weather_prefrences.dart';
import 'package:coyotex/feature/map/presentation/notofication_screen.dart';
import 'package:coyotex/feature/profile/presentation/FAQ_screen.dart';
import 'package:coyotex/feature/profile/presentation/change_password.dart';
import 'package:coyotex/feature/profile/presentation/edit_profile.dart';
import 'package:coyotex/feature/profile/presentation/web_screen.dart';
import 'package:coyotex/feature/trip/presentation/trip_history.dart';
import 'package:coyotex/feature/trip/view_model/trip_view_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../core/utills/shared_pref.dart';
import '../../../utils/app_dialogue_box.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int trips = 0;

  @override
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userProvider = Provider.of<UserViewModel>(context, listen: false);
      userProvider.getAnimalStats();
      userProvider.getUser();
      userProvider.getTrips();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  bool isLoading = false;

  void _handleGpxFile(String filePath) async {
    setState(() {
      isLoading = true;
    });
    String fileName = filePath.split('/').last;
    // Retrieve authorization token
    String? token = SharedPrefUtil.getValue(accessTokenPref, "") as String;
    ;
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authorization token not found. Please log in again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    var uri = Uri.parse('${CallHelper.baseUrl}gpxapi/upload-gpx');
    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    try {
      var multipartFile = await http.MultipartFile.fromPath('file', filePath);
      request.files.add(multipartFile);

      var response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        final tripProvider = Provider.of<TripViewModel>(context, listen: false);
        await tripProvider.getAllMarker();
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$fileName uploaded successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Failed to upload $fileName: ${response.reasonPhrase}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading $fileName: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, userViewModel, child) {
        return userViewModel.isLoading || isLoading
            ? const Center(
                child: CircularProgressIndicator.adaptive(
                backgroundColor: Colors.white,
              ))
            : Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.black,
                  elevation: 0,
                  title: const Text(
                    'Profile',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                  actions: [
                    // Added Upload Marker Icon
                    GestureDetector(
                      onTap: () async {
                        final status = await Permission.storage.request();
                        if (status.isGranted) {
                          // Proceed with file picking
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.any,
                            //allowedExtensions: ,
                            allowMultiple: false,
                            dialogTitle: 'Select GPX File',
                            allowCompression: true,
                            withData: false,
                            withReadStream: true,
                            lockParentWindow: true,
                            // iOS-specific UTIs for GPX files
                            onFileLoading: (FilePickerStatus status) =>
                                print(status),
                          );

                          if (result != null && result.files.isNotEmpty) {
                            final file = result.files.first;
                            if (file.path != null) {
                              _handleGpxFile(file.path!);
                            }
                          }
                        } else {
                          // Handle permission denial
                          final status = await Permission.storage.request();
                        }
                      },
                      child: const Icon(
                        Icons.add_location_alt,
                        color: Colors.green,
                        size: 24,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const NotificationScreen()));
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Icon(
                          Icons.notifications,
                          color: Colors.red,
                          size: 25,
                        ),
                      ),
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    Container(
                      color: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Column(
                        children: [
                          userViewModel.user.imageUrl.isNotEmpty
                              ? ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: userViewModel.user.imageUrl,
                                    width: 100,
                                    // Ensure circular shape
                                    height: 100,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      width: 100,
                                      height: 100,
                                      decoration: const BoxDecoration(
                                        color: Colors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.white,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      width: 100,
                                      height: 100,
                                      decoration: const BoxDecoration(
                                        color: Colors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : const CircleAvatar(
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
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return EditProfile(
                                      userModel: userViewModel.user,
                                    );
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
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                      return const TripsHistoryScreen();
                                    }));
                                  },
                                  child: _buildStatCard(
                                      'Trips',
                                      '${userViewModel.trips.length}',
                                      '+${userViewModel.trips.length}',
                                      Colors.orange),
                                ),
                                _buildStatCard('Animal Seen',
                                    '${userViewModel.animalSeen}', null, null),
                                _buildStatCard(
                                    'Total Killed',
                                    userViewModel.animalKilled.toString(),
                                    null,
                                    null),
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
                            const WeatherPreferenceScreen(
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
                          // _buildListTile(Icons.devices, 'Manage Linked Devices',
                          //     context, LinkedDevicesScreen()),
                          // _buildListTile(
                          //   Icons.credit_card,
                          //   'Subscription',
                          //   context,
                          //   const SubscriptionDetailsScreen(),
                          // ),
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
                            const FAQScreen(),
                          ),
                          _buildListTile(
                            Icons.lock_outline,
                            'Privacy Policy',
                            context,
                            const WebScreen(
                                url: "https://www.hunt30.com/privecyPolicy"),
                          ),
                          _buildListTile(
                            Icons.description,
                            'Terms and Conditions',
                            context,
                            const WebScreen(
                                url: "https://www.hunt30.com/termCondition"),
                          ),
                          _buildListTile(
                            Icons.delete,
                            'Delete Account Policy',
                            context,
                            const WebScreen(
                                url: "https://www.hunt30.com/deletePolicy"),
                          ),
                          _showDeleteDialog(context),
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

  Widget _showDeleteDialog(BuildContext context) {
    return Consumer<UserViewModel>(builder: (context, provider, child) {
      return ListTile(
        leading: const Icon(Icons.delete_outline, color: Colors.black),
        title: const Text(
          "Delete Account",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          _showDeleteAccountDialog(provider);
        },
      );
    });
  }

  _showDeleteAccountDialog(UserViewModel provider) {
    AppDialog.showSuccessDialog(
        context,
        title: "Alert!",
        "Are you sure to delete your account?",
        showSecondary: true,
        icon: Icons.delete,
        iconClr: Colors.red, () async {
      Navigator.pop(context);
      var response = await provider.deleteAccount();
      if (response.success) {
        AppDialog.showSuccessDialog(
            context, "Your account has been delete successfully.", () {
          Navigator.of(context).pop(); // Close the dialog
          SharedPrefUtil.preferences.clear();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        });
      } else {
        // Handle error
        AppDialog.showErrorDialog(context, response.message, () {
          Navigator.of(context).pop();
        });
      }
    });
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
                                        builder: (context) =>
                                            const LoginScreen()),
                                    (route) => false,
                                  );
                                } else {
                                  SharedPrefUtil.preferences.clear();
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen()),
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
