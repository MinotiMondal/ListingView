import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webskitterstask/views/detailsScreen.dart';

import '../provider/photosProvider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PhotoProvider>(context, listen: false).fetchPhotos();
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      Provider.of<PhotoProvider>(context, listen: false)
          .fetchPhotos(isNextPage: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photoProvider = Provider.of<PhotoProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Unsplash Gallery')),
      body: photoProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        controller: _scrollController,
        itemCount: photoProvider.photos.length +
            (photoProvider.isFetchingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == photoProvider.photos.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final photo = photoProvider.photos[index];
          return Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(photo: photo),
                    ),
                  );
                },
                child: Container(
                  height: 100,
                  width: double.infinity,
                  child: Image.network(photo.urls.thumb),
                ),
              ),
              Text(photo.description ?? 'No description'),
            ],
          );
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     photoProvider.fetchPhotos();
      //   },
      //   child: const Icon(Icons.refresh),
      // ),
    );
  }
}
