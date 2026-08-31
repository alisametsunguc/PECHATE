// ignore_for_file: unnecessary_underscores

import 'dart:async';
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
  // Demo: yalnızca ilk üç konuşma 4+ mesaj gösterir.
  final unread = [8, 6, 4, 3, 3, 3, 2, 2, 2, 2, 1, 1, 1, 1, 0];
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
                physics: const ClampingScrollPhysics(),
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
        Positioned(
          left: 0,
          right: 0,
          top: 118,
          height: 132,
          child: IgnorePointer(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 220),
              opacity: hiddenUnread > 0 ? 1 : 0,
              child: DropCurtain(count: hiddenUnread),
            ),
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
      p.lineTo(
        x,
        top +
            sin(x / 22 + wave * pi * 2) * 4.5 +
            sin(x / 47 - wave * pi * 4) * 1.8,
      );
    }
    p
      ..lineTo(s.width, s.height)
      ..lineTo(0, s.height)
      ..close();
    final shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xffffdd48).withValues(alpha: .72),
        _yellow.withValues(alpha: .92),
        const Color(0xffd99500).withValues(alpha: .92),
      ],
    ).createShader(Offset.zero & s);
    c.drawPath(p, Paint()..shader = shader);
    c.drawPath(
      Path()
        ..moveTo(0, top)
        ..quadraticBezierTo(s.width * .35, top - 4, s.width * .7, top + 2)
        ..quadraticBezierTo(s.width * .9, top + 5, s.width, top),
      Paint()
        ..color = const Color(0xfffff5b8).withValues(alpha: .92)
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
    duration: const Duration(milliseconds: 900),
  )..repeat();
  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: c,
    builder: (_, __) => CustomPaint(
      painter: DropsPainter(
        progress: c.value,
        count: min(max(2, widget.count * 2), 8),
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
            colors: [
              const Color(0xfffff8c9),
              const Color(0xffffd42f),
              const Color(0xffd88c00),
            ],
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
  Timer? invitationTimer;
  _ChatGameInvite? invitation;
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

  Future<void> openGames() async {
    final gameId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ChatGameSheet(),
    );
    if (gameId == null || !mounted) return;
    final game = _chatGames.firstWhere((item) => item.id == gameId);
    setState(() => invitation = _ChatGameInvite(game));
    invitationTimer?.cancel();
    invitationTimer = Timer(const Duration(milliseconds: 1400), () {
      if (!mounted || invitation?.game.id != game.id) return;
      setState(() => invitation!.status = _InviteStatus.accepted);
    });
  }

  Future<void> startAcceptedGame() async {
    final activeInvite = invitation;
    if (activeInvite == null || activeInvite.status != _InviteStatus.accepted) {
      return;
    }
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            _ChatGameArena(game: activeInvite.game, opponentName: widget.name),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        messages.add('🎮 $result');
        invitation!.status = _InviteStatus.completed;
      });
    }
  }

  @override
  void dispose() {
    invitationTimer?.cancel();
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
          onPressed: openGames,
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
              if (invitation != null)
                _GameInviteCard(
                  invite: invitation!,
                  opponentName: widget.name,
                  onStart: startAcceptedGame,
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
                  onPressed: openGames,
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
            const SizedBox(height: 4),
            Text(
              'Bir oyun seç ve davet gönder.',
              style: TextStyle(color: _ink.withValues(alpha: .62)),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              itemCount: _chatGames.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
              ),
              itemBuilder: (_, i) => Card(
                color: i.isEven ? _yellow : _water,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.pop(context, _chatGames[i].id),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _chatGames[i].emoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _chatGames[i].name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          _chatGames[i].description,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
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

class _ChatGameInfo {
  final String id;
  final String name;
  final String emoji;
  final String description;

  const _ChatGameInfo(this.id, this.name, this.emoji, this.description);
}

const _chatGames = <_ChatGameInfo>[
  _ChatGameInfo('xox', 'XOX', '⭕', 'Üçünü yan yana getir.'),
  _ChatGameInfo('rps', 'Taş Kâğıt Makas', '✊', 'Seçimini gizli yap.'),
  _ChatGameInfo('either', 'Bu mu Şu mu', '⚡', 'Aynı tarafı seçin.'),
  _ChatGameInfo('lie', 'İki Doğru Bir Yalan', '🤥', 'Yalanı yakala.'),
  _ChatGameInfo('same', 'Aynı Cevabı Bul', '🧠', 'Aynı şeyi düşünün.'),
  _ChatGameInfo('drop', 'Damla Soru', '💧', 'Sohbeti derinleştir.'),
  _ChatGameInfo('story', 'Birlikte Hikâye', '📖', 'Sırayla tek cümle yazın.'),
  _ChatGameInfo('mirror', 'Ayna', '🪞', 'Birbirinizi ne kadar okuyorsunuz?'),
  _ChatGameInfo('capsule', 'Zaman Kapsülü', '⏳', 'Geleceğe iki gizli not.'),
];

enum _InviteStatus { waiting, accepted, completed }

class _ChatGameInvite {
  final _ChatGameInfo game;
  _InviteStatus status = _InviteStatus.waiting;

  _ChatGameInvite(this.game);
}

class _GameInviteCard extends StatelessWidget {
  final _ChatGameInvite invite;
  final String opponentName;
  final VoidCallback onStart;

  const _GameInviteCard({
    required this.invite,
    required this.opponentName,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final accepted = invite.status == _InviteStatus.accepted;
    final completed = invite.status == _InviteStatus.completed;
    return Container(
      margin: const EdgeInsets.only(top: 12, left: 30),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accepted ? _water : Colors.white,
        border: Border.all(color: _ink, width: 2),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(5),
        ),
      ),
      child: Row(
        children: [
          Text(invite.game.emoji, style: const TextStyle(fontSize: 38)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invite.game.name,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  completed
                      ? 'Oyun tamamlandı.'
                      : accepted
                      ? '$opponentName daveti kabul etti.'
                      : '$opponentName yanıtlıyor…',
                ),
              ],
            ),
          ),
          if (accepted)
            FilledButton(
              onPressed: onStart,
              style: FilledButton.styleFrom(backgroundColor: _ink),
              child: const Text('OYNA'),
            )
          else if (!completed)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
        ],
      ),
    );
  }
}

