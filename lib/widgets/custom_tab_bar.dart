import 'package:flutter/material.dart';

class CustomTabBar extends StatefulWidget {
  final List<String> tabNames;
  final int selectedIndex;
  final Function(int) onTab;
  const CustomTabBar({
    Key? key,
    required this.tabNames,
    required this.onTab,
    required this.selectedIndex,
  }) : super(key: key);

  @override
  _CustomTabBarState createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  @override
  Widget build(BuildContext context) {
    var tabBar = TabBar(
      labelColor: const Color(0xFF5b1e19),
      labelPadding: EdgeInsets.zero,
      labelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
      indicatorPadding: EdgeInsets.zero,
      indicator: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey),
        ),
      ),
      tabs: widget.tabNames
          .asMap()
          .map((i, e) => MapEntry(
                i,
                Tab(
                  child: Text(
                    e,
                    style: TextStyle(
                      color: i == widget.selectedIndex
                          ? Colors.white
                          : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ))
          .values
          .toList(),
      onTap: widget.onTab,
    );
    return tabBar;
  }
}
