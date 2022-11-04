import socketio
from image_handler import ImageHandler
from device_handler import DeviceHandler
from user_input import UserInput
from env import socket_url

# * the start point of the code is initSocket() (bottom of the file)
# * to view normal operation of device see operateDevice()

# global instances
globalDeviceHandler = DeviceHandler()
client = socketio.Client()


@client.on("client_event_update_lock_state")
# when client manually updates the device lock state
def client_event_update_lock_state(data):
    globalDeviceHandler.deviceLockedState = data["new_lock_state"]
    print("Device lock state updated", globalDeviceHandler.deviceLockedState)


@client.on("client_event_modify_security_profile")
# when client adds / removes / edits a security profile
def client_event_modify_security_profile(data):
    globalDeviceHandler.securityProfiles = data["security_profiles"]
    allProfileImagesFileNames = []
    for securityProfile in globalDeviceHandler.securityProfiles:
        allProfileImagesFileNames.append(securityProfile["img_url"])
    ImageHandler.resyncImages(allProfileImagesFileNames)


# emits device state updated event
def emit_device_state_update():
    client.emit(
        "device_event",
        {
            "event": "device_event_update_state",
            "new_lock_state": globalDeviceHandler.deviceLockedState,
            "device_id": globalDeviceHandler.deviceUUID,
        },
    )

    print("Update lock state emitted")


# emits a login attempt event
def emit_login_attempt(security_profile, is_successful, img_url):
    client.emit(
        "device_event",
        {
            "event": "device_event_new_login_attempt",
            "profile_id": security_profile["id"],
            "device_id": globalDeviceHandler.deviceUUID,
            "is_successful": is_successful,
            "img_url": img_url,
        },
    )


# this function runs the operation of the device, it should be called once the initialisation sequence is complete
def operateDevice():
    print("Device successfully initiated")

    while True:
        # TODO: update outputs i.e LED to reflect current device state

        userInput = UserInput.getUserInput()

        # use if - else instead of switch - case since the
        # raspberry pi might not have the latest version of python
        if userInput == "lock" or userInput == "unlock":
            # if disabled, ignore
            if globalDeviceHandler.deviceLockedState == 2:
                print("ignored lol")
            else:
                # TODO: verify user
                newState = 0
                if userInput == "lock":
                    newState = 1

                globalDeviceHandler.deviceLockedState = newState
                emit_device_state_update()

        if userInput == "test attempt":
            emit_login_attempt(
                globalDeviceHandler.securityProfiles[0],
                True,
                "1667547948657.png",
            )

        else:
            print("invalid command")


# call this on init
def initSocket():
    client.connect(socket_url)

    def response(data):
        if "security_profiles" in data:
            print("Reconnection response received", data)
            globalDeviceHandler.securityProfiles = data["security_profiles"]

            allProfileImagesFileNames = []
            for securityProfile in globalDeviceHandler.securityProfiles:
                allProfileImagesFileNames.append(securityProfile["img_url"])
            ImageHandler.resyncImages(allProfileImagesFileNames)

            operateDevice()

        else:
            print("New Device response received", data)
            globalDeviceHandler.deviceUUID = data["device_id"]

            operateDevice()

    client.emit(
        "device_init",
        {
            "uuid": globalDeviceHandler.deviceUUID,
            "device_locked_state": globalDeviceHandler.deviceLockedState,
        },
        callback=response,
    )


initSocket()
