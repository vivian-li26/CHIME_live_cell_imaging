# CHIME_live_cell_imaging

## Directory structure

Before beginning your analysis, create a master folder `yyyy-mm-dd_live_cell_imaging` and upload your `.nd2` files. Follow the naming convention (**DO NOT** leave spaces in the file name):   
`yyyy-mm-dd_(optional summary of experiment purporse)_sample[i]_(optional summary of sample type).nd2`   
where `i` is the index of your sample number   


The scripts in this repository batch process live cell imaging data. Below is the directory structure containing all of the inputs and outputs involved in the scripts, with a description of each folder and its contents:

```
yyyy-mm-dd_live_cell_imaging/
├── yyyy-mm-dd_channel1/
│   <image stacks of channel1 split from .nd2 files> 
│   └── yyyy-mm-dd_channel1_segmented
│       <labeled image stacks of the segmentation results of channel1 images>
│
├── yyyy-mm-dd_channel2/
│   <image stacks of channel2 split from .nd2 files> 
│   └── yyyy-mm-dd_channel1_segmented
│       <labeled image stacks of the segmentation results of channel2 images>
│
├── yyyy-mm-dd_channel3/
│   <image stacks of channel3 split from .nd2 files> 
│   └── yyyy-mm-dd_channel1_segmented
│       <labeled image stacks of the segmentation results of channel3 images>
│
├── yyyy-mm-dd_channel4/
│   <image stacks of channel1 split from .nd2 files> 
│   └── yyyy-mm-dd_channel4_segmented
│       <labeled image stacks of the segmentation results of channel4 images>
│
├── (optional)yyyy-mm-dd_filtered_segmentation/
│   <post-processed labeled image stacks with misidentified debris removed> 
│   └── yyyy-mm-dd_concatenated segmentation/
│       <labeled image stacks concatenated from filtered YFP and PI channels>
│       <lookup table indicating the source (YFP or PI) of each label in the concatenated stack>
│
├── yyyy-mm-dd_tracking/
│   <effector cells spots>
│   <effector cells tracks>
│   <effector cells tracking metafile>
│   <target cell spots>
│   <target cell tracks>
│   <target cells tracking metafile>
│   └── (optional)yyyy-mm-dd_combined_spots_relabeled/
│       <target cells spots with the source of each spot (YFP or PI) updated>
│
├── yyyy-mm-dd_metrics/
│   ├── yyyy-mm-dd_measurements/
│   │   <target cell metrics>
│   ├── yyyy-mm-dd_leakages/
│   │   <target cell leakages>
│   └── yyyy-mm-dd_sample[i]_distance_csv_files/ 
│       <distance between each targets and its k nearest effector in each frame>
│       <pairs of targets and effectors approaching each other over multiple frames>
│       <pairs of targets and effectors under persistent contact over multiple frames>
│
└── yyyy-mm-dd_figures/
│   <figures generated from visualization script>
```

***

## Setting up interactive sessions on O2
#### Running FIJI on O2
1. Launch a Desktop Mate session with appropriate WallTime and memory.
2. *(First-time users)* To install FIJI, click on the terminal icon and enter the following command:
    `/n/app/bias/install/fiji/fiji-imagej.sh --install`
3. Use FIJI as usual

#### Running Jupyter Notebook on O2
Launch a Jupyter session:   
1. Modules to be preloaded:   
    `gcc/14.2.0 python/3.13.1 cuda/12.8 conda/miniforge3`
2. Partition (consult "How to choose a partition in O2" in the O2 documentation for more details):   
   **short/ medium/ long** for normal CPU tasks   
   **priority** if only running one job that day and would like shorter wait time   
   **gpu-quad** if require gpu resources
3. *(If requested gpu resources)* GPUs: `1`
4. Request appropriate WallTime and memory.
5. Jupyter Environment:   
    for StarDist segmentation **only**:
   `conda activate /n/data1/hms/immunology/sharpe/lab/CHIME_live_cell_image_analysis/stardist-env`   
    or   
    for all other scripts:
   `conda activate /n/data1/hms/immunology/sharpe/lab/CHIME_live_cell_image_analysis/cellpose-env`
7. Jupyter extra arguments:   
    `--notebook-dir= /n/data1/hms/immunology/sharpe/lab/CHIME_live_cell_image_analysis/live_cell_imaging_scripts`
8. Check `Enable JupyterLab`

***

## Workflow

