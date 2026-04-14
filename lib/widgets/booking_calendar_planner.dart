import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/booking.dart';

class BookingCalendarPlanner extends StatelessWidget {
  const BookingCalendarPlanner({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.bookings,
  });

  final DateTime focusedDay;
  final DateTime selectedDay;
  final void Function(DateTime selected, DateTime focused) onDaySelected;
  final ValueChanged<DateTime> onPageChanged;
  final List<Booking> bookings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return TableCalendar<Booking>(
      firstDay: DateTime(2024),
      lastDay: DateTime(2030, 12, 31),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) => isSameDay(day, selectedDay),
      eventLoader: (day) {
        return bookings.where((b) => isSameDay(b.dateOnly, day)).toList();
      },
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarFormat: CalendarFormat.week,
      availableCalendarFormats: const {CalendarFormat.week: 'Week'},
      onDaySelected: onDaySelected,
      onPageChanged: onPageChanged,
      rowHeight: 44,
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        cellMargin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        weekendTextStyle: TextStyle(color: scheme.onSurfaceVariant),
        defaultTextStyle: const TextStyle(fontWeight: FontWeight.w600),
        selectedDecoration: BoxDecoration(
          color: scheme.primary,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: scheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: scheme.tertiary,
          shape: BoxShape.circle,
        ),
        markersMaxCount: 3,
        markerSize: 4,
        markersAlignment: Alignment.bottomCenter,
      ),
      headerStyle: HeaderStyle(
        headerPadding: const EdgeInsets.symmetric(vertical: 6),
        formatButtonVisible: false,
        titleCentered: false,
        titleTextStyle: theme.textTheme.labelLarge!.copyWith(
          fontWeight: FontWeight.w600,
          color: scheme.onSurfaceVariant,
        ),
        leftChevronIcon: Icon(
          Icons.chevron_left,
          size: 20,
          color: scheme.primary,
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          size: 20,
          color: scheme.primary,
        ),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
        weekendStyle: TextStyle(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
