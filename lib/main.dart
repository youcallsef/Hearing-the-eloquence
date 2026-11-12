// Package Name: com.nasaesa.space
// Project: Cosmic Radio Array - Global Deep Space Monitoring Dashboard
// Architecture: Two-Tier Simulated Live Telemetry & Audio Stream Client

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CosmicSpaceApp());
}

class CosmicSpaceApp extends StatelessWidget {
  const CosmicSpaceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cosmic Radio Array [com.nasaesa.space]',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF04060A),
        primaryColor: Colors.cyanAccent,
        fontFamily: 'monospace',
        colorScheme: const ColorScheme.dark(
          primary: Colors.cyanAccent,
          secondary: Colors.greenAccent,
          surface: Color(0xFF0D111A),
          background: Color(0xFF04060A),
          error: Colors.redAccent,
        ),
      ),
      home: const CosmicMainDashboard(),
    );
  }
}

// ==========================================
// 1. DATA MODELS & TELEMETRY DEFINITIONS
// ==========================================

enum SpaceAgency { nasa, esa, globalArrays, websdr }

class RadioDishModel {
  final String id;
  final String name;
  final SpaceAgency agency;
  final String location;
  final String target;
  final double frequencyMHz;
  final double signalStrengthDbm;
  final double azimuth;
  final double elevation;
  final bool isLive;
  final String streamUrl;
  final List<String> telemetryLogs;

  RadioDishModel({
    required this.id,
    required this.name,
    required this.agency,
    required this.location,
    required this.target,
    required this.frequencyMHz,
    required this.signalStrengthDbm,
    required this.azimuth,
    required this.elevation,
    required this.isLive,
    required this.streamUrl,
    required this.telemetryLogs,
  });

  RadioDishModel copyWith({
    double? frequencyMHz,
    double? signalStrengthDbm,
    double? azimuth,
    double? elevation,
    bool? isLive,
    List<String>? telemetryLogs,
  }) {
    return RadioDishModel(
      id: id,
      name: name,
      agency: agency,
      location: location,
      target: target,
      frequencyMHz: frequencyMHz ?? this.frequencyMHz,
      signalStrengthDbm: signalStrengthDbm ?? this.signalStrengthDbm,
      azimuth: azimuth ?? this.azimuth,
      elevation: elevation ?? this.elevation,
      isLive: isLive ?? this.isLive,
      streamUrl: streamUrl,
      telemetryLogs: telemetryLogs ?? this.telemetryLogs,
    );
  }
}

// ==========================================
// 2. MOCK DATA REPOSITORY & LIVE SIMULATOR
// ==========================================

