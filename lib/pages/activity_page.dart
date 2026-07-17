import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:gard/services/notification_service.dart';
import 'package:gard/services/google_calendar_service.dart';
import 'package:gard/services/agent_service.dart';
import 'package:gard/services/supabase_service.dart';
import 'package:gard/services/health_connect_service.dart';
import 'package:gard/constants/app_colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  bool _isCalendarSignedIn = false;
  bool _isLoadingEvents = false;
  bool _isCheckingSignIn = true;
  bool _showAllEvents = false; // For limiting event list to 4

  List<CalendarEvent> _eventsForSelectedDay = [];
  Map<DateTime, List<CalendarEvent>> _allEventsCache = {};

  final _calService = GoogleCalendarService.instance;

  // AI Schedule state
  String? _aiScheduleResult;
  bool _isGeneratingSchedule = false;
  List<Map<String, dynamic>> _aiMealEvents = [];
  int? _expandedMealIndex;

  final List<Map<String, String>> _staticMeals = [
    {
      'summary': 'Sarapan Pagi',
      'time': '07:30',
      'description': 'Konsumsi oatmeal hangat, pisang, atau bubur ayam tanpa santan. Hindari kopi, susu tinggi lemak, dan buah asam untuk menjaga lambung tetap nyaman.',
    },
    {
      'summary': 'Makan Siang',
      'time': '12:30',
      'description': 'Konsumsi nasi tim ayam, sup sayur bening, dan tahu kukus. Hindari gorengan pedas dan minuman bersoda agar tidak memicu kembung.',
    },
    {
      'summary': 'Makan Malam',
      'time': '19:00',
      'description': 'Konsumsi kentang tumbuk atau ikan panggang. Pastikan makan 3 jam sebelum tidur dan hindari makanan porsi besar agar asam lambung tidak naik malam hari.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _initCalendar();
  }

  Future<void> _initCalendar() async {
    setState(() => _isCheckingSignIn = true);
    // Try to get a token — checks live session AND SharedPreferences fallback
    final token = await _calService.getStoredToken();
    final hasAccess = token != null && token.isNotEmpty;
    setState(() {
      _isCalendarSignedIn = hasAccess;
      _isCheckingSignIn = false;
    });
    if (hasAccess) {
      await _loadMonthEvents(_focusedDay);
      await _loadEventsForDay(_selectedDay!);
    }
    await _loadAiMealEvents(_selectedDay ?? _focusedDay);
  }

  Future<void> _loadAiMealEvents(DateTime day) async {
    final dateStr = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    final prefs = await SharedPreferences.getInstance();
    
    // Reset status ekspansi
    _expandedMealIndex = null;

    final jsonStr = prefs.getString('ai_schedule_full_$dateStr');
    if (jsonStr != null) {
      try {
        final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
        final events = decoded['events'] as List<dynamic>;
        final aiMessage = decoded['ai_message'] as String?;
        if (mounted) {
          setState(() {
            _aiMealEvents = events.map((e) => Map<String, dynamic>.from(e)).toList();
            _aiScheduleResult = aiMessage;
          });
        }
      } catch (e) {
        debugPrint('Error decoding saved AI schedule: $e');
        if (mounted) {
          setState(() {
            _aiMealEvents = [];
            _aiScheduleResult = null;
          });
        }
      }
    } else {
      // Fallback ke legacy key
      final legacyJsonStr = prefs.getString('ai_schedule_$dateStr');
      if (legacyJsonStr != null) {
        try {
          final decoded = jsonDecode(legacyJsonStr) as List<dynamic>;
          if (mounted) {
            setState(() {
              _aiMealEvents = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
              _aiScheduleResult = null;
            });
          }
        } catch (_) {}
      } else {
        if (mounted) {
          setState(() {
            _aiMealEvents = [];
            _aiScheduleResult = null;
          });
        }
      }
    }
  }

  // No separate connect needed — Calendar is auto-connected via Supabase Google token.
  // This is kept as a manual refresh trigger if token seems stale.
  Future<void> _retryCalendarAccess() async {
    setState(() => _isCheckingSignIn = true);
    await Future.delayed(const Duration(milliseconds: 300));
    final hasAccess = _calService.isSignedIn;
    setState(() {
      _isCalendarSignedIn = hasAccess;
      _isCheckingSignIn = false;
    });
    if (hasAccess) {
      await _loadMonthEvents(_focusedDay);
      await _loadEventsForDay(_selectedDay!);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Akses Calendar belum tersedia. Coba logout & login ulang untuk authorize ulang.'),
            backgroundColor: AppColors.warning,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _loadMonthEvents(DateTime month) async {
    try {
      final events = await _calService.getEventsForMonth(month);
      final Map<DateTime, List<CalendarEvent>> grouped = {};
      for (final event in events) {
        final key = DateTime(
            event.startTime.year, event.startTime.month, event.startTime.day);
        grouped[key] = [...(grouped[key] ?? []), event];
      }
      if (mounted) {
        setState(() => _allEventsCache = grouped);
      }
    } catch (e) {
      if (e.toString().contains('auth_error')) {
        _handleAuthError();
      }
    }
  }

  Future<void> _loadEventsForDay(DateTime day) async {
    if (!mounted) return;
    setState(() => _isLoadingEvents = true);
    
    try {
      final events = await _calService.getEventsForDay(day);
      if (mounted) {
        setState(() {
          _eventsForSelectedDay = events;
          _isLoadingEvents = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingEvents = false);
      }
      if (e.toString().contains('auth_error')) {
        _handleAuthError();
      }
    }
  }

  void _handleAuthError() {
    if (!mounted) return;
    setState(() {
      _isCalendarSignedIn = false;
      _allEventsCache = {};
      _eventsForSelectedDay = [];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Sesi Google Calendar kadaluarsa atau belum diizinkan. Silakan Logout dan Login ulang.'),
        backgroundColor: AppColors.error,
        duration: Duration(seconds: 5),
      ),
    );
  }

  /// Generate AI meal schedule recommendation for the selected day
  Future<void> _generateAiSchedule() async {
    if (_isGeneratingSchedule) return;
    setState(() {
      _isGeneratingSchedule = true;
      _aiScheduleResult = null;
    });

    try {
      // Collect context
      final profile = await SupabaseService.instance.getProfileData();
      Map<String, dynamic>? healthSummary;
      try {
        final healthService = HealthService();
        await healthService.init();
        if (await healthService.hasPermissions()) {
          healthSummary = await healthService.getTodaySummary();
        }
      } catch (_) {}

      // Build existing events from Google Calendar as context
      final targetDate = _selectedDay ?? _focusedDay;
      final existingEvents = _eventsForSelectedDay.map((e) => {
        'title': e.title,
        'start_time':
            '${e.startTime.hour.toString().padLeft(2, '0')}:${e.startTime.minute.toString().padLeft(2, '0')}',
        'end_time':
            '${e.endTime.hour.toString().padLeft(2, '0')}:${e.endTime.minute.toString().padLeft(2, '0')}',
      }).toList();

      // Get userId from Supabase auth
      final user = await SupabaseService.instance.getProfileData();
      final userId = user?['email'] ?? 'anonymous';

      final result = await AgentService.instance.generateSchedule(
        userId: userId,
        date: targetDate,
        healthSummary: healthSummary,
        profileData: profile,
        existingEvents: existingEvents,
      );

      if (result.success && result.events.isNotEmpty) {
        final dateStr = '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';
        final prefs = await SharedPreferences.getInstance();
        
        final Map<String, dynamic> fullData = {
          'events': result.events,
          'ai_message': result.scheduleText,
        };
        await prefs.setString('ai_schedule_full_$dateStr', jsonEncode(fullData));
        await prefs.setString('ai_schedule_$dateStr', jsonEncode(result.events));
        
        // ── 1. Tambahkan ke Google Calendar jika terhubung ──
        if (_isCalendarSignedIn) {
          for (final event in result.events) {
            try {
              final start = DateTime.parse(event['start_time']).toLocal();
              final end = DateTime.parse(event['end_time']).toLocal();
              await _calService.createEvent(
                title: event['summary'] ?? 'Jadwal Makan AI',
                description: event['description'],
                startTime: start,
                endTime: end,
              );
            } catch (calErr) {
              debugPrint('Error creating calendar event for AI schedule: $calErr');
            }
          }
          // Reload events to show circles on table calendar
          await _loadMonthEvents(_focusedDay);
          await _loadEventsForDay(_selectedDay!);
        }

        // ── 2. Jadwalkan Notifikasi Lokal ──
        for (final event in result.events) {
          try {
            final start = DateTime.parse(event['start_time']).toLocal();
            // Hanya jadwalkan jika waktu mulai belum lewat
            if (start.isAfter(DateTime.now())) {
              await NotificationService.scheduleEatingReminderAt(
                title: 'GARD: ${event['summary']} 🥣',
                body: event['description'] ?? 'Waktunya makan rekomendasi AI.',
                scheduledTime: start,
              );
            }
          } catch (notifErr) {
            debugPrint('Error scheduling notification for AI schedule: $notifErr');
          }
        }
      }

      if (mounted) {
        setState(() {
          _aiScheduleResult = result.scheduleText;
          _isGeneratingSchedule = false;
        });
        await _loadAiMealEvents(targetDate);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _aiScheduleResult = '⚠️ Gagal membuat jadwal: $e';
          _isGeneratingSchedule = false;
        });
      }
    }
  }

  List<CalendarEvent> _getEventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _allEventsCache[key] ?? [];
  }

  void _showEventForm({CalendarEvent? event}) {
    final titleCtrl = TextEditingController(text: event?.title ?? '');
    final descCtrl = TextEditingController(text: event?.description ?? '');

    DateTime startTime = event?.startTime ??
        DateTime(
          _selectedDay!.year,
          _selectedDay!.month,
          _selectedDay!.day,
          DateTime.now().hour,
          0,
        );
    DateTime endTime = event?.endTime ??
        startTime.add(const Duration(hours: 1));

    final isEditing = event != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Text(
                      isEditing ? 'Edit Aktivitas' : 'Tambah Aktivitas',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkAccent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Event akan disinkronkan ke Google Calendar Anda',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    TextField(
                      controller: titleCtrl,
                      autofocus: true,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Judul Aktivitas',
                        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        prefixIcon: const Icon(Icons.title_rounded, color: AppColors.primary, size: 20),
                        filled: true,
                        fillColor: AppColors.background.withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.softAccent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Description
                    TextField(
                      controller: descCtrl,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Deskripsi (opsional)',
                        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        prefixIcon: const Icon(Icons.notes_rounded, color: AppColors.primary, size: 20),
                        filled: true,
                        fillColor: AppColors.background.withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.softAccent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Start & End Time
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimePicker(
                            label: 'Mulai',
                            time: startTime,
                            icon: Icons.schedule_rounded,
                            onChanged: (picked) {
                              setModalState(() {
                                startTime = DateTime(
                                  startTime.year, startTime.month, startTime.day,
                                  picked.hour, picked.minute,
                                );
                                if (endTime.isBefore(startTime)) {
                                  endTime = startTime.add(const Duration(hours: 1));
                                }
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTimePicker(
                            label: 'Selesai',
                            time: endTime,
                            icon: Icons.schedule_outlined,
                            onChanged: (picked) {
                              setModalState(() {
                                endTime = DateTime(
                                  endTime.year, endTime.month, endTime.day,
                                  picked.hour, picked.minute,
                                );
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () async {
                          final title = titleCtrl.text.trim();
                          if (title.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Judul aktivitas tidak boleh kosong')),
                            );
                            return;
                          }
                          Navigator.pop(ctx);

                          if (isEditing) {
                            await _updateEvent(
                              eventId: event!.id,
                              title: title,
                              description: descCtrl.text.trim(),
                              startTime: startTime,
                              endTime: endTime,
                            );
                          } else {
                            await _createEvent(
                              title: title,
                              description: descCtrl.text.trim(),
                              startTime: startTime,
                              endTime: endTime,
                            );
                          }
                        },
                        child: Text(
                          isEditing ? 'Simpan Perubahan' : 'Tambah ke Kalender',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTimePicker({
    required String label,
    required DateTime time,
    required IconData icon,
    required Function(TimeOfDay) onChanged,
  }) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(time),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: AppColors.primary),
            ),
            child: child!,
          ),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background.withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.softAccent),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                Text(
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createEvent({
    required String title,
    String? description,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final created = await _calService.createEvent(
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
      );
      if (created != null) {
        _showSuccessSnack('Aktivitas berhasil ditambahkan ke Google Calendar!');
        await _loadMonthEvents(_focusedDay);
        await _loadEventsForDay(_selectedDay!);
      }
    } catch (e) {
      _showErrorSnack(e.toString());
    }
  }

  Future<void> _updateEvent({
    required String eventId,
    required String title,
    String? description,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final updated = await _calService.updateEvent(
      eventId: eventId,
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
    );
    if (updated != null) {
      _showSuccessSnack('Aktivitas berhasil diperbarui!');
      await _loadMonthEvents(_focusedDay);
      await _loadEventsForDay(_selectedDay!);
    } else {
      _showErrorSnack('Gagal memperbarui aktivitas. Coba lagi.');
    }
  }

  Future<void> _confirmDeleteEvent(CalendarEvent event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Aktivitas?',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkAccent)),
        content: Text(
          'Aktivitas "${event.title}" akan dihapus dari Google Calendar Anda.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final success = await _calService.deleteEvent(event.id);
      if (success) {
        _showSuccessSnack('Aktivitas berhasil dihapus');
        await _loadMonthEvents(_focusedDay);
        await _loadEventsForDay(_selectedDay!);
      } else {
        _showErrorSnack('Gagal menghapus aktivitas');
      }
    }
  }

  void _showRawApiDebug() async {
    try {
      final token = await _calService.getStoredToken();
      if (token == null) {
        _showErrorSnack('No token');
        return;
      }
      final day = _selectedDay ?? _focusedDay;
      final timeMin = DateTime(day.year, day.month, day.day).toUtc().toIso8601String();
      final timeMax = DateTime(day.year, day.month, day.day, 23, 59, 59).toUtc().toIso8601String();
      
      final uri = Uri.parse(
        'https://www.googleapis.com/calendar/v3/calendars/primary/events'
        '?timeMin=${Uri.encodeComponent(timeMin)}'
        '&timeMax=${Uri.encodeComponent(timeMax)}'
        '&singleEvents=true'
      );
      
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Raw API Status: ${response.statusCode}'),
            content: SingleChildScrollView(
              child: Text(response.body),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup'))
            ],
          )
        );
      }
    } catch (e) {
      _showErrorSnack(e.toString());
    }
  }

  void _showSuccessSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(msg)),
      ]),
      backgroundColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _showErrorSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: null,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Aktivitas & Jadwal',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sinkronisasi aktivitas dengan Google Calendar',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Google Calendar Banner / Connected badge ─────────────
                  if (_isCheckingSignIn)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    )
                  else if (!_isCalendarSignedIn)
                    _buildConnectBanner()
                  else
                    _buildConnectedBadge(),

                  const SizedBox(height: 16),

                  // ── Calendar Widget ──────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.darkAccent.withOpacity(0.03),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TableCalendar<CalendarEvent>(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      eventLoader: _isCalendarSignedIn ? _getEventsForDay : null,
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                          _showAllEvents = false; // Reset when changing days
                        });
                        if (_isCalendarSignedIn) {
                          _loadEventsForDay(selectedDay);
                        }
                        _loadAiMealEvents(selectedDay);
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                        if (_isCalendarSignedIn) {
                          _loadMonthEvents(focusedDay);
                        }
                      },
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, day, events) {
                          if (events.isEmpty) return const SizedBox.shrink();
                          return Positioned(
                            bottom: 2,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: events
                                  .take(3)
                                  .map((_) => Container(
                                        width: 5,
                                        height: 5,
                                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ))
                                  .toList(),
                            ),
                          );
                        },
                      ),
                      calendarStyle: CalendarStyle(
                        cellMargin: const EdgeInsets.all(8),
                        todayDecoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        todayTextStyle: const TextStyle(
                            color: AppColors.primary, fontWeight: FontWeight.bold),
                        selectedDecoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        selectedTextStyle: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        outsideDaysVisible: true,
                        outsideTextStyle: const TextStyle(color: Colors.black12),
                        defaultTextStyle: const TextStyle(color: Colors.black87),
                        weekendTextStyle: const TextStyle(color: Colors.black87),
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle:
                            TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        headerPadding: EdgeInsets.symmetric(vertical: 16),
                        leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.primary),
                        rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.primary),
                      ),
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        weekdayStyle: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                        weekendStyle: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Pengingat Harian Statis + AI ──────────────────────────
                  Row(
                    children: [
                      Container(
                        width: 3,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'PENGINGAT MAKAN HARIAN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Spacer(),
                      // Tombol generate AI schedule
                      GestureDetector(
                        onTap: _generateAiSchedule,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.midTeal,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isGeneratingSchedule)
                                const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              else
                                Image.asset(
                                  'assets/images/logo_icon.png',
                                  width: 12,
                                  height: 12,
                                  color: Colors.white,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              const SizedBox(width: 5),
                              Text(
                                _isGeneratingSchedule
                                    ? 'Membuat...'
                                    : 'Jadwal AI',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Tampilkan hasil AI Schedule jika ada
                  if (_aiScheduleResult != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Image.asset(
                                  'assets/images/logo_icon.png',
                                  width: 14,
                                  height: 14,
                                  color: Colors.white,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Rekomendasi Jadwal Makan AI',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _aiScheduleResult = null),
                                child: const Icon(Icons.close_rounded,
                                    size: 16, color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _aiScheduleResult!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Render AI meal cards if available, otherwise fallback to static cards
                  if (_aiMealEvents.isNotEmpty)
                    ..._aiMealEvents.asMap().entries.map((entry) {
                      final index = entry.key;
                      final event = entry.value;

                      final summary = event['summary'] ?? 'Jadwal Makan AI';
                      final startTimeStr = event['start_time'] ?? '';
                      String formattedTime = '00:00';
                      if (startTimeStr.isNotEmpty) {
                        try {
                          final dt = DateTime.parse(startTimeStr).toLocal();
                          formattedTime =
                              '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                        } catch (_) {}
                      }
                      final description = event['description'] ?? 'Rekomendasi diet aman lambung.';
                      final bool isExpanded = _expandedMealIndex == index;

                      return _buildActivityCard(
                        summary,
                        formattedTime,
                        Icons.auto_awesome_rounded,
                        AppColors.primary,
                        AppColors.softAccent,
                        () {
                          // Tap right icon -> toggle expansion
                          setState(() {
                            _expandedMealIndex = isExpanded ? null : index;
                          });
                        },
                        subtitle: description,
                        rightIcon: isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        isExpanded: isExpanded,
                        onCardTap: () {
                          // Tap whole card -> toggle expansion
                          setState(() {
                            _expandedMealIndex = isExpanded ? null : index;
                          });
                        },
                        imageAsset: 'assets/images/logo_icon.png',
                      );
                    }).toList()
                  else ...[
                    ..._staticMeals.asMap().entries.map((entry) {
                      final index = entry.key;
                      final meal = entry.value;
                      final bool isExpanded = _expandedMealIndex == index;

                      IconData icon;
                      if (index == 0) {
                        icon = Icons.wb_sunny_outlined;
                      } else if (index == 1) {
                        icon = Icons.restaurant_rounded;
                      } else {
                        icon = Icons.nightlight_round_rounded;
                      }

                      return _buildActivityCard(
                        meal['summary']!,
                        meal['time']!,
                        icon,
                        AppColors.primary,
                        AppColors.softAccent,
                        () {
                          // Tap play button -> schedule reminder
                          final titleStr = 'Waktunya ${meal['summary']}! 🥣';
                          final bodyStr = 'Jangan lupa ${meal['summary']} tepat waktu untuk menjaga lambungmu.';
                          NotificationService.scheduleEatingReminder(
                            title: titleStr,
                            body: bodyStr,
                            secondsDelay: 6,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pengingat makan berhasil dijadwalkan!'),
                              backgroundColor: AppColors.success,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        subtitle: meal['description'],
                        rightIcon: isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        isExpanded: isExpanded,
                        onCardTap: () {
                          // Tap whole card -> toggle expansion
                          setState(() {
                            _expandedMealIndex = isExpanded ? null : index;
                          });
                        },
                        imageAsset: 'assets/images/logo_icon.png',
                      );
                    }).toList()
                  ],

                  const SizedBox(height: 28),

                  // ── Google Calendar Events for Selected Day ──────────────
                  if (_isCalendarSignedIn) ...[
                    Row(
                      children: [
                        Container(
                          width: 3,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'AKTIVITAS GOOGLE CALENDAR',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const Spacer(),
                        if (_isLoadingEvents)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (!_isLoadingEvents && _eventsForSelectedDay.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.softAccent),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.event_available_rounded,
                                size: 36, color: AppColors.primary.withOpacity(0.4)),
                            const SizedBox(height: 10),
                            const Text(
                              'Tidak ada aktivitas di hari ini',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Tap "Tambah Aktivitas" untuk menambahkan',
                              style: TextStyle(
                                  color: AppColors.textHint, fontSize: 11),
                            ),
                          ],
                        ),
                      )
                    else
                      ...(_showAllEvents
                              ? _eventsForSelectedDay
                              : _eventsForSelectedDay.take(4))
                          .map((event) => _buildCalendarEventCard(event)),
                      
                    if (!_isLoadingEvents && _eventsForSelectedDay.length > 4)
                      Center(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _showAllEvents = !_showAllEvents;
                            });
                          },
                          child: Text(
                            _showAllEvents ? 'Tampilkan Lebih Sedikit' : 'Tampilkan Lebih Banyak',
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    const SizedBox(height: 28),
                  ],

                  // ── Tambah Aktivitas Button ──────────────────────────────
                  if (_isCalendarSignedIn) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showEventForm(),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text(
                          'Tambah Aktivitas Baru',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 100), // padding untuk navigation bar
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── UI Widgets ─────────────────────────────────────────────────────────────

  Widget _buildConnectBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.warning.withOpacity(0.08),
            AppColors.warning.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.08), blurRadius: 8),
                  ],
                ),
                child: const Icon(Icons.calendar_month_rounded,
                    color: AppColors.warning, size: 24),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Google Calendar Belum Aktif',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.darkAccent,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Logout & login ulang dengan akun Google Anda untuk mengaktifkan akses Calendar.',
                      style:
                          TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: _retryCalendarAccess,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF34A853).withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF34A853).withOpacity(0.25)),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_rounded, color: Color(0xFF34A853), size: 18),
          SizedBox(width: 8),
          Text(
            'Google Calendar terhubung otomatis',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D32),
            ),
          ),
          Spacer(),
          Icon(Icons.sync_rounded, color: Color(0xFF34A853), size: 16),
        ],
      ),
    );
  }

  Widget _buildCalendarEventCard(CalendarEvent event) {
    final startHour = '${event.startTime.hour.toString().padLeft(2, '0')}:${event.startTime.minute.toString().padLeft(2, '0')}';
    final endHour = '${event.endTime.hour.toString().padLeft(2, '0')}:${event.endTime.minute.toString().padLeft(2, '0')}';

    return Dismissible(
      key: Key(event.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 26),
      ),
      confirmDismiss: (_) async {
        await _confirmDeleteEvent(event);
        return false; // We handle refresh ourselves
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '$startHour – $endHour',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  if (event.description != null && event.description!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      event.description!,
                      style: const TextStyle(
                        color: AppColors.textHint,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Edit button
            IconButton(
              onPressed: () => _showEventForm(event: event),
              icon: const Icon(Icons.edit_rounded, size: 18, color: AppColors.primary),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            // Delete button
            IconButton(
              onPressed: () => _confirmDeleteEvent(event),
              icon: const Icon(Icons.delete_outline_rounded,
                  size: 18, color: AppColors.error),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(String title, String time, IconData icon,
      Color accentColor, Color tintColor, VoidCallback onTap,
      {String? subtitle,
      IconData rightIcon = Icons.play_circle_fill_rounded,
      bool isExpanded = false,
      VoidCallback? onCardTap,
      String? imageAsset}) {
    final cardContent = Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: tintColor,
                  shape: BoxShape.circle,
                ),
                child: imageAsset != null
                    ? Image.asset(
                        imageAsset,
                        width: 22,
                        height: 22,
                        color: accentColor,
                        errorBuilder: (_, __, ___) =>
                            Icon(icon, color: accentColor, size: 22),
                      )
                    : Icon(icon, color: accentColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      time,
                      style: const TextStyle(
                        color: Colors.black38,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onTap,
                icon: Icon(rightIcon, color: accentColor, size: 28),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          if (isExpanded && subtitle != null && subtitle.isNotEmpty) ...[
            const Divider(height: 20),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (onCardTap != null) {
      return GestureDetector(
        onTap: onCardTap,
        child: cardContent,
      );
    }
    return cardContent;
  }
}
