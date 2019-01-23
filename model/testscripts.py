import matplotlib
import matplotlib.pyplot as plt
import numpy as np


def diff_images(image1, image2):
    """
    image1/2: dateinamen (png funzt)
    """
    im1 = matplotlib.image.imread(image1)
    im2 = matplotlib.image.imread(image2)

    diff = im1 - im2
    print("Max Difference: ", np.max(np.abs(diff)))
    print("Sum Difference: ", np.sum(np.abs(diff)))
    plt.figure(1)
    plt.imshow(diff)
    plt.show()
