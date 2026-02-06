/// Model class for SIM card data
class SimCard {
  final String phoneNumber;
  final String? carrierName;
  final bool isPrimary;
  final int slotIndex;
  
  SimCard({
    required this.phoneNumber,
    this.carrierName,
    this.isPrimary = false,
    required this.slotIndex,
  });

  factory SimCard.fromJson(Map<String, dynamic> json) {
    return SimCard(
      phoneNumber: json['phoneNumber'] ?? '',
      carrierName: json['carrierName'],
      isPrimary: json['isPrimary'] ?? false,
      slotIndex: json['slotIndex'] ?? 0,
    );
  }
}
