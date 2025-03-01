// Select a folder containing ND2 files
dir = getDirectory("Select a folder containing ND2 files");
if (dir == "") exit("No folder selected");

// Get list of ND2 files in the folder
list = getFileList(dir);
for (i = 0; i < list.length; i++) {
    if (endsWith(list[i], ".nd2")) {
        processND2(dir, list[i]);
    }
}

function processND2(directory, filename) {
    filepath = directory + filename;
    print("Processing: " + filepath);
    open(filepath);
    wait(1000); // Ensure the file loads completely

    // Extract filename without extension
    dotIndex = lastIndexOf(filename, ".");
    if (dotIndex > 0) {
        name = substring(filename, 0, dotIndex);
    } else {
        name = filename; // Fallback if no extension
    }

    // Get number of channels
    getDimensions(width, height, channels, slices, frames);
    print("Image has " + channels + " channels");

    // Split channels
    run("Split Channels");
    wait(500); // Allow channels to split
    
    // Save each channel
    for (c = 1; c <= channels; c++) {
        chName = "C" + c + "-" + name + ".nd2";
        if (isOpen(chName)) {
            selectWindow(chName);
            savePath = directory + name + "-C" + c + ".tif";
            print("Saving: " + savePath);
            saveAs("Tiff", savePath);
            close();
        } else {
            print("Warning: Window " + chName + " not found!");
        }
    }

    // Close the original image if it's still open
    if (isOpen(name)) {
        close();
    }
}