import face_recognition
import os
import cv2
import time

import speech_recognition as sr
import pyttsx3


# Initialize the recognizer
r = sr.Recognizer()

# handles the collecting of user input
class UserInput:
    @staticmethod
    # Function to convert text to
    # speech
    def SpeakText(command):

        # Initialize the engine
        engine = pyttsx3.init()
        engine.say(command)
        engine.runAndWait()

    @staticmethod
    # listens for keywords or phrases and only returns when found
    def getUserInput() -> str:
        UserInput.SpeakText("Listening for commands")
        while 1:
            try:

                # use the microphone as source for input.
                with sr.Microphone() as source2:

                    # wait for a second to let the recognizer
                    # adjust the energy threshold based on
                    # the surrounding noise level
                    r.adjust_for_ambient_noise(source2, duration=0.2)

                    # listens for the user's input
                    audio2 = r.listen(source2)

                    # Using google to recognize audio
                    MyText = r.recognize_google(audio2)
                    MyText = MyText.lower()

                    return MyText

            except sr.RequestError as e:
                print("Could not request results; {0}".format(e))

            except sr.UnknownValueError:
                print("Still Listening")

    @staticmethod
    # takes a picture and returns path
    def getUserImagePath() -> str:
        camera = cv2.VideoCapture(0)
        success, frame = camera.read()
        timestamp = time.time()
        filename = "./attempts/image_{}.jpg".format(timestamp)
        cv2.imwrite(filename, frame)
        return filename

    @staticmethod
    # returns [filename of the matching user, filename of the comparison image]
    def verifyUser(entries_path=r"./profiles"):
        comparison_image_path = UserInput.getUserImagePath()

        # Accessing and Encrypting image files from FacesDB
        known_face_encodings = []
        known_face_names = []
        entries = os.listdir(entries_path)
        print(entries)

        for entry in entries:
            Loading_Image = face_recognition.load_image_file(entries_path + "/" + entry)
            known_face_encodings.append(
                face_recognition.face_encodings(Loading_Image)[0]
            )
            known_face_names.append(entry)

        # get face encoding
        unknown_face = face_recognition.load_image_file(comparison_image_path)
        unknown_face_encoding = face_recognition.face_encodings(unknown_face)[0]

        # See if the face is a match for the known face(s)
        matches = face_recognition.compare_faces(
            known_face_encodings, unknown_face_encoding
        )
        print(matches)

        # If a match was found in known_face_encodings, just use the first one.
        if True in matches:
            first_match_index = matches.index(True)
            name = known_face_names[first_match_index]
            print("This image matches up with " + name)
            return [name, comparison_image_path]

        return []
