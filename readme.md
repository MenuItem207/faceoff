# Faceoff

## Documentation

## Pending Users
---
This table contains data for a 'pending user'

### join_code
This code can be used to allow a user to create an account

### device_id
This code is a local id for a unique 'device'

## Users
---
This table contains data for a valid user


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
Whether or not the device is currently unlocked

## Login Attempts
---
This table contains data for all the login attempts for a device

### device_id
The device id

### success_state (bool)
Whether or not the login attempt was successful

### img
The captured image used to log-in the user


