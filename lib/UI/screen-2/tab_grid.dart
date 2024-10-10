import 'package:aer/services/tab_service.dart';
import 'package:flutter/material.dart';

class TabGrid extends StatefulWidget {
  const TabGrid({super.key});

  @override
  TabGridState createState() => TabGridState();
}

class TabGridState extends State<TabGrid> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: TabService().tabList.length,
        itemBuilder: (context, index) => Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Container(color: Colors.cyanAccent, child: TabService().tabList[index]),
              ),
              InkWell(
                onTap: () => TabService().setCurrentIndex(index),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
