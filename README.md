# Cone photoreceptor detection with machine learning elements
This repository contains matlab software pertaining to automated cone photoreceptor identification in adaptive optics scanning light ophthalmoscope (AOSLO) images. The software was developed as part of our Biomedical Optics Express submission, titled "Unsupervised Identification of Cone Photoreceptors in Non-Confocal Adaptive Optics Scanning Light Ophthalmoscope Images". 

The software given on this site is provided "as is" with the aim of being used in comparison studies or as a tool for rapid annotation of photoreceptors in AOSLO split-detection images.

## Dependencies
The software was evaluated in Matlab R2015a in Linux Ubuntu 16.04. Compatibility with other versions of Matlab has not been tested.

## Contents
The software package contains the following functions/scripts:

- findCellsInAOImage.m - receives the AOSLO image and outputing the photoreceptor locations.

- findFeatureVector.m - extracts features descriving a photoreceptor given a patch.

- findNonOverlappingExtremalRegions.m - returns number of connected components that have been fused together, based on iterative erosion of an input binary image.

mainScript.m - the entry function. Reads images from a directory, creates output directory structure, and processes the images.

setupParameters.m - specifies the parameters with which the algorithm shoud be run.

It makes use of the following toolbox and convenience functions:

bfilter2.m - processes the image with an edge preserving bilateral filter.

contains.m - quickly identifies whether elements in an array are within margins.

findImageIndices.m - returns image indices given rows and columns.

imgpolarcoord.m - returns an image in polar coordinates.

prepOutputDirectory.m - creates a directory structure to store the output and parameters.

recursivelyParseConnectedComponents.m - takes care of the iteration aspect of the findNonOverlappingExtremalRegions.m function.
