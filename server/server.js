const { makeJoinCode } = require('./src/helpers');

require('dotenv').config()
const socketPort = process.env.PORT
const mysqlHost = process.env.mysqlHost;
const mysqlPort = process.env.mysqlPort;
const mysqlDatabase = process.env.mysqlDatabase;
const mysqlUser = process.env.mysqlUser;
const mysqlPassword = process.env.mysqlPassword

const server = require('http').createServer();
const io = require('socket.io')().listen(server);

const mysql = require('mysql2');
const db = mysql.createConnection({
    'host': mysqlHost,
    'port': mysqlPort,
    'user': mysqlUser,
    'password': mysqlPassword,
    'database': mysqlDatabase
});

db.connect((err) => {
    if (err) {
        console.log(err);
    }
    else {
        console.log("Connected to db");
    }
});

/**
 * maps a device id to its socket id
 */
let connectedDevicesSocketIDs = {}

/**
 * maps a socket id to a device
 */
let socketIDsConnectedDevices = {}

// all device events should be titled device_[event] i.e device_init
// all client events should be titled client_[event] i.e client_init
io.on('connection', (socket) => {
    console.log('New client connected')

    socket.on('device_init', (data) => {
        console.log('initialised new device', data);
        deviceID = data['uuid'];
        isNewDevice = deviceID === null;

        if (isNewDevice) {
            let joinCode = makeJoinCode(5);
            let newDeviceSQL = `INSERT INTO devices (state) VALUES (0)`;
            db.query(newDeviceSQL, (err, result) => {
                if (err) throw err;
                deviceID = result.insertId;

                // update devices list
                connectedDevicesSocketIDs[deviceID] = socket.id
                socketIDsConnectedDevices[socket.id] = deviceID;

                // insert new pending code
                let newPendingCodeSQL = `INSERT INTO pending_codes (device_id, join_code) VALUES ('${deviceID}', '${joinCode}')`;
                db.query(newPendingCodeSQL,
                    (err) => {
                        if (err) throw err;
                        // send response to client
                        io.to(socket.id).emit(
                            'device_init_response', {
                            'device_id': deviceID,
                            'pending_code': joinCode,
                        });
                    },
                );

            },);
        } else {
            // update devices list
            connectedDevicesSocketIDs[deviceID] = socket.id
            socketIDsConnectedDevices[socket.id] = deviceID;
        }
    });

    socket.on('disconnect', () => {
        // remove device from devices list
        socketID = socket.id;
        deviceID = socketIDsConnectedDevices[socketID]
        delete connectedDevicesSocketIDs[deviceID]
        delete socketIDsConnectedDevices[socketID]
    });
});

server.listen(socketPort);
console.log('Server online on port', socketPort)