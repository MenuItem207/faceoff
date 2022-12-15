import os
import requests
from env import api_url

# handles the logic related to storing, saving, processing images etc
class ImageHandler:
    # checks urls of images locally stored, deletes unused images and downloads new ones
    def resyncImages(allProfileImagesFilenames):
        print("-" * 10)
        print("Syncing images")
        allLocalImagesFilenames = ImageHandler.getAllImagesFilenames()
        allNewImages = list(
            set(allProfileImagesFilenames) - set(allLocalImagesFilenames)
        )

        allRemovedImages = list(
            set(allLocalImagesFilenames) - set(allProfileImagesFilenames)
        )

        print("allNewImages", allNewImages)
        print("downloading new images")
        for filename in allNewImages:
            ImageHandler.getAndSaveImageWithFilename(filename)

        print("allRemovedImages", allRemovedImages)
        print("deleting removed images")
        for filename in allRemovedImages:
            ImageHandler.deleteImageWithFilename(filename)

        print("images synced successfully")
        print("-" * 10)

    @staticmethod
    # returns all the filenames (with extension) of all locally stored images
    def getAllImagesFilenames():
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

    @staticmethod
    # uploads a file to server
    def uploadImage(image_path):
        # Read the image file into memory
        with open(image_path, "rb") as image_file:
            image_data = image_file.read()

        # Prepare the request
        filename = os.path.basename(image_path)
        url = "{}/image".format(api_url)
        print(f"uploading image ${filename}")
        files = {"image": (filename, image_data)}

        # Send the request
        response = requests.post(url, files=files)

        # Print the response
        print(response.text)
        print(response.status_code)
