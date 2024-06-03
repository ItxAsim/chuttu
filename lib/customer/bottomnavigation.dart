import 'package:chuttu/customer/Home.dart';
import 'package:chuttu/customer/Uploadproblem.dart';

import 'package:chuttu/customer/userprofile.dart';

import 'package:flutter/material.dart';



class bottomnavigation extends StatefulWidget {
  final List<BottomNavigationBarItem> items;


  var  selectedIndex;
  bottomnavigation({super.key,required this.items, this.selectedIndex,});

  @override
  State<bottomnavigation> createState() => _bottomnavigationState();
}

class _bottomnavigationState extends State<bottomnavigation> {
  @override



  void _onItemTapped(int index) {
    setState(() {
      widget.selectedIndex = index;
      switch (index) {
      case 0:
        Navigator.push(
          context,
         MaterialPageRoute(builder: (context) => ApprovedGigsPage()),
       );
       break;
        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProblemUploadScreen()),
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
            MaterialPageRoute(builder: (context) => UserProfileScreen()),
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
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.blueGrey,
          onTap: _onItemTapped,
        ),
      ),
    );

  }
}
