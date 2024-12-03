import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:english_words/english_words.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'Flutter Codelab',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          useMaterial3: true,
        ),
        home: HomePage(),
      ),
    );
  }
}

class AppState extends ChangeNotifier {
  var currentWordPair = WordPair.random();

  void getNext() {
    currentWordPair = WordPair.random();
    notifyListeners();
  }

  var favoriteWordPairs = <WordPair>{};

  void toggleFavorite() {
    if (favoriteWordPairs.contains(currentWordPair)) {
      favoriteWordPairs.remove(currentWordPair);
    } else {
      favoriteWordPairs.add(currentWordPair);
    }
    notifyListeners();
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var selectedPageIndex = 0;

  Widget getPage() {
    switch (selectedPageIndex) {
      case 0:
        return GeneratorPage();
      case 1:
        return FavoritesPage();
      default:
        throw UnimplementedError('no page for index $selectedPageIndex');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth > 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedPageIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedPageIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: getPage(),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var favoriteWordPairs = appState.favoriteWordPairs;

    if (favoriteWordPairs.isEmpty) {
      return Center(
        child: Text('No favorites yet'),
      );
    }

    return Scaffold(
      body: ListView(
        children: favoriteWordPairs
            .map((wordPair) => ListTile(
                  title: Text(wordPair.asLowerCase),
                  onTap: () {
                    appState.currentWordPair = wordPair;
                  },
                ))
            .toList(),
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var wordPair = appState.currentWordPair;

    Widget getIcon() {
      if (appState.favoriteWordPairs.contains(wordPair)) {
        return Icon(Icons.favorite);
      } else {
        return Icon(Icons.favorite_border);
      }
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BigCard(wordPair: wordPair),
            SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    appState.toggleFavorite();
                  },
                  icon: getIcon(),
                  label: Text('Favorite'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    appState.getNext();
                  },
                  child: Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.wordPair,
  });

  final WordPair wordPair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(wordPair.asLowerCase,
            semanticsLabel: "${wordPair.first} ${wordPair.second}",
            style: textStyle),
      ),
    );
  }
}
