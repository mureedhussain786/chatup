import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme.dart';

class MediaLinksDocsScreen extends StatefulWidget {
  final String contactName;
  final String contactPhone;
  final int initialTab;

  const MediaLinksDocsScreen({
    super.key,
    required this.contactName,
    required this.contactPhone,
    this.initialTab = 0,
  });

  @override
  State<MediaLinksDocsScreen> createState() => _MediaLinksDocsScreenState();
}

class _MediaLinksDocsScreenState extends State<MediaLinksDocsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
        title: Text(
          widget.contactName,
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryGreen,
          labelColor: isDarkMode ? Colors.white : Colors.black,
          unselectedLabelColor: isDarkMode ? Colors.white54 : Colors.black54,
          tabs: const [
            Tab(text: 'Media'),
            Tab(text: 'Docs'),
            Tab(text: 'Links'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMediaTab(isDarkMode),
          _buildDocsTab(isDarkMode),
          _buildLinksTab(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildMediaTab(bool isDarkMode) {
    // Dummy media data
    final mediaItems = [
      {'type': 'image', 'url': 'https://picsum.photos/200/300?random=1', 'date': 'Today'},
      {'type': 'image', 'url': 'https://picsum.photos/200/300?random=2', 'date': 'Yesterday'},
      {'type': 'video', 'url': 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4', 'date': '2 days ago'},
      {'type': 'image', 'url': 'https://picsum.photos/200/300?random=3', 'date': '3 days ago'},
      {'type': 'image', 'url': 'https://picsum.photos/200/300?random=4', 'date': '1 week ago'},
      {'type': 'video', 'url': 'https://sample-videos.com/video123/mp4/720/sample-mp4-file.mp4', 'date': '1 week ago'},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: mediaItems.length,
      itemBuilder: (context, index) {
        final item = mediaItems[index];
        return GestureDetector(
          onTap: () => _showMediaViewer(item['url']!, item['type']!),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (item['type'] == 'image')
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      item['url']!,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.black54,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      item['date']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDocsTab(bool isDarkMode) {
    // Dummy docs data
    final docs = [
      {'name': 'Document1.pdf', 'size': '2.3 MB', 'date': 'Today'},
      {'name': 'Presentation.pptx', 'size': '5.1 MB', 'date': 'Yesterday'},
      {'name': 'Spreadsheet.xlsx', 'size': '1.8 MB', 'date': '3 days ago'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.insert_drive_file,
                  color: AppTheme.primaryGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc['name']!,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${doc['size']} • ${doc['date']}',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.download,
                color: isDarkMode ? Colors.white54 : Colors.black54,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLinksTab(bool isDarkMode) {
    // Dummy links data
    final links = [
      {'title': 'Flutter Documentation', 'url': 'https://flutter.dev/docs', 'date': 'Today'},
      {'title': 'GitHub Repository', 'url': 'https://github.com/flutter/flutter', 'date': 'Yesterday'},
      {'title': 'Stack Overflow', 'url': 'https://stackoverflow.com/questions/tagged/flutter', 'date': '2 days ago'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: links.length,
      itemBuilder: (context, index) {
        final link = links[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.link,
                  color: AppTheme.primaryGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      link['title']!,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      link['url']!,
                      style: TextStyle(
                        color: AppTheme.primaryGreen,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      link['date']!,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.open_in_new,
                color: isDarkMode ? Colors.white54 : Colors.black54,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMediaViewer(String url, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: type == 'image'
                ? Image.network(url, fit: BoxFit.contain)
                : const Center(
                    child: Text(
                      'Video Player\n(Implementation needed)',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
