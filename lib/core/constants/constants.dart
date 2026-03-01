import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../app_export.dart';

class ConstantsProvider{
  static List<Map<Object,Object>> LanguagesOf(BuildContext context) {
    AppLocalizations translator = AppLocalizations.of(context)!;
    return [
      {
        'text':translator.langFrench,
        'value':'Français',
      },
      {
        'text':translator.langEnglish,
        'value':'Anglais',
      },
      {
        'text':translator.langArabic,
        'value':'Arabe',
      },
      {
        'text':translator.langChinese,
        'value':'Chinois',
      },
      {
        'text':translator.langSpanish,
        'value':'Espagnol',
      },
      {
        'text':translator.langGerman,
        'value':'Allemand',
      },
      {
        'text':translator.langSwahili,
        'value':'Swahili',
      },
      {
        'text':translator.filter_language_russian,
        'value':'Russe',
      },
      {
        'text':translator.langOther,
        'value':'Autres',
      },
    ];
  }

  static List<Map<Object,Object>> ReligionsOf(BuildContext context) {
    AppLocalizations translator = AppLocalizations.of(context)!;
    return [
      {
        'text':translator.religionChristian,
        'value':'Chrétienne',
      },
      {
        'text':translator.religionMuslim,
        'value':'Musulmane',
      },
      {
        'text':translator.religionAnimist,
        'value':'Animiste',
      },
      {
        'text':translator.religionAtheist,
        'value':'Athée',
      },
      {
        'text':translator.religionJewish,
        'value':'Juive',
      },
      {
        'text':translator.option_other_religion,
        'value':'Autres',
      },
    ];
  }

  static List<Map<Object,Object>> AstrologicalSignsOf(BuildContext context) {
    AppLocalizations translator = AppLocalizations.of(context)!;
    return [
      {
        'text':translator.filter_astrology_aries,
        'value':'Bélier',
      },
      {
        'text':translator.filter_astrology_taurus,
        'value':'Taureau',
      },
      {
        'text':translator.filter_astrology_gemini,
        'value':'Gémeaux',
      },
      {
        'text':translator.filter_astrology_cancer,
        'value':'Cancer',
      },
      {
        'text':translator.filter_astrology_leo,
        'value':'Lion',
      },
      {
        'text':translator.filter_astrology_virgo,
        'value':'Vierge',
      },
      {
        'text':translator.filter_astrology_libra,
        'value':'Balance',
      },
      {
        'text':translator.filter_astrology_scorpio,
        'value':'Scorpion',
      },
      {
        'text':translator.filter_astrology_sagittarius,
        'value':'Sagittaire',
      },
      {
        'text':translator.filter_astrology_capricorn,
        'value':'Capricorne',
      },
      {
        'text':translator.filter_astrology_aquarius,
        'value':'Verseau',
      },
      {
        'text':translator.filter_astrology_pisces,
        'value':'Poissons',
      },
    ];
  }

  static List<Map<Object,Object>> PersonnalitiesOf(BuildContext context) {
    AppLocalizations translator = AppLocalizations.of(context)!;
    return [
      {
        'text':translator.introvert,
        'value':'Introverti',
      },
      {
        'text':translator.extrovert,
        'value':'Extraverti',
      },
      {
        'text':translator.bothPersonalities,
        'value':'Un peu des deux',
      },
    ];
  }

  static List<Map<Object,Object>> StudiesOf(BuildContext context) {
    AppLocalizations translator = AppLocalizations.of(context)!;
    return [
      {
        'text':translator.option_high_school,
        'value':'Lycée',
      },
      {
        'text':translator.option_at_university,
        'value':'A la fac',
      },
      {
        'text':translator.option_finished_university,
        'value':'A fini la fac',
      },
      {
        'text':translator.option_in_grad_school,
        'value':'En école supérieure',
      },
      {
        'text':translator.option_graduate,
        'value':'Diplomé(e)',
      },
    ];
  }

  static List<Map<Object,Object>> AlcoholSelfOf(BuildContext context) {
    AppLocalizations translator = AppLocalizations.of(context)!;
    return [
      {
        'text':translator.alcoholNever,
        'value':'Je ne bois jamais',
      },
      {
        'text':translator.alcoholOften,
        'value':'Je bois souvent',
      },
      {
        'text':translator.alcoholStopped,
        'value':'Je ne bois plus',
      },
      {
        'text':translator.alcoholOccasional,
        'value':'Je bois à l\'occasion',
      }
    ];
  }

  static List<Map<Object,Object>> AlcoholFilterOf(BuildContext context) {
    AppLocalizations translator = AppLocalizations.of(context)!;
    return [
      {
        'text':translator.option_never_drinks,
        'value':'Ne boit jamais',
      },
      {
        'text':translator.option_drinks_often,
        'value':'Boit souvent',
      },
      {
        'text':translator.option_no_longer_drinks,
        'value':'Ne boit plus',
      },
      {
        'text':translator.option_drinks_occasionally,
        'value':'Boit à l\'occasion',
      }
    ];
  }

  static List<Map<Object,Object>> SmokingOf(BuildContext context) {
    AppLocalizations translator = AppLocalizations.of(context)!;
    return [
      {
        'text':translator.tobaccoNever,
        'value':'Ne fumes pas',
      },
      {
        'text':translator.tobaccoOften,
        'value':'Fumes souvent',
      },
    ];
  }