class _ChatGameArena extends StatefulWidget {
  final _ChatGameInfo game;
  final String opponentName;

  const _ChatGameArena({required this.game, required this.opponentName});

  @override
  State<_ChatGameArena> createState() => _ChatGameArenaState();
}

class _ChatGameArenaState extends State<_ChatGameArena> {
  final rng = Random();
  final board = List<String>.filled(9, '');
  final gameInput = TextEditingController();
  final storyLines = <String>[];
  String turn = 'X';
  String? firstChoice;
  String? capsuleNote;
  String? result;
  int stage = 0;
  int storyTurn = 0;
  late final int promptIndex;
  late final int lieIndex;
  late final int questionIndex;

  static const _eitherPrompts = [
    ('Gece yürüyüşü', 'Sabah kahvesi'),
    ('Deniz kenarı', 'Dağ evi'),
    ('Planlı buluşma', 'Ani kaçamak'),
    ('Sesli mesaj', 'Uzun mesaj'),
    ('Tatlı', 'Tuzlu'),
  ];
  static const _samePrompts = [
    ('Birlikte kaçsak nereye?', ['Sahil', 'Orman', 'Şehir', 'Ev']),
    ('Şu an ne iyi gider?', ['Kahve', 'Yemek', 'Müzik', 'Uyku']),
    ('Bizi anlatan renk?', ['Sarı', 'Mavi', 'Kırmızı', 'Mor']),
    ('Ortak süper gücümüz?', ['Işınlanma', 'Zihin okuma', 'Zaman', 'Şans']),
  ];
  static const _lieCards = [
    [
      'Bir keresinde uçağı kaçırdım.',
      'Gizlice şiir yazıyorum.',
      'Hiç dondurma yemedim.',
    ],
    [
      'Gece yüzmeye bayılırım.',
      'Bir ünlüyle karşılaştım.',
      'Kahve kokusunu sevmem.',
    ],
    [
      'Çocukken evden kaçtım.',
      'Üç dil konuşuyorum.',
      'Yağmurda yürümeyi severim.',
    ],
  ];
  static const _dropQuestions = [
    'Kimseye kolay kolay söylemediğin bir hayalin ne?',
    'Birlikte yaşayacağımız kusursuz bir gün nasıl başlardı?',
    'Bende ilk fark ettiğin ama hiç söylemediğin şey ne?',
    'Şu an hiçbir sonuç olmayacak olsa neyi itiraf ederdin?',
    'İkimizin hikâyesine bir isim versen ne olurdu?',
    'Beni tek bir şarkıyla anlatman gerekse hangisi olurdu?',
  ];
  static const _storyStarters = [
    'Şehrin bütün ışıkları söndüğünde yalnızca ikimizin telefonu çaldı.',
    'Masadaki sarı peçetenin altında yarına ait bir not vardı.',
    'Tren son durağı geçti ama ikimiz de inmeyi düşünmedik.',
    'Yağmur başladığında gökyüzünden su yerine küçük mektuplar düştü.',
  ];
  static const _mirrorPrompts = [
    (
      'Diğerinin en çok ihtiyaç duyduğu şey?',
      ['Dinlenmek', 'Anlaşılmak', 'Cesaret', 'Kahkaha'],
    ),
    (
      'Zor bir günde ona nasıl yaklaşmalı?',
      ['Sarıl', 'Dinle', 'Alan ver', 'Güldür'],
    ),
    ('İlişkinizin gizli gücü?', ['Güven', 'Merak', 'Sabır', 'Tutku']),
    (
      'Söylemeden anladığınız şey?',
      ['Özlemek', 'Kırılmak', 'Heyecan', 'Yorgunluk'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    promptIndex = rng.nextInt(_eitherPrompts.length);
    lieIndex = rng.nextInt(3);
    questionIndex = rng.nextInt(_dropQuestions.length);
    storyLines.add(_storyStarters[rng.nextInt(_storyStarters.length)]);
  }

  @override
  void dispose() {
    gameInput.dispose();
    super.dispose();
  }

  void finish(String value) => setState(() => result = value);

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _yellow,
    appBar: AppBar(
      backgroundColor: _yellow,
      title: Text(
        '${widget.game.emoji} ${widget.game.name}',
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
    ),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        child: result == null ? _game() : _resultCard(),
      ),
    ),
  );

