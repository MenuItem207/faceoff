const { makeJoinCode } = require('./src/helpers');
const moment = require('moment')

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
    // maps a socket id to a device id
    let socketIDsToDeviceIDs = {}

    console.log('New client connected')

    socket.on('device_init', async (data, respondToDevice) => {
        console.log('initialised new device', data);
        deviceID = data['uuid'];
        isNewDevice = deviceID === null;
        deviceLockedState = data['device_locked_state'] ?? 1; // default to 1

        if (isNewDevice) {
            let joinCode = makeJoinCode(5);
            let newDeviceSQL = `INSERT INTO devices (state) VALUES (1)`; // insert locked state
            db.query(newDeviceSQL, (err, result) => {
                if (err) throw err;
                deviceID = result.insertId;

                // create room 
                socket.join('device_' + deviceID);

                // store id
                socketIDsToDeviceIDs[socket.id] = deviceID

                // insert new pending code
                let newPendingCodeSQL = `INSERT INTO pending_codes (device_id, join_code) VALUES ('${deviceID}', '${joinCode}')`;
                db.query(newPendingCodeSQL,
                    (err) => {
                        if (err) throw err;
                        // send response to device
                        respondToDevice({
                            'device_id': deviceID,
                            'pending_code': joinCode,
                        });
                    },
                );

            },);
        } else {
            // create room
            socket.join('device_' + deviceID);

            // store id
            socketIDsToDeviceIDs[socket.id] = deviceID

            // update db
            let updateDeviceSQL = `UPDATE devices SET state=${deviceLockedState} WHERE id=${deviceID}`;
            db.query(updateDeviceSQL, (err, result) => { if (err) throw err; });

            // get security profiles
            let securityProfileSQL = `SELECT * from security_profiles WHERE device_id=${deviceID}`;
            let securityProfileResults = await db.promise().query(securityProfileSQL);
            respondToDevice({
                'security_profiles': securityProfileResults[0],
            });

            // update connected clients of device update
            io.to('client_' + deviceID).emit(
                'device_event_reconnect',
                {
                    'device_locked_state': deviceLockedState,
                }
            );
        }
    });

    // events include:
    // device_event_reconnect (only emitted when device rejoins after disconnecting)
    // device_event_disconnect (only emitted when device disconnects)
    // device_event_update_state (emitted when the device's state is updated)
    // device_event_new_login_attempt (emitted when the device has a new attempt)
    socket.on('device_event', async (data) => {
        // TODO: update sql with latest device state
        // TODO: notify client of updates
        let device_id;
        switch (data['event']) {
            case 'device_event_update_state':
                let device_locked_state = data['new_lock_state']
                device_id = data['device_id'];

                // update db
                let updateDeviceSQL = `UPDATE devices SET state=${device_locked_state} WHERE id=${device_id}`;
                await db.promise().query(updateDeviceSQL);

                // notify client
                io.to('client_' + device_id).emit(
                    'device_event_update_state',
                    {
                        'new_lock_state': device_locked_state,
                    },
                );

                break;

            case 'device_event_new_login_attempt':
                let security_profile_id = data['profile_id'];
                let is_successful = data['is_successful'] === true ? 1 : 0;
                let img_url = data['img_url'];
                device_id = data['device_id'];

                let addLoginAttemptSQL = `INSERT INTO login_attempts (profile_id, device_id, success_state, img_url, timestamp) VALUES ('${security_profile_id}', '${device_id}', '${is_successful}', '${img_url}', '${moment(Date.now()).format('YYYY-MM-DD HH:mm:ss')}')`;
                await db.promise().query(addLoginAttemptSQL);

                // notify clients
                let loginAttemptsSQL = `SELECT * FROM login_attempts WHERE device_id=${device_id}`;
                let loginAttemptsResults = await db.promise().query(loginAttemptsSQL);
                io.to('client_' + device_id).emit(
                    'device_event_new_login_attempt',
                    {
                        'login_attempts': loginAttemptsResults[0],
                    },
                );

                break;

            default:
                break;
        }
    });

    socket.on('client_init', async (data, respondToClient) => {
        deviceID = data.device_id;

        /// join / create room
        socket.join('client_' + deviceID);

        let isDeviceOnline = false;
        if (io.sockets.adapter.rooms.get("device_" + deviceID)) { // check if room exists
            isDeviceOnline = true;
        }

        let lastDeviceState = undefined;
        let deviceSQL = `SELECT * from devices WHERE id='${deviceID}'`;
        let deviceResults = await db.promise().query(deviceSQL);
        if (deviceResults[0].length === 1) {
            lastDeviceState = deviceResults[0][0].state;
        }

        let securityProfileSQL = `SELECT * from security_profiles WHERE device_id='${deviceID}'`;
        let securityProfileResults = await db.promise().query(securityProfileSQL);

        respondToClient({
            'is_device_online': isDeviceOnline,
            'device_locked_state': lastDeviceState,
            'profiles': securityProfileResults[0], // a list of security profile objs (see documentation)
        });
    });

    // events include
    // client_event_update_lock_state
    // client_event_modify_security_profile
    socket.on('client_event', async (data, respondToClient) => {
        let name, img_url, device_id, securityProfileSQL, securityProfileResults;
        switch (data['event']) {
            case 'client_event_update_lock_state':
                let new_lock_state = data['new_lock_state'];
                device_id = data['device_id'];

                // notify device
                io.to('device_' + device_id).emit(
                    'client_event_update_lock_state',
                    {
                        'new_lock_state': new_lock_state,
                    },
                );

                // update db
                let updateDeviceSQL = `UPDATE devices SET state=${new_lock_state} WHERE id=${device_id}`;
                await db.promise().query(updateDeviceSQL);

                respondToClient({
                    'new_lock_state': new_lock_state,
                });

                break;

            case 'client_event_modify_security_profile':
                switch (data['type']) {
                    case 'add':
                        name = data['name'];
                        img_url = data['img_url'];
                        device_id = data['device_id'];

                        let profileSQL = `INSERT INTO security_profiles (name, device_id, img_url) VALUES ('${name}', '${device_id}', '${img_url}')`;
                        await db.promise().query(profileSQL);

                        break;

                    case 'update':
                        name = data['name'];
                        img_url = data['img_url'];
                        device_id = data['device_id'];
                        id = data['id'];

                        let updateProfileSQL = `UPDATE security_profiles SET name='${name}', img_url='${img_url}' WHERE device_id='${device_id}' AND id='${id}' `;
                        await db.promise().query(updateProfileSQL);

                        break;

                    case 'delete':
                        id = data['id'];
                        device_id = data['device_id'];
                        let deleteProfileSQL = `DELETE FROM security_profiles WHERE id='${id}'`;
                        await db.promise().query(deleteProfileSQL);

                        break;

                    default:
                        break;
                }

                securityProfileSQL = `SELECT * from security_profiles WHERE device_id=${device_id}`;
                securityProfileResults = await db.promise().query(securityProfileSQL);
                respondToClient({
                    'security_profiles': securityProfileResults[0],
                });

                // notify device
                io.to('device_' + device_id).emit(
                    "client_event_modify_security_profile",
                    {
                        'security_profiles': securityProfileResults[0],
                    },
                );

                break;

            default:
                break;
        }

        // events include:
        // toggle device unlock
        // new security_profile created
    });

    socket.on('disconnect', () => {
        // remove client / device from clients / devices list
        if (socket.id in socketIDsToDeviceIDs) {
            // device
            console.log('disconnected device');
            let deviceID = socketIDsToDeviceIDs[socket.id];
            delete socketIDsToDeviceIDs[socket.id];
            io.to('client_' + deviceID).emit('device_event_disconnect');
        }

    });
});

server.listen(socketPort);
console.log('Server online on port', socketPort)