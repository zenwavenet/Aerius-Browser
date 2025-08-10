import 'package:flutter/material.dart';
import '../utils/url_validator.dart';

class AddressBar extends StatefulWidget {
  final String initialUrl;
  final Function(String) onSubmitted;
  final bool isLoading;
  final bool isSecure;

  const AddressBar({
    super.key,
    required this.initialUrl,
    required this.onSubmitted,
    this.isLoading = false,
    this.isSecure = false,
  });

  @override
  State<AddressBar> createState() => _AddressBarState();
}

class _AddressBarState extends State<AddressBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialUrl);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(AddressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialUrl != oldWidget.initialUrl) {
      _controller.text = widget.initialUrl;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        // ignore: deprecated_member_use
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        style: TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Wpisz adres URL lub wyszukaj...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Color(0xFF2C2C2E),
          contentPadding: EdgeInsets.only(left: 24, right: 16),
          prefixIcon: Icon(
            widget.isSecure ? Icons.lock : Icons.lock_open,
            color: widget.isSecure ? Color(0xFF34C759) : Colors.grey,
            size: 16,
          ),
          suffixIcon: widget.isLoading
              ? Container(
                  width: 20,
                  height: 20,
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF00C853),
                    ),
                  ),
                )
              : null,
        ),
        textInputAction: TextInputAction.go,
        onSubmitted: (value) {
          final formattedUrl = URLValidator.formatUrl(value);
          widget.onSubmitted(formattedUrl);
          _focusNode.unfocus();
        },
        onTap: () {},
      ),
    );
  }
}
