SoundProcessing_MatlabFunctions
===============

Matlab sound analysis and plotting functions by Teresa Nick

These are Mathworks Matlab functions for use in plotting and analyzing wav files.  

Dependencies:
The Matlab Signal Processing Toolbox is required to run these functions.

Specific main functions:

waveditrev.m
This function is used to "cut" wave files to produce forward and reverse stimuli. In the birdsong field, birds' songs are cut to produce stimuli that selectively activate the song system.  Forward stimuli are typically more effective than reverse stimuli.

findvocs_wav.m
This function is used on directories of wav files to find and extract "songs" as defined by continuous sound segments separated by configurable silent periods.

motifhunter_wav.m
This function allows the user to select an exemplar motif and then uses the amplitude envelope of that exemplar motif to match and pull out other motifs from all wav files in the directory.  Under the hood, the peak cross-correlation is use to match.  Pick long, loud motifs for best results.  The exemplar amplitude envelope is saved and can be reused to find other motifs. 