class CosmicDataRepository {
  static List<RadioDishModel> getInitialDishes() {
    return [
      // NASA DSN
      RadioDishModel(
        id: 'nasa-dsn-13',
        name: 'DSS-13 Goldstone',
        agency: SpaceAgency.nasa,
        location: 'California, USA',
        target: 'Voyager 1 (Interstellar)',
        frequencyMHz: 8420.5,
        signalStrengthDbm: -142.3,
        azimuth: 184.5,
        elevation: 42.1,
        isLive: true,
        streamUrl: 'https://stream.snot.space/nasa/dss13',
        telemetryLogs: ['[19:22:01] CARRIER LOCK ACQUIRED', '[19:22:10] DOWNLINK STABLE X-BAND'],
      ),
      RadioDishModel(
        id: 'nasa-dsn-34',
        name: 'DSS-34 Canberra',
        agency: SpaceAgency.nasa,
        location: 'Tidbinbilla, Australia',
        target: 'James Webb Space Telescope',
        frequencyMHz: 2285.2,
        signalStrengthDbm: -118.7,
        azimuth: 92.1,
        elevation: 68.4,
        isLive: true,
        streamUrl: 'https://stream.snot.space/nasa/dss34',
        telemetryLogs: ['[19:21:45] S-BAND TELEMETRY NOMINAL', '[19:22:05] PHASE SHIFT DETECTED'],
      ),
      RadioDishModel(
        id: 'nasa-dsn-54',
        name: 'DSS-54 Madrid',
        agency: SpaceAgency.nasa,
        location: 'Robledo, Spain',
        target: 'Perseverance Rover (Mars)',
        frequencyMHz: 7150.0,
        signalStrengthDbm: -126.1,
        azimuth: 245.8,
        elevation: 31.0,
        isLive: true,
        streamUrl: 'https://stream.snot.space/nasa/dss54',
        telemetryLogs: ['[19:20:12] UHF RELAY ACTIVE', '[19:21:55] MARS RECONNAISSANCE LINK OK'],
      ),
      RadioDishModel(
        id: 'nasa-dsn-14',
        name: 'DSS-14 Mars Antenna',
        agency: SpaceAgency.nasa,
        location: 'California, USA',
        target: 'Pioneer 10',
        frequencyMHz: 2110.4,
        signalStrengthDbm: -155.0,
        azimuth: 110.2,
        elevation: 15.3,
        isLive: false,
        streamUrl: 'https://stream.snot.space/nasa/dss14',
        telemetryLogs: ['[18:40:00] SIGNAL LOSS - BELOW THRESHOLD'],
      ),

      // ESA ESTRACK
      RadioDishModel(
        id: 'esa-cebreros',
        name: 'DSA 1 Cebreros',
        agency: SpaceAgency.esa,
        location: 'Ávila, Spain',
        target: 'Juice (Jupiter Icy Moons)',
        frequencyMHz: 8432.1,
        signalStrengthDbm: -131.5,
        azimuth: 167.4,
        elevation: 50.8,
        isLive: true,
        streamUrl: 'https://stream.snot.space/esa/cebreros',
        telemetryLogs: ['[19:21:30] KA-BAND DOWNLINK LOCKED', '[19:22:00] SPECTRAL DENSITY STABLE'],
      ),
      RadioDishModel(
        id: 'esa-malargue',
        name: 'DSA 2 Malargüe',
        agency: SpaceAgency.esa,
        location: 'Mendoza, Argentina',
        target: 'Euclid Space Telescope',
        frequencyMHz: 3520.8,
        signalStrengthDbm: -122.4,
        azimuth: 312.0,
        elevation: 72.5,
        isLive: true,
        streamUrl: 'https://stream.snot.space/esa/malargue',
        telemetryLogs: ['[19:21:10] UPLINK COMMAND EXECUTED'],
      ),
      RadioDishModel(
        id: 'esa-newnorcia',
        name: 'DSA 3 New Norcia',
        agency: SpaceAgency.esa,
        location: 'Western Australia',
        target: 'Solar Orbiter',
        frequencyMHz: 8415.9,
        signalStrengthDbm: -115.2,
        azimuth: 45.6,
        elevation: 41.2,
        isLive: true,
        streamUrl: 'https://stream.snot.space/esa/newnorcia',
        telemetryLogs: ['[19:21:40] DOPPLER SHIFT CORRECTION APPLIED'],
      ),

      // GLOBAL ARRAYS
      RadioDishModel(
        id: 'array-alma',
        name: 'ALMA Interferometer',
        agency: SpaceAgency.globalArrays,
        location: 'Atacama, Chile',
        target: 'Sagittarius A* (Black Hole)',
        frequencyMHz: 230000.0,
        signalStrengthDbm: -105.0,
        azimuth: 180.0,
        elevation: 85.0,
        isLive: true,
        streamUrl: 'https://stream.snot.space/arrays/alma',
        telemetryLogs: ['[19:22:02] SUB-MILLIMETER PHASE CALIBRATION OK'],
      ),
      RadioDishModel(
        id: 'array-vla',
        name: 'VLA Array Element 09',
        agency: SpaceAgency.globalArrays,
        location: 'New Mexico, USA',
        target: 'Crab Pulsar (NP 0532)',
        frequencyMHz: 1420.4,
        signalStrengthDbm: -98.3,
        azimuth: 215.4,
        elevation: 60.1,
        isLive: true,
        streamUrl: 'https://stream.snot.space/arrays/vla',
        telemetryLogs: ['[19:21:50] HYDROGEN LINE 21CM DETECTED'],
      ),
      RadioDishModel(
        id: 'array-fast',
        name: 'FAST "Sky Eye"',
        agency: SpaceAgency.globalArrays,
        location: 'Guizhou, China',
        target: 'Fast Radio Burst FRB 20220208A',
        frequencyMHz: 1250.0,
        signalStrengthDbm: -89.1,
        azimuth: 0.0,
        elevation: 90.0,
        isLive: true,
        streamUrl: 'https://stream.snot.space/arrays/fast',
        telemetryLogs: ['[19:22:08] DISPERSION MEASURE COMPUTED'],
      ),

      // WEBSDR STREAMS
      RadioDishModel(
        id: 'sdr-ham-1',
        name: 'WebSDR Deep Space Net',
        agency: SpaceAgency.websdr,
        location: 'Bochum, Germany',
        target: 'ISS Ham Radio Repeater',
        frequencyMHz: 145.800,
        signalStrengthDbm: -72.4,
        azimuth: 132.0,
        elevation: 24.5,
        isLive: true,
        streamUrl: 'https://stream.snot.space/websdr/bochum',
        telemetryLogs: ['[19:21:58] VOICE PACKET DECODED AFSK'],
      ),
      RadioDishModel(
        id: 'sdr-meteor',
        name: 'SDR Radio Observatory',
        agency: SpaceAgency.websdr,
        location: 'Dwingeloo, Netherlands',
        target: 'Neutral Hydrogen Cloud Complex',
        frequencyMHz: 1420.4,
        signalStrengthDbm: -84.0,
        azimuth: 75.3,
        elevation: 48.2,
        isLive: true,
        streamUrl: 'https://stream.snot.space/websdr/dwingeloo',
        telemetryLogs: ['[19:21:15] DOPPLER SHIFT -1.2 kHz'],
      ),
    ];
  }
}

