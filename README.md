# ReadME

## Spine-Analysis-Pipeline

Pipeline for morphological classification of dendrite spines.
Originally, created in part for analysis of dendritic spine turnover due to estrous cycle changes, this pipeline is applicable for spine data exploration regarding both cross sectional and time series analysis. 

## Features

### Time Series Analysis
Runs getAllSpines (and subsequent functions) to determine the total population of spines to calculate turnover dynamics. Gaussian averaged images, binarized images, and super resolution images of the data are first produced. Manual selection of the threshold and editing of dendrites in each image is allowed. Then spine detection occurs. Spines are separated based on boundary boxes with centroids > 25 pixels (~1.7 microns) apart. Two 4D matrices (spine width x spine height x num days x num spines) are generated for each spine. Additionally, after spines are individually registered, classification based on morphological factors occurs. The four spine types are stubby, thin, mushroom, or filopodium. Users can edit the spines detected. Another GUI runs to allow selection of the spines the program could not ascertain as a spine (outliers), allowing for manual selection and classification.

### Cross Sectional Analysis

Images have been previously gaussian averaged across 4 imaging planes, typically ~3 micrometers apart. All spines in the sequence of images are detected, and the cumulative population of spines is determined. Spine type (stubby, thin, mushroom, or filopodium) is determined by a decision tree that is highly reliant on specific morphological features, therefore if the user is imaging outside of a 16X magnification (51.8 x 51.8 micron FOV) the decision tree should be modified to accommodate these changes, or the images should be normalized to match this magnification. Otherwise, an ML approach is more appropriate. This, along with morphological feature extraction, concludes the cross-sectional spine analysis, and results are plotted.

### Optional Cycle Input

Estrous cycle classifications saved as a cell array of strings can be preloaded if the user indicates that they would like to analyze spine dynamics as a function of the estrous cycle stage. Please refer to EstrousNet (https://github.com/ucsb-goard-lab/EstrousNet) for more information on how to reliably classify estrous stages from vaginal cytology images.

## Folder Structure

<details>
  <summary>View Structure</summary>
  
  ### Main Folder
  1. README.md
  2. Data Folder
     * ImagesforAnalysis.png
     * cycle.mat (i.e for estrous cycle)
     * binarized
       * binarized images
       * superresolution
            * superresolution images
        * data
          * original images
  3. SpineAnalysisPackage
      * .gitattributes
      * masterSpineAnalysis.m
      * main functions
          * getAllSpines.m
          * crossSectionalSpineAnalysis.m
          * analyzeDendrite_NSWEdit.m
      * subfunctions
          * violinplot.m
          * getManualSpines.m
          * binarizeMeanGausProjection_NSWEdit.m
          * natsortfiles
              * natsortfiles.m
              * natsort.m
              * license.txt
              * html
                  * natsortfiles_doc.html
          * ClassesAndHelpers
              * Violin_2.m
              * pixel_intersection.m
              * linept.m
              * getDendriteInfoClass.m
              * getSpineMorphologyClass.m
              * getFilteredImageClass.m
</details>

## MatLab Set-Up
1. Ensure at least 2018b version of MatLab 
2. Upload Main Folder into MatLab Current Folder
3. Open masterSpineAnalysis.m in editor
4. Direct to data folder in MatLab Current Folder
5. (If not done so) Create Cycle data as a cell array of strings
6. Make sure all functions in the program have not been renamed

## Usage & Important Notes
1. While open on Editor, run masterSpineAnalysis.m
2. If prompted, select add to path
    1. DO NOT CHANGE FROM CURRENT FOLDER
    2. May add Spine Analysis Package and all subfolders to Matlab path permanently
3. Time Series Analysis or Cross Sectional Analysis. Follow Prompts

### Time Series Analysis Features
#### Options
* If user would like to see images as they are processed, change show_image_steps to 1 (boxed in red in image below)
<br> (main functions/getAllSpines.m, Lines 46-47) </br>
![drawing](https://docs.google.com/drawings/d/17j3hRAn6GlAhZiVCwBNxfo2EApU8rkuzxetJw54Rlg4/export/png)



#### Manual Binarization Editing (Best Practices)
  1. Change Threshold (If want to) first
      * Images shown are of threshold x0.75, x1, x1.25 of current
  2. Remove/Add Portion of Dendrite: “adding” a portion of the image increases threshold by x 1.8
      <br> Note: If add/remove and then re-binarize, will revert to before addition/removal of ROI </br>

#### Manual Spine Classification Approval
1. Will be shown a diagram of the spines and color coded based on the type of spine (determined by program)
<br>Legend</br>
      * magenta - stubby
      * cyan - thin
      * yellow - mushroom
      * green - filopodia
2. Option to add or remove spines:
   * Add:
     <br> 1. select spine region and make sure first and final point for ROI connects  </br> 
        2. Select the classification for the spine
        3. Confirm classification
   * Subtract:
        <br> 1. Choose spine number wish to remove </br>
        2. Confirm selection
   * Neither: Saves all changes and continues analysis

#### SpineDetectionGUI
GUI for selecting spines the program could not determine
    GUI Structure:
<br>![drawing](https://docs.google.com/drawings/d/1o0OSf1Kc4vRM7I8bdtr34yE2cf0N_oBoMo3K8hjxRKs/export/png)</br>
1. Look through all spines for all dendrites and determine if it is a spine or not a spine
2. If you wish to change some information, select the Edit Button
3. Select the Rec #
4. Choose whether it should be classified as a spine or not
    * Spine: Type in “Spine”
    * No Spine: Type in “No Spine” (no “”)
   <br>Note: Canceling a change will cause the window to minimize. You can continue the addition and subtraction, just reopen the window.</br>
    * Confirm Selection
5. Accept Changes

## References

Program was written by Nora S. Wolcott and Marie Karpinska. The reference paper is:
    _[Long-term transverse imaging of the hippocampus with glass microperiscopes](https://elifesciences.org/articles/75391)._
<br>The helper function, natSortfiles, published on mathworks by Stephen Cobeldick (2021) and uses Bastian Bechtold’s (2016) violin plot algorithm. For more information: J.L. Hintze and R.D. Nelson. “Violin plots: a box plot-density trace synergism.” The American Statistician, vol. 52, no. 2, pp. 181-184, 1998.Spine Morphology Classification utilizes George Cubas (2003) linept.m algorithm.</br>
<br>The binarizing algorithm utilizes code from:</br>
  * SuperResolution functions written by William T. Redman.
    * Uses part of a procedure from Smirnov MS., et. al., (2018). An open-source tool for analysis and automatic identification of dendritic spines using machine learning. PLOS ONE 13(7): e0199589. [https://doi.org/10.1371/journal.pone.0199589.](https://doi.org/10.1371/journal.pone.0199589)
  * Automatic Threshold Selection from Histogram of Image, inspired by https://onlinelibrary.wiley.com/doi/full/10.1002/cyto.a.20431
