import "package:flutter/material.dart";
import "../../models/sport_space.dart";
import "../../models/time_slot.dart";
import "../../models/venue.dart";
import "../../services/availability_service.dart";
import "../../utils/date_formatter.dart";
import "../../widgets/accent_choice_chip.dart";
import "slot_grid.dart";
import "slot_summary_bar.dart";
import "confirm_reservation_screen.dart";

class AvailableSlotsScreen extends StatefulWidget {
  final Venue venue;
  final SportSpace space;
  // Courts of the same type in this venue (including `space`).
  final List<SportSpace> courts;

  const AvailableSlotsScreen({
    super.key,
    required this.venue,
    required this.space,
    required this.courts,
  });

  @override
  State<AvailableSlotsScreen> createState() => _AvailableSlotsScreenState();
}

class _AvailableSlotsScreenState extends State<AvailableSlotsScreen> {
  final _service = AvailabilityService();

  late final List<DateTime> _dates;
  late SportSpace _space;
  late DateTime _date;
  int _durationHours = 1;
  TimeSlot? _selectedSlot;
  late Future<List<TimeSlot>> _slotsFuture;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // Today and the next 6 days: the user cannot pick a past date.
    _dates = List.generate(
      7,
      (i) => DateTime(now.year, now.month, now.day + i),
    );
    _space = widget.space;
    _date = _dates.first;
    _slotsFuture = _fetch();
  }

  Future<List<TimeSlot>> _fetch() {
    return _service.getSlots(
      spaceId: _space.id,
      date: _date,
      durationHours: _durationHours,
    );
  }

  // Any filter change: clear the chosen slot and ask for the slots again.
  void _refresh(VoidCallback change) {
    setState(() {
      change();
      _selectedSlot = null;
      _slotsFuture = _fetch();
    });
  }

  Future<void> _onContinue() async {
    final slot = _selectedSlot;
    if (slot == null) return;

    final result = await Navigator.of(context).push<ConfirmResult>(
      MaterialPageRoute(
        builder: (_) => ConfirmReservationScreen(
          venue: widget.venue,
          space: _space,
          slot: slot,
        ),
      ),
    );
    if (!mounted) return;

    if (result == ConfirmResult.booked) {
      Navigator.of(context).pop(true); // keep going back to the tabs
    } else if (result == ConfirmResult.slotTaken) {
      _refresh(() {}); // reload the grid: that slot is now taken
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium;

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.venue.name} · ${_space.displayName}"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Only when there is more than one court of this type.
                if (widget.courts.length > 1) ...[
                  Text("Cancha", style: titleStyle),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final court in widget.courts)
                        AccentChoiceChip(
                          label: "Cancha ${court.number}",
                          selected: court.id == _space.id,
                          onSelected: () => _refresh(() => _space = court),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
                Text("Fecha", style: titleStyle),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final date in _dates)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: AccentChoiceChip(
                            label: formatDayChip(date),
                            selected: date == _date,
                            onSelected: () => _refresh(() => _date = date),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text("Duración", style: titleStyle),
                const SizedBox(height: 8),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 1, label: Text("1 hora")),
                    ButtonSegment(value: 2, label: Text("2 horas")),
                  ],
                  selected: {_durationHours},
                  onSelectionChanged: (values) =>
                      _refresh(() => _durationHours = values.first),
                ),
                const SizedBox(height: 20),
                Text("Horarios", style: titleStyle),
                const SizedBox(height: 8),
                SlotGrid(
                  future: _slotsFuture,
                  selected: _selectedSlot,
                  onSelect: (slot) => setState(() => _selectedSlot = slot),
                  onRetry: () => _refresh(() {}),
                ),
              ],
            ),
          ),
          SlotSummaryBar(
            space: _space,
            slot: _selectedSlot,
            durationHours: _durationHours,
            onContinue: _onContinue,
          ),
        ],
      ),
    );
  }
}