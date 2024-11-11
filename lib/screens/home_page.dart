import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart'as http;
import 'package:url_launcher/url_launcher.dart';

class Utils {
  static void launchURL(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String apiKey = "ea690beaea93460db4c6b1af1bc56720";
  final TextEditingController searchController = TextEditingController();
  String query = "tesla";

  @override
  void initState() {
    super.initState();
  }

  Future<List<dynamic>> getNewsData(String query) async {
    var newsUrl =
        "https://newsapi.org/v2/everything?q=$query&sortBy=publishedAt&apiKey=$apiKey";
    var newsResponse = await http.get(Uri.parse(newsUrl));
    var newsData = jsonDecode(newsResponse.body);
    return newsData['articles'];
  }

  void searchNews() {
    if (searchController.text.isNotEmpty) {
      setState(() {
        query = searchController.text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("News App"),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(120.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search news...',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: searchNews,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onSubmitted: (value) => searchNews(),
                  ),
                ),
                const TabBar(
                  isScrollable: true,
                  tabs: [
                    Tab(text: "Trending"),
                    Tab(text: "Top"),
                    Tab(text: "Headlines"),
                    Tab(text: "Technology"),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            NewsCategoryPage(query: "trending"),
            NewsCategoryPage(query: "top"),
            NewsCategoryPage(query: "headlines"),
            NewsCategoryPage(query: "technology"),
          ],
        ),
      ),
    );
  }
}

class NewsCategoryPage extends StatelessWidget {
  final String query;
  final String apiKey = "ea690beaea93460db4c6b1af1bc56720";

  NewsCategoryPage({required this.query});

  Future<List<dynamic>> getNewsData() async {
    var newsUrl =
        "https://newsapi.org/v2/everything?q=$query&sortBy=publishedAt&apiKey=$apiKey";
    var newsResponse = await http.get(Uri.parse(newsUrl));
    var newsData = jsonDecode(newsResponse.body);
    return newsData['articles'];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: getNewsData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error fetching data"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No articles available"));
        } else {
          return ListView.separated(
            separatorBuilder: (context, index) => const Divider(
              color: Colors.black,
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var article = snapshot.data![index];
              return ListTile(
                leading: article['urlToImage'] != null
                    ? FadeInImage.assetNetwork(
                  placeholder: '',
                  image: article['urlToImage'],
                  width: 100,
                  fit: BoxFit.cover,
                  imageErrorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.plagiarism_outlined);
                  },
                )
                    : Icon(Icons.plagiarism_outlined),
                title: Text(article['title']),
                subtitle: Text(article['source']['name']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArticleDetail(
                        article: article,
                      ),
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}

class ArticleDetail extends StatefulWidget {
  final Map<String, dynamic> article;

  const ArticleDetail({super.key, required this.article});

  @override
  State<ArticleDetail> createState() => _ArticleDetailState();
}

class _ArticleDetailState extends State<ArticleDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Article Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.article['title'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            widget.article['urlToImage'] != null
                ? Image.network(
              widget.article['urlToImage'],
              width: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.broken_image, size: 100);
              },
            )
                : const SizedBox(),
            const SizedBox(height: 16),
            Text(
              widget.article['content'] ?? "No content available",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Utils.launchURL(context, widget.article['url']);
              },
              child: const Text("Read Full Article"),
            ),
          ],
        ),
      ),
    );
  }
}