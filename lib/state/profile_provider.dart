import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile.dart';
import '../utils/profile_storage.dart';

final profilesProvider = StateNotifierProvider<ProfilesNotifier, List<Profile>>(
  (ref) => ProfilesNotifier(ref),
);

final currentProfileIdProvider = StateProvider<String?>((ref) => null);

// Liste des IDs de profils sélectionnés (pour mode multi-profils)
final selectedProfileIdsProvider = StateProvider<List<String>>((ref) => []);

final currentProfileProvider = Provider<Profile?>((ref) {
  final id = ref.watch(currentProfileIdProvider);
  final list = ref.watch(profilesProvider);
  if (id == null) return null;
  try {
    return list.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
});

// Provider pour obtenir tous les profils sélectionnés
final selectedProfilesProvider = Provider<List<Profile>>((ref) {
  final selectedIds = ref.watch(selectedProfileIdsProvider);
  final allProfiles = ref.watch(profilesProvider);
  if (selectedIds.isEmpty) {
    final currentId = ref.watch(currentProfileIdProvider);
    if (currentId == null) return [];
    try {
      return [allProfiles.firstWhere((p) => p.id == currentId)];
    } catch (_) {
      return [];
    }
  }
  return allProfiles.where((p) => selectedIds.contains(p.id)).toList();
});

class ProfilesNotifier extends StateNotifier<List<Profile>> {
  ProfilesNotifier(this.ref) : super([]) {
    _load();
  }
  final Ref ref;

  Future<void> _load() async {
    final all = await ProfileStorage.loadAll();
    state = all;
    final currentId = await ProfileStorage.loadCurrentId();
    ref.read(currentProfileIdProvider.notifier).state = currentId;
  }

  Future<void> addProfile(String name, String description) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final profile = Profile(id: id, name: name, description: description);
    state = [...state, profile];
    await ProfileStorage.saveAll(state);
  }

  Future<void> updateProfile(String id, String name, String description) async {
    state = [
      for (final p in state)
        if (p.id == id) p.copyWith(name: name, description: description) else p,
    ];
    await ProfileStorage.saveAll(state);
  }

  Future<void> deleteProfile(String id) async {
    state = state.where((p) => p.id != id).toList();
    await ProfileStorage.saveAll(state);
    final currentId = ref.read(currentProfileIdProvider);
    if (currentId == id) {
      ref.read(currentProfileIdProvider.notifier).state = null;
      await ProfileStorage.saveCurrentId(null);
    }
  }

  Future<void> selectProfile(String? id) async {
    ref.read(currentProfileIdProvider.notifier).state = id;
    // Reset multi-selection when single profile is selected
    ref.read(selectedProfileIdsProvider.notifier).state = [];
    await ProfileStorage.saveCurrentId(id);
  }

  void toggleMultiProfileSelection(String profileId) {
    final currentSelectedIds = ref.read(selectedProfileIdsProvider);
    final currentList = List<String>.from(currentSelectedIds);

    if (currentList.contains(profileId)) {
      currentList.remove(profileId);
    } else {
      currentList.add(profileId);
    }

    ref.read(selectedProfileIdsProvider.notifier).state = currentList;
    // Clear single selection when using multi-selection
    if (currentList.isNotEmpty) {
      ref.read(currentProfileIdProvider.notifier).state = null;
    }
  }

  void selectAllProfiles() {
    final allIds = state.map((p) => p.id).toList();
    ref.read(selectedProfileIdsProvider.notifier).state = allIds;
    ref.read(currentProfileIdProvider.notifier).state = null;
  }

  void clearMultiSelection() {
    ref.read(selectedProfileIdsProvider.notifier).state = [];
  }
}
