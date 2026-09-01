// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

const _ink = Color(0xff201c18),
    _paper = Color(0xfffffbf1),
    _yellow = Color(0xfff2b705),
    _water = Color(0xff62d6e5);

class GameInfo {
  final String id, name, emoji, type, subtitle;
  const GameInfo(this.id, this.name, this.emoji, this.type, this.subtitle);
}

const games = [
  GameInfo(
    'shoot',
    'Cep Düellosu',
    '🔫',
    '2–4 OYUNCU',
    'Dönen nişanla rakibini vur',
  ),
  GameInfo(
    'race',
    'Turbo Dokunuş',
    '🏎️',
    '2–4 OYUNCU',
    'En hızlı parmak kazanır',
  ),
  GameInfo('catch', 'Yıldızı Kap', '⭐', '2–4 OYUNCU', 'Doğru anda ilk sen bas'),
  GameInfo(
    'sumo',
    'Mini Sumo',
    '🟠',
    '2–4 OYUNCU',
    'Rakibini alanın dışına it',
  ),
  GameInfo(
    'dodge',
    'Son Platform',
    '🏃',
    '2–4 OYUNCU',
    'Tehlikeli şeritten kaç',
  ),
  GameInfo(
    'territory',
    'Renk Kapmaca',
    '🟩',
    '2–4 OYUNCU',
    'En çok kareyi ele geçir',
  ),
];

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Stack(
      children: [
        const Positioned.fill(
          child: CustomPaint(painter: _GamesBackdropPainter()),
        ),
        // dart format off
        Column(
          children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 15, 16, 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Mini Oyunlar',
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _ink,
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HIZLI OYNA',
                style: TextStyle(
                  color: _yellow,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'Aynı ekranda arkadaşlarına meydan oku.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                '6 oyun · 2–4 oyuncu · joystick kontrolleri',
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
            itemCount: games.length,
            itemBuilder: (_, i) {
              final g = games[i];
              return Card(
                color: [
                  const Color(0xfffff2bd),
                  const Color(0xffdcf5f5),
                  const Color(0xfff1e8ff),
                ][i % 3],
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PartyGame(game: g)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(g.emoji, style: const TextStyle(fontSize: 30)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _ink,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Text(
                                g.type,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 7,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          g.name,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          g.subtitle,
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.black54,
                          ),
                        ),
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
        // dart format on
      ],
    ),
  );
}

class _GamesBackdropPainter extends CustomPainter {
  const _GamesBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xfffffbf1), Color(0xfffff3c8), Color(0xffe7f8f8)],
        stops: [0, .55, 1],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, background);

    final waterWash = Paint()
      ..color = _water.withValues(alpha: .13)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * .91, size.height * .14),
        width: 190,
        height: 150,
      ),
      waterWash,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * .08, size.height * .83),
        width: 230,
        height: 175,
      ),
      waterWash,
    );

    final ring = Paint()
      ..color = _water.withValues(alpha: .22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final radius in [24.0, 42.0, 61.0]) {
      canvas.drawCircle(
        Offset(size.width * .88, size.height * .17),
        radius,
        ring,
      );
    }
    for (final radius in [19.0, 35.0, 52.0]) {
      canvas.drawCircle(
        Offset(size.width * .13, size.height * .8),
        radius,
        ring,
      );
    }

    final crease = Paint()
      ..color = _ink.withValues(alpha: .045)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final folds = [
      [Offset(0, size.height * .28), Offset(size.width, size.height * .2)],
      [Offset(size.width * .18, 0), Offset(size.width * .34, size.height)],
      [Offset(size.width, size.height * .62), Offset(0, size.height * .7)],
    ];
    for (final fold in folds) {
      canvas.drawLine(fold.first, fold.last, crease);
    }

    final drops = Paint()..color = _water.withValues(alpha: .38);
    for (final point in [
      Offset(size.width * .07, size.height * .18),
      Offset(size.width * .94, size.height * .49),
      Offset(size.width * .83, size.height * .76),
      Offset(size.width * .18, size.height * .57),
    ]) {
      canvas.drawCircle(point, 5, drops);
      canvas.drawCircle(point + const Offset(8, 9), 2.5, drops);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class QuickGame extends StatefulWidget {
  final GameInfo game;

  const QuickGame({super.key, required this.game});

  @override
  State<QuickGame> createState() => _QuickGameState();
}

class _QuickGameState extends State<QuickGame> {
  final rng = Random();
  final stopwatch = Stopwatch();
  Timer? timer;
  Timer? secondTimer;
  int score = 0;
  int round = 0;
  int timeLeft = 20;
  int target = 0;
  int oddIndex = 0;
  int colorWord = 0;
  int colorInk = 0;
  int dotCount = 0;
  int moves = 0;
  bool go = false;
  bool finished = false;
  String resultText = '';
  List<int> puzzle = List.generate(9, (i) => (i + 1) % 9);
  List<int> countOptions = [];

  static const colorNames = ['KIRMIZI', 'MAVİ', 'YEŞİL', 'SARI'];
  static const colorValues = [
    Color(0xffe5484d),
    Color(0xff2f75dc),
    Color(0xff35a854),
    Color(0xffe6aa08),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    timer?.cancel();
    secondTimer?.cancel();
    super.dispose();
  }

  void _start() {
    timer?.cancel();
    secondTimer?.cancel();
    setState(() {
      score = 0;
      round = 0;
      timeLeft = 20;
      moves = 0;
      go = false;
      finished = false;
      resultText = '';
    });
    switch (widget.game.id) {
      case 'shooting':
        target = rng.nextInt(12);
        timer = Timer.periodic(const Duration(milliseconds: 650), (_) {
          if (mounted && !finished) setState(() => target = rng.nextInt(12));
        });
        secondTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (!mounted || finished) return;
          setState(() => timeLeft--);
          if (timeLeft == 0) _finish('$score hedef vurdun.');
        });
        break;
      case 'puzzle':
        _shufflePuzzle();
        break;
      case 'reflex':
        stopwatch.reset();
        timer = Timer(Duration(milliseconds: 1400 + rng.nextInt(2200)), () {
          if (!mounted || finished) return;
          stopwatch.start();
          setState(() => go = true);
        });
        break;
      case 'odd':
        _nextOdd();
        break;
      case 'color':
        _nextColor();
        break;
      case 'count':
        _nextCount();
        break;
    }
  }

  void _finish(String text) {
    timer?.cancel();
    secondTimer?.cancel();
    stopwatch.stop();
    setState(() {
      finished = true;
      resultText = text;
    });
  }

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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _scoreBar(),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _paper,
                  border: Border.all(color: _ink, width: 4),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: finished ? _result() : _gameBody(),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _scoreBar() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
    decoration: BoxDecoration(
      color: _ink,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            _hint(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          widget.game.id == 'shooting'
              ? '$timeLeft sn · $score'
              : 'Skor $score',
          style: const TextStyle(color: _yellow, fontWeight: FontWeight.w900),
        ),
      ],
    ),
  );

  Widget _gameBody() => switch (widget.game.id) {
    'shooting' => _shooting(),
    'puzzle' => _puzzle(),
    'reflex' => _reflex(),
    'odd' => _odd(),
    'color' => _color(),
    _ => _count(),
  };

  Widget _shooting() => GridView.builder(
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
    ),
    itemCount: 12,
    itemBuilder: (_, i) => AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      decoration: BoxDecoration(
        color: i == target ? const Color(0xffff6b67) : const Color(0xffe9e5dc),
        shape: BoxShape.circle,
        border: Border.all(color: _ink, width: i == target ? 4 : 1),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          if (i != target) return;
          setState(() {
            score++;
            target = rng.nextInt(12);
          });
        },
        child: Center(
          child: Text(
            i == target ? '🎯' : '',
            style: const TextStyle(fontSize: 34),
          ),
        ),
      ),
    ),
  );

  void _shufflePuzzle() {
    puzzle = List.generate(9, (i) => (i + 1) % 9);
    for (var i = 0; i < 90; i++) {
      final zero = puzzle.indexOf(0);
      final neighbors = _neighbors(zero);
      final next = neighbors[rng.nextInt(neighbors.length)];
      final temp = puzzle[zero];
      puzzle[zero] = puzzle[next];
      puzzle[next] = temp;
    }
    setState(() {});
  }

  List<int> _neighbors(int index) {
    final values = <int>[];
    final row = index ~/ 3;
    final col = index % 3;
    if (row > 0) values.add(index - 3);
    if (row < 2) values.add(index + 3);
    if (col > 0) values.add(index - 1);
    if (col < 2) values.add(index + 1);
    return values;
  }

  Widget _puzzle() => Center(
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
        itemBuilder: (_, i) => AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            color: puzzle[i] == 0 ? Colors.transparent : _water,
            borderRadius: BorderRadius.circular(16),
            border: puzzle[i] == 0 ? null : Border.all(color: _ink, width: 2),
          ),
          child: InkWell(
            onTap: puzzle[i] == 0 ? null : () => _movePuzzle(i),
            child: Center(
              child: Text(
                puzzle[i] == 0 ? '' : '${puzzle[i]}',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  void _movePuzzle(int index) {
    final zero = puzzle.indexOf(0);
    if (!_neighbors(zero).contains(index)) return;
    setState(() {
      puzzle[zero] = puzzle[index];
      puzzle[index] = 0;
      moves++;
      score = max(0, 100 - moves * 2);
    });
    if (List.generate(9, (i) => (i + 1) % 9).join() == puzzle.join()) {
      _finish('$moves hamlede çözdün.');
    }
  }

  Widget _reflex() => InkWell(
    onTap: () {
      if (!go) {
        _finish('Erken bastın. Biraz daha sabır!');
      } else {
        final milliseconds = stopwatch.elapsedMilliseconds;
        score = max(0, 1000 - milliseconds);
        _finish('Tepki süren $milliseconds ms.');
      }
    },
    borderRadius: BorderRadius.circular(24),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: go ? const Color(0xff54cf73) : const Color(0xffe84f55),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Text(
          go ? 'ŞİMDİ BAS!' : 'BEKLE…',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    ),
  );

  void _nextOdd() {
    oddIndex = rng.nextInt(16);
    setState(() {});
  }

  Widget _odd() => GridView.builder(
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 4,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
    ),
    itemCount: 16,
    itemBuilder: (_, i) => FilledButton(
      onPressed: () {
        if (i != oddIndex) return;
        setState(() {
          score++;
          round++;
        });
        if (round == 5) {
          _finish('5 farklı simgeyi de buldun.');
        } else {
          _nextOdd();
        }
      },
      style: FilledButton.styleFrom(
        padding: EdgeInsets.zero,
        backgroundColor: const Color(0xffeeeae2),
        foregroundColor: _ink,
      ),
      child: Text(
        i == oddIndex ? '😎' : '🙂',
        style: const TextStyle(fontSize: 28),
      ),
    ),
  );

  void _nextColor() {
    colorWord = rng.nextInt(colorNames.length);
    colorInk = rng.nextInt(colorValues.length);
    setState(() {});
  }

  Widget _color() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        colorNames[colorWord],
        style: TextStyle(
          color: colorValues[colorInk],
          fontSize: 45,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 45),
      Row(
        children: [
          Expanded(child: _answerButton('EŞLEŞİYOR', colorWord == colorInk)),
          const SizedBox(width: 10),
          Expanded(child: _answerButton('FARKLI', colorWord != colorInk)),
        ],
      ),
    ],
  );

  Widget _answerButton(String label, bool correct) => FilledButton(
    onPressed: () {
      setState(() {
        if (correct) score++;
        round++;
      });
      if (round == 10) {
        _finish('10 soruda $score doğru yaptın.');
      } else {
        _nextColor();
      }
    },
    style: FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(65),
      backgroundColor: _ink,
    ),
    child: Text(label),
  );

  void _nextCount() {
    dotCount = 5 + rng.nextInt(11);
    final options = <int>{dotCount};
    while (options.length < 4) {
      options.add(max(1, dotCount - 3 + rng.nextInt(7)));
    }
    countOptions = options.toList()..shuffle(rng);
    setState(() {});
  }

  Widget _count() => Column(
    children: [
      Expanded(
        child: Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: List.generate(
              dotCount,
              (i) => Text(
                ['●', '▲', '■'][round % 3],
                style: TextStyle(
                  color: colorValues[i % colorValues.length],
                  fontSize: 30,
                ),
              ),
            ),
          ),
        ),
      ),
      Wrap(
        spacing: 8,
        children: countOptions
            .map(
              (value) => FilledButton(
                onPressed: () {
                  setState(() {
                    if (value == dotCount) score++;
                    round++;
                  });
                  if (round == 5) {
                    _finish('5 turda $score doğru saydın.');
                  } else {
                    _nextCount();
                  }
                },
                style: FilledButton.styleFrom(backgroundColor: _ink),
                child: Text('$value'),
              ),
            )
            .toList(),
      ),
    ],
  );

  Widget _result() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.game.emoji, style: const TextStyle(fontSize: 72)),
        const SizedBox(height: 12),
        Text(
          resultText,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _start,
          style: FilledButton.styleFrom(backgroundColor: _ink),
          icon: const Icon(Icons.replay),
          label: const Text('TEKRAR OYNA'),
        ),
      ],
    ),
  );

  String _hint() => switch (widget.game.id) {
    'shooting' => 'Beliren hedefe dokun.',
    'puzzle' => 'Boşluğa komşu sayıları kaydır.',
    'reflex' => 'Kırmızıdayken bekle, yeşilde bas.',
    'odd' => 'Diğerlerinden farklı olanı bul.',
    'color' => 'Kelime ile yazı rengi aynı mı?',
    _ => 'Şekilleri hızlıca say.',
  };
}

