class AppLang {
  static String current = 'bn';
  static Map<String, Map<String, String>> t = {
    'bn': {'appName':'Jomi Map','start':'জমি মাপা শুরু করুন','pro':'Pro Plans দেখুন - ₹99 থেকে শুরু','buy':'কিনুন'},
    'en': {'appName':'Jomi Map','start':'Start Measuring','pro':'View Pro Plans - From ₹99','buy':'Buy'},
    'hi': {'appName':'Jomi Map','start':'जमीन मापना शुरू करें','pro':'Pro Plans देखें - ₹99 से','buy':'खरीदें'},
  };
  static String get(String k) => t[current]?[k] ?? k;
}
