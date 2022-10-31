import json
import os

# handles the logic related to the device details like its ID
class DeviceHandler:
    def __init__(self):
        # load data into memory
        file = open("config.txt", "a+")

        file.seek(0)
        fileStr = file.read()

        if fileStr != "":
            # load data
            fileData = json.loads(fileStr)
            self._deviceUUID = fileData["uuid"]

        else:
            # init data
            self._deviceUUID = None
            fileData = {
                "uuid": None,
            }
            fileStr = json.dumps(fileData)
            file.write(fileStr)

        file.close()

    @property
    # the unique identifier of the device
    def deviceUUID(self):
        return self._deviceUUID

    @deviceUUID.setter
    # setter for deviceUUID
    def deviceUUID(self, value):
        self.updateField("uuid", value)
        self._deviceUUID = value

    # updates field in text file
    def updateField(self, key, value):
        file = open("config.txt", "a+")
        file.seek(0)
        fileStr = file.read()
        file.close()

        os.remove("config.txt")

        fileData = json.loads(fileStr)
        fileData[key] = value
        fileStr = json.dumps(fileData)

        file = open("config.txt", "w")
        file.write(fileStr)
        file.close()
