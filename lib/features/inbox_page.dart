// ignore_for_file: unnecessary_underscores

import 'dart:math';

import 'package:flutter/material.dart';

const _ink = Color(0xff201c18),
    _paper = Color(0xfffffbf1),
    _yellow = Color(0xfff2b705),
    _water = Color(0xff62d6e5);

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});
  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  final scroll = ScrollController();
  final people = [
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
  final unread = [8, 7, 6, 5, 4, 4, 3, 3, 2, 2, 2, 1, 1, 1, 0];
  int hiddenUnread = 0;
  @override
  void initState() {
    super.initState();
    scroll.addListener(_updateDrops);
  }

  void _updateDrops() {
    final hidden = (scroll.offset / 82).floor().clamp(0, people.length);
    final count = unread.take(hidden).where((n) => n > 0).length;
    if (count != hiddenUnread) setState(() => hiddenUnread = count);
  }

  String get hint {
    final n = unread.where((v) => v > 0).length;
    if (n >= 10) return 'Gelen kutunun tuvalet molasına ihtiyacı var.';
    if (n >= 6) return 'Taşmadan önce aşağı çek.';
    if (n >= 2) return 'Aşağı çek. Bir şeyler sızdırıyor.';
    if (n == 1) return 'Birisi daha fazla tutamamış.';
    return 'Can you feel the relief?';
  }

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Stack(
      children: [
        Column(
          children: [
            Container(
              height: 70,
              color: _yellow,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'YOUR INBOX',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          'Mesajlar',
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text('💧', style: TextStyle(fontSize: 27)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              color: _ink,
              child: Text(
                hint,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scroll,
                physics: const BouncingScrollPhysics(),
                itemCount: people.length,
                itemExtent: 82,
                itemBuilder: (_, i) => LiquidMessageTile(
                  name: people[i],
                  unread: unread[i],
                  onTap: () {
                    setState(() => unread[i] = 0);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(name: people[i]),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        IgnorePointer(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 220),
            opacity: hiddenUnread > 0 ? 1 : 0,
            child: DropCurtain(count: hiddenUnread),
          ),
        ),
      ],
    ),
  );
}

class LiquidMessageTile extends StatefulWidget {
  final String name;
  final int unread;
  final VoidCallback onTap;
  const LiquidMessageTile({
    super.key,
    required this.name,
    required this.unread,
    required this.onTap,
  });
  @override
  State<LiquidMessageTile> createState() => _LiquidMessageTileState();
}

class _LiquidMessageTileState extends State<LiquidMessageTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController wave = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1900),
  )..repeat();

  @override
  void dispose() {
    wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fill = (widget.unread / 4).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: wave,
                  builder: (_, child) => CustomPaint(
                    painter: LiquidPainter(fill: fill, wave: wave.value),
                  ),
                ),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                leading: CircleAvatar(
                  backgroundColor: widget.name.hashCode.isEven
                      ? _yellow
                      : _water,
                  child: Text(
                    widget.name[0],
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                title: Text(
                  widget.name,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  widget.unread > 0
                      ? 'Yeni bir şey sızdırdı…'
                      : 'Sonra görüşürüz.',
                ),
                trailing: widget.unread > 0
                    ? Badge(
                        backgroundColor: _ink,
                        label: Text(
                          widget.unread >= 4 ? '4+' : '${widget.unread}',
                        ),
                      )
                    : const Text('✓', style: TextStyle(color: Colors.black38)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LiquidPainter extends CustomPainter {
  final double fill, wave;
  LiquidPainter({required this.fill, required this.wave});
  @override
  void paint(Canvas c, Size s) {
    if (fill <= 0) return;
    final top = s.height * (1 - fill), p = Path()..moveTo(0, top);
    for (double x = 0; x <= s.width; x += 4) {
      p.lineTo(x, top + sin(x / 25 + wave * pi * 2) * 3);
    }
    p
      ..lineTo(s.width, s.height)
      ..lineTo(0, s.height)
      ..close();
    final shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        _water.withValues(alpha: .58),
        const Color(0xff1ba8c4).withValues(alpha: .72),
      ],
    ).createShader(Offset.zero & s);
    c.drawPath(p, Paint()..shader = shader);
    c.drawPath(
      Path()
        ..moveTo(0, top)
        ..quadraticBezierTo(s.width * .35, top - 4, s.width * .7, top + 2)
        ..quadraticBezierTo(s.width * .9, top + 5, s.width, top),
      Paint()
        ..color = Colors.white.withValues(alpha: .65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant LiquidPainter old) =>
      old.fill != fill || old.wave != wave;
}

class DropCurtain extends StatefulWidget {
  final int count;
  const DropCurtain({super.key, required this.count});
  @override
  State<DropCurtain> createState() => _DropCurtainState();
}

class _DropCurtainState extends State<DropCurtain>
    with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();
  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Positioned(
    left: 0,
    right: 0,
    top: 125,
    height: 88,
    child: AnimatedBuilder(
      animation: c,
      builder: (_, __) => CustomPaint(
        painter: DropsPainter(progress: c.value, count: min(widget.count, 8)),
      ),
    ),
  );
}

class DropsPainter extends CustomPainter {
  final double progress;
  final int count;
  DropsPainter({required this.progress, required this.count});
  @override
  void paint(Canvas c, Size s) {
    for (int i = 0; i < count; i++) {
      final t = (progress + i / count) % 1,
          x = s.width * (.12 + .76 * ((i * 37) % count) / (max(1, count - 1))),
          y = -10 + t * s.height,
          r = 4 + (i % 3) * 1.4;
      final p = Path()
        ..moveTo(x, y - r * 1.8)
        ..quadraticBezierTo(x + r, y - r * .4, x + r * .75, y + r * .5)
        ..quadraticBezierTo(x, y + r * 1.4, x - r * .75, y + r * .5)
        ..quadraticBezierTo(x - r, y - r * .4, x, y - r * 1.8);
      c.drawPath(
        p,
        Paint()
          ..shader = RadialGradient(
            colors: [Colors.white, _water, const Color(0xff087d9b)],
          ).createShader(Rect.fromCircle(center: Offset(x, y), radius: r * 2)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant DropsPainter old) => true;
}

class ChatPage extends StatefulWidget {
  final String name;
  const ChatPage({super.key, required this.name});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final input = TextEditingController();
  final messages = <String>[
    'Bu fotoğrafı açmadan da yazabiliyorsun.',
    'İddialı konuşma 😏',
  ];
  bool viewed = false;
  void send() {
    final v = input.text.trim();
    if (v.isEmpty) return;
    setState(() => messages.add(v));
    input.clear();
  }

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _paper,
    appBar: AppBar(
      backgroundColor: _yellow,
      title: Text(
        widget.name,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      actions: [
        IconButton(
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const ChatGameSheet(),
          ),
          icon: const Icon(Icons.sports_esports),
        ),
      ],
    ),
    body: Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(14),
            children: [
              Card(
                color: _ink,
                child: ListTile(
                  enabled: !viewed,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => const FlushViewer(),
                    ).then((_) {
                      if (mounted) setState(() => viewed = true);
                    });
                  },
                  leading: CircleAvatar(
                    backgroundColor: _water,
                    child: Icon(viewed ? Icons.check : Icons.visibility),
                  ),
                  title: Text(
                    viewed ? 'Sifonlandı.' : 'Tek gösterimlik fotoğraf',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  subtitle: Text(
                    viewed ? 'Kanıt artık yok.' : 'Açınca girdaba gider.',
                    style: const TextStyle(color: Colors.white60),
                  ),
                ),
              ),
              ...messages.indexed.map(
                (e) => Align(
                  alignment: e.$1 > 1
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: e.$1 > 1 ? _yellow : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(e.$2),
                  ),
                ),
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    builder: (_) => const ChatGameSheet(),
                  ),
                  icon: const Icon(Icons.add_circle),
                ),
                Expanded(
                  child: TextField(
                    controller: input,
                    onSubmitted: (_) => send(),
                    decoration: InputDecoration(
                      hintText: 'İçinde tutma…',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(24),
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
  late final c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
  );
  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent,
    child: AnimatedBuilder(
      animation: c,
      builder: (_, child) => Transform.rotate(
        angle: c.value * pi * 7,
        child: Transform.scale(
          scale: 1 - .94 * c.value,
          child: Opacity(opacity: 1 - c.value, child: child),
        ),
      ),
      child: Container(
        height: 390,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const RadialGradient(
            colors: [Colors.white, _water, Color(0xff07526b), _ink],
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
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 70),
            FilledButton.icon(
              onPressed: () => c.forward().then((_) {
                if (context.mounted) Navigator.pop(context);
              }),
              icon: const Icon(Icons.water),
              label: const Text('SİFONU ÇEK'),
            ),
          ],
        ),
      ),
    ),
  );
}

class ChatGameSheet extends StatelessWidget {
  const ChatGameSheet({super.key});
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sohbette Oyna',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            GridView.builder(
              shrinkWrap: true,
              itemCount: games.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
              ),
              itemBuilder: (_, i) => Card(
                color: i.isEven ? _yellow : _water,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
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
          ],
        ),
      ),
    );
  }
}
