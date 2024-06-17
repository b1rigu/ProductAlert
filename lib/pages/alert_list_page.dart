import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:productalert/api/firebase_api.dart';
import 'package:productalert/api/supabase_api.dart';
import 'package:productalert/main.dart';
import 'package:responsive_navigation_bar/responsive_navigation_bar.dart';

class AlertListPage extends StatefulWidget {
  const AlertListPage({super.key});

  @override
  State<AlertListPage> createState() => _AlertListPageState();
}

class _AlertListPageState extends State<AlertListPage> {
  final _alertNameController = TextEditingController();
  final _alertExpiresAtController = TextEditingController();
  late final Stream<List<Map<String, dynamic>>> _alertsStream;
  final formatter = DateFormat('yyyy-MM-dd');
  String _avatarUrl = "";
  String _username = "";
  int _selectedIndex = 0;
  bool _showExpiredAlerts = false;

  @override
  void initState() {
    _initializeNotifications();
    _getUserProfile();
    _alertsStream = supabase.from('alerts').stream(primaryKey: ["id"]).eq(
        'user_id', supabase.auth.currentSession!.user.id);
    super.initState();
  }

  @override
  void dispose() {
    _alertNameController.dispose();
    _alertExpiresAtController.dispose();
    super.dispose();
  }

  void _initializeNotifications() {
    FireaseApi.initNotifications(context);
  }

  void changeTab(int index) {
    setState(() {
      _selectedIndex = index;
      _showExpiredAlerts = index == 1;
    });
  }

  void _onMenuSelected(int position) {
    if (position == 0) {
      _logout();
    }
  }

  void _getUserProfile() async {
    final userData = await SupabaseApi.getUserProfile(context);
    setState(() {
      _avatarUrl = userData['avatar_url'];
      _username = userData['username'];
    });
  }

  void _createAlert() {
    final userId = supabase.auth.currentSession!.user.id;
    final productName = _alertNameController.text.trim();
    final expiresAt = _alertExpiresAtController.text.trim();

    if (productName.isEmpty || expiresAt.isEmpty) {
      context.showSnackBar("Please fill all the fields");
      return;
    }

    final alertData = {
      'user_id': userId,
      'product_name': productName,
      'product_image_url': "test",
      'expires_at': DateTime.parse(expiresAt).toIso8601String(),
    };

    SupabaseApi.insertDataToDatabase('alerts', alertData, context);

    Navigator.pop(context);

    _alertNameController.clear();
    _alertExpiresAtController.clear();
  }

  Future<void> _deleteAlert(int alertId) async {
    SupabaseApi.deleteDataFromDatabaseByField(
      'alerts',
      'id',
      alertId,
      context,
    );
  }

  void _logout() {
    SupabaseApi.logout(context);
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _alertExpiresAtController.text.isEmpty
          ? DateTime.now()
          : DateTime.parse(_alertExpiresAtController.text),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      _alertExpiresAtController.text = formatter.format(pickedDate);
    }
  }

  void _onAddAlert() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add Alert'),
            contentPadding: const EdgeInsets.all(8),
            actions: [
              TextField(
                autofocus: true,
                controller: _alertNameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  filled: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _alertExpiresAtController,
                decoration: const InputDecoration(
                  labelText: "Expires at",
                  filled: true,
                  prefixIcon: Icon(Icons.calendar_today),
                  enabledBorder:
                      OutlineInputBorder(borderSide: BorderSide.none),
                ),
                readOnly: true,
                onTap: () {
                  _selectDate();
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _createAlert,
                child: const Text("Create Alert"),
              ),
            ],
          );
        });
  }

  void _alertDeleteConfirmationDialog(int alertId) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Are you sure you want to delete this alert?'),
            contentPadding: const EdgeInsets.all(8),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  _deleteAlert(alertId);
                  Navigator.pop(context);
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    const Color.fromARGB(20, 0, 0, 0),
                  ),
                ),
                child: const Text("Delete permanently"),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;
    Color secondaryColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: Text("Hello, $_username"),
        actions: [
          PopupMenuButton(
            icon: AspectRatio(
              aspectRatio: 1,
              child: ClipOval(
                child: _avatarUrl.isEmpty
                    ? const SizedBox()
                    : SvgPicture.network(
                        _avatarUrl,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            onSelected: (value) {
              _onMenuSelected(value);
            },
            offset: const Offset(0.0, 50.0),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0),
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
              ),
            ),
            itemBuilder: (ctx) => [
              _buildPopupMenuItem('Logout', Icons.exit_to_app, 0),
            ],
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _alertsStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final alerts = snapshot.data!;

            return ListView.builder(
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final productName = alerts[index]['product_name'];
                // final productImageUrl = alerts[index]['product_image_url'];
                final expiresAt = formatter
                    .format(DateTime.parse(alerts[index]['expires_at']));

                final dateDifference = _showExpiredAlerts
                    ? DateTime.now()
                        .difference(DateTime.parse(alerts[index]['expires_at']))
                        .inDays
                    : DateTime.parse(alerts[index]['expires_at'])
                        .difference(DateTime.now())
                        .inDays;
                if (dateDifference < 0) {
                  return const SizedBox();
                }
                return Card(
                  elevation: 4.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color.fromRGBO(64, 75, 96, .9),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.only(right: 12.0),
                        decoration: const BoxDecoration(
                          border: Border(
                            right:
                                BorderSide(width: 1.0, color: Colors.white24),
                          ),
                        ),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              "https://i.pinimg.com/originals/49/73/5b/49735b38c27ca67787e201a8f4b0fd6d.jpg",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        productName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        _showExpiredAlerts
                            ? "Expired at: $expiresAt"
                            : "Expires at: $expiresAt",
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Color.fromARGB(172, 244, 67, 54),
                          size: 30.0,
                        ),
                        onPressed: () {
                          _alertDeleteConfirmationDialog(alerts[index]['id']);
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddAlert,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: ResponsiveNavigationBar(
        inactiveIconColor: Colors.black,
        backgroundOpacity: 0.4,
        selectedIndex: _selectedIndex,
        onTabChange: changeTab,
        textStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        navigationBarButtons: [
          NavigationBarButton(
            text: 'Active',
            icon: Icons.notifications_active,
            backgroundColor: primaryColor,
          ),
          NavigationBarButton(
            text: 'Expired',
            icon: Icons.notifications_paused,
            backgroundColor: secondaryColor,
          ),
        ],
      ),
    );
  }

  PopupMenuItem _buildPopupMenuItem(
      String title, IconData iconData, int position) {
    return PopupMenuItem(
      value: position,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(iconData),
          Text(title),
        ],
      ),
    );
  }
}
