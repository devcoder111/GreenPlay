import 'dart:ui';

class LanguageApplication {

    static final LanguageApplication _application = LanguageApplication._internal();

    factory LanguageApplication() {
        return _application;
    }

    LanguageApplication._internal();

    final List<String> supportedLanguages = [
        "English",
        "French France",
        "French",
    ];

    final List<String> supportedLanguagesCodes = [
        "en",
        "fr_FR",
        "fr",
    ];

    //returns the list of supported Locales
    Iterable<Locale> supportedLocales() =>
        supportedLanguagesCodes.map<Locale>((language) => Locale(language, ""));

    //function to be invoked when changing the language
    LocaleChangeCallback onLocaleChanged;
}

LanguageApplication languageApplication = LanguageApplication();

typedef void LocaleChangeCallback(Locale locale);
