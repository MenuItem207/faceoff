import socketio
from device_handler import DeviceHandler

# global instances
globalDeviceHandler = DeviceHandler()

socket_url = "http://localhost:3000"  # url for the socket TODO: move this to .env file
client = socketio.Client()

# # socket events
# @client.on("device_init_response")
# # when a the device has been created in backend, this response is received
# def device_init_response(data):
#
#     print(data)


# call this on init
def initSocket():
    client.connect(socket_url)

    def response(data):
        if "security_profiles" in data:
            print("reconnection response")
            globalDeviceHandler.securityProfiles = data["security_profiles"]
        else:
            print("new response")
            globalDeviceHandler.deviceUUID = data["device_id"]

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
