import 'dart:io';

import 'package:biblos/main.dart';
import 'package:biblos/src/reading.dart';
import 'package:biblos/src/services/books.dart';
import 'package:biblos/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

const debug = true;

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  BannerAd? _bannerAd;
  // TODO: When you make bannerAd real you need to make this false.
  bool _isLoaded = false;

  final adUnitId = Platform.isAndroid
      ? debug
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-5596240965341113/5552647641'
      : 'ca-app-pub-3940256099942544/2934735716';

  static HomePageState? of(BuildContext context) {
    return context.findAncestorStateOfType<HomePageState>();
  }

  /// Loads a banner ad.
  void loadAd() {
    if (!Platform.isAndroid && Platform.isIOS) {
      return;
    }
    _bannerAd ??= BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {
            _isLoaded = true;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          // Dispose the ad here to free resources.
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void initState() {
    loadAd();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themePrimary,
      appBar: AppBar(
        title: Center(
          child: Text("βίβλος",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge),
        ),
        backgroundColor: themePrimary,
      ),
      body: Container(
        color: themeLight,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const HomeTitleWidget(),
            const Expanded(
              child: BookLibraryWidget(),
            ),
            // Add Widget
            if (_isLoaded)
              SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
      ),
    );
  }
}

class HomeTitleWidget extends StatefulWidget {
  const HomeTitleWidget({
    super.key,
  });

  @override
  State<HomeTitleWidget> createState() => HomeTitleWidgetState();
}

class HomeTitleWidgetState extends State<HomeTitleWidget> {
  _updateLocation() {
    setState(() {});
  }

  @override
  void initState() {
    final appState = AppWidgetState.of(context)!.appData;
    appState.addListener(_updateLocation);
    super.initState();
  }

  @override
  void dispose() {
    final appState = AppWidgetState.of(context)!.appData;
    appState.removeListener(_updateLocation);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppWidgetState.of(context)!.appData;
    return Container(
      // margin: const EdgeInsets.all(themePadding),
      padding: themePaddingEdgeInset,
      width: double.infinity,
      height: blobHeight * 1.5,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: themePrimary,
        borderRadius: BorderRadius.only(
          bottomLeft: themeCircularRadius,
          bottomRight: themeCircularRadius,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ReadingPage(
                    book: appState.book,
                    chapter: appState.chapter,
                    offset: appState.offset,
                  ),
                ));
              },
              child: Text(
                  "Continue reading: ${appState.book} ${appState.chapter}")),
        ],
      ),
    );
  }
}

class BookLibraryWidget extends StatelessWidget {
  const BookLibraryWidget({super.key});

  Iterable<List<String>> booksIter(String category) sync* {
    final bi = bookDivisionMap[category]!.iterator;
    while (bi.moveNext()) {
      yield [
        bi.current,
        if (bi.moveNext()) bi.current,
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final buttonSize = (size.width / 2) - themePadding;

    return ListView(children: [
      for (var bookCategory in bookDivisionMap.keys)
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ReadingPage(
                book: bookCategory,
                chapter: "1",
                offset: 0,
              ),
            ));
          },
          child: Container(
            width: double.infinity,
            margin: themePaddingEdgeInset,
            decoration: const BoxDecoration(
              color: themePrimary,
              borderRadius: themeBorderRadius,
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Padding(
                  padding: themePaddingEdgeInset,
                  child: Text(
                    bookCategory,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: themeLight),
                  ),
                ),
                const SizedBox(height: themePadding / 2),
                for (var pair in booksIter(bookCategory))
                  Row(children: [
                    for (String book in pair)
                      SizedBox(
                        width: (buttonSize * 2) / pair.length,
                        height: blobHeight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 14),
                            backgroundColor: themeSecondaryLight,
                            foregroundColor: themePrimary,
                            // minimumSize: buttonSize,
                            shape: const ContinuousRectangleBorder(),
                          ),
                          onPressed: () {
                            AppWidgetState.of(context)!.appData.setBookMark(
                                newBook: book, newChapter: "1", newOffset: 0);
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ReadingPage(
                                book: book,
                                chapter: "1",
                                offset: 0,
                              ),
                            ));
                          },
                          child: Text(
                            book,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                  ]),
              ],
            ),
          ),
        )
    ]);
  }
}
