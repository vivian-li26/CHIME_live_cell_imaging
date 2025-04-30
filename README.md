# CHIME_live_cell_imaging

## Directory structure

Before beginning your analysis, create a master folder and upload your `.nd2` files. Follow the naming convention:

> **date_(optional) one word summary of experiment purpose_xy\[i]**
> where *i* is the index of your sample number

Batch processing features in the scripts will take care of extracting files from correct folders and saving outputs to correct folders, unless it is *otherwise noted* in the following directory tree (you will have to create those folders by hand).

- *BF*
  : contains tiff images of brighfield channel split from `.nd2` files
- *PI*
  : contains tiff images of PI channel split from `.nd2` files
    - PI_segmented
      : contains segmentation results of the PI channel images, saved as labeled images
- *YFP*
  : contains tiff images of YFP channel split from `.nd2` files
    - YFP_segmented
      : contains segmentation results of the YFP channel images, saved as labeled images
- *CTV*
  : contains tiff images of CTV channel split from `.nd2` files
    - CTV_segmented
      : contains segmentation results of the CTV channel images, saved as labeled images
- *tracking*
  : contains the TrackMate outputs (`spots.csv`, `tracks.csv`) of the CTV channel labeled images
    - combined_spots_relabeled
      : contains the `spots.csv` files of the (PI and YFP channels) concatenated labeled images with the source of each label updated
    - xy\[i]_distance_csv_files
      : contains the distances between each target and its k nearest effectors in each frame
      : contains the approaching pairs of effectors and targets identified
      : contains the effectors and targets under persistent contact identified
- filtered_segmentation
  : contains PI and YFP channel segmentation results with PI+ CTLs and debris removed
    - concatenated_segmentation
      : contains the respective filtered PI and YFP channel labeled images of the sample concatenated, with a lookup table indicating the
      : source (YFP or PI) of each label
      : contains the raw TrackMate outputs (`spots.csv`, `tracks.csv`) of the (PI and YFP channels) concatenated labeled images (does not yet have the
      : source of each label updated)


***

## Workflow

1. Run `ND2_split_channels_to_TIFF.ijm` in ImageJ. This script will name the tiff files according to the order they are acquired in. Afterwards, create a folder for each channel and move the tiff files to their respective folders.
2. Run `Cellpose_Segment_TimeSeries_O2.ipynb` and `StarDist_Segment_TimeSeries_O2.ipynb`. Provide the path to the **master folder**, and the scripts will batch process the segmentation.
3. Run `Labels_PostProcessing.ipynb` on PI and YFP channel labeled images to remove PI+ CTLs and debris. This scripts needs to be run manually on each inividual labeled image, because the filters should be set based on the metrics of the labels. However, the only thing that needs to be changed is the sample index.
4. Run TrackMate on the CTV channel labeled images and create a **tracking** folder to save the outputs (`spots.csv`, `tracks.csv`). Follow the naming convention:

> **date_(optional) one word summary of experiment purpose_xy\[i]_effector_spots (or tracks)**

5. Run `Batch_Concatenate_Labels.ipynb`. Provide the path to the **master folder**. First only run the code block to batch process the concatenation.
6. Run TrackMate on the (PI and YFP channels) concatenated labeled images and save the outputs (`spots.csv`, `tracks.csv`) in the **concatenated_segmentation** folder. Follow the naming convention:

> **date_(optional) one word summary of experiment purpose_xy\[i]_target_combined_spots (or tracks)**

7. Return to `Batch_Concatenate_Labels.ipynb` and run the code block to batch relabel the `spots.csv` files.
8. Run `Manipulate_Distance_Info_from_Tracking.ipynb` to calculate the distance, identify the interactions, and visualize the interaction kinetics.