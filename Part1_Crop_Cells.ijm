///Macro  Nathalie Coloc mask 3 marqueur
/// part 1

/// individualisation of cells to analyse


/// works with an .czi opened and save

dir=getDirectory("image");

name=getTitle();
ShortName=substring(name,0,lengthOf(name)-4);

dirOut=dir+ShortName+"_Output"+File.separator();

File.makeDirectory(dirOut);

canalMaskCell=3;
minCellThresh=300;

roiManager("reset");


///// masque des cellules
selectWindow(name);
run("Z Project...", "projection=[Max Intensity]");
run("Duplicate...", "title=MaskCell duplicate channels="+canalMaskCell);

selectWindow("MAX_"+name);
Stack.setDisplayMode("composite");
run("RGB Color");
rename("tempCtrlMask");

selectWindow("MaskCell");
run("Mean...", "radius=10");

run("Threshold...");
setThreshold(minCellThresh,4095);
run("Convert to Mask", "method=Default background=Default black");
run("Create Selection");
roiManager("add");

	
run("Colors...", "foreground=white background=black selection=yellow");
selectWindow("tempCtrlMask");
roiManager("Draw");

roiManager("Reset");
		
setTool("freeline");
waitForUser("Draw lines to separate Nuclei and add to the mananger with keybord (t)");
		
run("Line Width...", "line=2");
run("Colors...", "foreground=black background=white selection=yellow");
		
selectWindow("MaskCell");
roiManager("Draw");

roiManager("Reset");

setTool("wand");
waitForUser("select cellto analyse and add them to the mananger with keybord (t)");

///crop all cell
for(i=0;i<roiManager("Count");i++) {
	i1=i+1;
	selectWindow(name);
	roiManager("select",i);
	run("Duplicate...", "duplicate");
	saveAs("Tiff",dirOut+ShortName+"_cell"+i1+".tif");
	run("Close");
}

roiManager("save",dirOut+ShortName+"_roiCell.zip");

run("Close All");


