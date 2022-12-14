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
def emit_login_attempt(security_profile_id, is_successful, img_url):
    client.emit(
        "device_event",
        {
            "event": "device_event_new_login_attempt",
            "profile_id": security_profile_id,
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
        print(f"user command received: {userInput}")

        # use if - else instead of switch - case since the
        # raspberry pi might not have the latest version of python
        if "lock" in userInput:

            # check if is lock or unlock command
            shouldLock = True
            if "unlock" in userInput:
                shouldLock = False

            # if disabled, ignore
            if globalDeviceHandler.deviceLockedState == 2:
                print("ignored lol")
                UserInput.SpeakText(
                    "Device is disabled, you can renable the device from the website"
                )
            else:
                newState = 0
                if shouldLock:
                    newState = 1

                # only emit state if changed
                if globalDeviceHandler.deviceLockedState != newState:
                    result_image_paths = UserInput.verifyUser()

                    # result can be either false or an id so make isSuccess a bool
                    isSuccess = result_image_paths
                    if len(result_image_paths) == 2:
                        isSuccess = True
                    else:
                        isSuccess = False

                    profile_id = 0  # 0 for not verified

                    # only emit change in state if verified
                    if isSuccess:
                        UserInput.SpeakText(
                            "successful attempt recorded, updating state now"
                        )
                        globalDeviceHandler.deviceLockedState = newState
                        emit_device_state_update()

                        # find profile id
                        for securityProfile in globalDeviceHandler.securityProfiles:
                            if securityProfile["img_url"] == result_image_paths[1]:
                                profile_id = securityProfile["id"]
                    else:
                        UserInput.SpeakText("unsuccesful attempt recorded")

                    # emit a login attempt
                    emit_login_attempt(
                        profile_id,
                        isSuccess,
                        result_image_paths[0],
                    )

        elif userInput == "test attempt":
            emit_login_attempt(
                globalDeviceHandler.securityProfiles[0],
                True,
                "1667547948657.png",
            )

        else:
            UserInput.SpeakText("Invalid Command")
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

            UserInput.SpeakText("Device connected to server")
            operateDevice()

        else:
            print("New Device response received", data)
            globalDeviceHandler.deviceUUID = data["device_id"]
            UserInput.SpeakText(
                f"Device Initialized, open the website and create an account using the following code: {data['pending_code']}"
            )

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
