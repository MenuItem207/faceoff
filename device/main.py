import socketio
from image_handler import ImageHandler
from device_handler import DeviceHandler
from env import socket_url

# global instances
globalDeviceHandler = DeviceHandler()

client = socketio.Client()

# # socket events
# @client.on("device_init_response")
# # when a the device has been created in backend, this response is received
# def device_init_response(data):
#
#     print(data)


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


# this function runs the operation of the device, it should be called once the initialisation sequence is complete
def operateDevice():
    print("Device successfully initiated")


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