1. Upload time-lapse images to O2.   
    **Via command line:**
    `scp path_to_image_file your_hms_id@transfer.rc.hms.harvard.edu:/path_to_target_folder`   
    *Tip*: use `/*.nd2` at the end of the image file path to upload all `.nd2` files in the folder at once.
2. Run `ND2_split_channels_to_TIFF.ijm` in ImageJ. This script will name the tiff files according to the order they are acquired in. Afterwards, reanme the tiff files, replacing ImageJ's default numbering `-C[i]` with the correct `_ChannelName`. Create a folder for each channel `yyyy-mm-dd_ChannelName`, and move the tiff files to their respective folders.
3. *(Optional)* For selected channel(s), run `Rolling_ball_BG_denoise.ijm` in ImageJ. Move the raw images to somewhere outside the master folder, and proceed to segmentation with the background corrected images.
4. Run `Cellpose_Segment_TimeSeries_O2.ipynb` on the cytoplasm channel(s) and `StarDist_Segment_TimeSeries_O2.ipynb` on the nuclei channel(s).
5. *(Optional)* For selected channel(s), run `Labels_PostProcessing.ipynb` to join fragmented labels and remove misidentified debris. Based on the size distribution graphs and metrics, set the size cutoff(s) to remove unwanted labels.
6. *(for YFP/iRFP670/PI setup)* Run only the code block in `Batch_Concatenate_Labels.ipynb`, for concatenating the filtered iRFP670 and PI labels.  
7. Run TrackMate on the CTV (*effector*) and concatenated (*target*) labels or the CTV (*effector*) and mCherry (*target*) labels.   
    Before doing tracking, to quickly check the segmentation quality by eye, open the original image and labeled image side by side. Choose the labeled image first, go to `Plugins > BIOP > Image Analysis > ROIs > Label image to ROIs`. In the `ROI Manager` window that shows up, check `Show All`. Then move over to the original image and re-check `Show All`. Now you have the original image and the labeled image side by side, with all the identified cells outlined in yellow, to compare for segmentation quality. If segmentation looks good, proceed to tracking using the labeled image.

    7a. Launch `Plugins > Tracking > TrackMate`. Double check X, Y, T dimensions match what you expect.   
    7b. Select `Labeled Image Detector`. Once TrackMate finishes identifying labels and calculating label properties, you can set filters on various label parameters for which cells to include in tracking. TrackMate only allows for one-sided cutoff. To only include the middle portion of the distribution, set two filters (1 max and 1 min) for this given parameter. Also note that for any filters you set and paramters you entered, TrackMate will remember those values for the next tracking you do.   
    7c. Select `LAP Tracker`. For frame to frame linking distance, use 5-10 pixels more than the average distance that cells move between frames. For track segment gap closing distance, use 5-10 pixels more than the linking distance; for gap closing frame, use 5 for target cells, 1 for effector cells.   
    7d. Once TrackMate finishes tracking and calculating track properties, you can set filters on various track parameters for which tracks to include.   
    7e. To save tracking outputs, first create `yyyy-mm-dd_tracking`. For the outputs (`spots`, `tracks`, `metafile`), follow the naming convention:

    `yyyy-mm-dd_sample[i]_effector_spots.csv`   
    `yyyy-mm-dd_sample[i]_effector_tracks.csv`   
    `yyyy-mm-dd_sample[i]_effector_TrackMate.xml`   
    `yyyy-mm-dd_sample[i]_target_spots.csv`   
    `yyyy-mm-dd_sample[i]_target_tracks.csv`   
    `yyyy-mm-dd_sample[i]_target_TrackMate.xml`

9. *(for YFP/iRFP670/PI setup)* Run the relabel and quality check code blocks in  `Batch_Concatenate_Labels.ipynb`, for updating the source of each target in the `spots` files.
10. Collect metrics:   
    9a. *(for YFP/iRFP670/PI setup)* Run `Measure_Metrics_across_Frames.ipynb` to record target cell metrics.   
    9b. *(for GFP/mCherry setup)* Run `Detect_Nuclear_Leakage.ipynb` to record target cell nuclear damages.
11. Identify effector-target interactions and visualize interaction and killing kinetics:   
    10a. *(for CTV/YFP/iRFP670/PI setup)* Run `Manipulate_DistanceInfo_from_Tracking.ipynb`.   
    10b. *(for CTV/GFP/mCherry setup)* Run `Manipulate_DistanceInfo_with_Reporter.ipynb`.   