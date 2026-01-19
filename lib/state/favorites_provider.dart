import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recipe.dart';
import '../utils/favorites_storage.dart';
import 'profile_provider.dart';

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<Recipe>>(
      (ref) => FavoritesNotifier(ref),
    );

class FavoritesNotifier extends StateNotifier<List<Recipe>> {
  FavoritesNotifier(this.ref) : super([]) {
    _profileId = ref.read(currentProfileIdProvider);
    _load();
    ref.listen<String?>(currentProfileIdProvider, (prev, next) {
      _profileId = next;
      _load();
    });
  }

  final Ref ref;
  String? _profileId;

  Future<void> _load() async {
    final id = _profileId;
    if (id == null) {
      state = [];
      return;
    }
    final favs = await FavoritesStorage.loadForProfile(id);
    state = favs;
  }

  bool isFavorite(Recipe r) {
    return state.any((e) => e.title == r.title);
  }

  Future<void> toggleFavorite(Recipe r) async {
    final id = _profileId;
    if (id == null) return;
    if (isFavorite(r)) {
      state = state.where((e) => e.title != r.title).toList();
    } else {
      state = [...state, r];
    }
    await FavoritesStorage.saveForProfile(id, state);
  }
}
