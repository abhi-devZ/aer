import 'package:aer/UI/Screen/a_i.dart';
import 'package:aer/UI/Screen/shared.dart';
import 'package:aer/UI/Screen/web_view_home.dart';
import 'package:aer/UI/Widget/tab_count.dart';
import 'package:aer/UI/utils/constant.dart';
import 'package:flutter/material.dart';

List<Widget> pages = [const AI(), const WebViewHome(), const Shared()];

class AerHomePage extends StatefulWidget {
  const AerHomePage({super.key});

  @override
  AerHomePageState createState() => AerHomePageState();
}

class AerHomePageState extends State<AerHomePage> {
  late PageController _pageController;

  @override
  initState() {
    _pageController = PageController(viewportFraction: 1, initialPage: 1);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _pageView(),
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

  Widget _pageView() {
    return PageView.builder(
      controller: _pageController,
      physics: const BouncingScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return _hostingContainer(index);
      },
    );
  }

  Widget _hostingContainer(index) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 1,
      height: MediaQuery.sizeOf(context).height * 1,
      child: pages[index],
    );
  }

  Widget _bottomNavigationBar() {
    return BottomNavigationBar(
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: <BottomNavigationBarItem>[
        const BottomNavigationBarItem(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.blueGrey,
            size: 24,
          ),
          label: "Back",
        ),
        const BottomNavigationBarItem(
          icon: Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.blueGrey,
            size: 24,
          ),
          label: "Next",
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            "assets/icons/stack.png",
            color: Colors.blueGrey,
            width: 24,
            height: 24,
            fit: BoxFit.fill,
          ),
          label: "Stack",
        ),
        const BottomNavigationBarItem(
          icon: TabCount(),
          label: "Tabs",
        ),
        const BottomNavigationBarItem(
          icon: Icon(
            Icons.menu_rounded,
            color: Colors.blueGrey,
            size: 24,
          ),
          label: "Menu",
        ),
      ],
    );
  }
}
