const splash = document.querySelector('.splash');

splash.addEventListener('animationend', (event) => {
  if (event.animationName === 'splash-away') splash.remove();
});

const messagesScreen = document.querySelector('.messages-screen');
const messagesList = document.querySelector('.messages-list');
const dropCurtain = document.querySelector('.drop-curtain');
const fallingDrops = document.querySelector('.falling-drops');
const dropsLabel = dropCurtain.querySelector('b');
const pullHintText = document.querySelector('.pull-hint-text');
const chatScreen = document.querySelector('.chat-screen');
const chatBody = document.querySelector('.chat-body');
const composer = document.querySelector('.composer');
const composerInput = composer.querySelector('input');
const quickActions = document.querySelector('.quick-actions');
const onceViewer = document.querySelector('.once-viewer');
const gameSheet = document.querySelector('.game-sheet');
const flushCanvas = document.querySelector('.flush-canvas');
const openMessagesButtons = [
  document.querySelector('.inbox-button'),
  document.querySelector('.bottom-nav button:nth-child(4)')
];
let visibleDropCount = 0;

function openMessages() {
  messagesScreen.classList.add('open');
  messagesScreen.setAttribute('aria-hidden', 'false');
  window.requestAnimationFrame(() => {
    messagesList.scrollTop = 76;
    updateHiddenMessageDrops();
  });
}

function closeMessages() {
  messagesScreen.classList.remove('open');
  messagesScreen.setAttribute('aria-hidden', 'true');
  renderDrops(0);
}

function openChat() {
  chatScreen.classList.add('open');
  chatScreen.setAttribute('aria-hidden', 'false');
  composerInput.disabled = false;
  composerInput.readOnly = false;
  window.requestAnimationFrame(() => { chatBody.scrollTop = chatBody.scrollHeight; });
}

function closeChat() {
  chatScreen.classList.remove('open');
  chatScreen.setAttribute('aria-hidden', 'true');
  quickActions.classList.remove('open');
}

function renderDrops(count) {
  if (count === visibleDropCount) return;
  visibleDropCount = count;
  fallingDrops.replaceChildren();

  for (let index = 0; index < count; index += 1) {
    const drop = document.createElement('span');
    const spread = count === 1 ? 50 : 16 + ((68 / (count - 1)) * index);
    drop.style.setProperty('--drop-x', `${spread}%`);
    drop.style.setProperty('--drop-size', `${7 + ((index * 3) % 5)}px`);
    drop.style.setProperty('--drop-speed', `${0.72 + ((index % 3) * 0.14)}s`);
    drop.style.setProperty('--drop-delay', `${index * -0.19}s`);
    fallingDrops.append(drop);
  }

  if (count > 0) {
    dropsLabel.textContent = count >= 4
      ? '4+ unread chats above'
      : `${count} unread chat${count === 1 ? '' : 's'} above`;
    dropCurtain.classList.add('show');
  } else {
    dropCurtain.classList.remove('show');
  }
}

function updateHiddenMessageDrops() {
  const listTop = messagesList.getBoundingClientRect().top;
  const hiddenUnreadCount = [...document.querySelectorAll('.message-row.unread')]
    .filter((row) => row.getBoundingClientRect().bottom <= listTop + 5)
    .length;
  renderDrops(hiddenUnreadCount);
}

function updatePullHint() {
  const unreadPeople = document.querySelectorAll('.message-row.unread').length;
  let message;

  if (unreadPeople >= 10) {
    message = 'Your inbox needs a bathroom break.';
  } else if (unreadPeople >= 6) {
    message = 'Pull down before it overflows.';
  } else if (unreadPeople >= 2) {
    message = 'Pull down. Something’s leaking.';
  } else if (unreadPeople === 1) {
    message = 'Someone couldn’t hold it in.';
  } else {
    message = 'Can you feel the relief?';
  }

  pullHintText.textContent = message;
}

openMessagesButtons.forEach((button) => button.addEventListener('click', openMessages));
document.querySelector('.messages-back').addEventListener('click', closeMessages);

messagesList.addEventListener('scroll', updateHiddenMessageDrops, { passive: true });

document.querySelectorAll('.message-row.unread').forEach((row) => {
  row.addEventListener('click', () => {
    row.style.setProperty('--fill', '0%');
    row.classList.remove('unread');
    row.removeAttribute('data-unread');
    row.querySelector('.message-meta b')?.remove();
    updateHiddenMessageDrops();
    updatePullHint();
    openChat();
  });
});

