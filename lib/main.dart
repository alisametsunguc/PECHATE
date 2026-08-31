import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'features/inbox_page.dart' as inbox_feature;
import 'features/games_page.dart' as games_feature;

const ink = Color(0xff201c18);
const paper = Color(0xfffffbf1);
const yellow = Color(0xfff2b705);
const water = Color(0xff6bd7e5);

void main() => runApp(const PechateApp());

class PechateApp extends StatelessWidget {
  const PechateApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'PECHATE',
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: paper,
      colorScheme: ColorScheme.fromSeed(seedColor: yellow),
    ),
    home: const SplashScreen(),
  );
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1850),
    )..forward();
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeShell()),
        );
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: yellow,
    body: Center(
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, child) {
          final t = controller.value;
          final crumple = Curves.easeInOutCubic.transform(
            ((t - .08) / .72).clamp(0.0, 1.0),
          );
          final drop = Curves.easeInQuad.transform(
            ((t - .72) / .28).clamp(0.0, 1.0),
          );
          final scaleX = 1 - crumple * .78 + sin(crumple * pi * 5) * .035;
          final scaleY = 1 - crumple * .82 + cos(crumple * pi * 4) * .028;
          return Opacity(
            opacity: 1 - drop,
            child: Transform.translate(
              offset: Offset(sin(t * 13) * 5 * crumple, drop * drop * 90),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: sin(crumple * pi * 4.5) * .055 + drop * .18,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.diagonal3Values(scaleX, scaleY, 1),
                      child: _CrumpledTissue(progress: crumple),
                    ),
                  ),
                  Opacity(
                    opacity: 1 - ((crumple - .58) / .34).clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: 1 - crumple * .08,
                      child: const _PechateMark(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}

class _CrumpledTissue extends StatelessWidget {
  final double progress;

  const _CrumpledTissue({required this.progress});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 310,
    height: 310,
    child: ClipPath(
      clipper: _OrganicTissueClipper(progress),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _PaperSurfacePainter()),
          CustomPaint(painter: _CreasePainter(progress)),
        ],
      ),
    ),
  );
}

class _PechateMark extends StatelessWidget {
  const _PechateMark();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 112,
    height: 132,
    child: CustomPaint(painter: _PechateMarkPainter()),
  );
}

