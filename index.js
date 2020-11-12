const express = require('express')
const bodyParser = require('body-parser')
var app = express()
const expressWs = require('express-ws')(app)

app.use(bodyParser.urlencoded({ extended: true }))
app.use(express.static('static'))

var state = {}

/*var state = {
  'Dregu': {
    user: 'Dregu',
    char: '0',
    health: '4',
    bombs: '7',
    ropes: '4',
    level: [ '1', '2' ],
    record: [ '5', '1' ],
    shortcuts: '2',
    tries: '16',
    deaths: '10',
    wins: [ '0', '0', '0' ],
    gt: '123',
    rt: '4562.7'
  },
  'foobar': {
    user: 'foobar',
    char: '7',
    health: '99',
    bombs: '22',
    ropes: '45',
    level: [ '5', '1' ],
    record: [ '7', '95' ],
    shortcuts: '6',
    tries: '420',
    deaths: '333',
    wins: [ '2', '1', '0' ],
    gt: '222',
    rt: '555.5'
  }
}*/

console.log(state)

const broadcast = (status) => {
  for(let client of expressWs.getWss().clients) {
    client.send(JSON.stringify({ update: status }))
  }
}

app.post('/', (req, res) => {
  res.sendStatus(200)
  console.log(req.body)
  var status = req.body
  state[status['user']] = status
  broadcast(status)
})

app.get('/', (req, res) => {
  res.sendFile(__dirname + '/static/index.html')
})

app.get('/u/:user/?', (req, res) => {
  res.sendFile(__dirname + '/static/index.html')
})

app.ws('/', (ws, req) => {
  ws.on('message', (msg) => {
    console.log(msg)
    if(msg == 'state') {
      ws.send(JSON.stringify({ state: state }))
    }
  })

})

app.listen(2222)