document.querySelectorAll('.message-row:not(.unread)').forEach((row) => {
  row.addEventListener('click', openChat);
});

document.querySelector('.chat-back').addEventListener('click', closeChat);
document.querySelector('.composer-plus').addEventListener('click', () => {
  const open = quickActions.classList.toggle('open');
  quickActions.setAttribute('aria-hidden', String(!open));
});

composerInput.addEventListener('input', () => {
  const pressure = Math.min(100, (composerInput.value.length / 80) * 100);
  document.querySelector('.pressure-meter').style.width = `${pressure}%`;
  composerInput.placeholder = pressure > 75 ? 'Bu bayağı uzun bir akış…' : 'İçinde tutma…';
});

composer.addEventListener('submit', (event) => {
  event.preventDefault();
  const text = composerInput.value.trim();
  if (!text) return;
  const line = document.createElement('div');
  line.className = 'chat-line outgoing flushable';
  line.innerHTML = `<div class="bubble"></div><button class="mini-flush" aria-label="Mesajı sifonla">🚽</button><time>şimdi · Akıyor</time>`;
  line.querySelector('.bubble').textContent = text;
  chatBody.insertBefore(line, document.querySelector('.typing-bubble'));
  bindFlushButton(line.querySelector('.mini-flush'));
  composerInput.value = '';
  composerInput.dispatchEvent(new Event('input'));
  quickActions.classList.remove('open');
  window.requestAnimationFrame(() => { chatBody.scrollTop = chatBody.scrollHeight; });
});

function bindFlushButton(button) {
  button.addEventListener('click', () => {
    const line = button.closest('.chat-line');
    line.querySelector('.bubble').textContent = 'Sifonlandı.';
    line.querySelector('.bubble').style.cssText = 'background:#eee7dc;color:#8d8478;font-style:italic';
    button.remove();
  });
}

document.querySelectorAll('.mini-flush').forEach(bindFlushButton);
document.querySelector('.drop-react').addEventListener('click', (event) => {
  event.currentTarget.classList.toggle('reacted');
  event.currentTarget.textContent = event.currentTarget.classList.contains('reacted') ? '💦' : '💧';
});

document.querySelectorAll('.quick-actions [data-insert]').forEach((button) => {
  button.addEventListener('click', () => {
    composerInput.value = button.dataset.insert;
    composerInput.focus();
    composerInput.dispatchEvent(new Event('input'));
  });
});

document.querySelector('.view-once-card').addEventListener('click', () => {
  onceViewer.classList.add('open');
  onceViewer.setAttribute('aria-hidden', 'false');
});

