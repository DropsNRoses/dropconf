noble = require 'noble'


deviceList = []
device = null
dropService = null
chars = 
  0: {uuid: '0000280012008da5e31130b4c03b539b'}
  1: {uuid: '0000280112008da5e31130b4c03b539b'}
  2: {uuid: '0000280212008da5e31130b4c03b539b'}


onDeviceDiscover = (d) ->
  console.log deviceList.length + ': ' + d.uuid.match(/.{2}/g).join(':') + ' ' + d.advertisement.localName
  deviceList.push d

onRead = (data, isNotification) ->
  console.log "Notification: #{data.toString("hex")}"
  nextCommand()

readNextCommand = ->
  line = []
  while c = parseInt(stream.read(2), 16)
    break if c is 10
    line.push c
  value = []
  value.push parseInt(String.fromCharCode(line[i])+String.fromCharCode(line[i+1]), 16)  for i in [4...line.length] by 2
  {char: String.fromCharCode(line[0]), value: value, notify: (String.fromCharCode(line[2]) is '1')}


# States
startScanning = ->
  console.log "Start Scanning (at any moment, enter the number of a device to connect to it)."
  noble.startScanning()
  noble.on 'discover', onDeviceDiscover
  process.stdin.on 'data', parseDeviceChoice

parseDeviceChoice = (data) ->
  if parseInt(data) >= 0 && parseInt(data) < deviceList.length
    process.stdin.removeListener 'data', parseDeviceChoice
    device = deviceList[parseInt(data)]
    connect()
  else
    console.log "Error: number must be between 0 and #{deviceList.length-1}"

connect = ->
  console.log "Connecting to #{device.advertisement.localName}"
  noble.stopScanning()
  device.connect discoverCharacteristics

discoverCharacteristics = ->
  console.log "Discovering characteristics"
  characteristicUUIDs = (chars[c].uuid for c of chars)
  device.discoverSomeServicesAndCharacteristics [], characteristicUUIDs, onDiscoverCharacteristics

onDiscoverCharacteristics = (error, services, discoveredChars) ->
  dropService = services[0]
  for id of chars
    chars[id].value = discoveredChars.filter((c) -> c.uuid is chars[id].uuid)[0]
    chars[id].value.on 'notify', -> console.log "done"
    chars[id].value.on 'read', onRead
  activateNotifications()

activateNotifications = (i=0, error=null) ->
  if i is 3
    nextCommand()
  else
    console.log error if error?
    console.log "Activate notifications for #{chars[i].uuid}"
    chars[i].value.notify true, (err) -> activateNotifications i+1, err

nextCommand = ->
  command = readNextCommand()
  console.log "Write in #{chars[command.char].uuid}: #{command.value.map((v)->(v+0x100).toString(16)[1..]).join('')}"
  chars[command.char].value.write new Buffer(command.value), true, (nextCommand unless command.notify)

disconnect = -> 
  console.log "Disconnecting from #{device.advertisement.localName}"
  device.disconnect -> 
    console.log "You can now close the window"
    process.exit()


# Let's start!
if process.argv.length isnt 3
  console.log "Usage: coffee dropconf.coffee FILENAME"
  process.exit()

stream = require('fs').createReadStream(process.argv[2])
stream.setEncoding 'hex'
stream.on 'readable', startScanning
stream.on 'end', -> nextCommand = disconnect