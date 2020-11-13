const container = document.getElementById('container')
var state = {}
const user = window.location.pathname.split('/').slice(-1)[0]
const _colors = ['yellow', 'magenta', 'cyan', 'black', 'cinnabar', 'green', 'olive', 'white', 'cerulean', 'blue', 'lime', 'lemon', 'iris', 'gold', 'red', 'pink', 'violet', 'gray', 'khaki', 'orange']
const _items = {
  char: { file: 'char_yellow.png', x: 0, y: 0, w: 128, h: 128 },
  health: { file: 'hud.png', x: 0, y: 192, w: 64, h: 64 },
  dead: { file: 'hud.png', x: 192, y: 192, w: 64, h: 64 },
  bomb: { file: 'hud.png', x: 128, y: 64, w: 64, h: 64 },
  rope: { file: 'hud.png', x: 192, y: 64, w: 64, h: 64 },
  level: { file: 'hud.png', x: 384, y: 64, w: 64, h: 64 },
  record: { file: 'menu_deathmatch2.png', x: 1024, y: 128, w: 64, h: 64 },
  time: { file: 'hud.png', x: 320, y: 64-12, w: 64, h: 64 },
  best: { file: 'hud.png', x: 384, y: 128, w: 64, h: 64 },
  shortcut: { file: 'deco_basecamp.png', x: 256, y: 1664, w: 128, h: 128 },
  attempt: { file: 'menu_deathmatch2.png', x: 768, y: 128, w: 64, h: 64 },
  win: { file: 'menu_deathmatch2.png', x: 960, y: 128, w: 64, h: 64 },
  death: { file: 'items.png', x: 1920, y: 380, w: 128, h: 128 },
}
const getHud = (user) => {
  let hud = document.querySelector('.hud[data-user="'+user+'"]')
  if(!hud) {
    hud = document.createElement('div')
    hud.classList.add('hud')
    hud.dataset.user = user
    for(const [name, item] of Object.entries(_items)) {
      let element = document.createElement('div')
      element.classList.add('item')
      element.classList.add(name)
      let img = document.createElement('div')
      img.classList.add('img')
      img.style.background = 'url(/img/'+item['file']+') no-repeat -'+item['x']+'px -'+item['y']+'px';
      element.style.width = item['w']+'px'
      element.style.height = item['h']+'px'
      let text = document.createElement('div')
      text.classList.add('text')
      element.appendChild(text)
      element.appendChild(img)
      hud.appendChild(element)
    }
    container.appendChild(hud)
  }
  return hud
}
const formatTime = (time) => {
  let gt = new Date(0)
  gt.setSeconds(time)
  gt = gt.toISOString().substr(11, 8)
  return gt
}
const updateHud = (data) => {
  if(user && user != data['user']) {
    return
  }
  let hud = getHud(data['user'])
  if(!user && data['rank'] !== undefined) {
    hud.style.top = 128*data['rank']+'px'
  }
  let items = {}
  for(const [name, item] of Object.entries(_items)) {
    items[name] = hud.querySelector('.'+name)
  }
  items['char'].lastChild.style.backgroundImage = 'url(/img/char_'+_colors[data['char']]+'.png)'
  items['char'].firstChild.innerText = (Object.keys(state).length > 1?'#'+(data['rank']+1)+' ':'')+data['user']
  items['health'].firstChild.innerText = data['health']
  items['bomb'].firstChild.innerText = data['bombs']
  items['rope'].firstChild.innerText = data['ropes']
  items['level'].firstChild.innerText = data['level'][0]+'–'+data['level'][1]
  items['record'].firstChild.innerText = data['record'][0]+'–'+data['record'][1]
  items['shortcut'].firstChild.innerText = data['shortcuts']+'/9'
  items['attempt'].firstChild.innerText = data['tries']
  items['win'].firstChild.innerText = data['wins'][0]+data['wins'][1]+data['wins'][2]
  items['death'].firstChild.innerText = data['deaths']
  if(data['health'] == 0) {
    items['dead'].style.display = 'block'
    items['char'].classList.remove('wake')
    items['char'].classList.add('die')
  } else if(items['char'].classList.contains('die')) {
    items['dead'].style.display = 'none'
    items['char'].classList.add('wake')
  } else {
    items['dead'].style.display = 'none'
    items['char'].classList.remove('die')
  }
  if(data['phase'] == 'Ended') {
    items['char'].classList.add('jump')
  } else {
    items['char'].classList.remove('jump')
  }
  if(data['rank'] >= Object.keys(state).length-1) {
    items['char'].classList.add('last')
  } else {
    items['char'].classList.remove('last')
  }
  let igt = formatTime(data['igt'])
  let gt = formatTime(data['gt'])
  let bigt = formatTime(data['bigt'])
  let pb = formatTime(data['pb'])
  items['time'].firstChild.innerText = (data['gt'] > 0?gt:'')
  items['best'].firstChild.innerText = (data['pb'] > 0?pb:'')
  let hsl = getHsl(_colors[data['char']])
  items['health'].lastChild.style.filter = 'brightness('+(parseInt(hsl[2])*0.5+33)+'%) sepia(100%) hue-rotate('+(parseInt(hsl[0])-45)+'deg) saturate('+(parseInt(hsl[1])*3)+'%)'
}
const connect = () => {
  var ws = new WebSocket('ws://'+window.location.hostname+':'+window.location.port+'/')
  ws.onopen = () => {
    console.log('WebSocket opened')
    ws.send('state')
  }
  ws.onmessage = (e) => {
    let data = JSON.parse(e.data)
    if(data['state']) {
      for(let [user, item] of Object.entries(data['state'])) {
        state[user] = item
        updateHud(item)
      }
    } else if(data['update']) {
      state[data['update']['user']] = data['update']
      updateHud(data['update'])
    }
  }
  ws.onclose = (e) => {
    console.log('Socket is closed. Reconnect will be attempted in 1 second.', e.reason)
    setTimeout(() => {
      connect()
    }, 1000)
  }
  ws.onerror = (err) => {
    console.error('Socket encountered error: ', err.message, 'Closing socket')
    ws.close()
  };
  return ws
}
const getHsl = (color) => {
  const htmlcolors = {
    'cinnabar': 'red',
    'iris': 'rebeccapurple',
    'lemon': 'lemonchiffon',
    'cerulean': 'skyblue',
    'violet': 'indigo',
    'blue': 'mediumblue',
    'olive': 'olivedrab'
  }
  if(htmlcolors[color]) {
    color = htmlcolors[color]
  }
  return w3color(color).toHslString().slice(4, -1).split(', ')
}
const shuffle = (array) => {
  var currentIndex = array.length, temporaryValue, randomIndex
  while (0 !== currentIndex) {
    randomIndex = Math.floor(Math.random() * currentIndex)
    currentIndex -= 1
    temporaryValue = array[currentIndex]
    array[currentIndex] = array[randomIndex]
    array[randomIndex] = temporaryValue
  }
  return array
}
const cmp = (x, y) => {
  return x > y ? 1 : x < y ? -1 : 0
}
const sortLevel = (level) => {
  return 100*level[0]+1*level[1]
}
const sortTime = (time) => {
  if(time < 0) {
    return Number.MAX_SAFE_INTEGER
  }
  return time
}
const updateRanks = () => {
  var users = []
  for(let [user, item] of Object.entries(state)) {
    users.push(item)
  }
  users = users.sort((a, b) => {
    return cmp(
      [cmp(sortTime(a.pb), sortTime(b.pb)), -cmp(a.shortcuts, b.shortcuts), -cmp(Math.max(sortLevel(a.level), sortLevel(a.record)), Math.max(sortLevel(b.level), sortLevel(b.record)))],
      [cmp(sortTime(b.pb), sortTime(a.pb)), -cmp(b.shortcuts, a.shortcuts), -cmp(Math.max(sortLevel(b.level), sortLevel(b.record)), Math.max(sortLevel(a.level), sortLevel(a.record)))]
    )
  })
  for(let i = 0; i < users.length; i++) {
    users[i]['rank'] = i
  }
}
const tick = () => {
  updateRanks()
  for(let [user, item] of Object.entries(state)) {
    if(state[user].phase == 'Running') {
      state[user].gt = 1.0+state[user].gt
      state[user].rt = 1.0+state[user].rt
    }
    updateHud(state[user])
  }
}
const init = () => {
  var ws = connect()
  for(let i = 0; i < 7; i++) {
    var foo = {
      user: 'player'+i,
      char: i,
      health: Math.floor(Math.random()*12),
      bombs: Math.floor(Math.random()*12),
      ropes: Math.floor(Math.random()*12),
      level: { 0: Math.floor(1+Math.random()*2), 1: Math.floor(1+Math.random()*4) },
      record: { 0: Math.floor(1+Math.random()*2), 1: Math.floor(1+Math.random()*4) },
      shortcuts: Math.floor(Math.random()*9),
      tries: Math.floor(Math.random()*500),
      deaths: Math.floor(Math.random()*300),
      wins: [ Math.floor(Math.random()*8), Math.floor(Math.random()*3), Math.floor(Math.random()*2) ],
      igt: Math.floor(Math.random()*500),
      gt: Math.floor(Math.random()*500),
      bigt: Math.random()<0.7?-0.0166666667:Math.floor(Math.random()*500),
      pb: Math.random()<0.7?-0.0166666667:Math.floor(Math.random()*500),
      phase: Math.random()<0.2?'Ended':'Running'
    }
    state['player'+i] = foo
    updateHud(foo)
  }
  updateRanks()
  setInterval(tick, 1000)
}
init()
