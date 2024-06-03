
import 'package:chuttu/perfessional%20authentications/PerfessionalDashboard.dart';
import 'package:chuttu/perfessional%20authentications/gigcreationpage.dart';
import 'package:chuttu/perfessional%20authentications/perhome.dart';

import 'package:flutter/material.dart';




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
         MaterialPageRoute(builder: (context) => perhome()),
       );
       break;
        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GigCreationPage()),
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
            MaterialPageRoute(builder: (context) => ProfessionalDashboard()),
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
          backgroundColor: Colors.blueGrey,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
        ),
      ),
    );

  }
}
