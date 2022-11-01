# Faceoff

## Documentation

## Pending Codes
---
This table contains data for a device without an account

### id
the pending code id

### join_code
This code can be used to allow a user to create an account

### device_id
This code is a local id for a unique 'device'

## Users
---
This table contains data for a valid user

### id
the user's id

### name
the user's name

### email
The valid user's email

### password
The valid user's password

### device_id
The valid user's device id

## Devices
---
The devices

### id
the device id

### state (bool)
Whether or not the device is currently unlocked, locked or disabled

## security_profiles
---
login faces 

### id
the device face id

### name
the device face name (casual)

### device_id
The device id

### img_url
url of the user's verification image

## Login Attempts
---
This table contains data for all the login attempts for a device

### id
the login attempt id

### device_id
The device id

### success_state (bool)
Whether or not the login attempt was successful

### img_url
The captured image used to log-in the user

### timestamp
The datetime of the login attempt


