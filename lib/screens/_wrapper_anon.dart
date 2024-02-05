import 'package:flutter/material.dart';

import 'account/index.dart';

class AnonWrapper extends StatefulWidget {
  @override
  _AnonWrapperState createState() => _AnonWrapperState();
}

class _AnonWrapperState extends State<AnonWrapper> {
  int _selectedPage = 0;
  final _pageOptions = [

    AccountScreen(),
  ];

  // this build just open the account screen
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pageOptions[_selectedPage],
    );
  }

// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     body: _pageOptions[_selectedPage],
//     bottomNavigationBar: BottomNavigationBar(
//       currentIndex: _selectedPage,
//       showUnselectedLabels: false,
//       onTap: (int index) {
//         setState(() {
//           _selectedPage = index;
//         });
//       },
//       type: BottomNavigationBarType.fixed,
//       items: const [
//         BottomNavigationBarItem(
//           icon: Icon(Icons.account_box),
//           label: 'Home',
//         ),
//       ],
//     ),
//   );
// }
}