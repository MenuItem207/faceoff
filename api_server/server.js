const express = require('express')
const app = express()
const cors = require("cors");

require('dotenv').config()
const mysqlHost = process.env.mysqlHost;
const mysqlPort = process.env.mysqlPort;
const mysqlDatabase = process.env.mysqlDatabase;
const mysqlUser = process.env.mysqlUser;
const mysqlPassword = process.env.mysqlPassword

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

app.use(cors())
app.use(express.json())

/**
 * response codes used:
 * 400 - wrong password
 * 401 - wrong email
 */
app.post('/login', async (req, res) => {
    let email = req.body.email;
    let password = req.body.password;
    let loginSQL = `SELECT * FROM users WHERE email='${email}'`;
    let results = await db.promise().query(loginSQL);
    if (results[0].length === 1) {
        if (results[0][0].password === password) {
            res.json({ user_id: results[0][0].id });
            return;
        }
        res.status(400).json('Invalid password');
        return;
    }
    res.status(401).json('Invalid email');
});

/**
 * response codes used
 * 400 - email already in use
 * 401 - invalid join code
 */
app.post('/register', async (req, res) => {
    let email = req.body.email;
    let password = req.body.password;
    let name = req.body.name;
    let join_code = req.body.join_code;

    let joinCodeSQL = `SELECT * FROM pending_codes WHERE join_code='${join_code}'`;
    let joinCodeResults = await db.promise().query(joinCodeSQL);

    if (joinCodeResults[0].length == 1) {
        let existingUserSQL = `SELECT * FROM users WHERE email='${email}'`;
        let existingUserResults = await db.promise().query(existingUserSQL);

        if (existingUserResults[0].length != 0) {
            res.status(400).json('email already in use');
            return;
        } else {
            let deviceID = joinCodeResults[0][0].device_id;
            let newUserSQL = `INSERT INTO users (email, password, device_id, name) VALUES ('${email}', '${password}', '${deviceID}', '${name}')`;
            let newUserResults = await db.promise().query(newUserSQL);

            let deletePendingCodeSQL = `DELETE FROM pending_codes WHERE join_code='${join_code}'`;
            let deletePendingCodeResults = await db.promise().query(deletePendingCodeSQL);
            res.json({ 'status': 'Success', 1: newUserResults, 2: deletePendingCodeResults })
            return;
        }
    }

    res.status(401).json('Invalid join code');
});


const serverPort = process.env.PORT
app.listen(serverPort);
console.log('Server running on port', serverPort)