class _PechateMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: .16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final mark = Paint()
      ..color = const Color(0xfff7f4ec)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * .34, size.height * .72)
      ..lineTo(size.width * .34, size.height * .2)
      ..quadraticBezierTo(
        size.width * .34,
        size.height * .09,
        size.width * .48,
        size.height * .09,
      )
      ..lineTo(size.width * .61, size.height * .09)
      ..quadraticBezierTo(
        size.width * .84,
        size.height * .09,
        size.width * .84,
        size.height * .3,
      )
      ..quadraticBezierTo(
        size.width * .84,
        size.height * .5,
        size.width * .59,
        size.height * .5,
      )
      ..lineTo(size.width * .35, size.height * .5);
    final drop = Path()
      ..moveTo(size.width * .34, size.height * .67)
      ..cubicTo(
        size.width * .26,
        size.height * .79,
        size.width * .23,
        size.height * .85,
        size.width * .23,
        size.height * .9,
      )
      ..cubicTo(
        size.width * .23,
        size.height,
        size.width * .46,
        size.height,
        size.width * .46,
        size.height * .9,
      )
      ..cubicTo(
        size.width * .46,
        size.height * .84,
        size.width * .41,
        size.height * .76,
        size.width * .34,
        size.height * .67,
      );

    canvas.drawPath(path.shift(const Offset(3, 4)), shadow);
    canvas.drawPath(drop.shift(const Offset(3, 4)), shadow);
    canvas.drawPath(path, mark);
    canvas.drawPath(drop, mark);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PaperSurfacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final surface = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xffffffff), Color(0xffeeeae1)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, surface);

    final fiber = Paint()
      ..color = ink.withValues(alpha: .035)
      ..strokeWidth = .8
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 95; i++) {
      final x = (sin(i * 12.73) * .5 + .5) * size.width;
      final y = (cos(i * 8.41) * .5 + .5) * size.height;
      final length = 2 + (i % 5) * 1.3;
      canvas.drawLine(
        Offset(x, y),
        Offset(x + cos(i.toDouble()) * length, y + sin(i.toDouble()) * length),
        fiber,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OrganicTissueClipper extends CustomClipper<Path> {
  final double progress;

  const _OrganicTissueClipper(this.progress);

  @override
  Path getClip(Size size) {
    const pointCount = 28;
    final center = Offset(size.width / 2, size.height / 2);
    final points = <Offset>[];

    for (var i = 0; i < pointCount; i++) {
      final angle = -pi / 2 + i * 2 * pi / pointCount;
      final cosA = cos(angle);
      final sinA = sin(angle);
      final edgeRadius = min(
        size.width * .47 / max(cosA.abs(), .001),
        size.height * .47 / max(sinA.abs(), .001),
      );
      final softSquareRadius = min(edgeRadius, size.shortestSide * .61);
      final ballRadius =
          size.shortestSide * (.43 + sin(i * 2.17 + progress * 7) * .035);
      final radius =
          softSquareRadius * (1 - progress) +
          ballRadius * progress +
          sin(i * 1.73 + progress * 11) * (3 + progress * 8);
      final squeeze = 1 - progress * .12 * sin(angle * 3 + 1.1);
      points.add(center + Offset(cosA * radius * squeeze, sinA * radius));
    }

    final path = Path();
    final firstMid = Offset(
      (points.last.dx + points.first.dx) / 2,
      (points.last.dy + points.first.dy) / 2,
    );
    path.moveTo(firstMid.dx, firstMid.dy);
    for (var i = 0; i < points.length; i++) {
      final current = points[i];
      final next = points[(i + 1) % points.length];
      final midpoint = Offset(
        (current.dx + next.dx) / 2,
        (current.dy + next.dy) / 2,
      );
      path.quadraticBezierTo(current.dx, current.dy, midpoint.dx, midpoint.dy);
    }
    return path..close();
  }

  @override
  bool shouldReclip(covariant _OrganicTissueClipper oldClipper) =>
      oldClipper.progress != progress;
}

class _CreasePainter extends CustomPainter {
  final double progress;

  const _CreasePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final reveal = Curves.easeIn.transform(progress);
    final dark = Paint()
      ..color = ink.withValues(alpha: .08 + reveal * .2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2 + reveal * 1.8
      ..strokeCap = StrokeCap.round;
    final light = Paint()
      ..color = Colors.white.withValues(alpha: .18 + reveal * .34)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1 + reveal * 1.5
      ..strokeCap = StrokeCap.round;

    final creases = [
      [const Offset(.08, .22), const Offset(.36, .31), const Offset(.53, .52)],
      [const Offset(.93, .15), const Offset(.69, .34), const Offset(.53, .52)],
      [const Offset(.12, .82), const Offset(.34, .67), const Offset(.53, .52)],
      [const Offset(.88, .88), const Offset(.72, .65), const Offset(.53, .52)],
      [const Offset(.45, .02), const Offset(.42, .29), const Offset(.53, .52)],
      [const Offset(.58, .98), const Offset(.61, .71), const Offset(.53, .52)],
    ];

    for (var i = 0; i < creases.length; i++) {
      final line = creases[i];
      final path = Path()
        ..moveTo(line[0].dx * size.width, line[0].dy * size.height)
        ..quadraticBezierTo(
          (line[1].dx + sin(progress * 8 + i) * .035) * size.width,
          (line[1].dy + cos(progress * 7 + i) * .025) * size.height,
          line[2].dx * size.width,
          line[2].dy * size.height,
        );
      canvas.drawPath(path, i.isEven ? dark : light);
      canvas.drawPath(
        path.shift(Offset(1.5 + reveal * 2, 1 + reveal)),
        i.isEven ? light : dark,
      );
    }

    final shade = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-.2, -.25),
        radius: .9,
        colors: [
          Colors.transparent,
          ink.withValues(alpha: reveal * .18),
        ],
        stops: const [.46, 1],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, shade);
  }

  @override
  bool shouldRepaint(covariant _CreasePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;
  static const pages = [
    FeedPage(),
    games_feature.GamesPage(),
    inbox_feature.InboxPage(),
    ProfilePage(),
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: index == 2 ? const Color(0xfff2b705) : paper,
    body: IndexedStack(index: index, children: pages),
    bottomNavigationBar: NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (value) => setState(() => index = value),
      backgroundColor: ink,
      indicatorColor: yellow,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.water_drop), label: 'Stream'),
        NavigationDestination(icon: Icon(Icons.sports_esports), label: 'Games'),
        NavigationDestination(
          icon: Badge(label: Text('15'), child: Icon(Icons.chat_bubble)),
          label: 'Chat',
        ),
        NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
      ],
    ),
  );
}

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});
  @override
  Widget build(BuildContext context) => SafeArea(
    child: CustomScrollView(
      slivers: [
        const SliverAppBar(
          floating: true,
          title: Text('PECHATE', style: TextStyle(fontWeight: FontWeight.w900)),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Akışta ne sızıyor?',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),
          ),
        ),
        SliverList.builder(
          itemCount: 5,
          itemBuilder: (_, i) => PostCard(index: i),
        ),
      ],
    ),
  );
}

