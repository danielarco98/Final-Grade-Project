# Final Grade Project
### Daniel Arco Alonso
Final Grade Project for Bachelor Degree on Bionformatics 2019-2020.

Design and analysis of a psychophysical experiment which aims to establish if symmetry can be perceived as a continuous feature.
Each folder contains code and information about different stages of the experimental procedure:

* Experiment:
Contains code about the symmetric images creation procedure and experimental design. There are two subdirectories containing the experimental(ExperimentIm) and training (TrainingIm) images. 
Scripts were written in Matlab 2019b environment:
  1. Generate_PartialSymmetricImage.m: Main function used for generating white and black images
  with global and local symmetric patterns.
  2. CreateSymm_Pattern.m: Function used on Generate_PartialSymmetricImage.m for generating local symmetric patterns with desired asymmetry gradation.
  3. Symmetry_Score.m: Function used for assigning the correlation coefficient as a symmetry measure on the experimental images.
  4. testscores.m: Script used for testing the evolution of global symmetry and correlation between symmetric halves.
  5. training.m: Code for the training phase of the experiment. Psychtoolbox is required. 
  6. EXPERIMENT.m: Main code for the experimental design. Psychtoolbox is required.

* Stadistics:
Contains the code used for the statistical analysis of the experimental data. The results obtained on the experiment are also included on the subdirectory Results.
Scripts were written in R:
  1. detectiontask.R: Analysis of the accuracy of detecting the symmetry axis.
  2. scoringmodel.R: Analysis of the score assigned to correctly detected symmetry.
