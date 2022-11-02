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
            self._deviceLockedState = fileData["device_locked_state"]
            self._securityProfiles = fileData["security_profiles"]

        else:
            # init data
            self._deviceUUID = None
            self._deviceLockedState = 1  # set to locked
            self._securityProfiles = []
            fileData = {
                "uuid": None,
                "device_locked_state": self._deviceLockedState,
                "security_profiles": self._securityProfiles,
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

    @property
    # whether or not the device is unlocked (0), locked (1), or disabled (2)
    def deviceLockedState(self):
        return self._deviceLockedState

    @deviceLockedState.setter
    # setter for deviceLockedState
    def deviceLockedState(self, value):
        self.updateField("device_locked_state", value)
        self._deviceLockedState = value

    @property
    # the security profiles
    def securityProfiles(self):
        return self._securityProfiles

    @securityProfiles.setter
    # setter for securityProfiles
    def securityProfiles(self, value):
        self.updateField("security_profiles", value)
        self._securityProfiles = value

    # updates field in text file
    # *don't call this function directly, instead use a setter to update both state and file
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