class PartyGame extends StatefulWidget {
  final GameInfo game;
  const PartyGame({super.key, required this.game});
  @override
  State<PartyGame> createState() => _PartyGameState();
}

class _ArenaBullet {
  final int owner;
  double x;
  double y;
  final double dx;
  final double dy;

  _ArenaBullet({
    required this.owner,
    required this.x,
    required this.y,
    required this.dx,
    required this.dy,
  });
}

class _PlayerJoystick extends StatefulWidget {
  final int player;
  final Color color;
  final ValueChanged<Offset> onMove;
  final VoidCallback onAction;
  final String action;

  const _PlayerJoystick({
    required this.player,
    required this.color,
    required this.onMove,
    required this.onAction,
    required this.action,
  });

  @override
  State<_PlayerJoystick> createState() => _PlayerJoystickState();
}

class _PlayerJoystickState extends State<_PlayerJoystick> {
  Offset knob = Offset.zero;

  void move(Offset local) {
    final vector = local - const Offset(42, 42);
    final limited = vector.distance > 25
        ? Offset.fromDirection(vector.direction, 25)
        : vector;
    setState(() => knob = limited);
    if (vector.distance > 7) widget.onMove(vector / max(vector.distance, 1));
  }

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'P${widget.player + 1}',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          GestureDetector(
            onPanStart: (d) => move(d.localPosition),
            onPanUpdate: (d) => move(d.localPosition),
            onPanEnd: (_) => setState(() => knob = Offset.zero),
            onPanCancel: () => setState(() => knob = Offset.zero),
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: .28),
                shape: BoxShape.circle,
                border: Border.all(color: _ink, width: 3),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.add, size: 55, color: Colors.black26),
                  Transform.translate(
                    offset: knob,
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: widget.color,
                        shape: BoxShape.circle,
                        border: Border.all(color: _ink, width: 3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      const SizedBox(width: 7),
      GestureDetector(
        onTap: widget.onAction,
        child: Container(
          width: 55,
          height: 55,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            border: Border.all(color: _ink, width: 3),
            boxShadow: const [
              BoxShadow(color: Colors.black26, offset: Offset(0, 3)),
            ],
          ),
          child: Text(
            widget.action,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    ],
  );
}

class _PartyGameState extends State<PartyGame> with TickerProviderStateMixin {
  int players = 0;
  List<int> score = [];
  List<double> progress = [];
  List<int> lanes = [];
  List<int> territory = List.filled(25, -1);
  List<int> lives = [];
  List<double> tankAngles = [];
  List<Offset> tankPositions = [];
  List<_ArenaBullet> bullets = [];
  List<int> lastMoveAt = [];
  int target = -1, memoryStep = 0;
  List<int> sequence = [];
  bool go = false, finished = false;
  double balance = 0, ballX = .5, ballY = .5, dx = .012, dy = .009;
  Timer? timer;
  final rng = Random();
  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void start(int n) {
    timer?.cancel();
    setState(() {
      players = widget.game.id == 'pong' ? 2 : n;
      score = List.filled(players, 0);
      progress = List.filled(players, 0);
      lanes = List.filled(players, 1);
      territory = List.filled(25, -1);
      lives = List.filled(players, 3);
      tankAngles = List.generate(players, (i) => i * pi);
      tankPositions = _startingPositions(players);
      bullets = [];
      lastMoveAt = List.filled(players, 0);
      target = -1;
      memoryStep = 0;
      sequence = [];
      go = widget.game.id != 'panic';
      finished = false;
      balance = 0;
      ballX = .5;
      ballY = .5;
    });
    switch (widget.game.id) {
      case 'shoot':
        _startShoot();
        break;
      case 'catch':
      case 'target':
        _spawnTarget();
        break;
      case 'dodge':
        _startDodge();
        break;
      case 'memory':
        _nextMemory();
        break;
      case 'panic':
        timer = Timer(Duration(milliseconds: 1300 + rng.nextInt(2600)), () {
          if (mounted) setState(() => go = true);
        });
        break;
      case 'balance':
        _startBalance();
        break;
      case 'pong':
        _startPong();
        break;
    }
  }

  List<Offset> _startingPositions(int count) => switch (count) {
    2 => const [Offset(.16, .5), Offset(.84, .5)],
    3 => const [Offset(.16, .2), Offset(.84, .2), Offset(.5, .82)],
    _ => const [
      Offset(.16, .18),
      Offset(.84, .18),
      Offset(.16, .82),
      Offset(.84, .82),
    ],
  };

  void _startShoot() {
    timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (!mounted || finished) return;
      final removed = <_ArenaBullet>[];
      for (final bullet in bullets) {
        bullet.x += bullet.dx;
        bullet.y += bullet.dy;
        if (bullet.x < 0 || bullet.x > 1 || bullet.y < 0 || bullet.y > 1) {
          removed.add(bullet);
          continue;
        }
        for (var i = 0; i < players; i++) {
          if (i == bullet.owner || lives[i] == 0) continue;
          if ((tankPositions[i] - Offset(bullet.x, bullet.y)).distance < .075) {
            lives[i]--;
            score[bullet.owner]++;
            removed.add(bullet);
            break;
          }
        }
      }
      bullets.removeWhere(removed.contains);
      final alive = List.generate(
        players,
        (i) => i,
      ).where((i) => lives[i] > 0).toList();
      if (alive.length <= 1) {
        final winner = alive.isEmpty
            ? score.indexOf(score.reduce(max))
            : alive.first;
        _win(winner, message: 'P${winner + 1} düelloyu kazandı!');
        return;
      }
      setState(() {});
    });
  }

  void _spawnTarget() {
    timer = Timer(Duration(milliseconds: 450 + rng.nextInt(650)), () {
      if (mounted && !finished) setState(() => target = rng.nextInt(12));
    });
  }

  void _startDodge() {
    timer = Timer.periodic(const Duration(milliseconds: 700), (t) {
      if (!mounted || finished) return;
      final danger = rng.nextInt(3);
      for (int i = 0; i < players; i++) {
        if (lanes[i] == danger && rng.nextDouble() < .35)
          score[i] = max(-3, score[i] - 1);
        else
          score[i]++;
      }
      setState(() => target = danger);
      if (score.any((v) => v >= 16)) _win(score.indexOf(score.reduce(max)));
    });
  }

  void _nextMemory() {
    sequence.add(rng.nextInt(9));
    memoryStep = 0;
    setState(() => go = false);
    var delay = 0;
    for (final cell in sequence) {
      Timer(Duration(milliseconds: delay), () {
        if (mounted) setState(() => target = cell);
      });
      delay += 430;
      Timer(Duration(milliseconds: delay - 140), () {
        if (mounted) setState(() => target = -1);
      });
    }
    Timer(Duration(milliseconds: delay + 100), () {
      if (mounted) setState(() => go = true);
    });
  }

  void _startBalance() {
    timer = Timer.periodic(const Duration(milliseconds: 150), (t) {
      if (!mounted || finished) return;
      balance += (rng.nextDouble() - .5) * .14;
      if (balance.abs() > 1) _win(balance > 0 ? 0 : min(1, players - 1));
      setState(() {});
    });
  }

  void _startPong() {
    timer = Timer.periodic(const Duration(milliseconds: 30), (t) {
      if (!mounted || finished) return;
      ballX += dx;
      ballY += dy;
      if (ballY < .03 || ballY > .92) dy = -dy;
      if (ballX < .03) {
        score[1]++;
        ballX = .5;
      }
      if (ballX > .94) {
        score[0]++;
        ballX = .5;
      }
      if (score.any((v) => v >= 5)) _win(score.indexOf(score.reduce(max)));
      setState(() {});
    });
  }

  void press(int i) {
    if (finished) return;
    switch (widget.game.id) {
      case 'shoot':
        if (lives[i] == 0) return;
        bullets.add(
          _ArenaBullet(
            owner: i,
            x: tankPositions[i].dx,
            y: tankPositions[i].dy,
            dx: cos(tankAngles[i]) * .018,
            dy: sin(tankAngles[i]) * .018,
          ),
        );
        break;
      case 'race':
        progress[i] += .055 + rng.nextDouble() * .025;
        score[i] = (progress[i] * 100).round();
        if (progress[i] >= 1) _win(i);
        break;
      case 'catch':
      case 'target':
        if (target >= 0) {
          score[i]++;
          target = -1;
          if (score[i] >= 7)
            _win(i);
          else
            _spawnTarget();
        } else
          score[i] = max(0, score[i] - 1);
        break;
      case 'sumo':
        final victim = (i + 1 + rng.nextInt(max(1, players - 1))) % players;
        score[i]++;
        progress[victim] += .15;
        if (progress[victim] >= 1) _win(i);
        break;
      case 'dodge':
        lanes[i] = (lanes[i] + 1) % 3;
        break;
      case 'memory':
        if (!go) return;
        if (memoryStep < sequence.length) {
          memoryStep++;
          score[i] = sequence.length;
          if (memoryStep == sequence.length) {
            if (sequence.length >= 6)
              _win(i);
            else
              _nextMemory();
          }
        }
        break;
      case 'panic':
        if (!go)
          _win(
            (i + 1) % players,
            message: 'P${i + 1} erken bastı ve sifonu bozdu!',
          );
        else
          _win(i);
        break;
      case 'balance':
        balance += (i.isEven ? -1 : 1) * .18;
        score[i] = (100 - balance.abs() * 100).round();
        break;
      case 'pong':
        progress[i] = (progress[i] + .24) % 1;
        break;
      case 'territory':
        final free = <int>[];
        for (int n = 0; n < 25; n++) if (territory[n] < 0) free.add(n);
        if (free.isEmpty) {
          _win(score.indexOf(score.reduce(max)));
          break;
        }
        final cell = free[rng.nextInt(free.length)];
        territory[cell] = i;
        score[i]++;
        if (score[i] >= 13) _win(i);
        break;
    }
    setState(() {});
  }

  void movePlayer(int i, Offset direction) {
    if (finished || i >= players) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - lastMoveAt[i] < 45) return;
    lastMoveAt[i] = now;
    switch (widget.game.id) {
      case 'shoot':
        if (lives[i] == 0) return;
        tankAngles[i] = direction.direction;
        tankPositions[i] = Offset(
          (tankPositions[i].dx + direction.dx * .035)
              .clamp(.07, .93)
              .toDouble(),
          (tankPositions[i].dy + direction.dy * .035)
              .clamp(.07, .93)
              .toDouble(),
        );
        break;
      case 'race':
        if (direction.dx > .25 || direction.dy < -.25) press(i);
        return;
      case 'dodge':
        if (direction.dy.abs() > .55) {
          lanes[i] = (lanes[i] + (direction.dy > 0 ? 1 : -1))
              .clamp(0, 2)
              .toInt();
        }
        break;
      case 'sumo':
        tankPositions[i] = Offset(
          (tankPositions[i].dx + direction.dx * .04).clamp(.08, .92).toDouble(),
          (tankPositions[i].dy + direction.dy * .04).clamp(.08, .92).toDouble(),
        );
        break;
      default:
        tankAngles[i] = direction.direction;
    }
    setState(() {});
  }

  void _win(int i, {String? message}) {
    if (finished) return;
    finished = true;
    timer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: _yellow,
        title: const Text('💦 RAUNT BİTTİ'),
        content: Text(
          message ?? 'P${i + 1} kazandı! Ortalık biraz ıslandı.',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              start(players);
            },
            child: const Text('TEKRAR OYNA'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _yellow,
    appBar: AppBar(
      backgroundColor: _yellow,
      title: Text(
        widget.game.name,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
    ),
    body: players == 0 ? _select() : _play(),
  );
  Widget _select() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.game.emoji, style: const TextStyle(fontSize: 82)),
        const Text(
          'Kaç kişisiniz?',
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          children: [2, 3, 4]
              .map(
                (n) => FilledButton(
                  onPressed: () => start(n),
                  style: FilledButton.styleFrom(
                    fixedSize: const Size(78, 72),
                    backgroundColor: _paper,
                    foregroundColor: _ink,
                    side: const BorderSide(color: _ink, width: 3),
                  ),
                  child: Text(
                    '$n',
                    style: const TextStyle(
                      fontSize: 27,
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
  Widget _play() => SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: List.generate(
              players,
              (i) => Expanded(
                child: Container(
                  margin: const EdgeInsets.all(3),
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.game.id == 'shoot'
                        ? 'P${i + 1}: ${List.filled(lives[i], '♥').join()}'
                        : 'P${i + 1}: ${score[i]}',
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
              margin: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: _paper,
                border: Border.all(color: _ink, width: 4),
                borderRadius: BorderRadius.circular(26),
              ),
              clipBehavior: Clip.antiAlias,
              child: _field(),
            ),
          ),
          Text(_hint(), style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 9),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            runAlignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 8,
            children: List.generate(players, (i) {
              final color = [
                const Color(0xffff6b67),
                _water,
                const Color(0xff8bd669),
                const Color(0xffad8ced),
              ][i];
              return _PlayerJoystick(
                player: i,
                color: color,
                onMove: (direction) => movePlayer(i, direction),
                onAction: () => press(i),
                action: _button(),
              );
            }),
          ),
        ],
      ),
    ),
  );
  Widget _field() => switch (widget.game.id) {
    'shoot' => LayoutBuilder(
      builder: (_, bounds) => Stack(
        children: [
          ...List.generate(
            players,
            (i) => Positioned(
              left: tankPositions[i].dx * bounds.maxWidth - 24,
              top: tankPositions[i].dy * bounds.maxHeight - 24,
              child: Opacity(
                opacity: lives[i] > 0 ? 1 : .2,
                child: Transform.rotate(
                  angle: tankAngles[i] + pi / 2,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: [
                        const Color(0xffff6b67),
                        _water,
                        const Color(0xff8bd669),
                        const Color(0xffad8ced),
                      ][i],
                      shape: BoxShape.circle,
                      border: Border.all(color: _ink, width: 3),
                    ),
                    child: const Icon(Icons.navigation, color: _ink),
                  ),
                ),
              ),
            ),
          ),
          ...bullets.map(
            (bullet) => Positioned(
              left: bullet.x * bounds.maxWidth - 5,
              top: bullet.y * bounds.maxHeight - 5,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: _ink,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    'race' => Stack(
      children: [
        ...List.generate(
          players,
          (i) => AnimatedPositioned(
            duration: const Duration(milliseconds: 150),
            left: 16 + progress[i] * 240,
            top: 38 + i * 61,
            child: Text('${i + 1}🏎️', style: const TextStyle(fontSize: 27)),
          ),
        ),
        const Positioned(
          right: 20,
          top: 15,
          bottom: 15,
          child: VerticalDivider(color: _ink, thickness: 6),
        ),
      ],
    ),
    'catch' || 'target' => GridView.builder(
      padding: const EdgeInsets.all(18),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 12,
      itemBuilder: (_, i) => AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: i == target ? _water : const Color(0xffeee7dc),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            i == target ? widget.game.emoji : '',
            style: const TextStyle(fontSize: 28),
          ),
        ),
      ),
    ),
    'sumo' => LayoutBuilder(
      builder: (_, bounds) => Stack(
        children: [
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _ink, width: 5),
              ),
            ),
          ),
          ...List.generate(
            players,
            (i) => AnimatedPositioned(
              duration: const Duration(milliseconds: 180),
              left: tankPositions[i].dx * bounds.maxWidth - 22,
              top: tankPositions[i].dy * bounds.maxHeight - 22,
              child: Text('${i + 1}🟠', style: const TextStyle(fontSize: 31)),
            ),
          ),
        ],
      ),
    ),
    'dodge' => Stack(
      children: [
        ...List.generate(
          2,
          (i) => Positioned(
            left: 0,
            right: 0,
            top: (i + 1) * 105,
            child: const Divider(color: Colors.black26, thickness: 2),
          ),
        ),
        ...List.generate(
          players,
          (i) => AnimatedPositioned(
            duration: const Duration(milliseconds: 180),
            left: 35 + i * 66,
            top: 30 + lanes[i] * 105,
            child: Text('${i + 1}🏃', style: const TextStyle(fontSize: 27)),
          ),
        ),
        if (target >= 0)
          Positioned(
            right: 20,
            top: 30 + target * 105,
            child: const Text('⚠️⚠️', style: TextStyle(fontSize: 27)),
          ),
      ],
    ),
    'memory' => GridView.builder(
      padding: const EdgeInsets.all(35),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 9,
      itemBuilder: (_, i) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: i == target ? _yellow : const Color(0xffe7ded1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _ink, width: 2),
        ),
      ),
    ),
    'panic' => AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      color: go ? const Color(0xff58cf76) : const Color(0xffe7504b),
      child: Center(
        child: Text(
          go ? 'BAS!' : 'SAKIN BASMA',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 35,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    ),
    'balance' => Stack(
      children: [
        Center(
          child: Container(
            height: 18,
            margin: const EdgeInsets.symmetric(horizontal: 35),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                colors: [Colors.red, _water, _water, Colors.red],
                stops: [0, .38, .62, 1],
              ),
            ),
          ),
        ),
        AnimatedAlign(
          duration: const Duration(milliseconds: 120),
          alignment: Alignment(balance.clamp(-1.0, 1.0), 0),
          child: const Text('🧻', style: TextStyle(fontSize: 54)),
        ),
      ],
    ),
    'pong' => Stack(
      children: [
        Positioned(
          left: 12,
          top: progress[0] * 230 + 20,
          child: Container(width: 12, height: 70, color: _ink),
        ),
        Positioned(
          right: 12,
          top: progress[1] * 230 + 20,
          child: Container(width: 12, height: 70, color: _ink),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 25),
          left: ballX * 300,
          top: ballY * 300,
          child: const Text('💧', style: TextStyle(fontSize: 24)),
        ),
      ],
    ),
    'territory' => GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
      ),
      itemCount: 25,
      itemBuilder: (_, i) => AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: territory[i] < 0
              ? const Color(0xffeee7dc)
              : [
                  const Color(0xffff6b67),
                  _water,
                  const Color(0xff8bd669),
                  const Color(0xffad8ced),
                ][territory[i]],
          border: Border.all(color: Colors.black12),
        ),
        child: territory[i] < 0
            ? null
            : Center(
                child: Text(
                  'P${territory[i] + 1}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
      ),
    ),
    _ => Center(
      child: Text(widget.game.emoji, style: const TextStyle(fontSize: 100)),
    ),
  };
  String _button() => switch (widget.game.id) {
    'shoot' => 'ATEŞ',
    'race' => 'BAS!',
    'catch' => 'YAKALA',
    'sumo' => 'İT!',
    'dodge' => 'ŞERİT',
    'target' => 'POMPALA',
    'memory' => 'CEVAP',
    'panic' => 'BAS!',
    'balance' => 'DENGE',
    'pong' => 'HAREKET',
    _ => 'KAP!',
  };
  String _hint() => switch (widget.game.id) {
    'shoot' => 'Joystick ile hareket edip nişan al, ATEŞ ile rakibini vur.',
    'race' => 'Joystick’i ileri iterek bitiş çizgisine ilk sen ulaş.',
    'catch' => 'Yıldız görününce ilk sen yakala.',
    'sumo' => 'Rakibini çemberin dışına it.',
    'dodge' => 'Joystick’i yukarı-aşağı itip tehlikeli şeritten kaç.',
    'target' => 'Pompa çıkınca ilk sen bas.',
    'memory' => 'Lekelerin sırasını hatırla.',
    'panic' => 'Yeşil olmadan sakın basma.',
    'balance' => 'Sol oyuncular sola, sağ oyuncular sağa.',
    'pong' => 'Tek tuşla raketini döndür, gideri koru.',
    'territory' => 'Her basış bir kare. En çok alanı kap.',
    _ => '',
  };
}
