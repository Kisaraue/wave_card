import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/profile_card.dart';
import '../data/storage/secure_storage_service.dart';

final profileCardProvider = StateNotifierProvider<ProfileCardNotifier, AsyncValue<List<ProfileCard>>>((ref) {
  return ProfileCardNotifier();
});

class ProfileCardNotifier extends StateNotifier<AsyncValue<List<ProfileCard>>> {
  ProfileCardNotifier() : super(const AsyncValue.loading()) {
    loadProfileCards();
  }

  final SecureStorageService _storageService = SecureStorageService();

  Future<void> loadProfileCards() async {
    try {
      state = const AsyncValue.loading();
      final cards = await _storageService.getProfileCards();
      state = AsyncValue.data(cards);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addProfileCard(ProfileCard card) async {
    try {
      await _storageService.addProfileCard(card);
      await loadProfileCards();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateProfileCard(ProfileCard updatedCard) async {
    try {
      await _storageService.updateProfileCard(updatedCard);
      await loadProfileCards();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteProfileCard(String cardId) async {
    try {
      await _storageService.deleteProfileCard(cardId);
      await loadProfileCards();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> duplicateProfileCard(ProfileCard card) async {
    try {
      final duplicatedCard = ProfileCard(
        fullName: '${card.fullName} (Copy)',
        jobTitle: card.jobTitle,
        company: card.company,
        profileImageUrl: card.profileImageUrl,
        email: card.email,
        phone: card.phone,
        address: card.address,
        socialLinks: Map.from(card.socialLinks),
        customFields: Map.from(card.customFields),
        cardStyle: card.cardStyle,
      );
      await addProfileCard(duplicatedCard);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Provider for getting a specific profile card by ID
final profileCardByIdProvider = Provider.family<ProfileCard?, String>((ref, cardId) {
  final cardsAsync = ref.watch(profileCardProvider);
  return cardsAsync.maybeWhen(
    data: (cards) => cards.firstWhere(
      (card) => card.id == cardId,
      orElse: () => ProfileCard(
        fullName: '',
        jobTitle: '',
        company: '',
      ),
    ),
    orElse: () => null,
  );
});

// Provider for profile cards count
final profileCardCountProvider = Provider<int>((ref) {
  final cardsAsync = ref.watch(profileCardProvider);
  return cardsAsync.maybeWhen(
    data: (cards) => cards.length,
    orElse: () => 0,
  );
});

// Provider for checking if max cards limit is reached
final canAddMoreCardsProvider = Provider<bool>((ref) {
  final count = ref.watch(profileCardCountProvider);
  return count < 5; // Maximum 5 cards as per requirements
});

// Provider for the currently selected card (for editing)
final selectedCardProvider = StateProvider<ProfileCard?>((ref) => null);

// Provider for card creation/editing form state
final cardFormProvider = StateNotifierProvider<CardFormNotifier, ProfileCard>((ref) {
  return CardFormNotifier();
});

class CardFormNotifier extends StateNotifier<ProfileCard> {
  CardFormNotifier() : super(ProfileCard(
    fullName: '',
    jobTitle: '',
    company: '',
  ));

  void setCard(ProfileCard card) {
    state = card;
  }

  void updateFullName(String name) {
    state = state.copyWith(fullName: name);
  }

  void updateJobTitle(String title) {
    state = state.copyWith(jobTitle: title);
  }

  void updateCompany(String company) {
    state = state.copyWith(company: company);
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updatePhone(String phone) {
    state = state.copyWith(phone: phone);
  }

  void updateAddress(String address) {
    state = state.copyWith(address: address);
  }

  void updateProfileImage(String imageUrl) {
    state = state.copyWith(profileImageUrl: imageUrl);
  }

  void updateSocialLink(String platform, String url) {
    final updatedSocialLinks = Map<String, String>.from(state.socialLinks);
    if (url.isEmpty) {
      updatedSocialLinks.remove(platform);
    } else {
      updatedSocialLinks[platform] = url;
    }
    state = state.copyWith(socialLinks: updatedSocialLinks);
  }

  void updateCustomField(String key, String value) {
    final updatedCustomFields = Map<String, String>.from(state.customFields);
    if (value.isEmpty) {
      updatedCustomFields.remove(key);
    } else {
      updatedCustomFields[key] = value;
    }
    state = state.copyWith(customFields: updatedCustomFields);
  }

  void updateCardStyle(CardStyle style) {
    state = state.copyWith(cardStyle: style);
  }

  void updateMultipleFields({
    String? fullName,
    String? jobTitle,
    String? company,
    String? email,
    String? phone,
    String? address,
    String? profileImageUrl,
    Map<String, String>? socialLinks,
    Map<String, String>? customFields,
    CardStyle? cardStyle,
  }) {
    state = state.copyWith(
      fullName: fullName ?? state.fullName,
      jobTitle: jobTitle ?? state.jobTitle,
      company: company ?? state.company,
      email: email ?? state.email,
      phone: phone ?? state.phone,
      address: address ?? state.address,
      profileImageUrl: profileImageUrl ?? state.profileImageUrl,
      socialLinks: socialLinks ?? state.socialLinks,
      customFields: customFields ?? state.customFields,
      cardStyle: cardStyle ?? state.cardStyle,
    );
  }

  void reset() {
    state = ProfileCard(
      fullName: '',
      jobTitle: '',
      company: '',
    );
  }
}