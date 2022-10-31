import socketio
from device_handler import DeviceHandler

globalDeviceHandler = DeviceHandler()
print("hi5")

# url for the socket
# TODO: move this to .env file
socket_url = "http://localhost:3000"
client = socketio.Client()


@client.on("device_init_response")
# when a the device has been created in backend, this response is received
def device_init_response(data):
    globalDeviceHandler.updateField("uuid", data["device_id"])
    print(data)


# call this on init
def initSocket():
    client.connect(socket_url)

    client.emit(
        "device_init",
        {
            "uuid": globalDeviceHandler.deviceUUID,
        },
    )


initSocket()
