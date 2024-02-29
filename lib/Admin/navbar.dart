
// Define the navigation bar items
import 'package:chuttu/Admin/AdminAprroval.dart';
import 'package:chuttu/Admin/Gigaprroval.dart';
import 'package:flutter/material.dart';


class navbar extends StatefulWidget {
  @override
  _navbarState createState() => _navbarState();
}

class _navbarState extends State<navbar> {


  int _selectedIndex = 0; // State variable to keep track of the selected index

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        body: navigationItems[_selectedIndex].page,
        bottomNavigationBar: BottomNavigationBar(
          items: navigationItems.map((item) =>
              BottomNavigationBarItem(icon: Icon(item.icon), label: item.label))
              .toList(),
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),

    );
  }
}
class MyNavItem {
  final String label;
  final IconData icon;
  final Widget page;

  MyNavItem({required this.label, required this.icon, required this.page});
}

 List<MyNavItem> navigationItems = [
  MyNavItem(label: 'Home', icon: Icons.home, page: AdminApprovalPage(), ),
   MyNavItem(label: 'GIgAProval', icon: Icons.hail, page: GigApproval(), ),

];