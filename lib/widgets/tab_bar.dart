import 'package:flutter/material.dart';
import '../models/browser_tab.dart';

class TabBar extends StatelessWidget {
  final List<BrowserTab> tabs;
  final int currentTabIndex;
  final Function(int) onTabSelected;
  final Function(int) onTabClosed;
  final VoidCallback onSettings;

  const TabBar({
    super.key,
    required this.tabs,
    required this.currentTabIndex,
    required this.onTabSelected,
    required this.onTabClosed,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Color(0xFF1A1A1A),
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              itemBuilder: (context, index) {
                return _buildTabItem(context, index);
              },
            ),
          ),
          _buildSettingsButton(context),
        ],
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, int index) {
    final tab = tabs[index];
    final isSelected = index == currentTabIndex;

    return GestureDetector(
      onTap: () => onTabSelected(index),
      child: Container(
        width: 200,
        margin: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF2C2C2E) : Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: Color(0xFF00C853), width: 1)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              margin: EdgeInsets.only(left: 8),
              child: tab.favicon != null
                  ? Text(tab.favicon!, style: TextStyle(fontSize: 14))
                  : Icon(Icons.public, size: 16, color: Colors.grey),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  tab.title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[400],
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Container(
              width: 24,
              height: 24,
              margin: EdgeInsets.only(right: 4),
              child: tab.isLoading
                  ? SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF00C853),
                        ),
                      ),
                    )
                  : IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.grey[400],
                      ),
                      onPressed: () => onTabClosed(index),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: IconButton(
        icon: Icon(Icons.more_vert, color: Colors.grey[400]),
        onPressed: onSettings,
      ),
    );
  }
}
