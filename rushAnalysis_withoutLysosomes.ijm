
/// Work with an open movie of a cropped cells

run("Set Measurements...", "area mean integrated display redirect=None decimal=3");

if(isOpen("Results")==true) {
	selectWindow("Results");
	run("Close");
}

frameInterval=1;
TimeUnit="min";

GolgiSizeCuttoff=20;
///noise tolerance should be adapted for the analyze particle function to detect small compartments according to the picture
NoiseTolerance=1800;

name=getTitle(); 
Stack.getStatistics(voxelCount, mean, min, max, stdDev);
Stack.getDimensions(width, height, channels, slices, frames);
dir=getDirectory("Image");
name1=substring(name,0,lengthOf(name)-4);



selectWindow(name);
setMinAndMax(min, max);
run("Duplicate...", "title=maskGolgi.tif duplicate");
run("8-bit");
run("Threshold...");
waitForUser("Faire le seuillage du golgi sur l'image maskGolgi.tif");
setOption("BlackBackground", true);
run("Convert to Mask", "method=Default background=Default black");

/// prepare Array for measurement
time=newArray(frames);
GolgiArea=newArray(frames);
GolgiFluoInt=newArray(frames);
NbVesicles=newArray(frames);

run("ROI Manager...");

for(i=0;i<frames;i++) {
	selectWindow("maskGolgi.tif");
	run("Select None");
	Stack.setFrame(i+1);
	run("Analyze Particles...", "size="+GolgiSizeCuttoff+"-Infinity clear include add frame");
	nbROIs=roiManager("Count");
	if(nbROIs==0) {
		GolgiArea[i]=0;
		GolgiFluoInt[i]=0;
		time[i]=i*frameInterval;
		selectWindow("maskGolgi.tif");
		run("Select All");
		run("Clear", "frame");
		
	}
	if(nbROIs==1) {
	selectWindow(name);
	roiManager("Select", 0);
	run("Measure");
	GolgiArea[i]=getResult("Area",0);
	GolgiFluoInt[i]=getResult("RawIntDen",0);
	time[i]=i*frameInterval;
	run("Clear Results");
	selectWindow("maskGolgi.tif");
	roiManager("Select", 0);
	run("Clear Outside", "frame");
	}
	if(nbROIs>1) {
	roiIndexes=newArray(nbROIs);
	for(p=0;p<nbROIs;p++) {
		roiIndexes[p]=p;
	}
	selectWindow(name);
	roiManager("Select", roiIndexes);
	roiManager("Combine");
	run("Measure");
	GolgiArea[i]=getResult("Area",0);
	GolgiFluoInt[i]=getResult("RawIntDen",0);
	time[i]=i*frameInterval;
	run("Clear Results");
	selectWindow("maskGolgi.tif");
	roiManager("Select", roiIndexes);
	roiManager("Combine");
	run("Clear Outside", "frame");
	}
	roiManager("reset");
	
}

Array.getStatistics(GolgiArea, minGolgiArea, maxGolgiArea, meanGolgiArea, stdDevGolgiArea);
for(i=0;i<frames;i++) {
	if(GolgiArea[i]==maxGolgiArea) {
		frameGolgiMax=i;
	}
}

for(i=0;i<frames;i++) {
	if(i>frameGolgiMax) {
	selectWindow(name);
	run("Select None");
	Stack.setFrame(i+1);
	run("Find Maxima...", "noise="+NoiseTolerance+" output=[Single Points]");
	rename("Maxima");
	selectWindow("maskGolgi.tif");
	run("Select None");
	Stack.setFrame(i+1);
	run("Duplicate...", "title=temp");
	run("Invert");
	run("Divide...", "value=255.000");
	imageCalculator("Multiply create", "Maxima","temp");
	selectWindow("temp");
	run("Close");
	selectWindow("Maxima");
	run("Close");
	selectWindow("Result of Maxima");
	rename("time"+i);
	run("Select All");
	run("Measure");
	NbVesicles[i]=getResult("RawIntDen",0)/255;
	run("Clear Results");
	} else {
	selectWindow("maskGolgi.tif");
	Stack.setFrame(i+1);
	run("Duplicate...", "title=temp");
	rename("time"+i);
	run("Select All");
	run("Clear");
	}
}

run("Images to Stack", "name=Stack title=[] use");



if(isOpen("Results")==true) {
	selectWindow("Results");
	run("Close");
}

for(i=0;i<frames;i++) {
	setResult("Time",i,time[i]);
	setResult("Golgi Area",i,GolgiArea[i]);
	setResult("Golgi Tot Fluo Int",i,GolgiFluoInt[i]);
	setResult("NB Vesicles",i,NbVesicles[i]);
	updateResults();
}
IJ.renameResults("Results","RushResults");
selectWindow("RushResults");
saveAs("Results", dir+name1+"_RushResults.txt");

selectWindow(name);
run("Duplicate...", "duplicate");
run("8-bit");
rename("duplicata");
selectWindow("Stack");
run("Duplicate...", "duplicate");
selectWindow("maskGolgi.tif");
run("Duplicate...", "duplicate");
run("Merge Channels...", "c1=Stack-1 c3=maskGolgi-1.tif c4=duplicata create");
selectWindow("Composite");
saveAs("Tiff", dir+name1+"_composite.tif");

run("Close All");