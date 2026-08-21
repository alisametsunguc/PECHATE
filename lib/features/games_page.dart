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
  GameInfo('race', 'Sifon Sprint', '🚽', 'YARIŞ', 'Hızlı dokun'),
  GameInfo('catch', 'Damlayı Yakala', '💧', 'REFLEKS', 'Zamanlamanı göster'),
  GameInfo('sumo', 'Peçete Sumo', '🧻', 'ARENA', 'Ringden dışarı it'),
  GameInfo('dodge', 'Sızıntıdan Kaç', '☔', 'KAÇIŞ', 'Şerit değiştir'),
  GameInfo('target', 'Pompa Patlat', '🪠', 'HEDEF', 'Çıkan hedefi vur'),
  GameInfo('memory', 'Leke Hafızası', '🟨', 'HAFIZA', 'Deseni hatırla'),
  GameInfo('panic', 'Sakın Basma', '🚨', 'SİNİR', 'Yeşili bekle'),
  GameInfo('balance', 'Rulo Dengesi', '⚖️', 'DENGE', 'Ortada tut'),
  GameInfo('pong', 'Gider Pong', '🏓', 'DÜELLO', 'Kaleni koru'),
  GameInfo('territory', 'Kuru Yer Kapmaca', '🧼', 'TAKTİK', 'Alanı ele geçir'),
];

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 15, 16, 10),
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
            color: _ink,
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PECHATE PARTY',
                style: TextStyle(
                  color: _yellow,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
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
                '10 oyun · 2–4 kişi · tek dokunuş kontrolleri',
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
  );
}

class PartyGame extends StatefulWidget {
  final GameInfo game;
  const PartyGame({super.key, required this.game});
  @override
  State<PartyGame> createState() => _PartyGameState();
}

class _PartyGameState extends State<PartyGame> with TickerProviderStateMixin {
  int players = 0;
  List<int> score = [];
  List<double> progress = [];
  List<int> lanes = [];
  List<int> territory = List.filled(25, -1);
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
                    'P${i + 1}: ${score[i]}',
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
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: 2.15,
            children: List.generate(
              players,
              (i) => Padding(
                padding: const EdgeInsets.all(4),
                child: FilledButton(
                  onPressed: () => press(i),
                  style: FilledButton.styleFrom(
                    backgroundColor: [
                      const Color(0xffff6b67),
                      _water,
                      const Color(0xff8bd669),
                      const Color(0xffad8ced),
                    ][i],
                    foregroundColor: _ink,
                    side: const BorderSide(color: _ink, width: 3),
                  ),
                  child: Text(
                    'P${i + 1} · ${_button()}',
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
  Widget _field() => switch (widget.game.id) {
    'race' => Stack(
      children: [
        ...List.generate(
          players,
          (i) => AnimatedPositioned(
            duration: const Duration(milliseconds: 150),
            left: 16 + progress[i] * 240,
            top: 38 + i * 61,
            child: Text('${i + 1}🚽', style: const TextStyle(fontSize: 27)),
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
    'sumo' => Stack(
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
            left: 70 + (i % 2) * 130 + progress[i] * 30,
            top: 70 + (i ~/ 2) * 125 + progress[i] * 35,
            child: Text('${i + 1}🧻', style: const TextStyle(fontSize: 31)),
          ),
        ),
      ],
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
            child: const Text('💧💧', style: TextStyle(fontSize: 27)),
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
    'race' => 'Sifonu en hızlı kim çekecek?',
    'catch' => 'Damla görününce ilk sen yakala.',
    'sumo' => 'Rakibini ringden peçete gibi uçur.',
    'dodge' => 'Parlayan şeritten kaç, kuru kal.',
    'target' => 'Pompa çıkınca ilk sen bas.',
    'memory' => 'Lekelerin sırasını hatırla.',
    'panic' => 'Yeşil olmadan sakın basma.',
    'balance' => 'Sol oyuncular sola, sağ oyuncular sağa.',
    'pong' => 'Tek tuşla raketini döndür, gideri koru.',
    'territory' => 'Her basış bir kuru kare. En çok alanı kap.',
    _ => '',
  };
}