// ==========================================
// 3. MAIN DASHBOARD SCREEN & STATEFUL SHELL
// ==========================================

class CosmicMainDashboard extends StatefulWidget {
  const CosmicMainDashboard({Key? key}) : super(key: key);

  @override
  _CosmicMainDashboardState createState() => _CosmicMainDashboardState();
}

class _CosmicMainDashboardState extends State<CosmicMainDashboard> with TickerProviderStateMixin {
  late TabController _tabController;
  late List<RadioDishModel> _dishes;
  Timer? _telemetryTimer;
  String _searchQuery = '';
  bool _isGlobalMuted = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _dishes = CosmicDataRepository.getInitialDishes();
    
    // محاكاة تغير الإشارات والترددات لحظياً في الخلفية
    _telemetryTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _dishes = _dishes.map((dish) {
            if (!dish.isLive) return dish;
            final randomDelta = (math.Random().nextDouble() - 0.5) * 0.4;
            final newSignal = (dish.signalStrengthDbm + randomDelta).clamp(-170.0, -50.0);
            return dish.copyWith(signalStrengthDbm: double.parse(newSignal.toStringAsFixed(1)));
          }).toList();
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _telemetryTimer?.cancel();
    super.dispose();
  }

  List<RadioDishModel> _filterDishes(SpaceAgency agency) {
    return _dishes.where((dish) {
      final matchesAgency = dish.agency == agency;
      final matchesQuery = dish.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          dish.target.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          dish.location.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesAgency && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D111A),
        elevation: 6,
        shadowColor: Colors.cyanAccent.withOpacity(0.3),
        title: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.greenAccent,
                boxShadow: [BoxShadow(color: Colors.greenAccent.withOpacity(0.8), blurRadius: 8)],
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'com.nasaesa.space // ARRAY V2.6',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.cyanAccent),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isGlobalMuted ? Icons.volume_off : Icons.volume_up, color: Colors.cyanAccent),
            tooltip: 'Global Audio Mute',
            onPressed: () {
              setState(() {
                _isGlobalMuted = !_isGlobalMuted;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isGlobalMuted ? 'تم كتم جميع تدفقات البث الصوتي' : 'تم تفعيل الصوت العام'),
                  duration: const Duration(seconds: 1),
                  backgroundColor: Colors.blueGrey[900],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.terminal, color: Colors.greenAccent),
            tooltip: 'System Telemetry Logs',
            onPressed: () => _showTelemetryConsole(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(95),
          child: Column(
            children: [
              // شريط البحث السريع
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'بحث في الأطباق، الأهداف الفضائية، أو المواقع...',
                    hintStyle: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    prefixIcon: const Icon(Icons.search, size: 18, color: Colors.cyanAccent),
                    filled: true,
                    fillColor: const Color(0xFF04060A),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.cyanAccent.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Colors.cyanAccent),
                    ),
                  ),
                ),
              ),
              // تبويبات الوكالات العلوية
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.cyanAccent,
                indicatorWeight: 3,
                labelColor: Colors.cyanAccent,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'monospace'),
                tabs: const [
                  Tab(text: 'NASA DSN (4)'),
                  Tab(text: 'ESA ESTRACK (3)'),
                  Tab(text: 'GLOBAL ARRAYS (3)'),
                  Tab(text: 'WEBSDR STREAMS (2)'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          DishesGridView(dishes: _filterDishes(SpaceAgency.nasa), isMuted: _isGlobalMuted),
          DishesGridView(dishes: _filterDishes(SpaceAgency.esa), isMuted: _isGlobalMuted),
          DishesGridView(dishes: _filterDishes(SpaceAgency.globalArrays), isMuted: _isGlobalMuted),
          DishesGridView(dishes: _filterDishes(SpaceAgency.websdr), isMuted: _isGlobalMuted),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: const Color(0xFF0D111A),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('STATUS: ALL NODES SYNCHRONIZED', style: TextStyle(fontSize: 9, color: Colors.greenAccent)),
            Text('LATENCY: 42ms // SECURE SSL', style: TextStyle(fontSize: 9, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  void _showTelemetryConsole(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D111A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 350,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('// GLOBAL TELEMETRY CONSOLE', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(color: Colors.white24),
              Expanded(
                child: ListView(
                  children: _dishes.expand((dish) {
                    return dish.telemetryLogs.map((log) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text('[${dish.name}] $log', style: const TextStyle(fontSize: 10, color: Colors.cyanAccent)),
                    ));
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ==========================================
// 4. DISHES GRID VIEW & ARCHITECTURE
// ==========================================

class DishesGridView extends StatelessWidget {
  final List<RadioDishModel> dishes;
  final bool isMuted;

  const DishesGridView({Key? key, required this.dishes, required this.isMuted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (dishes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.radar, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text('لا توجد أطباق مطابقة للبحث الحالي', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.76,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: dishes.length,
      itemBuilder: (context, index) {
        return DishCardWidget(dish: dishes[index], isGlobalMuted: isMuted);
      },
    );
  }
}

// ==========================================
// 5. INDIVIDUAL DISH CARD & AUDIO PLAYER
// ==========================================

class DishCardWidget extends StatefulWidget {
  final RadioDishModel dish;
  final bool isGlobalMuted;

  const DishCardWidget({Key? key, required this.dish, required this.isGlobalMuted}) : super(key: key);

  @override
  _DishCardWidgetState createState() => _DishCardWidgetState();
}

class _DishCardWidgetState extends State<DishCardWidget> with SingleTickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _waveController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing && !widget.isGlobalMuted;
          _isLoading = state.processingState == ProcessingState.buffering;
        });
      }
    }, onError: (_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _isLoading = false;
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant DishCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isGlobalMuted && _isPlaying) {
      _audioPlayer.pause();
    }
  }

  @override
  void