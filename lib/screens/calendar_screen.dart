import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_application_deux/models/event.dart';
import 'package:flutter_application_deux/services/event_service.dart';
import 'package:flutter_application_deux/services/notification_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final EventService _eventService = EventService();
  Map<DateTime, List<Event>> _eventsByDay = {};
  List<Event> _selectedEvents = [];
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    final events = await _eventService.getEvents();

    // Agrupamos eventos por día para el calendario
    final Map<DateTime, List<Event>> byDay = {};
    for (final event in events) {
      final day = DateTime(event.date.year, event.date.month, event.date.day);
      byDay[day] = [...(byDay[day] ?? []), event];
    }

    setState(() {
      _eventsByDay = byDay;
      _isLoading = false;
      if (_selectedDay != null) {
        _selectedEvents = _getEventsForDay(_selectedDay!);
      }
    });
  }

  List<Event> _getEventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _eventsByDay[key] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendario')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventDialog(context),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar<Event>(
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2030),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: _getEventsForDay,
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      _selectedEvents = _getEventsForDay(selectedDay);
                    });
                  },
                  calendarStyle: const CalendarStyle(
                    markerDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: _selectedEvents.isEmpty
                      ? const Center(
                          child: Text('No hay eventos este día'),
                        )
                      : ListView.builder(
                          itemCount: _selectedEvents.length,
                          itemBuilder: (context, index) {
                            final event = _selectedEvents[index];
                            return ListTile(
                              title: Text(event.title),
                              subtitle: Text(event.description),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () =>
                                        _showEventDialog(context, event: event),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () async {
                                      await _eventService.deleteEvent(event.id);
                                      _loadEvents();
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  void _showEventDialog(BuildContext context, {Event? event}) async {
    final titleController = TextEditingController(text: event?.title ?? '');
    final descController =
        TextEditingController(text: event?.description ?? '');
    DateTime selectedDate = event?.date ?? _selectedDay ?? DateTime.now();
    DateTime? reminder = event?.reminder;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(event == null ? 'Nuevo evento' : 'Editar evento'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(selectedDate),
                      );
                      if (time != null) {
                        setDialogState(() {
                          selectedDate = DateTime(date.year, date.month,
                              date.day, time.hour, time.minute);
                        });
                      }
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.alarm,
                      color: Colors.red),
                  title: Text(reminder != null
                      ? 'Recordatorio: ${reminder!.day}/${reminder!.month} ${reminder!.hour}:${reminder!.minute.toString().padLeft(2, '0')}'
                      : 'Agregar recordatorio'),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setDialogState(() {
                          reminder = DateTime(date.year, date.month, date.day,
                              time.hour, time.minute);
                        });
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty) return;

                bool success;
                if (event == null) {
                  success = await _eventService.createEvent(
                    title: titleController.text,
                    description: descController.text,
                    date: selectedDate,
                    reminder: reminder,
                  );
                } else {
                  success = await _eventService.updateEvent(
                    id: event.id,
                    title: titleController.text,
                    description: descController.text,
                    date: selectedDate,
                    reminder: reminder,
                  );
                }

                // Programar notificación si hay recordatorio
                if (success && reminder != null) {
                  await NotificationService.scheduleReminder(
                    id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                    title: titleController.text,
                    body: descController.text,
                    scheduledDate: reminder!,
                  );
                }

                if (context.mounted) Navigator.pop(context);
                _loadEvents();
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}