function runWaterFlush() {
  const context = flushCanvas.getContext('2d');
  const bounds = flushCanvas.getBoundingClientRect();
  const ratio = Math.min(window.devicePixelRatio || 1, 2);
  const width = bounds.width;
  const height = bounds.height;
  const centerX = width / 2;
  const centerY = height / 2;
  flushCanvas.width = width * ratio;
  flushCanvas.height = height * ratio;
  context.setTransform(ratio, 0, 0, ratio, 0, 0);

  const particles = Array.from({ length: 34 }, (_, index) => {
    const left = index % 2 === 0;
    return {
      startX: left ? -18 - Math.random() * 55 : width + 18 + Math.random() * 55,
      startY: height * (.2 + Math.random() * .62),
      angle: Math.random() * Math.PI * 2,
      radius: 55 + Math.random() * Math.min(width, height) * .34,
      size: 2.5 + Math.random() * 5.5,
      delay: Math.random() * .14,
      wobble: Math.random() * Math.PI * 2
    };
  });

  const start = performance.now();
  const ease = (value) => 1 - Math.pow(1 - Math.max(0, Math.min(1, value)), 3);

  function drop(x, y, size, direction, alpha) {
    context.save();
    context.translate(x, y);
    context.rotate(direction);
    context.globalAlpha = alpha;
    const gradient = context.createRadialGradient(-size * .3, -size * .4, .5, 0, 0, size * 1.3);
    gradient.addColorStop(0, 'rgba(245,255,255,.98)');
    gradient.addColorStop(.28, 'rgba(135,231,241,.92)');
    gradient.addColorStop(.72, 'rgba(37,168,194,.8)');
    gradient.addColorStop(1, 'rgba(8,93,119,.2)');
    context.fillStyle = gradient;
    context.beginPath();
    context.ellipse(0, 0, size * .72, size * 1.45, 0, 0, Math.PI * 2);
    context.fill();
    context.strokeStyle = `rgba(220,255,255,${alpha * .62})`;
    context.lineWidth = .8;
    context.stroke();
    context.restore();
  }

  function frame(now) {
    const time = Math.min(1, (now - start) / 1600);
    context.clearRect(0, 0, width, height);

    if (time > .24) {
      const vortex = ease((time - .24) / .76);
      const outerRadius = (1 - vortex) * Math.min(width, height) * .52 + 14;
      const wash = context.createRadialGradient(centerX, centerY, 3, centerX, centerY, outerRadius);
      wash.addColorStop(0, `rgba(1,20,27,${.88 * vortex})`);
      wash.addColorStop(.12, `rgba(13,111,137,${.7 * (1 - vortex * .35)})`);
      wash.addColorStop(.42, `rgba(62,194,210,${.28 * (1 - vortex)})`);
      wash.addColorStop(1, 'rgba(119,235,239,0)');
      context.fillStyle = wash;
      context.fillRect(0, 0, width, height);

      context.save();
      context.translate(centerX, centerY);
      context.rotate(vortex * Math.PI * 7);
      for (let ring = 0; ring < 7; ring += 1) {
        const radius = Math.max(5, outerRadius * (1 - ring * .105));
        context.beginPath();
        context.ellipse(0, 0, radius, radius * (.42 + ring * .025), ring * .32, ring * .7, ring * .7 + Math.PI * 1.35);
        context.strokeStyle = `rgba(${ring % 2 ? '202,252,252' : '48,175,198'},${.58 * (1 - vortex * .55)})`;
        context.lineWidth = Math.max(1, 5 - ring * .45);
        context.stroke();
      }
      context.restore();
    }

    particles.forEach((particle) => {
      const local = Math.max(0, (time - particle.delay) / (1 - particle.delay));
      if (local < .34) {
        const progress = ease(local / .34);
        const targetX = centerX + Math.cos(particle.angle) * particle.radius;
        const targetY = centerY + Math.sin(particle.angle) * particle.radius * .48;
        const x = particle.startX + (targetX - particle.startX) * progress;
        const y = particle.startY + (targetY - particle.startY) * progress + Math.sin(progress * 10 + particle.wobble) * 7;
        if (progress > .08) {
          const trail = context.createLinearGradient(particle.startX, particle.startY, x, y);
          trail.addColorStop(0, 'rgba(68,181,204,0)');
          trail.addColorStop(.68, `rgba(85,205,220,${.1 + progress * .2})`);
          trail.addColorStop(1, `rgba(216,255,255,${.3 + progress * .35})`);
          context.beginPath();
          context.moveTo(particle.startX, particle.startY);
          context.quadraticCurveTo((particle.startX + x) / 2, y + Math.sin(particle.wobble) * 15, x, y);
          context.strokeStyle = trail;
          context.lineWidth = particle.size * (1.3 + progress);
          context.lineCap = 'round';
          context.stroke();
        }
        drop(x, y, particle.size, particle.startX < 0 ? Math.PI / 2 : -Math.PI / 2, Math.min(1, progress * 2));
      } else {
        const progress = ease((local - .34) / .66);
        const radius = particle.radius * (1 - progress) + 2;
        const angle = particle.angle + progress * Math.PI * 8;
        const x = centerX + Math.cos(angle) * radius;
        const y = centerY + Math.sin(angle) * radius * .48;
        drop(x, y, particle.size * (1 - progress * .72), angle + Math.PI / 2, 1 - progress * .78);
      }
    });

    if (time < 1) requestAnimationFrame(frame);
    else context.clearRect(0, 0, width, height);
  }

  requestAnimationFrame(frame);
}

onceViewer.querySelector('button').addEventListener('click', () => {
  runWaterFlush();
  onceViewer.classList.add('flushing');
  window.setTimeout(() => {
    onceViewer.classList.remove('open', 'flushing');
    onceViewer.setAttribute('aria-hidden', 'true');
    const card = document.querySelector('.view-once-card');
    card.disabled = true;
    card.innerHTML = '<span class="once-orbit">🚽</span><span><strong>Sifonlandı.</strong><small>Kanıt artık yok.</small></span>';
  }, 1630);
});

function openGame() {
  document.querySelector('.game-picker').hidden = false;
  document.querySelector('.game-play').hidden = true;
  gameSheet.classList.add('open');
  gameSheet.setAttribute('aria-hidden', 'false');
}

