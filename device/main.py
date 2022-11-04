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
    print("unimplemented")


@client.on("client_event_modify_security_profile")
# when client adds / removes / edits a security profile
def client_event_modify_security_profile(data):
    print("unimplemented")


# this function runs the operation of the device, it should be called once the initialisation sequence is complete
def operateDevice():
    print("Device successfully initiated")


# call this on init
def initSocket():
    client.connect(socket_url)

    def response(data):
        if "security_profiles" in data:
            print("reconnection response")
            globalDeviceHandler.securityProfiles = data["security_profiles"]

            allProfileImagesFileNames = []
            for securityProfile in globalDeviceHandler.securityProfiles:
                allProfileImagesFileNames.append(securityProfile["img_url"])
            ImageHandler.resyncImages(allProfileImagesFileNames)

            operateDevice()

        else:
            print("new response")
            globalDeviceHandler.deviceUUID = data["device_id"]

            operateDevice()

        print(data)

    client.emit(
        "device_init",
        {
            "uuid": globalDeviceHandler.deviceUUID,
            "device_locked_state": globalDeviceHandler.deviceLockedState,
        },
        callback=response,
    )


initSocket()
