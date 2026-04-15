/// Booking status (`pending` | `completed`).
enum BookingStatus { pending, completed }

/// A single booking with schedule, location, and pricing via [finalAmount].
class Booking {
  const Booking({
    required this.id,
    required this.customerName,
    required this.serviceType,
    required this.status,
    required this.amount,
    required this.scheduledAt,
    required this.locationName,
    required this.address,
  });

  final String id;
  final String customerName;
  final String serviceType;
  final BookingStatus status;

  /// Original booking amount in RM (before discount).
  final double amount;

  /// When the booking takes place (date + time).
  final DateTime scheduledAt;

  /// Local calendar date for planner / month views .
  DateTime get dateOnly =>
      DateTime(scheduledAt.year, scheduledAt.month, scheduledAt.day);

  /// Short venue label for display in lists and calendar. E.g. "Bangsar" or "JW Marriot, Bukit Bintang".
  final String locationName;

  /// Full address for display and opening in maps.
  final String address;

  /// Opens Google Maps search for [address].
  Uri get mapsSearchUri => Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
  );

  /// Discount applies when amount is **greater than** RM 200.
  static const double discountThreshold = 200.0;
  static const double discountRate = 0.10;

  bool get qualifiesForDiscount => amount > discountThreshold;

  /// Price after 10% discount when [qualifiesForDiscount] is true.
  double get finalAmount =>
      qualifiesForDiscount ? amount * (1 - discountRate) : amount;

  double get discountAmount => qualifiesForDiscount ? amount * discountRate : 0;

  Booking copyWith({
    String? id,
    String? customerName,
    String? serviceType,
    BookingStatus? status,
    double? amount,
    DateTime? scheduledAt,
    String? locationName,
    String? address,
  }) {
    return Booking(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      serviceType: serviceType ?? this.serviceType,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      locationName: locationName ?? this.locationName,
      address: address ?? this.address,
    );
  }
}