class PostCard extends StatefulWidget {
  final int index;
  const PostCard({super.key, required this.index});
  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool reacted = false;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.fromLTRB(14, 4, 14, 14),
    color: Colors.white,
    child: Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: widget.index.isEven ? yellow : water,
            child: Text(widget.index.isEven ? 'M' : 'A'),
          ),
          title: Text(
            widget.index.isEven ? 'Maya Lin' : 'Alex Reed',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          subtitle: const Text('İstanbul · 3 dk'),
        ),
        Container(
          height: 220,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: widget.index.isEven
                  ? const [Color(0xffffd56b), Color(0xff6bcbd6)]
                  : const [Color(0xff403b68), Color(0xffe88973)],
            ),
          ),
          child: const Center(
            child: Text(
              'somewhere between\nhere and nowhere',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        Row(
          children: [
            TextButton.icon(
              onPressed: () => setState(() => reacted = !reacted),
              icon: Text(reacted ? '💦' : '💧'),
              label: Text(reacted ? '249 drops' : '248 drops'),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.comment_outlined),
              label: const Text('31'),
            ),
          ],
        ),
      ],
    ),
  );
}

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});
  static const names = [
    'Deniz',
    'Ece',
    'Kerem',
    'Mina',
    'Bora',
    'Lara',
    'Mert',
    'Ada',
    'Can',
    'İpek',
    'Arda',
    'Zeynep',
    'Emre',
    'Duru',
    'Alex',
  ];
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Column(
      children: [
        Container(
          color: yellow,
          padding: const EdgeInsets.all(16),
          child: const Row(
            children: [
              Expanded(
                child: Text(
                  'Mesajlar',
                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
                ),
              ),
              Text('💧💧💧💧'),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          color: ink,
          padding: const EdgeInsets.all(10),
          child: const Text(
            'Gelen kutunun tuvalet molasına ihtiyacı var.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: names.length,
            itemBuilder: (_, i) {
              final fill = min(1.0, (15 - i) / 4);
              return InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChatPage(name: names[i])),
                ),
                child: Container(
                  height: 75,
                  margin: const EdgeInsets.fromLTRB(12, 7, 12, 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        water.withValues(alpha: .5),
                        water.withValues(alpha: .5),
                        Colors.white,
                        Colors.white,
                      ],
                      stops: [0, fill, fill, 1],
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: i.isEven ? yellow : water,
                      child: Text(names[i][0]),
                    ),
                    title: Text(
                      names[i],
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: const Text('Yeni bir şey sızdırdı…'),
                    trailing: Badge(label: Text('${15 - i}')),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

class ChatPage extends StatefulWidget {
  final String name;
  const ChatPage({super.key, required this.name});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final controller = TextEditingController();
  final messages = <String>[
    'Bu tek gösterimlik fotoğrafı açmadan da yazabilirsin.',
    'İddialı konuşma 😏',
  ];
  void send() {
    if (controller.text.trim().isEmpty) return;
    setState(() => messages.add(controller.text.trim()));
    controller.clear();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: yellow,
      title: Text(
        widget.name,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      actions: [
        IconButton(
          onPressed: () => showModalBottomSheet(
            context: context,
            builder: (_) => const ChatGames(),
          ),
          icon: const Icon(Icons.sports_esports),
        ),
      ],
    ),
    body: Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: messages.length + 1,
            itemBuilder: (_, i) {
              if (i == 0) {
                return Card(
                  color: ink,
                  child: ListTile(
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => const FlushViewer(),
                    ),
                    leading: const Icon(Icons.visibility, color: water),
                    title: const Text(
                      'Tek gösterimlik fotoğraf',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    subtitle: const Text(
                      'Açınca girdaba gider.',
                      style: TextStyle(color: Colors.white60),
                    ),
                  ),
                );
              }
              return Align(
                alignment: i > 2 ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: i > 2 ? yellow : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(messages[i - 1]),
                ),
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    onSubmitted: (_) => send(),
                    decoration: InputDecoration(
                      hintText: 'İçinde tutma…',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(onPressed: send, icon: const Icon(Icons.send)),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class FlushViewer extends StatefulWidget {
  const FlushViewer({super.key});
  @override
  State<FlushViewer> createState() => _FlushViewerState();
}

class _FlushViewerState extends State<FlushViewer>
    with SingleTickerProviderStateMixin {
  late final AnimationController animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent,
    child: AnimatedBuilder(
      animation: animation,
      builder: (_, child) => Transform.rotate(
        angle: animation.value * pi * 6,
        child: Transform.scale(
          scale: 1 - .9 * animation.value,
          child: Opacity(opacity: 1 - animation.value, child: child),
        ),
      ),
      child: Container(
        height: 380,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const RadialGradient(
            colors: [Colors.white, water, Color(0xff07526b)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.photo, size: 100, color: Colors.white),
            const Text(
              'kanıt burada',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 60),
            FilledButton(
              onPressed: () => animation.forward().then((_) {
                if (context.mounted) Navigator.pop(context);
              }),
              child: const Text('SİFONU ÇEK'),
            ),
          ],
        ),
      ),
    ),
  );
}

class ChatGames extends StatelessWidget {
  const ChatGames({super.key});
  @override
  Widget build(BuildContext context) {
    const games = [
      'XOX',
      'Taş Kâğıt Makas',
      'Bu mu Şu mu',
      'İki Doğru Bir Yalan',
      'Aynı Cevabı Bul',
      'Damla Soru',
    ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: GridView.builder(
          shrinkWrap: true,
          itemCount: games.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
          ),
          itemBuilder: (_, i) => Card(
            color: i.isEven ? yellow : water,
            child: Center(
              child: Text(
                games[i],
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GameInfo {
  final String id, name, emoji, type;
  const GameInfo(this.id, this.name, this.emoji, this.type);
}

const partyGames = [
  GameInfo('race', 'Sifon Sprint', '🚽', 'YARIŞ'),
  GameInfo('catch', 'Damlayı Yakala', '💧', 'REFLEKS'),
  GameInfo('sumo', 'Peçete Sumo', '🧻', 'ARENA'),
  GameInfo('dodge', 'Sızıntıdan Kaç', '☔', 'KAÇIŞ'),
  GameInfo('target', 'Pompa Patlat', '🪠', 'HEDEF'),
  GameInfo('memory', 'Leke Hafızası', '🟨', 'HAFIZA'),
  GameInfo('panic', 'Sakın Basma', '🚨', 'SİNİR'),
  GameInfo('balance', 'Rulo Dengesi', '⚖️', 'DENGE'),
  GameInfo('pong', 'Gider Pong', '🏓', 'DÜELLO'),
  GameInfo('territory', 'Kuru Yer Kapmaca', '🧼', 'TAKTİK'),
];

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Büyük Oyunlar',
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ink,
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PECHATE PARTY',
                style: TextStyle(color: yellow, fontWeight: FontWeight.w900),
              ),
              Text(
                'Tek telefon. Dört parmak. Sıfır huzur.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                '2–4 kişi seç, telefonu masaya bırak.',
                style: TextStyle(color: Colors.white60),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(15),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: partyGames.length,
            itemBuilder: (_, i) {
              final game = partyGames[i];
              return Card(
                color: [
                  const Color(0xfffff2bd),
                  const Color(0xffdcf5f5),
                  const Color(0xfff1e8ff),
                ][i % 3],
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PartyGamePage(game: game),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(game.emoji, style: const TextStyle(fontSize: 30)),
                        const Spacer(),
                        Text(
                          game.name,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        Text(game.type, style: const TextStyle(fontSize: 8)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

class PartyGamePage extends StatefulWidget {
  final GameInfo game;
  const PartyGamePage({super.key, required this.game});
  @override
  State<PartyGamePage> createState() => _PartyGamePageState();
}

class _PartyGamePageState extends State<PartyGamePage> {
  int players = 0;
  List<int> scores = [];
  bool go = false;
  Timer? timer;
  void start(int count) {
    setState(() {
      players = widget.game.id == 'pong' ? 2 : count;
      scores = List.filled(players, 0);
      go = widget.game.id != 'panic';
    });
    if (!go) {
      timer = Timer(Duration(milliseconds: 1200 + Random().nextInt(2500)), () {
        if (mounted) setState(() => go = true);
      });
    }
  }

  void tap(int i) {
    if (!go) {
      win('P${i + 1} erken bastı!');
      return;
    }
    setState(() => scores[i]++);
    if (scores[i] >= (widget.game.id == 'territory' ? 13 : 10)) {
      win('P${i + 1} kazandı! Ortalık biraz ıslandı.');
    }
  }

  void win(String text) => showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: yellow,
      title: const Text('💦 RAUNT BİTTİ'),
      content: Text(text),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            start(players);
          },
          child: const Text('TEKRAR'),
        ),
      ],
    ),
  );
  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: yellow,
    appBar: AppBar(
      backgroundColor: yellow,
      title: Text(
        widget.game.name,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
    ),
    body: players == 0 ? playerSelect() : play(),
  );
  Widget playerSelect() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.game.emoji, style: const TextStyle(fontSize: 80)),
        const Text(
          'Kaç kişisiniz?',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 12,
          children: [2, 3, 4]
              .map(
                (n) => FilledButton(
                  onPressed: () => start(n),
                  style: FilledButton.styleFrom(
                    backgroundColor: paper,
                    foregroundColor: ink,
                    fixedSize: const Size(78, 70),
                  ),
                  child: Text(
                    '$n',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    ),
  );
  Widget play() => SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: List.generate(
              players,
              (i) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: Text(
                    'P${i + 1}: ${scores[i]}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: paper,
                border: Border.all(color: ink, width: 4),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Center(
                child: Text(
                  widget.game.id == 'panic'
                      ? (go ? 'BAS!' : 'SAKIN BASMA')
                      : widget.game.emoji,
                  style: const TextStyle(
                    fontSize: 70,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          const Text(
            'Tek tuş, kısa raund, bahanesi yok.',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: 2.1,
            children: List.generate(
              players,
              (i) => Padding(
                padding: const EdgeInsets.all(4),
                child: FilledButton(
                  onPressed: () => tap(i),
                  style: FilledButton.styleFrom(
                    backgroundColor: [
                      const Color(0xffff6b67),
                      water,
                      const Color(0xff8bd669),
                      const Color(0xffad8ced),
                    ][i],
                    foregroundColor: ink,
                  ),
                  child: Text(
                    'P${i + 1} · BAS!',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) => const SafeArea(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 55,
          backgroundColor: yellow,
          child: Text(
            'S',
            style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900),
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Samet',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
        ),
        Text('@alisametsunguc · İstanbul'),
        SizedBox(height: 20),
        Text(
          '248 Damla  ·  15 Sızıntı  ·  42 Galibiyet',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}
