import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The bottom-nav tab currently shown by [HomeScreen]'s IndexedStack.
///
/// Lets a screen pushed on top of Home (e.g. a chat) switch which tab is
/// selected before popping back to it — used by the "garage near me"
/// shortcut to land on the Carte tab instead of whichever one was active.
final homeTabIndexProvider = StateProvider<int>((ref) => 0);
