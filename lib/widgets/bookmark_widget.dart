import 'package:flutter/material.dart';
import '../models/bookmark_item.dart';

class BookmarkWidget extends StatelessWidget {
  final BookmarkItem bookmark;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const BookmarkWidget({
    super.key,
    required this.bookmark,
    required this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onRemove != null ? () => _showRemoveDialog(context) : null,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(20),
          // ignore: deprecated_member_use
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              margin: EdgeInsets.only(right: 8),
              child: bookmark.favicon != null
                  ? Text(bookmark.favicon!, style: TextStyle(fontSize: 12))
                  : Icon(Icons.bookmark, size: 12, color: Colors.grey),
            ),
            Text(
              bookmark.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF2C2C2E),
          title: Text('Usuń zakładkę', style: TextStyle(color: Colors.white)),
          content: Text(
            'Czy na pewno chcesz usunąć zakładkę "${bookmark.title}"?',
            style: TextStyle(color: Colors.grey[300]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Anuluj', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onRemove?.call();
              },
              child: Text('Usuń', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
