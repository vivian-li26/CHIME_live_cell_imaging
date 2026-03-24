// Select a folder containing files to process
dir = getDirectory("Select a folder containing files to denoise background");
if (dir == "") exit("No folder selected");

// Ask user for rolling ball radius
Dialog.create("Background subtraction parameters");
Dialog.addNumber("Rolling ball radius (pixels):", 50);
Dialog.show();
radius = Dialog.getNumber();

// Get list of TIF files in the folder
list = getFileList(dir);
for (i = 0; i < list.length; i++) {
    if (endsWith(list[i], ".tif")) {
        process_DN_BG(dir, list[i], radius);
    }
}

function process_DN_BG(directory, filename, radius) {
	filepath = directory + filename;
	print("Processing: " + filepath);
	open(filepath);
	wait(500); // Ensure the file loads completely
	
	// Extract filename without extension
    dotIndex = lastIndexOf(filename, ".");
    if (dotIndex > 0) {
        origTitle = substring(filename, 0, dotIndex);
    } else {
        origTitle = filename; // Fallback if no extension
    }
    
    // Duplicate stack
    dupTitle = origTitle + "_CORR";
    run("Duplicate...", "title=[" + dupTitle +"] duplicate");
    
    // Subtract background
    run("Subtract Background...", "rolling=" + radius + " sliding stack");
    wait(1000); // Allow background denoising to run
    
    // Save processed file
    savePath = directory + dupTitle + ".tif";
    print("Saving: " + savePath);
    saveAs("Tiff", savePath);
    
    // Close all windows
    close();
    selectWindow(filename);
    close();
    
}