  static List<Map<Object,Object>> PetsOf(BuildContext context) {
    AppLocalizations translator = AppLocalizations.of(context)!;
    return [
      {
        'text':translator.filter_pets_cat,
        'value':'Chat(s)',
      },
      {
        'text':translator.filter_pets_dog,
        'value':'Chien(s)',
      },
      {
        'text':translator.filter_pets_other,
        'value':'Autres',
      },
      {
        'text':translator.filter_pets_multiple,
        'value':'Plusieurs',
      },
      {
        'text':translator.filter_pets_none,
        'value':'Aucun',
      },
    ];
  }

  static List<Map<Object,Object>> ChildrenOf(BuildContext context) {
    AppLocalizations translator = AppLocalizations.of(context)!;
    return [
      {
        'text':translator.childrenSomeday,
        'value':'En voudrait un jour',
      },
      {
        'text':translator.childrenHave,
        'value':'En a déjà',
      },
      {
        'text':translator.childrenNone,
        'value':'N\'en veut pas',
      }
    ];
  }

  static List<Map<Object,Object>> ExpectationsOf(BuildContext context) {
    AppLocalizations translator = AppLocalizations.of(context)!;
    return [
      {
        'text':translator.lookingDating,
        'value':'Rencontres',
      },
      {
        'text':translator.lookingSerious,
        'value':'Une Relation sérieuse',
      },
      {
        'text':translator.lookingChat,
        'value':'Discuter',
      }
    ];
  }

  static List<Map<Object,Object>> StatusOf(BuildContext context) {
    AppLocalizations translator = AppLocalizations.of(context)!;
    return [
      {
        'text':translator.option_single,
        'value':'Célibataire',
      },
      {
        'text':translator.option_open_relationship,
        'value':'En relation libre',
      },
      {
        'text':translator.option_in_relationship,
        'value':'En couple',
      },
    ];
  }

  static List<Map<Object,Object>> HobbiesOf(BuildContext context) {
    final AppLocalizations currentLocale = AppLocalizations.of(context)!;
    final AppLocalizations frenchLocale = lookupAppLocalizations(const Locale('fr'));

    return [
      for(var i=0;i<getLocalizedHobbies(currentLocale).length;i++)
        {
        'text': getLocalizedHobbies(currentLocale)[i],
        'value': getLocalizedHobbies(frenchLocale)[i],
        }
    ];
  }

  static List<String> getLocalizedHobbies(AppLocalizations local) {
    return [
      local.hobby_football,
      local.hobby_laughing,
      local.hobby_comedy,
      local.hobby_memes,
      local.hobby_sport,
      local.hobby_cinema,
      local.hobby_sea,
      local.hobby_travel,
      local.hobby_party,
      local.hobby_cooking,
      local.hobby_relaxation,
      local.hobby_music,
      local.hobby_gospel,
      local.hobby_novel,
      local.hobby_diy,
      local.hobby_decor,
      local.hobby_manicure,
      local.hobby_pedicure,
      local.hobby_shopping,
      local.hobby_self_motivation,
      local.hobby_news,
      local.hobby_social_media,
      local.hobby_tiktok,
      local.hobby_instagram,
      local.hobby_love,
      local.hobby_friendship,
    ];
  }

  static String translate(String key,List<Map<Object,Object>> list){
    String result=key;
    for(var item in list){
      if(item['value']==key){
        return item['text'].toString();
      }
    }
    return result;
  }

  static List<String> getWeekDaysLocalized(BuildContext context) {
    AppLocalizations translator = AppLocalizations.of(context)!;
    return [
      translator.monday,
      translator.tuesday,
      translator.wednesday,
      translator.thursday,
      translator.friday,
      translator.saturday,
      translator.sunday,
    ];
  }

  static List<String> getMonthsLocalized(BuildContext context) {
    AppLocalizations translator = AppLocalizations.of(context)!;
    return [
      translator.january,
      translator.february,
      translator.march,
      translator.april,
      translator.may,
      translator.june,
      translator.july,
      translator.august,
      translator.september,
      translator.october,
      translator.november,
      translator.december,
    ];
  }

  static Color getColorFromLetter(BuildContext context,String letter){
    // Function to generate a color from each of the letters of the Alphabet randomly
    Color color;
    switch (letter.toUpperCase()) {
      case 'A':
        color = Colors.red;
        break;
      case 'B':
        color = Colors.blue;
        break;
      case 'C':
        color = Colors.green;
        break;
      case 'D':
        color = Colors.orange;
        break;
      case 'E':
        color = Colors.purple;
        break;
      case 'F':
        color = Colors.teal;
        break;
      case 'G':
        color = Colors.brown;
        break;
      case 'H':
        color = Colors.cyan;
        break;
      case 'I':
        color = Colors.indigo;
        break;
      case 'J':
        color = Colors.lime;
        break;
      case 'K':
        color = Colors.pink;
        break;
      case 'L':
        color = Colors.amber;
        break;
      case 'M':
        color = Colors.deepOrange;
        break;
      case 'N':
        color = Colors.deepPurple;
        break;
      case 'O':
        color = Colors.lightBlue;
        break;
      case 'P':
        color = Colors.lightGreen;
        break;
      case 'Q':
        color = Colors.yellow;
        break;
      case 'R':
        color = Colors.grey;
        break;
      case 'S':
        color = Colors.blueGrey;
        break;
      case 'T':
        color = Colors.redAccent;
        break;
      case 'U':
        color = Colors.greenAccent;
        break;
      case 'V':
        color = Colors.purpleAccent;
        break;
      case 'W':
        color = Colors.orangeAccent;
        break;
      case 'X':
        color = Colors.tealAccent;
        break;
      case 'Y':
        color = Colors.pinkAccent;
        break;
      case 'Z':
        color = Colors.amberAccent;
        break;
      default:
        color = Theme.of(context).colorScheme.primary;
  }
    return color;
  }
}

