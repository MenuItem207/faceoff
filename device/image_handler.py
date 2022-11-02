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

        print(allNewImages)
        print(allRemovedImages)

    @staticmethod
    # returns all the filenames (with extension) of all locally stored images
    def getAllImagesFilenames():
        return []
