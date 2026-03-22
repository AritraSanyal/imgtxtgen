import 'dart:convert';

class BusinessProfile {
  final String businessName;
  final String industry;
  final String tagline;
  final List<String> brandTones;
  final String ageRange;
  final String targetGender;
  final List<String> interests;
  final String currentProduct;
  final List<String> keyBenefits;

  const BusinessProfile({
    this.businessName = '',
    this.industry = '',
    this.tagline = '',
    this.brandTones = const [],
    this.ageRange = '',
    this.targetGender = '',
    this.interests = const [],
    this.currentProduct = '',
    this.keyBenefits = const [],
  });

  BusinessProfile copyWith({
    String? businessName,
    String? industry,
    String? tagline,
    List<String>? brandTones,
    String? ageRange,
    String? targetGender,
    List<String>? interests,
    String? currentProduct,
    List<String>? keyBenefits,
  }) {
    return BusinessProfile(
      businessName: businessName ?? this.businessName,
      industry: industry ?? this.industry,
      tagline: tagline ?? this.tagline,
      brandTones: brandTones ?? this.brandTones,
      ageRange: ageRange ?? this.ageRange,
      targetGender: targetGender ?? this.targetGender,
      interests: interests ?? this.interests,
      currentProduct: currentProduct ?? this.currentProduct,
      keyBenefits: keyBenefits ?? this.keyBenefits,
    );
  }

  Map<String, dynamic> toJson() => {
        'businessName': businessName,
        'industry': industry,
        'tagline': tagline,
        'brandTones': brandTones,
        'ageRange': ageRange,
        'targetGender': targetGender,
        'interests': interests,
        'currentProduct': currentProduct,
        'keyBenefits': keyBenefits,
      };

  factory BusinessProfile.fromJson(Map<String, dynamic> json) =>
      BusinessProfile(
        businessName: json['businessName'] ?? '',
        industry: json['industry'] ?? '',
        tagline: json['tagline'] ?? '',
        brandTones: List<String>.from(json['brandTones'] ?? []),
        ageRange: json['ageRange'] ?? '',
        targetGender: json['targetGender'] ?? '',
        interests: List<String>.from(json['interests'] ?? []),
        currentProduct: json['currentProduct'] ?? '',
        keyBenefits: List<String>.from(json['keyBenefits'] ?? []),
      );

  String toJsonString() => jsonEncode(toJson());

  factory BusinessProfile.fromJsonString(String s) =>
      BusinessProfile.fromJson(jsonDecode(s));

  bool get isComplete =>
      businessName.isNotEmpty &&
      industry.isNotEmpty &&
      currentProduct.isNotEmpty;
}
