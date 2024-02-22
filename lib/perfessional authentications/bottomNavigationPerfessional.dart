
import 'package:chuttu/Admin/AdminAprroval.dart';
import 'package:chuttu/admin%20console.dart';
import 'package:chuttu/createPost.dart';
import 'package:chuttu/perfessional%20authentications/Perfessional%20Service%20Page.dart';
import 'package:chuttu/perfessional%20authentications/PerfessionalDashboard.dart';
import 'package:chuttu/userRagistration.dart';
import 'package:chuttu/userprofile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Home.dart';



class Perbottomnavigation extends StatefulWidget {
  final List<BottomNavigationBarItem> items;


  var  selectedIndex;
  Perbottomnavigation({super.key,required this.items, this.selectedIndex,});

  @override
  State<Perbottomnavigation> createState() => _bottomnavigationState();
}

class _bottomnavigationState extends State<Perbottomnavigation> {
  @override
  int _selectedIndex = 0;



  void _onItemTapped(int index) {
    setState(() {
      widget.selectedIndex = index;
      switch (index) {
      case 0:
        Navigator.push(
          context,
         MaterialPageRoute(builder: (context) => ProfessionalDashboard()),
       );
       break;
        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfessionalServicesPage()),
          );
          break;
        // case 2:
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(builder: (context) => UserRegistrationScreen()),
        //   );
          break;
        case 2:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdminPage()),
          );
          break;


      };
    });}
  Widget build(BuildContext context) {

    return Container(
      //color: Colors.amber,
      child: Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: BottomNavigationBar(
          items: widget.items,
          currentIndex:  widget.selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );

  }
}
