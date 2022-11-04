import os
import requests
from env import api_url

# handles the logic related to storing, saving, processing images etc
class ImageHandler:
    # checks urls of images locally stored, deletes unused images and downloads new ones
    def resyncImages(allProfileImagesFilenames):
        allLocalImagesFilenames = ImageHandler.getAllImagesFilenames()
        allNewImages = list(
            set(allProfileImagesFilenames) - set(allLocalImagesFilenames)
        )

        allRemovedImages = list(
            set(allLocalImagesFilenames) - set(allProfileImagesFilenames)
        )

        print("retrieving new images")
        for filename in allNewImages:
            ImageHandler.getAndSaveImageWithFilename(filename)

        print("deleting removed images")
        for filename in allRemovedImages:
            ImageHandler.deleteImageWithFilename(filename)

        print("allNewImages", allNewImages)
        print("allRemovedImages", allRemovedImages)

    @staticmethod
    # returns all the filenames (with extension) of all locally stored images
    def getAllImagesFilenames():
        print("files")
        return os.listdir("./profiles")

    @staticmethod
    # retrieves a file with filename from server and saves it
    def getAndSaveImageWithFilename(filename):
        url = api_url + "/image/" + filename
        response = requests.get(url)
        open("profiles/" + filename, "wb").write(response.content)

    @staticmethod
    # deletes a file with filename
    def deleteImageWithFilename(filename):
        os.remove("profiles/" + filename)
