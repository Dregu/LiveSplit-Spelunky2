const express = require('express')
const bodyParser = require('body-parser')
var app = express()
const expressWs = require('express-ws')(app)
const nconf = require('nconf')

nconf.file({ file: 'config.json' })
if(!nconf.get('pass')) {
  nconf.set('pass', 'tiamat')
  nconf.save()
}

app.use(bodyParser.urlencoded({ extended: true }))
app.use(express.static('static'))

var state = {}

const broadcast = (status) => {
  for(let client of expressWs.getWss().clients) {
    client.send(JSON.stringify({ update: status }))
  }
}

app.post('/:user/:pass', (req, res) => {
  if(req.params.pass != nconf.get('pass') && nconf.get('pass')) {
    res.sendStatus(403)
    return
  }
  res.sendStatus(200)
  var status = req.body
  status['user'] = req.params.user
  status = Object.entries(status).reduce((acc, [key, value]) => {
    acc[key] = isNaN(+value) ? value : +value
    return acc
  },{})
  status.level = Object.entries(status.level).reduce((acc, [key, value]) => {
    acc[key] = isNaN(+value) ? value : +value
    return acc
  },{})
  status.record = Object.entries(status.record).reduce((acc, [key, value]) => {
    acc[key] = isNaN(+value) ? value : +value
    return acc
  },{})
  status.wins = Object.entries(status.wins).reduce((acc, [key, value]) => {
    acc[key] = isNaN(+value) ? value : +value
    return acc
  },{})
  console.log(status)
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
