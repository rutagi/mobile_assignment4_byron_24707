import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = Locale('en', '');

  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      theme: ThemeData(
        primaryColor: Color(0xFF02653B),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Color(0xFF4CAF50),
        ),
        scaffoldBackgroundColor: Color(0xFFF5F5F5),
        textTheme: TextTheme(
          headlineLarge: TextStyle(color: Colors.white, fontSize: 20),
          bodyLarge: TextStyle(color: Color(0xFF4CAF50)),
        ),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('es', ''), // Spanish
      ],
      home: MyHomePage(onLocaleChange: _setLocale),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Function(Locale) onLocaleChange;

  MyHomePage({required this.onLocaleChange});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Contact> _contacts = [];
  final List<Contact> _constantContacts = [
    Contact(givenName: 'John', familyName: 'Doe', displayName: 'John Doe'),
    Contact(givenName: 'Jane', familyName: 'Smith', displayName: 'Jane Smith'),
  ];

  @override
  void initState() {
    super.initState();
    requestPermissions().then((_) {
      getContacts();
    });
  }

  Future<void> requestPermissions() async {
    await [
      Permission.contacts,
      Permission.camera,
      Permission.storage,
    ].request();
  }

  Future<void> getContacts() async {
    if (await Permission.contacts.isGranted) {
      try {
        Iterable<Contact> contacts = await ContactsService.getContacts();
        setState(() {
          _contacts = _constantContacts + contacts.toList();
        });
        for (var contact in contacts) {
          print(contact.displayName);
        }
      } catch (e) {
        print('Error fetching contacts: $e');
      }
    } else {
      setState(() {
        _contacts = _constantContacts;
      });
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      print('Picked image: ${pickedFile.path}');
    }
  }

  Widget _buildContactItem(Contact contact) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage('assets/images/default_profile.png'),
        radius: 20,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      title: Text(
        contact.displayName ?? '',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(contact.givenName ?? ''),
      onTap: () {
        // Handle contact tap if needed
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var localization = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localization.translate('title')),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Handle search action
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              accountName: Text('RB'),
              accountEmail: Text('rutagibyron@gmail.com'),
              currentAccountPicture: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              title: Text(localization
                                  .translate('select_from_gallery')),
                              onTap: () {
                                Navigator.pop(context);
                                pickImage(ImageSource.gallery);
                              },
                            ),
                            ListTile(
                              title:
                                  Text(localization.translate('take_a_photo')),
                              onTap: () {
                                Navigator.pop(context);
                                pickImage(ImageSource.camera);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: CircleAvatar(
                  backgroundImage:
                      AssetImage('assets/images/profile_placeholder.png'),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.language),
              title: Text(localization.translate('select_language')),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(localization.translate('select_language')),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildLanguageOption(localization, 'English', 'en'),
                          _buildLanguageOption(localization, 'Spanish', 'es'),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          Contact contact = _contacts[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: _buildContactItem(contact),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle floating action button press
        },
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildLanguageOption(
      AppLocalizations localization, String languageName, String languageCode) {
    return ListTile(
      title: Text(languageName),
      onTap: () {
        Locale newLocale = Locale(languageCode, '');
        widget.onLocaleChange(newLocale);
        Navigator.pop(context);
      },
    );
  }
}

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  late Map<String, String> _localizedStrings;

  Future<bool> load() async {
    try {
      String jsonString = await rootBundle
          .loadString('assets/lang/${locale.languageCode}.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);

      _localizedStrings = jsonMap.map((key, value) {
        return MapEntry(key, value.toString());
      });
    } catch (e) {
      print('Error loading localization for ${locale.languageCode}: $e');
      _localizedStrings = {};
    }

    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? '';
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = new AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}
