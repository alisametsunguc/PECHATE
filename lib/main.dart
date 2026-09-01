import 'dart:async';
import 'dart:typed_data';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
      duration: const Duration(milliseconds: 2600),
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
            ((t - .05) / .88).clamp(0.0, 1.0),
          );
          final vanish = Curves.easeInQuad.transform(
            ((t - .88) / .12).clamp(0.0, 1.0),
          );
          final scale = 1 - crumple * .93;
          return Opacity(
            opacity: 1 - vanish,
            child: Transform.scale(
              scale: scale,
              child: Transform.rotate(
                angle: sin(crumple * pi * 4.5) * .045,
                child: _CrumpledTissue(progress: crumple),
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
    width: 330,
    height: 360,
    child: ClipPath(
      clipper: _OrganicTissueClipper(progress),
      child: Stack(
        fit: StackFit.expand,
        children: [
          OverflowBox(
            maxWidth: 620,
            maxHeight: 620,
            child: Transform.translate(
              offset: const Offset(0, 41),
              child: Image.asset(
                'assets/branding/pecete-chat-logo-v3.png',
                width: 620,
                height: 620,
                fit: BoxFit.cover,
              ),
            ),
          ),
          CustomPaint(painter: _CreasePainter(progress)),
        ],
      ),
    ),
  );
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
      final foldedRadius =
          size.shortestSide *
          (.43 * (1 - progress) + .32 + sin(i * 2.17 + progress * 7) * .028);
      final radius =
          softSquareRadius * (1 - progress) +
          foldedRadius * progress +
          sin(i * 1.73 + progress * 11) * (3 + progress * 4);
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
  final List<_FeedComment> comments = [
    const _FeedComment('Ece', 'Burası tam kaybolup geri gelmelikmiş.', '🌊'),
    const _FeedComment('Kerem', 'Konum at, pusulayı ben getiririm.', '🧭'),
    const _FeedComment('Duru', 'Fotoğrafın sesi olsa lo-fi çalardı.', '🎧'),
  ];

  void openComments() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CommentsSheet(
        postOwner: widget.index.isEven ? 'Maya' : 'Alex',
        comments: comments,
        totalCount: 31 + comments.length - 3,
        onAdded: (comment) {
          setState(() => comments.add(comment));
        },
      ),
    );
  }

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
              onPressed: openComments,
              icon: const Icon(Icons.comment_outlined),
              label: Text('${31 + comments.length - 3}'),
            ),
          ],
        ),
      ],
    ),
  );
}

class _FeedComment {
  final String name, text, emoji;
  const _FeedComment(this.name, this.text, this.emoji);
}

class _CommentsSheet extends StatefulWidget {
  final String postOwner;
  final List<_FeedComment> comments;
  final int totalCount;
  final ValueChanged<_FeedComment> onAdded;

  const _CommentsSheet({
    required this.postOwner,
    required this.comments,
    required this.totalCount,
    required this.onAdded,
  });

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final controller = TextEditingController();

