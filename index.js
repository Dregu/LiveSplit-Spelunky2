const express = require('express')
const bodyParser = require('body-parser')
const app = express()

app.use(bodyParser.urlencoded({ extended: true }))

app.post('/', (req, res) => {
  res.sendStatus(200)
  console.log(req.body)
})

app.listen(2222)