document.querySelector('.chat-game').addEventListener('click', openGame);
document.querySelector('.quick-game').addEventListener('click', openGame);
document.querySelector('.game-close').addEventListener('click', () => {
  gameSheet.classList.remove('open');
  gameSheet.setAttribute('aria-hidden', 'true');
});

const gameInfo = {
  xox: ['XOX', 'Sıranı seç. Alex hemen karşılık versin.'],
  rps: ['Taş Kâğıt Makas', 'Tek raund, bahanesi yok.'],
  thisthat: ['Bu mu, şu mu?', 'Aynı seçimi yapabilecek misiniz?'],
  truthlie: ['İki doğru bir yalan', 'Alex’in yalanını yakala.'],
  same: ['Aynı cevabı bul', 'Aynı şeyi düşünüyor musunuz?'],
  question: ['Damla soru', 'Sohbeti akıtacak rastgele bir soru.']
};

function sendGameInvite(title) {
  const invite = document.createElement('div');
  invite.className = 'chat-line outgoing';
  invite.innerHTML = `<div class="bubble">🎮 <strong></strong><br><small>Oyun daveti gönderildi · Alex bekleniyor</small></div><time>şimdi</time>`;
  invite.querySelector('strong').textContent = title;
  chatBody.insertBefore(invite, document.querySelector('.typing-bubble'));
  chatBody.scrollTop = chatBody.scrollHeight;
}