  void sendComment() {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    widget.onAdded(_FeedComment('Sen', text, '💧'));
    controller.clear();
    setState(() {});
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    initialChildSize: .74,
    minChildSize: .45,
    maxChildSize: .94,
    expand: false,
    builder: (_, scrollController) => Container(
      decoration: const BoxDecoration(
        color: paper,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: ink, width: 3)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 52,
            height: 5,
            decoration: BoxDecoration(
              color: ink,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 13, 10, 11),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: yellow,
                    shape: BoxShape.circle,
                    border: Border.all(color: ink, width: 2),
                  ),
                  child: const Text('💬', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'YORUMLAR',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.2,
                        ),
                      ),
                      Text(
                        '${widget.postOwner}’nın gönderisine ${widget.totalCount} damla',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: ink, thickness: 2),
          Expanded(
            child: ListView.separated(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 15, 16, 20),
              itemCount: widget.comments.length,
              separatorBuilder: (_, _) => const SizedBox(height: 11),
              itemBuilder: (_, index) {
                final comment = widget.comments[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 39,
                      height: 39,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: index.isEven ? water : yellow,
                        shape: BoxShape.circle,
                        border: Border.all(color: ink, width: 2),
                      ),
                      child: Text(comment.emoji),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: ink, width: 1.5),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comment.name,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(comment.text),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          AnimatedPadding(
            duration: const Duration(milliseconds: 160),
            padding: EdgeInsets.fromLTRB(
              14,
              10,
              14,
              MediaQuery.viewInsetsOf(context).bottom + 12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => sendComment(),
                    decoration: InputDecoration(
                      hintText: 'Bir damla yorum bırak...',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: const BorderSide(color: ink, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: const BorderSide(color: ink, width: 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: sendComment,
                  style: IconButton.styleFrom(
                    backgroundColor: water,
                    foregroundColor: ink,
                    side: const BorderSide(color: ink, width: 2),
                  ),
                  icon: const Icon(Icons.water_drop_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
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

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = 'Samet';
  String handle = '@alisametsunguc';
  String bio = 'Kahveyi soğumadan, mesajı cevapsız bırakmadan severim.';
  String mood = 'Keyfim damla damla';
  final ImagePicker picker = ImagePicker();
  Uint8List? avatarBytes;
  final List<_ProfileMedia> media = [];
  late List<String> firstMessages;
  int selectedMessage = 0;

  @override
  void initState() {
    super.initState();
    firstMessages = buildFirstMessages();
  }

  List<String> buildFirstMessages() {
    final options = <String>[
      'Kahve konusunda bu kadar iddialıysan siparişimi sana bırakıyorum ☕',
      'Kötü espri yarışı yapalım mı? Kaybeden daha kötüsünü anlatır.',
      'Sosyal pilin düşükse tek emojilik sohbetle başlayabiliriz 🔋',
      'Podcast uzunluğundaki sesli mesajının konusu ne olurdu? 🎙️',
      'Beklenmedik iltifat hakkımı şimdi mi kullanayım, sonra mı?',
      'Makarna bilgesi rozetini hangi tarifle kazandın? 🍝',
      'Gece kuşuysan en iyi sohbet saatini tahmin edeyim: 01.17?',
      'Profilindeki en doğru ve en abartılı cümleyi söyle.',
      'Birlikte beş dakikada saçma bir hikâye yazsak ilk cümlen ne olurdu?',
      '${name.split(' ').first}, bugün keyfini bir film adıyla anlatsan hangisi olurdu?',
    ];
    if (mood == 'Sosyal pil %3') {
      options.insert(
        0,
        'Konuşmak zorunda değiliz; bana sadece bugünün emojisini at 🪫',
      );
    } else if (mood == 'Kahveyle konuşurum') {
      options.insert(
        0,
        'İlk sorum ciddi: kahve mi seni seçti, sen mi kahveyi?',
      );
    } else if (mood == 'Gülmeye geldim') {
      options.insert(0, 'Seni güldürmek için bir deneme hakkım var mı? 🤡');
    }
    options.shuffle(Random());
    return options.take(3).toList();
  }

  void refreshFirstMessages() {
    setState(() {
      firstMessages = buildFirstMessages();
      selectedMessage = 0;
    });
  }

  void sendFirstMessage() {
    final message = firstMessages[selectedMessage];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ink,
        content: Text('$name’e gönderildi: “$message”'),
        action: SnackBarAction(
          label: 'GERİ AL',
          textColor: yellow,
          onPressed: () {},
        ),
      ),
    );
  }

  Future<void> pickAvatar() async {
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1200,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (mounted) setState(() => avatarBytes = bytes);
  }

  Future<void> addPhotos() async {
    final files = await picker.pickMultiImage(
      imageQuality: 82,
      maxWidth: 1600,
      limit: 8,
    );
    if (files.isEmpty) return;
    final additions = <_ProfileMedia>[];
    for (final file in files) {
      additions.add(
        _ProfileMedia(name: file.name, bytes: await file.readAsBytes()),
      );
    }
    if (mounted) setState(() => media.addAll(additions));
  }

  Future<void> addVideo() async {
    final file = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 2),
    );
    if (file == null || !mounted) return;
    setState(() => media.add(_ProfileMedia(name: file.name, isVideo: true)));
  }

  void editProfile() {
    final nameController = TextEditingController(text: name);
    final bioController = TextEditingController(text: bio);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: paper,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          22,
          20,
          MediaQuery.viewInsetsOf(sheetContext).bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Kendini biraz cilala',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const Text('Fazla parlatma, göz alıyor.'),
            const SizedBox(height: 18),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'İsim',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bioController,
              maxLines: 3,
              maxLength: 110,
              decoration: const InputDecoration(
                labelText: 'Kısaca sen',
                border: OutlineInputBorder(),
              ),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  name = nameController.text.trim().isEmpty
                      ? name
                      : nameController.text.trim();
                  bio = bioController.text.trim().isEmpty
                      ? bio
                      : bioController.text.trim();
                  firstMessages = buildFirstMessages();
                  selectedMessage = 0;
                });
                Navigator.pop(sheetContext);
              },
              style: FilledButton.styleFrom(
                backgroundColor: ink,
                foregroundColor: paper,
              ),
              child: const Text('OLDU BU'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
          sliver: SliverList.list(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PROFİL',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                          ),
                        ),
                        Text(
                          'Ben, kendim ve Wi-Fi',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filled(
                    onPressed: editProfile,
                    style: IconButton.styleFrom(
                      backgroundColor: yellow,
                      foregroundColor: ink,
                      side: const BorderSide(color: ink, width: 2),
                    ),
                    icon: const Icon(Icons.edit_note_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Transform.rotate(
                angle: -.018,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: ink, width: 3),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(7),
                      topRight: Radius.circular(24),
                      bottomLeft: Radius.circular(21),
                      bottomRight: Radius.circular(9),
                    ),
                    boxShadow: const [
                      BoxShadow(color: ink, offset: Offset(5, 6)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: pickAvatar,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 92,
                                  height: 106,
                                  alignment: Alignment.center,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    color: water,
                                    border: Border.all(color: ink, width: 3),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(48),
                                      topRight: Radius.circular(48),
                                      bottomLeft: Radius.circular(48),
                                      bottomRight: Radius.circular(13),
                                    ),
                                  ),
                                  child: avatarBytes == null
                                      ? Text(
                                          name.characters.first.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 43,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        )
                                      : Image.memory(
                                          avatarBytes!,
                                          width: 92,
                                          height: 106,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                const Positioned(
                                  right: -8,
                                  bottom: -7,
                                  child: CircleAvatar(
                                    radius: 17,
                                    backgroundColor: yellow,
                                    child: Icon(
                                      Icons.add_a_photo_rounded,
                                      color: ink,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 17),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 27,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text('$handle · İstanbul'),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: yellow.withValues(alpha: .28),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '💧 $mood',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          bio,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 17),
                      const Row(
                        children: [
                          _ProfileStat(value: '248', label: 'Damla'),
                          _ProfileStat(value: '15', label: 'Sızıntı'),
                          _ProfileStat(value: '42', label: 'Muhabbet'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  const Expanded(
                    child: _ProfileTitle(
                      title: 'Benden kareler',
                      subtitle:
                          'Fotoğraf olur, video olur; vesikalık şart değil.',
                    ),
                  ),
                  IconButton.outlined(
                    tooltip: 'Fotoğraf ekle',
                    onPressed: addPhotos,
                    style: IconButton.styleFrom(
                      foregroundColor: ink,
                      side: const BorderSide(color: ink, width: 2),
                    ),
                    icon: const Icon(Icons.add_photo_alternate_rounded),
                  ),
                  const SizedBox(width: 6),
                  IconButton.filled(
                    tooltip: 'Video ekle',
                    onPressed: addVideo,
                    style: IconButton.styleFrom(
                      backgroundColor: water,
                      foregroundColor: ink,
                      side: const BorderSide(color: ink, width: 2),
                    ),
                    icon: const Icon(Icons.video_call_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (media.isEmpty)
                GestureDetector(
                  onTap: addPhotos,
                  child: Container(
                    height: 145,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: water.withValues(alpha: .12),
                      border: Border.all(color: ink, width: 2),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.collections_rounded, size: 37),
                        SizedBox(height: 6),
                        Text(
                          'Henüz bir şey yok. Gizemli ama biraz fazla gizemli.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text('Dokun ve ilk fotoğrafını ekle.'),
                      ],
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 190,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: media.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (_, index) => _ProfileMediaCard(
                      item: media[index],
                      onRemove: () => setState(() => media.removeAt(index)),
                    ),
                  ),
                ),
              const SizedBox(height: 28),
              const _ProfileTitle(
                title: 'Bugün nasılız?',
                subtitle: 'Dürüst ol, algoritma yargılamıyor. Şimdilik.',
              ),
              const SizedBox(height: 11),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    [
                          'Keyfim damla damla',
                          'Sosyal pil %3',
                          'Kahveyle konuşurum',
                          'Gülmeye geldim',
                        ]
                        .map(
                          (item) => ChoiceChip(
                            label: Text(item),
                            selected: mood == item,
                            selectedColor: water,
                            side: const BorderSide(color: ink, width: 2),
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                            onSelected: (_) {
                              setState(() {
                                mood = item;
                                firstMessages = buildFirstMessages();
                                selectedMessage = 0;
                              });
                            },
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 27),
              const _ProfileTitle(
                title: 'Kullanım kılavuzum',
                subtitle: 'Yan etkiler arasında ani kahkaha bulunabilir.',
              ),
              const SizedBox(height: 11),
              const Row(
                children: [
                  Expanded(
                    child: _TraitCard(
                      emoji: '🎙️',
                      title: 'Sesli mesaj',
                      text: '1:32’yi geçince podcast olur.',
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _TraitCard(
                      emoji: '👻',
                      title: 'Kaybolma hızı',
                      text: 'Mesai saatinde biraz gizemli.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Expanded(
                    child: _TraitCard(
                      emoji: '🤡',
                      title: 'Mizah seviyesi',
                      text: 'Kötü espriye bile emek verir.',
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _TraitCard(
                      emoji: '☕',
                      title: 'Yakıt türü',
                      text: 'Kahve ve beklenmedik iltifat.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 27),
              const _ProfileTitle(
                title: 'Kazandığım saçma şeyler',
                subtitle: 'CV’ye yazılmaz ama burada gururla sergilenir.',
              ),
              const SizedBox(height: 12),
              const Wrap(
                spacing: 9,
                runSpacing: 9,
                children: [
                  _Badge(emoji: '🫂', text: 'Buz Kırıcı'),
                  _Badge(emoji: '🌙', text: 'Gece Kuşu'),
                  _Badge(emoji: '💦', text: '100 Damla'),
                  _Badge(emoji: '🍝', text: 'Makarna Bilgesi'),
                ],
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: yellow,
                  border: Border.all(color: ink, width: 3),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('💬', style: TextStyle(fontSize: 31)),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'İLK DAMLA',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.4,
                                ),
                              ),
                              Text(
                                'Ne yazacağını düşünme, birini seç.',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Yeni mesajlar getir',
                          onPressed: refreshFirstMessages,
                          icon: const Icon(Icons.refresh_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 11),
                    ...List.generate(
                      firstMessages.length,
                      (index) => GestureDetector(
                        onTap: () => setState(() => selectedMessage = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(11),
                          decoration: BoxDecoration(
                            color: selectedMessage == index
                                ? paper
                                : Colors.white54,
                            border: Border.all(
                              color: ink,
                              width: selectedMessage == index ? 3 : 1.5,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  firstMessages[index],
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    height: 1.22,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                selectedMessage == index
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: sendFirstMessage,
                        style: FilledButton.styleFrom(
                          backgroundColor: ink,
                          foregroundColor: paper,
                        ),
                        icon: const Icon(Icons.water_drop_rounded, size: 18),
                        label: Text('$name’E GÖNDER'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ProfileStat extends StatelessWidget {
  final String value, label;
  const _ProfileStat({required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class _ProfileTitle extends StatelessWidget {
  final String title, subtitle;
  const _ProfileTitle({required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
      ),
      Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Colors.black54),
      ),
    ],
  );
}

class _TraitCard extends StatelessWidget {
  final String emoji, title, text;
  const _TraitCard({
    required this.emoji,
    required this.title,
    required this.text,
  });
  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 130),
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: ink, width: 2),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 27)),
        const SizedBox(height: 5),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        Text(text, style: const TextStyle(fontSize: 12, height: 1.25)),
      ],
    ),
  );
}

class _Badge extends StatelessWidget {
  final String emoji, text;
  const _Badge({required this.emoji, required this.text});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: ink, width: 2),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Text(
      '$emoji  $text',
      style: const TextStyle(fontWeight: FontWeight.w800),
    ),
  );
}

class _ProfileMedia {
  final String name;
  final Uint8List? bytes;
  final bool isVideo;

  const _ProfileMedia({required this.name, this.bytes, this.isVideo = false});
}

class _ProfileMediaCard extends StatelessWidget {
  final _ProfileMedia item;
  final VoidCallback onRemove;

  const _ProfileMediaCard({required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 145,
    child: Stack(
      children: [
        Positioned.fill(
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: item.isVideo ? ink : Colors.white,
              border: Border.all(color: ink, width: 3),
              borderRadius: BorderRadius.circular(18),
            ),
            child: item.isVideo
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 27,
                        backgroundColor: water,
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: ink,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 9),
                      const Text(
                        'VİDEO',
                        style: TextStyle(
                          color: paper,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  )
                : Image.memory(item.bytes!, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 7,
          right: 7,
          child: IconButton.filled(
            onPressed: onRemove,
            style: IconButton.styleFrom(
              backgroundColor: paper,
              foregroundColor: ink,
              minimumSize: const Size(31, 31),
              padding: EdgeInsets.zero,
              side: const BorderSide(color: ink, width: 2),
            ),
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
        ),
      ],
    ),
  );
}
