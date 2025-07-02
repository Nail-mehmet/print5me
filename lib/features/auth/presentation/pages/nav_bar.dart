import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printer/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:printer/features/models/presentation/pages/start_page.dart';

import '../../../../demo.dart';
import '../../../adverts/presentation/pages/adverts_page.dart';
import '../../../home_screen.dart';
import '../../../models/presentation/pages/model_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../domain/models/user_model.dart';



class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  //User? currentUser;
  int currentTab = 0;
  late final PageStorageBucket bucket;
  late Widget currentScreen;
  late List<Widget> screens;

  @override
  void initState() {
    super.initState();
    //final authCubit = context.read<AuthBloc>();
    //currentUser = authCubit.currentUser;

    screens = [
      StartPage(),
      IlanlarPage(pageSize: 2,),
      PrinterAuthPage(),
      ProfilePage(),
      //ChatsListPage(),
      //ProfilePage(uid: currentUser!.uid),
    ];

    bucket = PageStorageBucket();
    currentScreen = ModelHomePage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      //backgroundColor: Theme.of(context).colorScheme.secondary,
      body: PageStorage(
        bucket: bucket,
        child: currentScreen,
      ),
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiary,

          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            buildNavBarItem("assets/icons/home.png", "Anasayfa", 0),
            buildNavBarItem("assets/icons/adverts.png", "İlanlar", 1),
            buildNavBarItem("assets/icons/offers.png", "Teklifler", 2),
            buildNavBarItem("assets/icons/profile.png", "Profil", 3),

          ],
        ),
      ),
    );
  }

  Widget buildNavBarItem(String iconPath, String label, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          currentScreen = screens[index];
          currentTab = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            iconPath,
            color: currentTab == index ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary,
            height: 24,
            width: 24,
          ),
          SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: currentTab == index ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary,
              fontSize: 12,
            ),
          ),
          if (currentTab == index)
            Container(
              height: 5,
              width: 20,
              margin: EdgeInsets.only(top: 5),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
        ],
      ),
    );
  }
}
