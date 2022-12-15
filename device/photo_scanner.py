import cv2
import face_recognition
import numpy as np
import os

known_image_directory = r""
unk_image_directory = r""


def is_known_face(entries_path, comparison_image_path):
    # Accessing and Encrypting image files from FacesDB
    known_face_encodings = []
    known_face_names = []
    entries = os.listdir(known_image_directory)
    
    
    for entry in entries: 
        os.chdir(known_image_directory)
        Loading_Image = face_recognition.load_image_file(entry)
        known_face_encodings.append(face_recognition.face_encodings(Loading_Image)[0])
        known_face_names.append(entry)
    
    # Accessing and Encrypting image files from UnkFacesDB
    unknown_entries = os.listdir(unk_image_directory)
    unknown_face_encodings = []
    unknown_face_names = []
    
    for entry in unknown_entries: 
        os.chdir(unk_image_directory)
        Loading_Image = face_recognition.load_image_file(entry)
        unknown_face_encodings.append(face_recognition.face_encodings(Loading_Image)[0])
        unknown_face_names.append(entry)
    
    for face_encoding in unknown_face_encodings:
                # See if the face is a match for the known face(s)
                matches = face_recognition.compare_faces(known_face_encodings, face_encoding)
                name = "Unknown"
    
                # If a match was found in known_face_encodings, just use the first one.
                if True in matches:
                     first_match_index = matches.index(True)
                     name = known_face_names[first_match_index]
                     print("This image matches up with " + name)
                     break
                 
                # Or instead, use the known face with the smallest distance to the new face
                face_distances = face_recognition.face_distance(known_face_encodings, face_encoding)
                best_match_index = np.argmin(face_distances)
                if matches[best_match_index]:
                    name = known_face_names[best_match_index]
                    print("This image is similar to " + name)
    
    
result = is_known_face(known_image_directory,unk_image_directory)
    