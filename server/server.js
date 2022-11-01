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

                // create room
                socket.join(deviceID);

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
            // create room
            socket.join('device_' + deviceID);
            // TODO: update client that device is online + latest data
        }
    });

    socket.on('device_event', (data) => {
        // TODO: update sql with latest device state
        // TODO: notify client of updates
    });

    socket.on('client_init', async (data, respondToClient) => {
        // TODO: <TEST> retrieve current state of device + display all user faces
        // TODO: <TEST> establish communication channel between device and client
        deviceID = data.device_id;

        /// join / create room
        socket.join('client_' + deviceID);

        let isDeviceOnline = false;
        if (io.sockets.adapter.rooms["device_" + deviceID]) { // check if room exists
            isDeviceOnline = true;
        }

        let lastDeviceState = undefined;
        let deviceSQL = `SELECT * from devices WHERE id='${deviceID}'`;
        let deviceResults = await db.promise().query(deviceSQL);
        if (deviceResults[0].length === 1) {
            lastDeviceState = deviceResults[0][0].state;
        }

        let securityProfileSQL = `SELET * from security_profiles WHERE device_id=${deviceID}`;
        let securityProfileResults = await db.promise().query(securityProfileSQL);

        respondToClient({
            'isDeviceOnline': isDeviceOnline,
            'lastDeviceState': lastDeviceState,
            'profiles': securityProfileResults[0], // a list of security profile objs (see documentation)
        });
    });

    socket.on('client_event', (data) => {
        // TODO: update sql with latest client state
        // TODO: notify device of updates

        // events include:
        // toggle device unlock
        // new security_profile created
    });

    socket.on('disconnect', () => {
        // remove client / device from clients / devices list
        // TODO: check if socket-client is client or device
        // TODO: if device: check if client is connected and notify client of disconnection
        // TODO: if client: do nothing

    });
});

server.listen(socketPort);
console.log('Server online on port', socketPort)