class VirtualCard {
  final String id;
  final String name;
  final String cardNumber;
  final String expiryDate;
  final String cvv;
  final String cardHolderName;
  final double balance;
  final String currency;
  final CardDesign design;
  final bool isActive;
  final DateTime createdAt;

  VirtualCard({
    required this.id,
    required this.name,
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    required this.cardHolderName,
    required this.balance,
    required this.currency,
    required this.design,
    required this.isActive,
    required this.createdAt,
  });

  factory VirtualCard.fromJson(Map<String, dynamic> json) {
    return VirtualCard(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      cardNumber: json['cardNumber'] ?? '',
      expiryDate: json['expiryDate'] ?? '',
      cvv: json['cvv'] ?? '',
      cardHolderName: json['cardHolderName'] ?? '',
      balance: (json['balance'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'USD',
      design: CardDesign.fromJson(json['design'] ?? {}),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cardNumber': cardNumber,
      'expiryDate': expiryDate,
      'cvv': cvv,
      'cardHolderName': cardHolderName,
      'balance': balance,
      'currency': currency,
      'design': design.toJson(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get maskedCardNumber {
    if (cardNumber.length < 4) return cardNumber;
    return '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';
  }

  String get formattedBalance {
    return '\$${balance.toStringAsFixed(2)}';
  }
}

class CardDesign {
  final String id;
  final String name;
  final String primaryColor;
  final String secondaryColor;
  final String gradientStart;
  final String gradientEnd;
  final String pattern;
  final String logoPosition;
  final bool hasGlow;
  final String texture;

  CardDesign({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.gradientStart,
    required this.gradientEnd,
    required this.pattern,
    required this.logoPosition,
    required this.hasGlow,
    required this.texture,
  });

  factory CardDesign.fromJson(Map<String, dynamic> json) {
    return CardDesign(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      primaryColor: json['primaryColor'] ?? '#1E3A8A',
      secondaryColor: json['secondaryColor'] ?? '#3B82F6',
      gradientStart: json['gradientStart'] ?? '#1E3A8A',
      gradientEnd: json['gradientEnd'] ?? '#3B82F6',
      pattern: json['pattern'] ?? 'none',
      logoPosition: json['logoPosition'] ?? 'top-right',
      hasGlow: json['hasGlow'] ?? false,
      texture: json['texture'] ?? 'none',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'gradientStart': gradientStart,
      'gradientEnd': gradientEnd,
      'pattern': pattern,
      'logoPosition': logoPosition,
      'hasGlow': hasGlow,
      'texture': texture,
    };
  }
}

class VirtualAccount {
  final String id;
  final String accountNumber;
  final String bankName;
  final String accountName;
  final String currency;
  final double balance;
  final bool isActive;
  final DateTime createdAt;
  final List<VirtualCard> cards;

  VirtualAccount({
    required this.id,
    required this.accountNumber,
    required this.bankName,
    required this.accountName,
    required this.currency,
    required this.balance,
    required this.isActive,
    required this.createdAt,
    required this.cards,
  });

  factory VirtualAccount.fromJson(Map<String, dynamic> json) {
    return VirtualAccount(
      id: json['id'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      bankName: json['bankName'] ?? 'Nexa Prime Bank',
      accountName: json['accountName'] ?? '',
      currency: json['currency'] ?? 'USD',
      balance: (json['balance'] ?? 0.0).toDouble(),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      cards: (json['cards'] as List<dynamic>? ?? [])
          .map((card) => VirtualCard.fromJson(card))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountNumber': accountNumber,
      'bankName': bankName,
      'accountName': accountName,
      'currency': currency,
      'balance': balance,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'cards': cards.map((card) => card.toJson()).toList(),
    };
  }

  String get formattedBalance {
    return '\$${balance.toStringAsFixed(2)}';
  }

  String get maskedAccountNumber {
    if (accountNumber.length < 4) return accountNumber;
    return '****${accountNumber.substring(accountNumber.length - 4)}';
  }
}
