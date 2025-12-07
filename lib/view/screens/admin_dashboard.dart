import 'package:flutter/material.dart';
import 'package:text_to_qr/login_page.dart';
import 'package:text_to_qr/view/screens/admin_reports.dart';
import 'package:text_to_qr/view/screens/customer_management.dart';
import 'package:text_to_qr/view/screens/report_by_date.dart';
import 'package:text_to_qr/view/screens/settings.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AdminCustomersScreen(),
    const AdminReportsScreen(),
    const ReportByDate(),
    const Settings()
  ];

 
  final List<Map<String, dynamic>> _destinations = [
    {'icon': Icons.people, 'label': 'Customers'},
    {'icon': Icons.check, 'label': 'Status'},
    {'icon': Icons.analytics, 'label': 'Daily Reports'},
    {'icon': Icons.info_outline_rounded, 'label': 'About'}
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
   
    return LayoutBuilder(
      builder: (context, constraints) {
        
        bool isMobile = constraints.maxWidth < 600;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Admin Portal"),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            leading: isMobile ? null : Container(), 
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
              )
            ],
          ),
          
          drawer: isMobile
              ? Drawer(
                  child: Column(
                    children: [
                      const UserAccountsDrawerHeader(
                        decoration: BoxDecoration(color: Colors.blue),
                        accountName: Text("Admin"),
                        accountEmail: Text("admin@dairy.com"),
                        currentAccountPicture: CircleAvatar(
                         backgroundColor: Colors.white,
                         child: Image(image: AssetImage("assets/logo/app_icon.png"), fit: BoxFit.cover,),
                        
                        ),
                      ),
                      
                      ..._destinations.asMap().entries.map((entry) {
                        int idx = entry.key;
                        Map item = entry.value;
                        return ListTile(
                          leading: Icon(item['icon']),
                          title: Text(item['label']),
                          selected: _selectedIndex == idx,
                          selectedColor: Colors.blue,
                          onTap: () {
                            _onDestinationSelected(idx);
                            Navigator.pop(context); 
                          },
                        );
                      }),
                    ],
                  ),
                )
              : null, 
          
         
          body: Row(
            children: [
              
              if (!isMobile)
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onDestinationSelected,
                  labelType: NavigationRailLabelType.all,
                  destinations: _destinations
                      .map(
                        (item) => NavigationRailDestination(
                          icon: Icon(item['icon']),
                          label: Text(item['label']),
                        ),
                      )
                      .toList(),
                ),
              
              
              if (!isMobile) const VerticalDivider(thickness: 1, width: 1),

             
              Expanded(child: _pages[_selectedIndex]),
            ],
          ),
        );
      },
    );
  }
}