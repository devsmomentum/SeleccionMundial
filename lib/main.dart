import 'dart:convert';
import 'dart:ui';

import 'package:confetti/confetti.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

// ─── CRM (Recived_landing_with_token) ────────────────────────────────────────
// Endpoint del CRM y token de la empresa. El proyecto CRM (bjdqjxrwvktfqienbzop)
// es DISTINTO al Supabase de esta app, por eso se envía con un POST HTTP directo.
// Ambos valores se pueden sobrescribir con --dart-define en el build si cambian.
const _crmEndpoint = String.fromEnvironment(
  'CRM_ENDPOINT',
  defaultValue:
      'https://bjdqjxrwvktfqienbzop.supabase.co/functions/v1/Recived_landing_with_token',
);
const _crmToken = String.fromEnvironment(
  'CRM_TOKEN',
  defaultValue: 'lt_72560d39ccdf579fbbc6cb7e',
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: _supabaseUrl, publishableKey: _supabaseAnonKey);
  runApp(const MundialPicksApp());
}

// ─── App ─────────────────────────────────────────────────────────────────────

class MundialPicksApp extends StatelessWidget {
  const MundialPicksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mundial 2026 Picks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B0000),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF161B22),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// ─── Modelo ───────────────────────────────────────────────────────────────────

class Seleccion {
  final String nombre;
  final String bandera;
  final String isoCode;
  final String confederacion;
  final String grupo;

  const Seleccion(this.nombre, this.bandera, this.isoCode, this.confederacion, this.grupo);
}

const List<Seleccion> todasLasSelecciones = [
  // ── Grupo A ──
  Seleccion('México',          '🇲🇽', 'MX',     'CONCACAF', 'A'),
  Seleccion('Sudáfrica',       '🇿🇦', 'ZA',     'CAF',      'A'),
  Seleccion('Corea del Sur',   '🇰🇷', 'KR',     'AFC',      'A'),
  Seleccion('Rep. Checa',      '🇨🇿', 'CZ',     'UEFA',     'A'),
  // ── Grupo B ──
  Seleccion('Canadá',          '🇨🇦', 'CA',     'CONCACAF', 'B'),
  Seleccion('Bosnia',          '🇧🇦', 'BA',     'UEFA',     'B'),
  Seleccion('Qatar',           '🇶🇦', 'QA',     'AFC',      'B'),
  Seleccion('Suiza',           '🇨🇭', 'CH',     'UEFA',     'B'),
  // ── Grupo C ──
  Seleccion('Brasil',          '🇧🇷', 'BR',     'CONMEBOL', 'C'),
  Seleccion('Marruecos',       '🇲🇦', 'MA',     'CAF',      'C'),
  Seleccion('Haití',           '🇭🇹', 'HT',     'CONCACAF', 'C'),
  Seleccion('Escocia',         '🏴󠁧󠁢󠁳󠁣󠁴󠁿', 'GB-SCT', 'UEFA',     'C'),
  // ── Grupo D ──
  Seleccion('Estados Unidos',  '🇺🇸', 'US',     'CONCACAF', 'D'),
  Seleccion('Paraguay',        '🇵🇾', 'PY',     'CONMEBOL', 'D'),
  Seleccion('Australia',       '🇦🇺', 'AU',     'AFC',      'D'),
  Seleccion('Turquía',         '🇹🇷', 'TR',     'UEFA',     'D'),
  // ── Grupo E ──
  Seleccion('Alemania',        '🇩🇪', 'DE',     'UEFA',     'E'),
  Seleccion('Curazao',         '🇨🇼', 'CW',     'CONCACAF', 'E'),
  Seleccion('Costa de Marfil', '🇨🇮', 'CI',     'CAF',      'E'),
  Seleccion('Ecuador',         '🇪🇨', 'EC',     'CONMEBOL', 'E'),
  // ── Grupo F ──
  Seleccion('Países Bajos',    '🇳🇱', 'NL',     'UEFA',     'F'),
  Seleccion('Japón',           '🇯🇵', 'JP',     'AFC',      'F'),
  Seleccion('Suecia',          '🇸🇪', 'SE',     'UEFA',     'F'),
  Seleccion('Túnez',           '🇹🇳', 'TN',     'CAF',      'F'),
  // ── Grupo G ──
  Seleccion('Bélgica',         '🇧🇪', 'BE',     'UEFA',     'G'),
  Seleccion('Egipto',          '🇪🇬', 'EG',     'CAF',      'G'),
  Seleccion('Irán',            '🇮🇷', 'IR',     'AFC',      'G'),
  Seleccion('Nueva Zelanda',   '🇳🇿', 'NZ',     'OFC',      'G'),
  // ── Grupo H ──
  Seleccion('España',          '🇪🇸', 'ES',     'UEFA',     'H'),
  Seleccion('Cabo Verde',      '🇨🇻', 'CV',     'CAF',      'H'),
  Seleccion('Arabia Saudita',  '🇸🇦', 'SA',     'AFC',      'H'),
  Seleccion('Uruguay',         '🇺🇾', 'UY',     'CONMEBOL', 'H'),
  // ── Grupo I ──
  Seleccion('Francia',         '🇫🇷', 'FR',     'UEFA',     'I'),
  Seleccion('Senegal',         '🇸🇳', 'SN',     'CAF',      'I'),
  Seleccion('Irak',            '🇮🇶', 'IQ',     'AFC',      'I'),
  Seleccion('Noruega',         '🇳🇴', 'NO',     'UEFA',     'I'),
  // ── Grupo J ──
  Seleccion('Argentina',       '🇦🇷', 'AR',     'CONMEBOL', 'J'),
  Seleccion('Argelia',         '🇩🇿', 'DZ',     'CAF',      'J'),
  Seleccion('Austria',         '🇦🇹', 'AT',     'UEFA',     'J'),
  Seleccion('Jordania',        '🇯🇴', 'JO',     'AFC',      'J'),
  // ── Grupo K ──
  Seleccion('Portugal',        '🇵🇹', 'PT',     'UEFA',     'K'),
  Seleccion('Rep. Dem. Congo', '🇨🇩', 'CD',     'CAF',      'K'),
  Seleccion('Uzbekistán',      '🇺🇿', 'UZ',     'AFC',      'K'),
  Seleccion('Colombia',        '🇨🇴', 'CO',     'CONMEBOL', 'K'),
  // ── Grupo L ──
  Seleccion('Inglaterra',      '🏴󠁧󠁢󠁥󠁮󠁧󠁿', 'GB-ENG', 'UEFA',     'L'),
  Seleccion('Croacia',         '🇭🇷', 'HR',     'UEFA',     'L'),
  Seleccion('Ghana',           '🇬🇭', 'GH',     'CAF',      'L'),
  Seleccion('Panamá',          '🇵🇦', 'PA',     'CONCACAF', 'L'),
];

