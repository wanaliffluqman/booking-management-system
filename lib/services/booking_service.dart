import 'dart:math';

import '../models/booking.dart';

/// Mock API with artificial latency. Use [failNextFetch] or optional random
/// failure for error UI demos.
///
/// Seed data mirrors real-world laundry flows similar to
/// [AeroSparkle](https://apps.apple.com/my/app/aerosparkle/id6747414923):
/// doorstep pickup, wash & fold, delivery windows, and billing-style totals.
class BookingService {
  BookingService() {
    _bookings.addAll(_seedBookings);
  }

  final List<Booking> _bookings = [];
  final Random _random = Random();

  /// When `true`, the next [fetchBookings] throws (then resets to `false`).
  bool failNextFetch = false;

  /// If `true`, each fetch has a [randomFailureChance] probability of failing.
  bool randomFailuresEnabled = false;

  /// Used only when [randomFailuresEnabled] is `true`.
  double randomFailureChance = 0.2;

  static const Duration _mutationDelay = Duration(milliseconds: 450);

  /// Simulated network delay (1–2 seconds).
  Future<void> _simulateFetchLatency() async {
    final ms = 1000 + _random.nextInt(1001);
    await Future<void>.delayed(Duration(milliseconds: ms));
  }

  List<Booking> get _snapshot => List<Booking>.unmodifiable(_bookings);

  /// Latest bookings from the mock store.
  List<Booking> get bookings => List<Booking>.from(_snapshot);

  /// Simulates GET /bookings.
  Future<List<Booking>> fetchBookings() async {
    await _simulateFetchLatency();

    if (failNextFetch) {
      failNextFetch = false;
      throw BookingServiceException(
        'Could not load bookings. Please try again.',
      );
    }

    if (randomFailuresEnabled && _random.nextDouble() < randomFailureChance) {
      throw BookingServiceException('Temporary server error. Please retry.');
    }

    return List<Booking>.from(_snapshot);
  }

  /// Simulates PATCH when an order is fulfilled (e.g. delivered / completed).
  Future<Booking> markCompleted(String id) async {
    await Future<void>.delayed(_mutationDelay);
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index == -1) {
      throw BookingServiceException('Booking not found.');
    }
    final current = _bookings[index];
    if (current.status == BookingStatus.completed) {
      return current;
    }
    final updated = current.copyWith(status: BookingStatus.completed);
    _bookings[index] = updated;
    return updated;
  }

  static List<Booking> get _seedBookings => [
    Booking(
      id: 'as-101',
      customerName: 'Aina Rahman',
      serviceType: 'Pickup — wash & fold (weekly)',
      status: BookingStatus.pending,
      amount: 88.0,
      scheduledAt: DateTime(2026, 4, 14, 9, 0),
      locationName: 'Bangsar',
      address: '12 Jalan Telawi 5, Bangsar, 59100 Kuala Lumpur',
    ),
    Booking(
      id: 'as-102',
      customerName: 'Wei Chen',
      serviceType: 'Delivery - Express dry cleaning + ironing',
      status: BookingStatus.pending,
      amount: 280.0,
      scheduledAt: DateTime(2026, 4, 16, 14, 0),
      locationName: 'KLCC',
      address: 'Menara Maxis, Kuala Lumpur City Centre, 50088 KL',
    ),
    Booking(
      id: 'as-103',
      customerName: 'Priya Nair',
      serviceType: 'Return delivery — folded & packed',
      status: BookingStatus.completed,
      amount: 95.0,
      scheduledAt: DateTime(2026, 4, 14, 16, 30),
      locationName: 'Damansara Utama',
      address: '18 Jalan SS 21/1, Damansara Utama, 47400 Petaling Jaya',
    ),
    Booking(
      id: 'as-104',
      customerName: 'Farah Adila',
      serviceType: 'Pickup — school uniforms wash & press',
      status: BookingStatus.pending,
      amount: 130.0,
      scheduledAt: DateTime(2026, 4, 14, 18, 0),
      locationName: 'Apartment Cheras',
      address: 'Residensi Alam Damai, 56000 Cheras, Kuala Lumpur',
    ),
    Booking(
      id: 'as-105',
      customerName: 'Nabil Firdaus',
      serviceType: 'Pickup — comforter deep cleaning',
      status: BookingStatus.pending,
      amount: 220.0,
      scheduledAt: DateTime(2026, 4, 15, 9, 30),
      locationName: 'Setia Alam',
      address: 'Jalan Setia Prima U13, 40170 Shah Alam, Selangor',
    ),
    Booking(
      id: 'as-106',
      customerName: 'Joanne Lim',
      serviceType: 'Delivery — dry cleaning return',
      status: BookingStatus.pending,
      amount: 175.0,
      scheduledAt: DateTime(2026, 4, 15, 15, 45),
      locationName: 'Office tower — Mid Valley',
      address: 'Lingkaran Syed Putra, Mid Valley City, 59200 KL',
    ),
    Booking(
      id: 'as-107',
      customerName: 'Daniel Ong',
      serviceType: 'Pickup — Bulk business laundry (monthly)',
      status: BookingStatus.pending,
      amount: 450.0,
      scheduledAt: DateTime(2026, 4, 18, 8, 30),
      locationName: 'Putrajaya',
      address: 'Block A, Persiaran Perdana, Presint 4, 62000 Putrajaya',
    ),
    Booking(
      id: 'as-108',
      customerName: 'Siti Hajar',
      serviceType: 'Pickup — curtains & bedding',
      status: BookingStatus.pending,
      amount: 210.0,
      scheduledAt: DateTime(2026, 4, 16, 11, 15),
      locationName: 'Subang Jaya',
      address: 'USJ 9/3Q, 47620 Subang Jaya, Selangor',
    ),
    Booking(
      id: 'as-109',
      customerName: 'Rashid Karim',
      serviceType: 'Pickup — Hotel linen batch',
      status: BookingStatus.pending,
      amount: 320.0,
      scheduledAt: DateTime(2026, 4, 16, 19, 0),
      locationName: 'JW Marriot, Bukit Bintang',
      address: 'Jalan Sultan Ismail, 50250 Kuala Lumpur',
    ),
    Booking(
      id: 'as-110',
      customerName: 'Melissa Tan',
      serviceType: 'Delivery — ironed workwear set',
      status: BookingStatus.pending,
      amount: 145.0,
      scheduledAt: DateTime(2026, 4, 17, 10, 15),
      locationName: 'Condo Cyberjaya',
      address: 'Persiaran Multimedia, 63000 Cyberjaya, Selangor',
    ),
    Booking(
      id: 'as-111',
      customerName: 'Hafiz Zain',
      serviceType: 'Pickup — family weekly bundle',
      status: BookingStatus.pending,
      amount: 205.0,
      scheduledAt: DateTime(2026, 4, 17, 17, 20),
      locationName: 'Puchong',
      address: 'Jalan Puteri 5/1, Bandar Puteri, 47100 Puchong',
    ),
    Booking(
      id: 'as-112',
      customerName: 'Marcus Lee',
      serviceType: 'Delivery - Stain treatment + wash (delicate)',
      status: BookingStatus.pending,
      amount: 165.0,
      scheduledAt: DateTime(2026, 4, 20, 10, 0),
      locationName: 'Locker drop-off — Mont Kiara',
      address: '163 Retail Park, Jalan Kiara, Mont Kiara, 50480 KL',
    ),
  ];
}

class BookingServiceException implements Exception {
  BookingServiceException(this.message);
  final String message;

  @override
  String toString() => message;
}
