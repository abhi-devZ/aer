import 'package:aer/UI/Widget/search_button.dart';
import 'package:aer/UI/Widget/tab_count.dart';
import 'package:flutter/material.dart';

class MyState {
  final bool searchExpanded;
  final bool animCompleted;

  MyState(this.searchExpanded, this.animCompleted);
}

class NavigationController extends StatefulWidget {
  final OnClickButtonCallback? onSubmitTextField;

  const NavigationController({super.key, this.onSubmitTextField});

  @override
  State<NavigationController> createState() => _NavigationControllerState();
}

class _NavigationControllerState extends State<NavigationController> {
  final searchExpanded = ValueNotifier<bool>(false);
  final animCompleted = ValueNotifier<bool>(false);
  final combinedState = ValueNotifier<MyState>(MyState(false, false));

  void updateCombinedState() {
    combinedState.value = MyState(searchExpanded.value, animCompleted.value);
  }

  @override
  Widget build(BuildContext context) {
    return _navbar();
  }

  Widget _navbar() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 64,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            spreadRadius: 1,
            blurRadius: 8,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: ValueListenableBuilder<MyState>(
        valueListenable: combinedState,
        builder: (context, state, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Visibility(
                visible: !state.animCompleted,
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.blueGrey, size: 20),
              ),
              Visibility(
                visible: !state.animCompleted,
                child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.blueGrey, size: 20),
              ),
              SearchButton(
                searchExpanded: state.searchExpanded,
                animFinishedCallback: (value) {
                  animCompleted.value = value;
                  updateCombinedState();
                },
                onClickedCallback: (value) {
                  searchExpanded.value = value;
                  if (value) {
                    animCompleted.value = value;
                  }
                  updateCombinedState();
                },
                onSubmitCallback: (value) {
                  widget.onSubmitTextField!(value);
                },
              ),
              Visibility(
                visible: !state.animCompleted,
                child: const TabCount(),
              ),
              Visibility(
                visible: !state.animCompleted,
                child: const Icon(Icons.menu_rounded, color: Colors.blueGrey, size: 20),
              ),
            ],
          );
        },
      ),
    );
  }

  bool exp = false;

  Widget _navTest() {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            spreadRadius: 1,
            blurRadius: 8,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              exp = !exp;
              setState(() {});
            },
            child: const Icon(Icons.looks_one, color: Colors.blueGrey, size: 20),
          ),
          Visibility(
            visible: !exp,
            child: const Icon(Icons.looks_two, color: Colors.blueGrey, size: 20),
          ),
          cont(),
          Visibility(
            visible: !exp,
            child: const Icon(Icons.looks_4, color: Colors.blueGrey, size: 20),
          ),
          Visibility(
            visible: !exp,
            child: const Icon(Icons.looks_5, color: Colors.blueGrey, size: 20),
          ),
        ],
      ),
    );
  }

  Widget cont() {
    return Flexible(
      fit: FlexFit.loose,
      child: AnimatedContainer(
        width: !exp ? 48 : MediaQuery.of(context).size.width * 0.8,
        height: 48,
        duration: const Duration(milliseconds: 1000),
        padding: EdgeInsets.symmetric(horizontal: exp ? 16.0 : 0.0, vertical: !exp ? 4.0 : 0.0),
        decoration: BoxDecoration(
          color: Colors.blueGrey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(48.0),
        ),
        child: const Icon(Icons.looks_3, color: Colors.blueGrey, size: 36),
      ),
    );
  }
}