const int maxSeleccion = 16;
const List<String> ordenConfs = ['CONCACAF', 'CONMEBOL', 'UEFA', 'AFC', 'CAF', 'OFC'];

const Map<String, Color> colorConfederacion = {
  'CONCACAF': Color(0xFF1A6B3C),
  'CONMEBOL': Color(0xFF1565C0),
  'UEFA':     Color(0xFF6A1B9A),
  'AFC':      Color(0xFFB71C1C),
  'CAF':      Color(0xFFE65100),
  'OFC':      Color(0xFF00838F),
};

// ─── HomeScreen ──────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Set<String> _seleccionados = {};
  String? _filtroConf;

  void _toggleSeleccion(String nombre) {
    setState(() {
      if (_seleccionados.contains(nombre)) {
        _seleccionados.remove(nombre);
      } else if (_seleccionados.length < maxSeleccion) {
        _seleccionados.add(nombre);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Ya seleccionaste $maxSeleccion países.'),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF8B0000),
        ));
      }
    });
  }

  List<Seleccion> get _seleccionesFiltradas {
    if (_filtroConf == null) return todasLasSelecciones;
    return todasLasSelecciones.where((s) => s.confederacion == _filtroConf).toList();
  }

  Map<String, List<Seleccion>> _agrupadosPorConf() {
    final mapa = <String, List<Seleccion>>{};
    for (final s in _seleccionesFiltradas) {
      mapa.putIfAbsent(s.confederacion, () => []).add(s);
    }
    return {for (final c in ordenConfs) if (mapa.containsKey(c)) c: mapa[c]!};
  }

  @override
  Widget build(BuildContext context) {
    final grupos = _agrupadosPorConf();
    final selCount = _seleccionados.length;
    final listo = selCount == maxSeleccion;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: const _MundialHeader(),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _ContadorBanner(selCount: selCount, max: maxSeleccion),
        ),
      ),
      body: Column(
        children: [
          _FiltroConfederacion(
            seleccionado: _filtroConf,
            onSeleccionar: (conf) =>
                setState(() => _filtroConf = _filtroConf == conf ? null : conf),
          ),
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              cacheExtent: 600,
              slivers: [
                ...grupos.entries.expand((e) {
                  final color = colorConfederacion[e.key] ?? Colors.grey;
                  return [
                    SliverToBoxAdapter(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border(left: BorderSide(color: color, width: 4)),
                          color: color.withValues(alpha: 0.12),
                        ),
                        child: Text(
                          e.key,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(8),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => _PaisCard(
                            seleccion: e.value[i],
                            isSelected: _seleccionados.contains(e.value[i].nombre),
                            accentColor: color,
                            onTap: () => _toggleSeleccion(e.value[i].nombre),
                          ),
                          childCount: e.value.length,
                          addAutomaticKeepAlives: false,
                          addSemanticIndexes: false,
                        ),
                      ),
                    ),
                  ];
                }),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
              ],
            ),
          ),
          _PanelConfirmar(
            selCount: selCount,
            onConfirmar: listo
                ? () async {
                    final success = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EmailCaptureScreen(
                          picks: todasLasSelecciones
                              .where((s) => _seleccionados.contains(s.nombre))
                              .toList()
                            ..sort((a, b) => a.grupo.compareTo(b.grupo)),
                        ),
                      ),
                    );
                    if (success == true) {
                      setState(() {
                        _seleccionados.clear();
                        _filtroConf = null;
                      });
                    }
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

