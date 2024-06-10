import 'dart:math';

import 'package:biblos/src/reading.dart';
import 'package:biblos/src/services/ls.dart';
import 'package:biblos/src/static.dart';
import 'package:biblos/theme.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const HomeDrawer(),
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: BooksWidget(books: verseMap.keys.toList()),
    );
  }
}

class BooksWidget extends StatelessWidget {
  final List<String> books;
  static Random r = Random();
  const BooksWidget({super.key, required this.books});

  Iterable<List<String>> booksIter() sync* {
    final booksIter = books.iterator;
    while (booksIter.moveNext()) {
      yield [
        booksIter.current,
        if (booksIter.moveNext()) booksIter.current,
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          FutureBuilder<({String? book, String? chapter, double? offset})>(
              future: AppDataClass.getBookmark(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const CircularProgressIndicator();
                }
                return Center(
                  child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ReadingPage(
                            book: snapshot.data?.book ?? "Matthew",
                            chapter: snapshot.data?.chapter ?? "1",
                            offset: snapshot.data?.offset ?? 0,
                          ),
                        ));
                      },
                      icon: const Icon(Icons.bookmark),
                      label: Text(
                          "${snapshot.data?.book} ${snapshot.data?.chapter}")),
                );
              }),
          for (var pair in booksIter())
            Row(children: [
              for (String book in pair)
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ReadingPage(
                        book: book,
                        chapter: "1",
                        offset: 0,
                      ),
                    ));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      width: (constraints.maxWidth / 2) - 40,
                      height: (constraints.maxWidth / 2) - 40,
                      padding: const EdgeInsets.all(30),
                      color: Color.fromRGBO(
                        120 + r.nextInt(125),
                        100 + r.nextInt(145),
                        110 + r.nextInt(135),
                        1,
                      ),
                      child: FittedBox(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: "${book[0]}\n",
                            style: Theme.of(context).textTheme.displayLarge,
                            children: [
                              TextSpan(
                                text: book.substring(1),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ]),
        ],
      );
    });
  }
}

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: themePaddingEdgeInset,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton.filled(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Home",
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  )
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
              child: Divider(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ConstrainedBox(
                constraints:
                    BoxConstraints.tight(const Size(double.infinity, 50)),
                child: FilledButton.icon(
                  icon: const Icon(Icons.book),
                  onPressed: () => Navigator.popUntil(context, (route) {
                    return route.isFirst;
                  }),
                  label: const Text("Greek Resources"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
