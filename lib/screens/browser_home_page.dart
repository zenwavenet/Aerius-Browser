import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/browser_tab.dart';
import '../models/bookmark_item.dart';
import '../services/ssl_service.dart';
import '../services/bookmark_service.dart';
import '../utils/url_validator.dart';
import '../widgets/tab_bar.dart' as custom_widgets;
import '../widgets/address_bar.dart';
import '../widgets/ssl_info_dialog.dart';
import '../widgets/bookmark_widget.dart';
import '../widgets/loading_indicator.dart';

class BrowserHomePage extends StatefulWidget {
  const BrowserHomePage({super.key});

  @override
  State<BrowserHomePage> createState() => _BrowserHomePageState();
}

class _BrowserHomePageState extends State<BrowserHomePage>
    with TickerProviderStateMixin {
  List<BrowserTab> tabs = [];
  int currentTabIndex = 0;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool _showBookmarks = false;
  List<BookmarkItem> _bookmarks = [];

  final bool _isLoadingSSL = false;
  final String _sslLoadingDomain = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _loadBookmarks();
    _createInitialTab();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  void _loadBookmarks() {
    setState(() {
      _bookmarks = BookmarkService.getDefaultBookmarks();
      BookmarkService.getDefaultBookmarks().forEach(
        BookmarkService.addBookmark,
      );
    });
  }

  void _createInitialTab() {
    _createNewTab();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _createNewTab() {
    final newTab = BrowserTab(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Nowa karta',
      url: '',
    );

    setState(() {
      tabs.add(newTab);
      currentTabIndex = tabs.length - 1;
    });

    _animationController.reset();
    _animationController.forward();
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.add_box, color: Colors.grey[400]),
              title: Text('Nowa karta', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _createNewTab();
              },
            ),
            ListTile(
              leading: Icon(Icons.history, color: Colors.grey[400]),
              title: Text('Historia', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.download, color: Colors.grey[400]),
              title: Text(
                'Pobrane pliki',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.grey[400]),
              title: Text('Ustawienia', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _closeTab(int index) {
    if (tabs.length <= 1) return;

    setState(() {
      tabs.removeAt(index);
      if (currentTabIndex >= tabs.length) {
        currentTabIndex = tabs.length - 1;
      } else if (currentTabIndex > index) {
        currentTabIndex--;
      }
    });
  }

  void _selectTab(int index) {
    setState(() {
      currentTabIndex = index;
    });
  }

  void _navigateToUrl(String url) {
    if (tabs.isEmpty) {
      _createNewTab();
    }

    final currentTab = tabs[currentTabIndex];

    setState(() {
      tabs[currentTabIndex] = currentTab.copyWith(url: url, isLoading: true);
    });

    if (currentTab.controller == null) {
      _initializeWebView(currentTabIndex, url);
    } else {
      currentTab.controller!.loadRequest(Uri.parse(url));
    }
  }

  void _initializeWebView(int tabIndex, String url) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) => _onPageStarted(tabIndex, url),
          onPageFinished: (String url) => _onPageFinished(tabIndex, url),
          onHttpError: (HttpResponseError error) =>
              _onHttpError(tabIndex, error),
          onWebResourceError: (WebResourceError error) =>
              _onWebResourceError(tabIndex, error),
        ),
      )
      ..loadRequest(Uri.parse(url));

    setState(() {
      tabs[tabIndex] = tabs[tabIndex].copyWith(controller: controller);
    });
  }

  void _onPageStarted(int tabIndex, String url) {
    if (tabIndex < tabs.length) {
      setState(() {
        tabs[tabIndex] = tabs[tabIndex].copyWith(
          url: url,
          isLoading: true,
          title: 'Ładowanie...',
        );
      });
    }
  }

  void _onPageFinished(int tabIndex, String url) {
    if (tabIndex < tabs.length) {
      _updatePageTitle(tabIndex, url);
      setState(() {
        tabs[tabIndex] = tabs[tabIndex].copyWith(url: url, isLoading: false);
      });
    }
  }

  void _onHttpError(int tabIndex, HttpResponseError error) {
    if (tabIndex < tabs.length) {
      setState(() {
        tabs[tabIndex] = tabs[tabIndex].copyWith(
          isLoading: false,
          title: 'Błąd HTTP ${error.response?.statusCode}',
        );
      });
    }
  }

  void _onWebResourceError(int tabIndex, WebResourceError error) {
    if (tabIndex < tabs.length) {
      setState(() {
        tabs[tabIndex] = tabs[tabIndex].copyWith(
          isLoading: false,
          title: 'Błąd ładowania',
        );
      });
    }
  }

  void _updatePageTitle(int tabIndex, String url) async {
    if (tabIndex < tabs.length && tabs[tabIndex].controller != null) {
      try {
        final title = await tabs[tabIndex].controller!.getTitle();
        if (title != null && title.isNotEmpty) {
          setState(() {
            tabs[tabIndex] = tabs[tabIndex].copyWith(
              title: title.length > 30 ? '${title.substring(0, 30)}...' : title,
              favicon: _getFaviconForUrl(url),
            );
          });
        }
      } catch (e) {
        // ignore: deprecated_member_use
      }
    }
  }

  String? _getFaviconForUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final domain = uri.host.toLowerCase();

      final faviconMap = {
        'google.com': '🔍',
        'youtube.com': '📺',
        'github.com': '💻',
        'stackoverflow.com': '❓',
        'reddit.com': '🗨️',
        'twitter.com': '🐦',
        'facebook.com': '📘',
        'instagram.com': '📷',
        'linkedin.com': '💼',
        'amazon.com': '🛒',
      };

      return faviconMap[domain];
    } catch (e) {
      return null;
    }
  }

  void _showSSLInfo() async {
    if (tabs.isEmpty || tabs[currentTabIndex].url.isEmpty) return;

    final currentUrl = tabs[currentTabIndex].url;
    final domain = URLValidator.extractDomain(currentUrl);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SSLLoadingSheet(),
    );

    try {
      final sslInfo = await SSLService.getSSLInfo(domain);
      if (!mounted) return;
      Navigator.pop(context);

      if (sslInfo != null) {
        if (!mounted) return;
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => SizedBox(
            height: MediaQuery.of(context).size.height * 0.9,
            child: SSLInfoDialog(sslInfo: sslInfo),
          ),
        );
      } else {
        _showErrorSnackBar('Nie można pobrać informacji o certyfikacie SSL');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showErrorSnackBar('Błąd podczas pobierania informacji SSL: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleBookmarks() {
    setState(() {
      _showBookmarks = !_showBookmarks;
    });
  }

  void _addCurrentPageToBookmarks() {
    if (tabs.isEmpty || tabs[currentTabIndex].url.isEmpty) return;

    final currentTab = tabs[currentTabIndex];
    final bookmark = BookmarkItem(
      title: currentTab.title,
      url: currentTab.url,
      favicon: currentTab.favicon,
    );

    BookmarkService.addBookmark(bookmark);
    setState(() {
      _bookmarks = BookmarkService.bookmarks;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dodano zakładkę: ${bookmark.title}'),
        backgroundColor: Color(0xFF34C759),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _removeBookmark(BookmarkItem bookmark) {
    BookmarkService.removeBookmark(bookmark.url);
    setState(() {
      _bookmarks = BookmarkService.bookmarks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            if (tabs.isNotEmpty)
              custom_widgets.TabBar(
                tabs: tabs,
                currentTabIndex: currentTabIndex,
                onTabSelected: _selectTab,
                onTabClosed: _closeTab,
                onSettings: _showSettings,
              ),

            if (_showBookmarks && _bookmarks.isNotEmpty)
              Container(
                height: 40,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  border: Border(
                    // ignore: deprecated_member_use
                    bottom: BorderSide(color: Colors.grey.withOpacity(0.1)),
                  ),
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _bookmarks.length,
                  itemBuilder: (context, index) {
                    final bookmark = _bookmarks[index];
                    return BookmarkWidget(
                      bookmark: bookmark,
                      onTap: () => _navigateToUrl(bookmark.url),
                      onRemove: () => _removeBookmark(bookmark),
                    );
                  },
                ),
              ),

            Expanded(
              child: _isLoadingSSL
                  ? _buildSSLLoadingContent()
                  : tabs.isEmpty
                  ? _buildWelcomeScreen()
                  : _buildWebViewContent(),
            ),

            AddressBar(
              initialUrl: tabs.isNotEmpty ? tabs[currentTabIndex].url : '',
              onSubmitted: _navigateToUrl,
              isLoading: tabs.isNotEmpty
                  ? tabs[currentTabIndex].isLoading
                  : false,
              isSecure: tabs.isNotEmpty
                  ? tabs[currentTabIndex].url.startsWith('https://')
                  : false,
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildWelcomeScreen() {
    return Container(
      color: Color(0xFF0A0A0A),
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: Icon(Icons.public, size: 80, color: Color(0xFF00C853)),
          ),
          SizedBox(height: 24),
          Text(
            'Witaj w przeglądarce',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Nowoczesna przeglądarka internetowa\nz zaawansowanymi funkcjami bezpieczeństwa',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
              height: 1.5,
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _createNewTab,
            icon: Icon(Icons.add),
            label: Text('Otwórz nową kartę'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF00C853),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebViewContent() {
    final currentTab = tabs[currentTabIndex];

    if (currentTab.url.isEmpty) {
      return _buildNewTabScreen();
    }

    if (currentTab.controller == null) {
      return LoadingIndicator(message: 'Inicjalizacja przeglądarki...');
    }

    return WebViewWidget(controller: currentTab.controller!);
  }

  Widget _buildSSLLoadingContent() {
    return Container(
      color: Color(0xFF0A0A0A),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C853)),
            strokeWidth: 3,
          ),
          SizedBox(height: 32),
          Text(
            'Sprawdzanie certyfikatu SSL...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Pobieranie informacji o bezpieczeństwie dla $_sslLoadingDomain',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          Text(
            'To może potrwać kilka sekund...',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildNewTabScreen() {
    return Container(
      color: Color(0xFF0A0A0A),
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.tab, size: 80, color: Color(0xFF00C853)),
          SizedBox(height: 24),
          Text(
            'Nowa karta',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Wprowadź adres URL w pasku adresu\nlub wybierz zakładkę',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        // ignore: deprecated_member_use
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomNavButton(
            icon: Icons.arrow_back,
            onPressed:
                tabs.isNotEmpty && tabs[currentTabIndex].controller != null
                ? () => tabs[currentTabIndex].controller!.goBack()
                : null,
          ),
          _buildBottomNavButton(
            icon: Icons.arrow_forward,
            onPressed:
                tabs.isNotEmpty && tabs[currentTabIndex].controller != null
                ? () => tabs[currentTabIndex].controller!.goForward()
                : null,
          ),
          _buildBottomNavButton(
            icon: Icons.refresh,
            onPressed:
                tabs.isNotEmpty && tabs[currentTabIndex].controller != null
                ? () => tabs[currentTabIndex].controller!.reload()
                : null,
          ),
          _buildBottomNavButton(
            icon: _showBookmarks ? Icons.bookmark : Icons.bookmark_border,
            onPressed: _toggleBookmarks,
            onLongPress: tabs.isNotEmpty ? _addCurrentPageToBookmarks : null,
          ),
          _buildBottomNavButton(icon: Icons.add, onPressed: _createNewTab),
          _buildBottomNavButton(
            icon: Icons.security,
            onPressed: tabs.isNotEmpty && tabs[currentTabIndex].url.isNotEmpty
                ? _showSSLInfo
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavButton({
    required IconData icon,
    VoidCallback? onPressed,
    VoidCallback? onLongPress,
  }) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: IconButton(
        icon: Icon(
          icon,
          color: onPressed != null ? Colors.white : Colors.grey[600],
          size: 24,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
