// Ask user to select a folder
dir = getDirectory("Select a folder containing TIFF files for segmentation");
if (dir == "") exit("No folder selected");

// Get list of TIFF files in the folder
list = getFileList(dir);
for (i = 0; i < list.length; i++) {
    if (endsWith(list[i], ".tif")) {
        processTiff(dir, list[i]);
    }
}

function processTiff(directory, filename) {
    filepath = directory + filename;
    print("Processing: " + filepath);
    open(filepath);
    wait(500); // Ensure image loads fully

    // Get image properties
    getDimensions(width, height, channels, slices, frames);
    print("Image has " + slices + " z-slices");

    // Store the original image title
    originalImage = getTitle();

    // Create an empty stack for segmented images
    newImage("Segmented_" + filename, "8-bit black", width, height, slices);

    // Process each z-slice with StarDist
    for (z = 1; z <= slices; z++) {
        print("Processing slice " + z);
        
        // Extract single slice as a 2D image
        selectWindow(originalImage);
        setSlice(z);
        run("Duplicate...", "title=tempSlice");

        // Run StarDist segmentation on the 2D slice
        run("StarDist 2D", "model=Versatile (fluorescent nuclei) " +
            "probability_map " +
            "output_type=Label Image " +
            "prob_thresh=0.5 " +
            "nms_thresh=0.4");

        // Copy the segmented result into the new stack
        selectWindow("Label Image");
        run("Copy");
        selectWindow("Segmented_" + filename);
        setSlice(z);
        run("Paste");

        // Close intermediate images
        close("Label Image");
        close("tempSlice");
    }

    // Save the segmented multi-slice TIFF
    saveAs("Tiff", directory + "Segmented_" + filename);

    // Close the original image
    selectWindow(originalImage);
    close();

    // Close the segmentation result
    selectWindow("Segmented_" + filename);
    close();
}