  Widget _game() => Column(
    children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _ink,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          _instruction(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      const SizedBox(height: 14),
      Expanded(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _paper,
            border: Border.all(color: _ink, width: 4),
            borderRadius: BorderRadius.circular(28),
          ),
          child: switch (widget.game.id) {
            'xox' => _xox(),
            'rps' => _secretChoices(['✊', '✋', '✌️']),
            'either' => _secretChoices([
              _eitherPrompts[promptIndex].$1,
              _eitherPrompts[promptIndex].$2,
            ]),
            'lie' => _lie(),
            'same' => _secretChoices(
              _samePrompts[promptIndex % _samePrompts.length].$2,
            ),
            'drop' => _drop(),
            'story' => _story(),
            'mirror' => _secretChoices(
              _mirrorPrompts[promptIndex % _mirrorPrompts.length].$2,
            ),
            _ => _capsule(),
          },
        ),
      ),
    ],
  );

  String _instruction() => switch (widget.game.id) {
    'xox' => 'Sıra $turn oyuncusunda · İlk üçlü kazanır.',
    'rps' =>
      stage == 0
          ? 'Önce sen gizli seçimini yap.'
          : stage == 1
          ? 'Ekranı ${widget.opponentName} kişisine ver.'
          : '${widget.opponentName}, şimdi sen seç.',
    'either' || 'same' =>
      stage == 0
          ? 'Önce sen seç. Cevabın gizlenecek.'
          : stage == 1
          ? 'Ekranı ${widget.opponentName} kişisine ver.'
          : '${widget.opponentName}, içinden geleni seç.',
    'lie' => '${widget.opponentName} hakkında yalan olan cümleyi yakala.',
    'drop' => 'Damlayı aç. Cevaptan kaçmak yok.',
    'story' =>
      'Sıra ${storyTurn.isEven ? 'sende' : widget.opponentName}. Yalnızca bir cümle ekle.',
    'mirror' =>
      stage == 0
          ? '${widget.opponentName} ne derdi? Gizli seç.'
          : stage == 1
          ? 'Ekranı ${widget.opponentName} kişisine ver.'
          : '${widget.opponentName}, kendi cevabını seç.',
    _ =>
      stage == 0
          ? 'Geleceğe bir not bırak. Notun gizlenecek.'
          : stage == 1
          ? 'Kapsülü ${widget.opponentName} kişisine ver.'
          : '${widget.opponentName}, sen de bir not bırak.',
  };

  Widget _xox() => Center(
    child: AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 9,
        itemBuilder: (_, i) => FilledButton(
          onPressed: board[i].isEmpty ? () => _playXox(i) : null,
          style: FilledButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: i.isEven ? _water : Colors.white,
            disabledBackgroundColor: i.isEven ? _water : Colors.white,
            foregroundColor: _ink,
            disabledForegroundColor: _ink,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: _ink, width: 2),
            ),
          ),
          child: Text(
            board[i],
            style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    ),
  );

  void _playXox(int i) {
    setState(() {
      board[i] = turn;
      final winner = _winner();
      if (winner != null) {
        result = winner == 'Berabere'
            ? 'XOX berabere bitti. Rövanş şart!'
            : 'XOX kazananı: $winner 🎉';
      } else {
        turn = turn == 'X' ? 'O' : 'X';
      }
    });
  }

  String? _winner() {
    const lines = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    for (final line in lines) {
      if (board[line[0]].isNotEmpty &&
          board[line[0]] == board[line[1]] &&
          board[line[1]] == board[line[2]]) {
        return board[line[0]];
      }
    }
    return board.every((cell) => cell.isNotEmpty) ? 'Berabere' : null;
  }

  Widget _secretChoices(List<String> choices) {
    if (stage == 1) {
      return Center(
        child: FilledButton.icon(
          onPressed: () => setState(() => stage = 2),
          style: FilledButton.styleFrom(
            backgroundColor: _ink,
            minimumSize: const Size(220, 74),
          ),
          icon: const Icon(Icons.visibility_off),
          label: Text('${widget.opponentName} HAZIR'),
        ),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.game.id == 'same' || widget.game.id == 'mirror') ...[
          Text(
            widget.game.id == 'mirror'
                ? _mirrorPrompts[promptIndex % _mirrorPrompts.length].$1
                : _samePrompts[promptIndex % _samePrompts.length].$1,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 18),
        ],
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: choices
              .map(
                (choice) => FilledButton(
                  onPressed: () => _chooseSecret(choice),
                  style: FilledButton.styleFrom(
                    backgroundColor: _water,
                    foregroundColor: _ink,
                    minimumSize: const Size(125, 70),
                    side: const BorderSide(color: _ink, width: 2),
                  ),
                  child: Text(
                    choice,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: widget.game.id == 'rps' ? 34 : 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  void _chooseSecret(String choice) {
    if (stage == 0) {
      setState(() {
        firstChoice = choice;
        stage = 1;
      });
      return;
    }
    if (widget.game.id == 'rps') {
      const beats = {'✊': '✌️', '✋': '✊', '✌️': '✋'};
      final outcome = firstChoice == choice
          ? 'Berabere! İkiniz de $choice seçtiniz.'
          : beats[firstChoice] == choice
          ? 'Sen kazandın: $firstChoice, $choice seçimini yendi.'
          : '${widget.opponentName} kazandı: $choice, $firstChoice seçimini yendi.';
      finish('Taş Kâğıt Makas · $outcome');
    } else {
      final matched = firstChoice == choice;
      finish(
        matched
            ? '${widget.game.name}: Aynı cevabı verdiniz — $choice 💦'
            : '${widget.game.name}: Sen “$firstChoice”, ${widget.opponentName} “$choice” dedi.',
      );
    }
  }

  Widget _lie() {
    final card = _lieCards[promptIndex % _lieCards.length];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        card.length,
        (i) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: FilledButton(
            onPressed: () => finish(
              i == lieIndex
                  ? 'Yalanı yakaladın! “${card[i]}” doğru cevapti. 🤥'
                  : 'Yalan kaçtı! Asıl yalan: “${card[lieIndex]}”',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: i.isEven ? Colors.white : _water,
              foregroundColor: _ink,
              minimumSize: const Size.fromHeight(72),
              side: const BorderSide(color: _ink, width: 2),
            ),
            child: Text(
              card[i],
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ),
    );
  }

  Widget _drop() => Center(
    child: InkWell(
      borderRadius: BorderRadius.circular(150),
      onTap: stage == 0
          ? () => setState(() => stage = 1)
          : () => finish('Damla Soru: “${_dropQuestions[questionIndex]}”'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 450),
        width: stage == 0 ? 190 : 285,
        height: stage == 0 ? 240 : 300,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: _water,
          border: Border.all(color: _ink, width: 4),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(150),
            topRight: const Radius.circular(150),
            bottomLeft: const Radius.circular(150),
            bottomRight: Radius.circular(stage == 0 ? 18 : 90),
          ),
        ),
        child: Center(
          child: Text(
            stage == 0 ? '💧\nAÇ' : _dropQuestions[questionIndex],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    ),
  );

  Widget _story() => Column(
    children: [
      Expanded(
        child: ListView.builder(
          itemCount: storyLines.length,
          itemBuilder: (_, i) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: i == 0
                  ? _ink
                  : i.isEven
                  ? _water
                  : _yellow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              storyLines[i],
              style: TextStyle(
                color: i == 0 ? Colors.white : _ink,
                fontWeight: i == 0 ? FontWeight.w900 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 10),
      TextField(
        controller: gameInput,
        maxLength: 140,
        maxLines: 2,
        decoration: InputDecoration(
          hintText: 'Hikâyeye tek cümle ekle…',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
      FilledButton.icon(
        onPressed: _addStorySentence,
        style: FilledButton.styleFrom(
          backgroundColor: _ink,
          minimumSize: const Size.fromHeight(52),
        ),
        icon: const Icon(Icons.auto_stories),
        label: const Text('TEK CÜMLEYİ EKLE'),
      ),
    ],
  );

  void _addStorySentence() {
    var sentence = gameInput.text.trim().replaceAll('\n', ' ');
    if (sentence.isEmpty) return;
    final punctuation = RegExp(r'[.!?]').allMatches(sentence).length;
    if (punctuation > 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Her turda yalnızca bir cümle yazabilirsin.'),
        ),
      );
      return;
    }
    if (!RegExp(r'[.!?]$').hasMatch(sentence)) sentence = '$sentence.';
    final author = storyTurn.isEven ? 'Sen' : widget.opponentName;
    setState(() {
      storyLines.add('$author: $sentence');
      storyTurn++;
      gameInput.clear();
      if (storyTurn == 6) {
        result = 'Birlikte Hikâye tamamlandı:\n${storyLines.join(' ')}';
      }
    });
  }

  Widget _capsule() {
    if (stage == 1) {
      return Center(
        child: FilledButton.icon(
          onPressed: () => setState(() => stage = 2),
          style: FilledButton.styleFrom(
            backgroundColor: _ink,
            minimumSize: const Size(235, 74),
          ),
          icon: const Icon(Icons.lock),
          label: Text('${widget.opponentName} HAZIR'),
        ),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('⏳', style: TextStyle(fontSize: 72)),
        const SizedBox(height: 12),
        TextField(
          controller: gameInput,
          maxLength: 120,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: stage == 0
                ? 'Bir yıl sonraki ikinize not…'
                : 'Senin gelecek notun…',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
          ),
        ),
        FilledButton.icon(
          onPressed: _sealCapsule,
          style: FilledButton.styleFrom(backgroundColor: _ink),
          icon: const Icon(Icons.lock_outline),
          label: const Text('NOTU MÜHÜRLE'),
        ),
      ],
    );
  }

  void _sealCapsule() {
    final note = gameInput.text.trim();
    if (note.isEmpty) return;
    if (stage == 0) {
      setState(() {
        capsuleNote = note;
        gameInput.clear();
        stage = 1;
      });
    } else {
      finish(
        'Zaman Kapsülü mühürlendi ⏳\nSen: “$capsuleNote”\n${widget.opponentName}: “$note”',
      );
    }
  }

  Widget _resultCard() => Center(
    child: Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _paper,
        border: Border.all(color: _ink, width: 4),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.game.emoji, style: const TextStyle(fontSize: 62)),
          const SizedBox(height: 12),
          Text(
            result!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, result),
            style: FilledButton.styleFrom(backgroundColor: _ink),
            icon: const Icon(Icons.chat_bubble),
            label: const Text('SOHBETE GÖNDER'),
          ),
        ],
      ),
    ),
  );
}
