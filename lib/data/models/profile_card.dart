import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ProfileCard {
  final String id;
  final String fullName;
  final String jobTitle;
  final String company;
  final String? profileImageUrl;
  final String? email;
  final String? phone;
  final String? address;
  final Map<String, String> socialLinks;
  final Map<String, String> customFields;
  final CardStyle cardStyle;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileCard({
    String? id,
    required this.fullName,
    required this.jobTitle,
    required this.company,
    this.profileImageUrl,
    this.email,
    this.phone,
    this.address,
    Map<String, String>? socialLinks,
    Map<String, String>? customFields,
    CardStyle? cardStyle,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        socialLinks = socialLinks ?? {},
        customFields = customFields ?? {},
        cardStyle = cardStyle ?? CardStyle.defaultStyle(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  ProfileCard copyWith({
    String? fullName,
    String? jobTitle,
    String? company,
    String? profileImageUrl,
    String? email,
    String? phone,
    String? address,
    Map<String, String>? socialLinks,
    Map<String, String>? customFields,
    CardStyle? cardStyle,
  }) {
    return ProfileCard(
      id: id,
      fullName: fullName ?? this.fullName,
      jobTitle: jobTitle ?? this.jobTitle,
      company: company ?? this.company,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      socialLinks: socialLinks ?? this.socialLinks,
      customFields: customFields ?? this.customFields,
      cardStyle: cardStyle ?? this.cardStyle,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'jobTitle': jobTitle,
      'company': company,
      'profileImageUrl': profileImageUrl,
      'email': email,
      'phone': phone,
      'address': address,
      'socialLinks': socialLinks,
      'customFields': customFields,
      'cardStyle': cardStyle.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ProfileCard.fromJson(Map<String, dynamic> json) {
    return ProfileCard(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      jobTitle: json['jobTitle'] as String,
      company: json['company'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      socialLinks: Map<String, String>.from(json['socialLinks'] ?? {}),
      customFields: Map<String, String>.from(json['customFields'] ?? {}),
      cardStyle: CardStyle.fromJson(json['cardStyle']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfileCard && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class CardStyle {
  final String template;
  final String fontFamily;
  final double fontSize;
  final FontWeight fontWeight;
  final Color textColor;
  final Color backgroundColor;
  final String backgroundType; // 'solid', 'gradient', 'image'
  final List<Color> gradientColors;
  final String? backgroundImageUrl;
  final double borderRadius;
  final bool hasGlassmorphism;
  final bool has3DEffect;

  CardStyle({
    required this.template,
    required this.fontFamily,
    required this.fontSize,
    required this.fontWeight,
    required this.textColor,
    required this.backgroundColor,
    required this.backgroundType,
    required this.gradientColors,
    this.backgroundImageUrl,
    required this.borderRadius,
    required this.hasGlassmorphism,
    required this.has3DEffect,
  });

  factory CardStyle.defaultStyle() {
    return CardStyle(
      template: 'Classic',
      fontFamily: 'Inter',
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      textColor: Colors.black,
      backgroundColor: Colors.white,
      backgroundType: 'solid',
      gradientColors: [Colors.white, Colors.grey.shade100],
      borderRadius: 20.0,
      hasGlassmorphism: false,
      has3DEffect: true,
    );
  }

  CardStyle copyWith({
    String? template,
    String? fontFamily,
    double? fontSize,
    FontWeight? fontWeight,
    Color? textColor,
    Color? backgroundColor,
    String? backgroundType,
    List<Color>? gradientColors,
    String? backgroundImageUrl,
    double? borderRadius,
    bool? hasGlassmorphism,
    bool? has3DEffect,
  }) {
    return CardStyle(
      template: template ?? this.template,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      textColor: textColor ?? this.textColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundType: backgroundType ?? this.backgroundType,
      gradientColors: gradientColors ?? this.gradientColors,
      backgroundImageUrl: backgroundImageUrl ?? this.backgroundImageUrl,
      borderRadius: borderRadius ?? this.borderRadius,
      hasGlassmorphism: hasGlassmorphism ?? this.hasGlassmorphism,
      has3DEffect: has3DEffect ?? this.has3DEffect,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'template': template,
      'fontFamily': fontFamily,
      'fontSize': fontSize,
      'fontWeight': fontWeight.index,
      'textColor': textColor.value,
      'backgroundColor': backgroundColor.value,
      'backgroundType': backgroundType,
      'gradientColors': gradientColors.map((color) => color.value).toList(),
      'backgroundImageUrl': backgroundImageUrl,
      'borderRadius': borderRadius,
      'hasGlassmorphism': hasGlassmorphism,
      'has3DEffect': has3DEffect,
    };
  }

  factory CardStyle.fromJson(Map<String, dynamic> json) {
    return CardStyle(
      template: json['template'] as String? ?? 'Classic',
      fontFamily: json['fontFamily'] as String? ?? 'Inter',
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 14.0,
      fontWeight: json['fontWeight'] != null 
          ? FontWeight.values[json['fontWeight'] as int] 
          : FontWeight.normal,
      textColor: json['textColor'] != null 
          ? Color(json['textColor'] as int) 
          : Colors.black,
      backgroundColor: json['backgroundColor'] != null 
          ? Color(json['backgroundColor'] as int) 
          : Colors.white,
      backgroundType: json['backgroundType'] as String? ?? 'solid',
      gradientColors: json['gradientColors'] != null 
          ? (json['gradientColors'] as List<dynamic>)
              .map((color) => Color(color as int))
              .toList()
          : [Colors.white, Colors.grey.shade100],
      backgroundImageUrl: json['backgroundImageUrl'] as String?,
      borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 20.0,
      hasGlassmorphism: json['hasGlassmorphism'] as bool? ?? false,
      has3DEffect: json['has3DEffect'] as bool? ?? true,
    );
  }
}