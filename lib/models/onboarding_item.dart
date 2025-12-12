enum OnboardingIconType {
  airplane,
  box,
  shoppingBag,
  globe,
}

class OnboardingItem {
  final OnboardingIconType iconType;
  final String titleRu;
  final String titleEn;
  final String titleUz;
  final String descriptionRu;
  final String descriptionEn;
  final String descriptionUz;

  OnboardingItem({
    required this.iconType,
    required this.titleRu,
    required this.titleEn,
    required this.titleUz,
    required this.descriptionRu,
    required this.descriptionEn,
    required this.descriptionUz,
  });

  String getTitle(String language) {
    switch (language) {
      case 'RU':
        return titleRu;
      case 'EN':
        return titleEn;
      case 'UZ':
        return titleUz;
      default:
        return titleRu;
    }
  }

  String getDescription(String language) {
    switch (language) {
      case 'RU':
        return descriptionRu;
      case 'EN':
        return descriptionEn;
      case 'UZ':
        return descriptionUz;
      default:
        return descriptionRu;
    }
  }
}

