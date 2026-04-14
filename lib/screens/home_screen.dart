import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/booking.dart';
import '../services/booking_service.dart';
import '../widgets/booking_calendar_planner.dart';
import '../widgets/booking_card.dart';
import 'booking_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BookingService _service = BookingService();

  List<Booking> _bookings = [];
  bool _loading = true;
  String? _errorMessage;
  String? _updatingId;

  int _navIndex = 0;

  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _focusedDay = today;
    _selectedDay = today;
    _loadBookings();
  }

  void _syncCalendarToBookings() {
    if (_bookings.isEmpty) return;
    final selectedHasBookings = _bookings.any(
      (b) => isSameDay(b.dateOnly, _selectedDay),
    );
    if (selectedHasBookings) {
      _focusedDay = _selectedDay;
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayHasBookings = _bookings.any((b) => isSameDay(b.dateOnly, today));
    if (todayHasBookings) {
      _selectedDay = today;
      _focusedDay = today;
      return;
    }

    final first = _bookings
        .map((b) => b.dateOnly)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    _selectedDay = first;
    _focusedDay = first;
  }

  Future<void> _loadBookings() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final data = await _service.fetchBookings();
      if (!mounted) return;
      setState(() {
        _bookings = data;
        _loading = false;
        _syncCalendarToBookings();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _markCompleted(String id) async {
    setState(() => _updatingId = id);
    try {
      await _service.markCompleted(id);
      if (!mounted) return;
      setState(() {
        _bookings = _service.bookings;
        _updatingId = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _updatingId = null);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  bool _canMarkCompleted(Booking booking) {
    if (booking.status == BookingStatus.completed) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return !booking.dateOnly.isAfter(today);
  }

  Future<void> _markCompletedWithConfirmation(Booking booking) async {
    if (!_canMarkCompleted(booking)) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Mark order as completed?'),
          content: Text('This will mark ${booking.customerName} as completed.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _markCompleted(booking.id);
    }
  }

  List<Booking> get _sortedBookings {
    final list = List<Booking>.from(_bookings);
    list.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return list;
  }

  List<Booking> get _bookingsForSelectedDay {
    return _sortedBookings
        .where((b) => isSameDay(b.dateOnly, _selectedDay))
        .toList();
  }

  List<Booking> get _todayBookings {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _sortedBookings
        .where(
          (b) =>
              b.status == BookingStatus.pending && isSameDay(b.dateOnly, today),
        )
        .toList();
  }

  List<Booking> get _upcomingBookings {
    final now = DateTime.now();
    final startToday = DateTime(now.year, now.month, now.day);
    return _sortedBookings
        .where(
          (b) =>
              b.status == BookingStatus.pending &&
              b.dateOnly.isAfter(startToday),
        )
        .toList();
  }

  List<Booking> get _completedBookings {
    return _sortedBookings
        .where((b) => b.status == BookingStatus.completed)
        .toList();
  }

  void _openDetail(Booking booking) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => BookingDetailScreen(booking: booking),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('AeroSparkle - Booking Management System'),
            Text(
              'Bookings & Schedule',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Force next load to fail (demo)',
            onPressed: () {
              setState(() => _service.failNextFetch = true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Next refresh will simulate a failed request.'),
                ),
              );
            },
            icon: const Icon(Icons.bug_report_outlined),
          ),
          IconButton(
            tooltip: 'Toggle random fetch failures',
            onPressed: () {
              setState(() {
                _service.randomFailuresEnabled =
                    !_service.randomFailuresEnabled;
              });
              final on = _service.randomFailuresEnabled;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    on
                        ? 'Random failures enabled (~20% per fetch).'
                        : 'Random failures disabled.',
                  ),
                ),
              );
            },
            icon: Icon(
              _service.randomFailuresEnabled ? Icons.shuffle_on : Icons.shuffle,
            ),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _loadBookings,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final offset = Tween<Offset>(
            begin: const Offset(0.03, 0),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: offset, child: child),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<String>(
            'tab-$_navIndex-loading-$_loading-error-${_errorMessage != null}',
          ),
          child: _buildBody(),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) {
          setState(() {
            _navIndex = i;
            if (i == 0) {
              final now = DateTime.now();
              _selectedDay = DateTime(now.year, now.month, now.day);
              _focusedDay = _selectedDay;
            }
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Planner',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_laundry_service_outlined),
            selectedIcon: Icon(Icons.local_laundry_service),
            label: 'All Bookings',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading your schedule...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _loadBookings,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_navIndex == 0) {
      return _buildPlannerTab();
    }
    return _buildAllBookingsTab();
  }

  Widget _buildPlannerTab() {
    final theme = Theme.of(context);
    final dayLabel = DateFormat.yMMMMEEEEd().format(_selectedDay);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedStatusLabel =
        isSameDay(_selectedDay, today)
            ? 'Today'
            : _selectedDay.isAfter(today)
            ? 'Upcoming'
            : 'Past';

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: BookingCalendarPlanner(
                    focusedDay: _focusedDay,
                    selectedDay: _selectedDay,
                    bookings: _bookings,
                    onDaySelected: (selected, focused) {
                      setState(() {
                        _selectedDay = selected;
                        _focusedDay = focused;
                      });
                    },
                    onPageChanged: (focused) {
                      setState(() => _focusedDay = focused);
                    },
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: Row(
                children: [
                  _SectionTag(label: selectedStatusLabel),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      dayLabel,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${_bookingsForSelectedDay.length} Booking(s)',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_bookingsForSelectedDay.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.event_busy_outlined,
                        size: 52,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No pickup or delivery bookings for this day.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Select another date in the planner.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final booking = _bookingsForSelectedDay[index];
                  return BookingCard(
                    booking: booking,
                    canMarkCompleted: _canMarkCompleted(booking),
                    isUpdating: _updatingId == booking.id,
                    onMarkCompleted:
                        () => _markCompletedWithConfirmation(booking),
                    onOpenDetail: () => _openDetail(booking),
                  );
                }, childCount: _bookingsForSelectedDay.length),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAllBookingsTab() {
    if (_bookings.isEmpty) {
      return const Center(child: Text('No Bookings yet.'));
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _buildSection('Today', _todayBookings),
          _buildSection('Upcoming', _upcomingBookings),
          _buildSection('Completed', _completedBookings),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Booking> bookings) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Row(
            children: [
              _SectionTag(label: title),
              const SizedBox(width: 8),
              Text(
                '${bookings.length} Booking(s)',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (bookings.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'No bookings in this section.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          ...bookings.map(
            (booking) => BookingCard(
              booking: booking,
              canMarkCompleted: _canMarkCompleted(booking),
              isUpdating: _updatingId == booking.id,
              onMarkCompleted: () => _markCompletedWithConfirmation(booking),
              onOpenDetail: () => _openDetail(booking),
            ),
          ),
      ],
    );
  }
}

class _SectionTag extends StatelessWidget {
  const _SectionTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
