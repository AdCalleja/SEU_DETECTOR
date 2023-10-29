import cv2
import numpy as np
import matplotlib.pyplot as plt


class Debayer:
    def __init__(self, bayer_input):
        self.bayer_input = bayer_input

        # bayer_input = np.array([[1, 2, 3, 4, 5, 6, ],
        #                         [7, 8, 9, 10, 11, 12],
        #                         [13, 14, 15, 16, 17, 18],
        #                         [19, 20, 21, 22, 22, 24,],
        #                         [25, 26, 27, 28, 29, 30,],
        #                         [31, 32, 33, 34, 35, 36,]], dtype=np.uint8)


        bayer_pattern = np.tile(np.array([['g', 'r',],
                                            ['b', 'g',]]),(int(bayer_input.shape[0]/2),int(bayer_input.shape[1]/2)))

        # Bayer input channel composition
        self.bayer_input_composition = np.zeros((bayer_input.shape[0], bayer_input.shape[0], 3), dtype=np.uint8)
        self.bayer_input_composition[:,:,0] = bayer_input
        self.bayer_input_composition[bayer_pattern == 'g', 1] = self.bayer_input_composition[bayer_pattern == 'g', 0]; self.bayer_input_composition[ bayer_pattern == 'g', 0] = 0
        self.bayer_input_composition[bayer_pattern == 'b', 2] = self.bayer_input_composition[bayer_pattern == 'b', 0]; self.bayer_input_composition[bayer_pattern == 'b', 0] = 0

        # Bayer input channels
        self.red_channel = np.copy(bayer_input); self.green_channel = np.copy(bayer_input); self.blue_channel = np.copy(bayer_input)
        self.red_channel[(bayer_pattern == 'g') | (bayer_pattern == 'b')] = 0
        self.green_channel[(bayer_pattern == 'r') | (bayer_pattern == 'b')] = 0
        self.blue_channel[(bayer_pattern == 'r') | (bayer_pattern == 'g')] = 0

        # Debayered image
        self.debayered = cv2.cvtColor(bayer_input, cv2.COLOR_BayerGB2RGB)

        # Values for the Debayered matrix as 32bits RGB
        self.debayered_uint32 = np.zeros((bayer_input.shape[0], bayer_input.shape[1]), dtype=np.uint32)
        for i in range(bayer_input.shape[0]):
            for j in range(bayer_input.shape[1]):
                self.debayered_uint32[i, j] = (
                    self.debayered[i, j, 0] << 16 |
                    self.debayered[i, j, 1] << 8 |
                    self.debayered[i, j, 2])

    def plot_debayering_process(self):
        plt.figure(figsize=(10,10))
        plt.subplot(332)
        plt.title('Input')
        plt.imshow(self.bayer_input_composition)
        plt.subplot(334)
        plt.title('Red Channel')
        plt.imshow(self.red_channel, cmap='Reds')
        plt.subplot(335)
        plt.title('Green Channel')
        plt.imshow(self.green_channel, cmap='Greens')
        plt.subplot(336)
        plt.title('Blue Channel')
        plt.imshow(self.blue_channel, cmap='Blues')
        plt.subplot(338)
        plt.title('Debayered Image')
        plt.imshow(self.debayered)


    def plot_debayered_uint32(self):
        # DEBAYERED VALUES
        plt.figure(figsize=(10,10))
        plt.title('Debayered Image Values')
        for (j,i),label in np.ndenumerate(self.debayered_uint32):
            plt.text(i,j,f"{label}\n{hex(label)}",ha='center',va='center', color='White')
        plt.imshow(self.debayered)
        plt.show()