// ─── EmailCaptureScreen ──────────────────────────────────────────────────────

class EmailCaptureScreen extends StatefulWidget {
  final List<Seleccion> picks;

  const EmailCaptureScreen({required this.picks, super.key});

  @override
  State<EmailCaptureScreen> createState() => _EmailCaptureScreenState();
}

class _EmailCaptureScreenState extends State<EmailCaptureScreen>
    with TickerProviderStateMixin {
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _telefonoCtrl = TextEditingController();
  final FocusNode _nombreFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _telefonoFocus = FocusNode();
  bool _enviando = false;

  late final AnimationController _bgCtrl;
  late final AnimationController _shimmerCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _fadeCtrl;
  late final ConfettiController _confettiCtrl;

  late final Animation<double> _shimmerAnim;
  late final Animation<double> _pulseAnim;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  bool get _formValido =>
      _nombreCtrl.text.trim().isNotEmpty &&
      RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w+$').hasMatch(_emailCtrl.text.trim()) &&
      _telefonoCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _shimmerAnim = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    _fadeAnims = List.generate(8, (i) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _fadeCtrl,
          curve: Interval(i * 0.12, (i * 0.12 + 0.5).clamp(0.0, 1.0),
              curve: Curves.easeOut),
        ),
      );
    });

    _slideAnims = List.generate(8, (i) {
      return Tween<Offset>(
              begin: const Offset(0, 0.3), end: Offset.zero)
          .animate(
        CurvedAnimation(
          parent: _fadeCtrl,
          curve: Interval(i * 0.12, (i * 0.12 + 0.5).clamp(0.0, 1.0),
              curve: Curves.easeOut),
        ),
      );
    });

    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 4));
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _shimmerCtrl.dispose();
    _pulseCtrl.dispose();
    _fadeCtrl.dispose();
    _confettiCtrl.dispose();
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _telefonoCtrl.dispose();
    _nombreFocus.dispose();
    _emailFocus.dispose();
    _telefonoFocus.dispose();
    super.dispose();
  }

  Widget _fadeSlide(int index, Widget child) {
    return FadeTransition(
      opacity: _fadeAnims[index],
      child: SlideTransition(position: _slideAnims[index], child: child),
    );
  }

  void _mostrarSnack(String msg, {required Color color}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.poppins()),
      duration: const Duration(seconds: 3),
      backgroundColor: color,
    ));
  }

  Future<void> _enviarEmail() async {
    if (!_formValido || _enviando) return;
    setState(() => _enviando = true);

    final nombre = _nombreCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final telefono = _telefonoCtrl.text.trim();

    try {
      await Supabase.instance.client.from('selecciones').insert({
        'nombre': nombre,
        'email': email,
        'telefono': telefono,
        'paises': widget.picks.map((s) => s.nombre).toList(),
      });
    } catch (e) {
      if (e is PostgrestException && e.code == '23505') {
        final msg = (e.details ?? '').toString().contains('telefono')
            ? 'Este número ya envió su selección.'
            : 'Este correo ya envió su selección.';
        _mostrarSnack(msg, color: Colors.orange[900]!);
      } else {
        _mostrarSnack('Error al guardar: $e', color: Colors.red[900]!);
      }
      setState(() => _enviando = false);
      return;
    }

    try {
      await Supabase.instance.client.functions.invoke(
        'send-confirmation',
        body: {
          'nombre': nombre,
          'email': email,
          'picks': widget.picks
              .map((s) => {
                    'nombre': s.nombre,
                    'bandera': s.bandera,
                    'grupo': s.grupo,
                  })
              .toList(),
        },
      );
    } catch (_) {}

    // Enviar al CRM (no bloquea el flujo si falla)
    await _enviarAlCrm(nombre: nombre, email: email, telefono: telefono);

    _confettiCtrl.play();
    _mostrarSnack('¡Selección realizada! Revisa tu correo.',
        color: Colors.green[900]!);
    setState(() => _enviando = false);

    await Future.delayed(const Duration(seconds: 4));
    if (mounted) Navigator.of(context).pop(true);
  }

  /// Envía el lead al CRM (Recived_landing_with_token) con los 16 países
  /// seleccionados como NOTA. Es no crítico: si falla, no interrumpe el flujo.
  Future<void> _enviarAlCrm({
    required String nombre,
    required String email,
    required String telefono,
  }) async {
    if (_crmEndpoint.isEmpty || _crmToken.isEmpty) {
      debugPrint('🔴 CRM: endpoint o token no configurados, se omite envío.');
      return;
    }

    // Construir la nota con los 16 países (bandera + nombre + grupo)
    final lineasPaises = [
      for (var i = 0; i < widget.picks.length; i++)
        '${i + 1}. ${widget.picks[i].bandera} ${widget.picks[i].nombre} '
            '(Grupo ${widget.picks[i].grupo})',
    ].join('\n');
    final nota = '🏆 Selección Mundial 2026 — ${widget.picks.length} países elegidos:\n'
        '$lineasPaises';

    final url = Uri.parse(
      '$_crmEndpoint?token=${Uri.encodeComponent(_crmToken)}',
    );
    final payload = {
      'nombre_completo': nombre,
      'correo_electronico': email,
      'telefono': telefono,
      'evento': 'Selección Mundial 2026',
      'notas': nota,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      debugPrint(
        '🟡 CRM Status: ${response.statusCode} | Body: ${response.body}',
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('🟢 CRM: lead enviado correctamente.');
      } else {
        debugPrint('🔴 CRM respondió con error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('⚠️ CRM: error no crítico al enviar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (context2, child2) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(const Color(0xFF050D2E),
                        const Color(0xFF0A1845), _bgCtrl.value)!,
                    Color.lerp(const Color(0xFF1A0533),
                        const Color(0xFF2D0A50), _bgCtrl.value)!,
                    Color.lerp(const Color(0xFF0D1B4E),
                        const Color(0xFF1C0639), _bgCtrl.value)!,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiCtrl,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 30,
              colors: const [
                Color(0xFFFFD700),
                Color(0xFFFF6B6B),
                Color(0xFF4ECDC4),
                Color(0xFFFFE66D),
                Colors.white,
              ],
              gravity: 0.3,
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              child: Column(
                children: [
                  // Back button
                  _fadeSlide(
                    0,
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white70, size: 18),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Trophy glow
                  _fadeSlide(
                    1,
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFFFFD700).withValues(alpha: 0.5),
                            blurRadius: 50,
                            spreadRadius: 12,
                          ),
                        ],
                      ),
                      child: const Text('🏆',
                          style: TextStyle(fontSize: 76)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Title
                  _fadeSlide(
                    2,
                    Text(
                      '¡TUS 16 ELEGIDOS\nESTÁN LISTOS!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.bebasNeue(
                        fontSize: 40,
                        color: Colors.white,
                        letterSpacing: 3,
                        height: 1.05,
                        shadows: const [
                          Shadow(
                            color: Color(0xFFFFD700),
                            blurRadius: 24,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Subtitle
                  _fadeSlide(
                    2,
                    Text(
                      'Completa tus datos para confirmar\ntu selección y participar.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white54,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Nombre
                  _fadeSlide(
                    3,
                    _GlassInput(
                      controller: _nombreCtrl,
                      focusNode: _nombreFocus,
                      onChanged: (_) => setState(() {}),
                      hintText: 'Nombre completo',
                      icon: Icons.person_outline,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Email
                  _fadeSlide(
                    4,
                    _GlassInput(
                      controller: _emailCtrl,
                      focusNode: _emailFocus,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Teléfono
                  _fadeSlide(
                    5,
                    _GlassInput(
                      controller: _telefonoCtrl,
                      focusNode: _telefonoFocus,
                      onChanged: (_) => setState(() {}),
                      hintText: '0424-000-0000',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // CTA button with pulse
                  _fadeSlide(
                    6,
                    ScaleTransition(
                      scale: _pulseAnim,
                      child: _ShimmerButton(
                        shimmerAnim: _shimmerAnim,
                        enabled: _formValido && !_enviando,
                        enviando: _enviando,
                        onTap: _enviarEmail,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Picks preview
                  _fadeSlide(7, _PicksPreview(picks: widget.picks)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widgets ─────────────────────────────────────────────────────────────────

class _MundialHeader extends StatelessWidget {
  const _MundialHeader();

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      color: const Color(0xFF161B22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: topPad),
          Row(
            children: const [
              Expanded(child: ColoredBox(color: Color(0xFFD80621), child: SizedBox(height: 4))),
              Expanded(child: ColoredBox(color: Color(0xFF003DA5), child: SizedBox(height: 4))),
              Expanded(child: ColoredBox(color: Color(0xFF006847), child: SizedBox(height: 4))),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(
              children: [
                const Text('🏆', style: TextStyle(fontSize: 30)),
                const SizedBox(width: 10),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'HAZ TU SELECCIÓN Y GANA PREMIOS',
                      style: GoogleFonts.bebasNeue(
                        fontSize: 36,
                        color: Colors.white,
                        letterSpacing: 3,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContadorBanner extends StatelessWidget {
  final int selCount;
  final int max;

  const _ContadorBanner({required this.selCount, required this.max});

  @override
  Widget build(BuildContext context) {
    final completo = selCount == max;
    return Container(
      width: double.infinity,
      color: completo ? const Color(0xFF1A3A1A) : const Color(0xFF1C2028),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            completo ? '✅ ¡Listo! Confirma tu selección' : 'Elige exactamente $max países',
            style: TextStyle(
              color: completo ? Colors.greenAccent : Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: completo ? Colors.green[900] : const Color(0xFF8B0000),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$selCount / $max',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _FiltroConfederacion extends StatelessWidget {
  final String? seleccionado;
  final void Function(String) onSeleccionar;

  const _FiltroConfederacion({
    required this.seleccionado,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      color: const Color(0xFF0D1117),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: ordenConfs.length,
        separatorBuilder: (context3, i3) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final conf = ordenConfs[i];
          final color = colorConfederacion[conf]!;
          final activo = seleccionado == conf;
          return GestureDetector(
            onTap: () => onSeleccionar(conf),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: activo ? color : color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: activo ? color : color.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                conf,
                style: TextStyle(
                  color: activo ? Colors.white : color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


class _PaisCard extends StatelessWidget {
  final Seleccion seleccion;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  const _PaisCard({
    required this.seleccion,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? accentColor : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: accentColor.withValues(alpha: 0.35), blurRadius: 8)]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AspectRatio(
                    aspectRatio: 3 / 2,
                    child: seleccion.isoCode == 'GB-SCT' || seleccion.isoCode == 'GB-ENG'
                        ? FittedBox(
                            fit: BoxFit.contain,
                            child: CountryFlag.fromCountryCode(
                              seleccion.isoCode,
                              height: 64,
                              width: 64,
                            ),
                          )
                        : FittedBox(
                            fit: BoxFit.contain,
                            child: Text(seleccion.bandera,
                                style: const TextStyle(fontSize: 64)),
                          ),
                  ),
                  Expanded(
                    child: Container(
                      color: isSelected
                          ? accentColor.withValues(alpha: 0.3)
                          : const Color(0xFF1C2028),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text(
                        seleccion.nombre.toUpperCase(),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 7.5,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (isSelected)
                Positioned(
                  top: 3,
                  right: 3,
                  child: Container(
                    decoration:
                        BoxDecoration(color: accentColor, shape: BoxShape.circle),
                    padding: const EdgeInsets.all(2),
                    child: const Icon(Icons.check, color: Colors.white, size: 9),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PanelConfirmar extends StatelessWidget {
  final int selCount;
  final VoidCallback? onConfirmar;

  const _PanelConfirmar({required this.selCount, required this.onConfirmar});

  @override
  Widget build(BuildContext context) {
    final faltan = maxSeleccion - selCount;
    final listo = selCount == maxSeleccion;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF161B22),
        border: Border(top: BorderSide(color: Color(0xFF30363D))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: onConfirmar,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                listo ? const Color(0xFF8B0000) : const Color(0xFF2D333B),
            foregroundColor: listo ? Colors.white : Colors.white38,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            elevation: listo ? 4 : 0,
          ),
          child: listo
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'CONFIRMAR MIS 16 PICKS',
                      style: GoogleFonts.bebasNeue(
                        fontSize: 18,
                        letterSpacing: 2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                )
              : Text(
                  'Faltan $faltan ${faltan == 1 ? 'país' : 'países'}',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500),
                ),
        ),
      ),
    );
  }
}

// ─── Glass Input ─────────────────────────────────────────────────────────────

class _GlassInput extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String) onChanged;
  final String hintText;
  final IconData icon;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;

  const _GlassInput({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.hintText = 'tu@correo.com',
    this.icon = Icons.email_outlined,
    this.keyboardType = TextInputType.emailAddress,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<_GlassInput> createState() => _GlassInputState();
}

class _GlassInputState extends State<_GlassInput> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocus);
  }

  void _onFocus() => setState(() => _focused = widget.focusNode.hasFocus);

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocus);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _focused
              ? const Color(0xFF00E5FF)
              : Colors.white.withValues(alpha: 0.2),
          width: _focused ? 2 : 1,
        ),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            color: Colors.white.withValues(alpha: 0.08),
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              onChanged: widget.onChanged,
              keyboardType: widget.keyboardType,
              textCapitalization: widget.textCapitalization,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle:
                    GoogleFonts.poppins(color: Colors.white30, fontSize: 15),
                prefixIcon: Icon(
                  widget.icon,
                  color: _focused ? const Color(0xFF00E5FF) : Colors.white38,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 18, horizontal: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Shimmer Button ──────────────────────────────────────────────────────────

class _ShimmerButton extends StatelessWidget {
  final Animation<double> shimmerAnim;
  final bool enabled;
  final bool enviando;
  final VoidCallback onTap;

  const _ShimmerButton({
    required this.shimmerAnim,
    required this.enabled,
    required this.enviando,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: enabled ? 1.0 : 0.45,
        child: Container(
          height: 58,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFAB00), Color(0xFFFFD700), Color(0xFFFF8F00)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.45),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                LayoutBuilder(
                  builder: (ctx, constraints) => AnimatedBuilder(
                    animation: shimmerAnim,
                    builder: (ctx2, child3) {
                      final x = shimmerAnim.value *
                              (constraints.maxWidth + 80) -
                          40;
                      return Transform.translate(
                        offset: Offset(x, 0),
                        child: Container(
                          width: 70,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.white.withValues(alpha: 0.4),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Center(
                  child: enviando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.lock_rounded,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'SELLAR PRONÓSTICO',
                              style: GoogleFonts.bebasNeue(
                                fontSize: 22,
                                color: Colors.white,
                                letterSpacing: 2.5,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Picks Preview ───────────────────────────────────────────────────────────

class _PicksPreview extends StatelessWidget {
  final List<Seleccion> picks;

  const _PicksPreview({required this.picks});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TUS 16 SELECCIONADOS',
          style: GoogleFonts.bebasNeue(
            fontSize: 16,
            color: const Color(0xFFFFD700),
            letterSpacing: 2.5,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.75,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: picks.length,
          itemBuilder: (_, i) {
            final s = picks[i];
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.35)),
                color: Colors.white.withValues(alpha: 0.05),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: s.isoCode == 'GB-SCT' || s.isoCode == 'GB-ENG'
                          ? FittedBox(
                              fit: BoxFit.contain,
                              child: CountryFlag.fromCountryCode(
                                s.isoCode,
                                height: 64,
                                width: 64,
                              ),
                            )
                          : FittedBox(
                              fit: BoxFit.contain,
                              child: Text(s.bandera,
                                  style: const TextStyle(fontSize: 64)),
                            ),
                    ),
                    Container(
                      width: double.infinity,
                      color: Colors.black26,
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 3),
                      child: Text(
                        s.nombre.toUpperCase(),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
