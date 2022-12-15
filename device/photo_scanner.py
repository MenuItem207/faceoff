import face_recognition
import os

unk_image_directory = r"./attempts/a2.jpg"

# returns false if no face and the id of the user if matched
def is_known_face(comparison_image_path, entries_path=r"./profiles"):
    # Accessing and Encrypting image files from FacesDB
    known_face_encodings = []
    known_face_names = []
    entries = os.listdir(entries_path)
    print(entries)

    for entry in entries:
        Loading_Image = face_recognition.load_image_file(entries_path + "/" + entry)
        known_face_encodings.append(face_recognition.face_encodings(Loading_Image)[0])
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
        return name.split(".")[0]

    return False
