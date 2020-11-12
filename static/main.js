const container = document.getElementById('container')
var state = {}
var rank = []
const user = window.location.pathname.split('/').slice(-1)[0]
const _colors = ['yellow', 'magenta', 'cyan', 'black', 'cinnabar', 'green', 'olive', 'white', 'cerulean', 'blue', 'lime', 'lemon', 'iris', 'gold', 'red', 'pink', 'violet', 'gray', 'khaki', 'orange']
const _items = {
  char: { file: 'char_yellow.png', x: 0, y: 0, w: 128, h: 128 },
  health: { file: 'hud.png', x: 0, y: 192, w: 64, h: 64 },
  dead: { file: 'hud.png', x: 192, y: 192, w: 64, h: 64 },
  bomb: { file: 'hud.png', x: 128, y: 64, w: 64, h: 64 },
  rope: { file: 'hud.png', x: 192, y: 64, w: 64, h: 64 },
  level: { file: 'hud.png', x: 384, y: 64, w: 64, h: 64 },
  time: { file: 'hud.png', x: 320, y: 64-12, w: 64, h: 64 },
  record: { file: 'menu_deathmatch2.png', x: 768, y: 128, w: 64, h: 64 },
  shortcut: { file: 'deco_basecamp.png', x: 256, y: 1664, w: 128, h: 128 },
  win: { file: 'menu_deathmatch2.png', x: 960, y: 128, w: 64, h: 64 },
  best: { file: 'hud.png', x: 384, y: 128, w: 64, h: 64 }
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
const updateHud = (data) => {
  if(user && user != data['user']) {
    return
  }
  let hud = getHud(data['user'])
  if(!user) {
    hud.style.top = 128*getRank(data['user'])+'px'
  }
  let items = {}
  for(const [name, item] of Object.entries(_items)) {
    items[name] = hud.querySelector('.'+name)
  }
  items['char'].lastChild.style.backgroundImage = 'url(/img/char_'+_colors[data['char']]+'.png)'
  items['char'].firstChild.innerText = data['user']
  items['health'].firstChild.innerText = data['health']
  items['bomb'].firstChild.innerText = data['bombs']
  items['rope'].firstChild.innerText = data['ropes']
  items['level'].firstChild.innerText = data['level'][0].replace('8','7')+'–'+data['level'][1]
  items['record'].firstChild.innerText = data['record'][0].replace('8','7')+'–'+data['record'][1]
  items['shortcut'].firstChild.innerText = data['shortcuts']+'/9'
  items['win'].firstChild.innerText = data['wins'].reduce((total, num) => { return parseInt(total) + parseInt(num) })
  if(data['health'] == 0) {
    items['dead'].style.display = 'block'
    items['char'].lastChild.style.backgroundPositionX = '-1152px'
  } else {
    items['dead'].style.display = 'none'
    items['char'].lastChild.style.backgroundPositionX = '0px'
  }
  let gt = new Date(0)
  gt.setSeconds(data['gt'])
  gt = gt.toISOString().substr(11, 8)
  let rt = new Date(0)
  rt.setSeconds(data['rt'])
  rt = rt.toISOString().substr(11, 8)
  let bt = new Date(0)
  bt.setSeconds(data['bt'])
  bt = bt.toISOString().substr(11, 8)
  items['time'].firstChild.innerText = gt
  items['best'].firstChild.innerText = bt
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
    'blue': 'mediumblue'
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

const updateRanks = () => {
  var users = []
  for(let [user, item] of Object.entries(state)) {
    users.push(user)
  }
  rank = users.sort((a, b) => {
    let sa = Math.max(100*state[a]['level'][0]+1*state[a]['level'][1], 100*state[a]['record'][0]+1*state[a]['record'][1])
    let sb = Math.max(100*state[b]['level'][0]+1*state[b]['level'][1], 100*state[b]['record'][0]+1*state[b]['record'][1])
    return sa > sb
  }).reverse()
}
const getRank = (user) => {
  for(let i = 0; i < rank.length; i++) {
    if(rank[i] == user) {
      return i
    }
  }
  return 0
}
const tick = () => {
  updateRanks()
  for(let [user, item] of Object.entries(state)) {
    state[user].gt = (parseFloat(state[user].gt)+1.0).toString()
    state[user].rt = (parseFloat(state[user].rt)+1.0).toString()
    updateHud(state[user])
  }
}
const init = () => {
  var ws = connect()
  if(user) {
    getHud(user)
  }
  for(let i = 0; i < 7; i++) {
    var foo = {
      user: 'player'+i,
      char: i,
      health: Math.floor(Math.random()*12).toString(),
      bombs: Math.floor(Math.random()*12).toString(),
      ropes: Math.floor(Math.random()*12).toString(),
      level: [ Math.floor(1+Math.random()*2).toString(), Math.floor(1+Math.random()*4).toString() ],
      record: [ Math.floor(1+Math.random()*2).toString(), Math.floor(1+Math.random()*4).toString() ],
      shortcuts: Math.floor(Math.random()*9).toString(),
      tries: Math.floor(Math.random()*500).toString(),
      deaths: Math.floor(Math.random()*300).toString(),
      wins: [ Math.floor(Math.random()*8).toString(), '0', '0' ],
      gt: Math.floor(Math.random()*500).toString(),
      rt: Math.floor(Math.random()*500).toString(),
      bt: Math.floor(Math.random()*500).toString()
    }
    state['player'+i] = foo
    updateHud(foo)
  }
  updateRanks()
  setInterval(tick, 1000)
}
init()
