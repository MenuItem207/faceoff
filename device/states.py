import enum

# different states for the device
class State(enum.Enum):
    SETUP = 1  # state for setting up the device
    IDLE = 2  # state when device is awaiting instructions
    AUTHENTICATING = 3  # state when device is trying to authenticate user
