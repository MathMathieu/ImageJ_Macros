///Macro  Nathalie Coloc mask 3 marqueur
/// part 2

/// make compartments masks

/// apply a small radirus bg substraction to keep only small objects

dir=getDirectory("output Directory with crops");

dirOut=dir+"Masks"+File.separator();
File.makeDirectory(dirOut);

list=getFileList(dir);

BGradius=10;

canalCD63=2;
minCD63Thresh=550;

canalCD9=1;
minCD9Thresh=1200;

canalRab7=3;
minRab7Thresh=800;

run("Colors...", "foreground=white background=black selection=yellow");

for(i=0;i<lengthOf(list);i++) {
	if(endsWith(list[i],".tif")) {
		roiManager("reset");
		open(dir+list[i]);
		ShortName=substring(list[i],0,lengthOf(list[i])-4);
		roiManager("Add");
		run("Select None");
		run("Median...", "radius=1 stack");
		run("Subtract Background...", "rolling="+BGradius+" stack");
		setMinAndMax(0,4095);
		
		
		run("Split Channels");

		selectWindow("C"+canalCD63+"-"+list[i]);
		run("Threshold...");
		setAutoThreshold("Default dark stack");
		setThreshold(minCD63Thresh,4095);
		run("Convert to Mask", "method=Default background=Default black");
		roiManager("Select",0);
		run("Clear Outside", "stack");

		saveAs("Tiff",dirOut+ShortName+"_MaskCD63.tif");
		run("Close");

		selectWindow("C"+canalCD9+"-"+list[i]);
		run("Threshold...");
		setAutoThreshold("Default dark stack");
		setThreshold(minCD9Thresh,4095);
		run("Convert to Mask", "method=Default background=Default black");
		roiManager("Select",0);
		run("Clear Outside", "stack");

		saveAs("Tiff",dirOut+ShortName+"_MaskCD9.tif");
		run("Close");

		selectWindow("C"+canalRab7+"-"+list[i]);
		run("Threshold...");
		setAutoThreshold("Default dark stack");
		setThreshold(minRab7Thresh,4095);
		run("Convert to Mask", "method=Default background=Default black");
		roiManager("Select",0);
		run("Clear Outside", "stack");

		saveAs("Tiff",dirOut+ShortName+"_MaskRab7.tif");
		run("Close");

		run("Close All");
		
	}
}