function renderGame(type) {
  const [title, subtitle] = gameInfo[type];
  const picker = document.querySelector('.game-picker');
  const play = document.querySelector('.game-play');
  const stage = document.querySelector('.game-stage');
  picker.hidden = true;
  play.hidden = false;
  play.querySelector('.game-title').textContent = title;
  play.querySelector('.game-subtitle').textContent = subtitle;
  sendGameInvite(title);
  stage.innerHTML = '<div class="game-invite-status">💧 Davet sohbete düştü. Demo için Alex kabul etti.</div>';

  if (type === 'xox') {
    stage.insertAdjacentHTML('beforeend', '<div class="xox-board">' + '<button></button>'.repeat(9) + '</div><div class="game-result">Sen başlıyorsun: X</div>');
    const board = Array(9).fill('');
    const cells = [...stage.querySelectorAll('.xox-board button')];
    const result = stage.querySelector('.game-result');
    const winner = () => [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]].find(line => board[line[0]] && board[line[0]] === board[line[1]] && board[line[1]] === board[line[2]]);
    const celebrate = (line, won) => {
      line.forEach(i => cells[i].classList.add('winning-cell'));
      const boardElement = stage.querySelector('.xox-board');
      boardElement.classList.add(won ? 'xox-win' : 'xox-lose');
      for (let i = 0; i < 12; i += 1) {
        const confetti = document.createElement('i');
        confetti.className = 'xox-confetti';
        confetti.style.setProperty('--x', `${-100 + Math.random() * 200}px`);
        confetti.style.setProperty('--delay', `${Math.random() * .25}s`);
        boardElement.append(confetti);
      }
    };
    cells.forEach((cell, index) => cell.addEventListener('click', () => {
      if (board[index] || winner()) return;
      board[index] = 'X'; cell.textContent = '×'; cell.classList.add('placed-x');
      if (winner()) { celebrate(winner(), true); result.textContent = 'Kazandın. Alex bunu unutmayacak.'; return; }
      const empty = board.map((value, i) => value ? -1 : i).filter(i => i >= 0);
      if (empty.length) { const move = empty[Math.floor(Math.random() * empty.length)]; board[move] = 'O'; cells[move].textContent = '○'; cells[move].classList.add('placed-o'); }
      if (winner()) { celebrate(winner(), false); result.textContent = 'Alex kazandı. Rövanş kokusu geliyor.'; } else result.textContent = 'Sıra sende.';
    }));
  } else if (type === 'rps') {
    stage.insertAdjacentHTML('beforeend', '<div class="rps-battle"><div class="rps-hand player-hand">✊</div><div class="rps-flash">VS</div><div class="rps-hand alex-hand">✊</div></div><div class="rps-choices"><button>✊<br>Taş</button><button>✋<br>Kâğıt</button><button>✌️<br>Makas</button></div><div class="game-result">Birini seç.</div>');
    const choices = ['Taş','Kâğıt','Makas'];
    const icons = ['✊','✋','✌️'];
    stage.querySelectorAll('.rps-choices button').forEach((button, index) => button.addEventListener('click', () => {
      const alex = Math.floor(Math.random() * 3); const outcome = (index - alex + 3) % 3;
      const battle = stage.querySelector('.rps-battle'); const result = stage.querySelector('.game-result');
      stage.querySelectorAll('.rps-choices button').forEach(choice => choice.disabled = true);
      battle.className = 'rps-battle counting'; result.textContent = 'Taş… Kâğıt… Makas…';
      window.setTimeout(() => {
        battle.querySelector('.player-hand').textContent = icons[index]; battle.querySelector('.alex-hand').textContent = icons[alex];
        battle.className = `rps-battle revealed ${outcome === 1 ? 'player-wins' : outcome === 2 ? 'alex-wins' : 'draw'}`;
        result.textContent = `Alex: ${choices[alex]} · ${outcome === 0 ? 'Berabere. Basınç devam ediyor.' : outcome === 1 ? 'Kazandın! 💦' : 'Alex kazandı. Sifon çekme.'}`;
        stage.querySelectorAll('.rps-choices button').forEach(choice => choice.disabled = false);
      }, 850);
    }));
  } else if (type === 'thisthat') {
    stage.insertAdjacentHTML('beforeend', '<div class="thisthat-choices"><button>Gece dışarı 🌙</button><button>Evde kal 🛋️</button></div><div class="game-result">Bir taraf seç.</div>');
    stage.querySelectorAll('.thisthat-choices button').forEach(button => button.addEventListener('click', () => stage.querySelector('.game-result').textContent = `Sen: ${button.textContent} · Alex’in cevabı bekleniyor…`));
  } else if (type === 'truthlie') {
    stage.insertAdjacentHTML('beforeend', '<div class="truth-choices"><button>Paraşütle atladım</button><button>Üç dil biliyorum</button><button>Hiç kahve içmedim</button></div><div class="game-result">Sence hangisi yalan?</div>');
    stage.querySelectorAll('.truth-choices button').forEach((button, index) => button.addEventListener('click', () => stage.querySelector('.game-result').textContent = index === 2 ? 'Yakaladın! Alex kahvesiz duramıyor. ☕' : 'Bu doğruymuş. Alex seni kandırdı.'));
  } else if (type === 'same') {
    stage.insertAdjacentHTML('beforeend', '<div class="question-card">Birlikte gitmek istediğiniz şehir?</div><div class="same-answer"><input placeholder="Cevabını yaz"><button>Gönder</button></div><div class="game-result"></div>');
    stage.querySelector('.same-answer button').addEventListener('click', () => { const value = stage.querySelector('input').value.trim(); if (value) stage.querySelector('.game-result').textContent = `${value} kilitlendi. Alex yazıyor…`; });
  } else {
    const questions = ['Bir günlüğüne görünmez olsan ilk ne yapardın?', 'En gereksiz yeteneğin ne?', 'Şu an ışınlanabileceğin tek yer neresi?', 'Seni anında güldüren şey ne?'];
    stage.insertAdjacentHTML('beforeend', `<div class="question-card">${questions[Math.floor(Math.random()*questions.length)]}</div><div class="game-result">Cevabını sohbete bırak. İçinde tutma.</div>`);
  }
}

document.querySelectorAll('.mini-game-grid [data-game]').forEach(button => button.addEventListener('click', () => renderGame(button.dataset.game)));
document.querySelector('.game-picker-back').addEventListener('click', () => { document.querySelector('.game-picker').hidden = false; document.querySelector('.game-play').hidden = true; });

const gamesScreen = document.querySelector('.games-screen');
document.querySelector('.games-nav').addEventListener('click', () => { gamesScreen.classList.add('open'); gamesScreen.setAttribute('aria-hidden','false'); });
document.querySelector('.games-back').addEventListener('click', () => { gamesScreen.classList.remove('open'); gamesScreen.setAttribute('aria-hidden','true'); });

updatePullHint();

document.querySelector('.reaction').addEventListener('click', (event) => {
  const button = event.currentTarget;
  button.innerHTML = '<span>💦</span> 249 drops';
  button.animate([
    { transform: 'scale(1)' },
    { transform: 'scale(1.18) rotate(-3deg)' },
    { transform: 'scale(1)' }
  ], { duration: 360, easing: 'cubic-bezier(.2,.8,.2,1)' });
});
