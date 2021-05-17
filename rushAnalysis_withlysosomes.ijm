
/// Work with an open movie of a cropped cell

run("Set Measurements...", "area mean integrated display redirect=None decimal=3");

if(isOpen("Results")==true) {
	selectWindow("Results");
	run("Close");
}

frameInterval=1;
TimeUnit="min";

GolgiSizeCuttoff=20;

///noise tolerance should be adapted for the analyze particle function to detect small compartments according to the picture 
NoiseTolerance=1700;

LysoSizeCuttoff=15;

name=getTitle(); 
Stack.getStatistics(voxelCount, mean, min, max, stdDev);
Stack.getDimensions(width, height, channels, slices, frames);
dir=getDirectory("Image");
name1=substring(name,0,lengthOf(name)-4);

waitForUser("Choisir le temps de disparition du golgi");
Stack.getPosition(channel1, frameGolgiEnd, frame1);

waitForUser("Choisir le temps d'arrivee des lysos");
Stack.getPosition(channel1,frameLysoStart, frame1);

//seuillages

selectWindow(name);
setMinAndMax(min, max);
run("Duplicate...", "title=maskGolgi.tif duplicate");
run("8-bit");
run("Threshold...");
waitForUser("Faire le seuillage du golgi sur l'image maskGolgi.tif");
setOption("BlackBackground", true);
run("Convert to Mask", "method=Default background=Default black");


selectWindow(name);
setMinAndMax(min, max);
run("Duplicate...", "title=maskLysos.tif duplicate");
run("8-bit");
run("Threshold...");
waitForUser("Faire le seuillage des Lysos+Golgi sur l'image maskGolgi1.tif");
setOption("BlackBackground", true);
run("Convert to Mask", "method=Default background=Default black");



time=newArray(frames);
GolgiArea=newArray(frames);
GolgiFluoInt=newArray(frames);
NbVesicles=newArray(frames);
LysoArea=newArray(frames);
LysoFluoInt=newArray(frames);


run("ROI Manager...");

for(i=0;i<frames;i++) {
	if(i<frameGolgiEnd) {
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
	else {
		time[i]=i*frameInterval;
		selectWindow("maskGolgi.tif");
		Stack.setFrame(i+1);
		run("Select All");
		run("Clear", "frame");
	}
}


for(i=0;i<frames;i++) {
	if(i>frameLysoStart) {
	selectWindow("maskLysos.tif");
	run("Select None");
	Stack.setFrame(i+1);
	run("Analyze Particles...", "size="+LysoSizeCuttoff+"-Infinity clear include add frame");
	nbROIs=roiManager("Count");
	if(nbROIs==0) {
		LysoArea[i]=0;
		LysoFluoInt[i]=0;
		selectWindow("maskLysos.tif");
		run("Select All");
		run("Clear", "frame");
		
	}
	if(nbROIs==1) {
	selectWindow(name);
	roiManager("Select", 0);
	run("Measure");
	LysoArea[i]=getResult("Area",0);
	LysoFluoInt[i]=getResult("RawIntDen",0);
	run("Clear Results");
	selectWindow("maskLysos.tif");
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
	LysoArea[i]=getResult("Area",0);
	LysoFluoInt[i]=getResult("RawIntDen",0);
	run("Clear Results");
	selectWindow("maskLysos.tif");
	roiManager("Select", roiIndexes);
	roiManager("Combine");
	run("Clear Outside", "frame");
	}
	roiManager("reset");
	}
	else {
		selectWindow("maskLysos.tif");
		Stack.setFrame(i+1);
		run("Select All");
		run("Clear", "frame");
	}
}

imageCalculator("OR create stack", "maskGolgi.tif","maskLysos.tif");
selectWindow("Result of maskGolgi.tif");
rename("maskGolgi1.tif");

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
	run("Find Maxima...", "prominence="+NoiseTolerance+" output=[Point Selection]");
	rename("Maxima");
	selectWindow("maskGolgi1.tif");
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
	selectWindow("maskGolgi1.tif");
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
	setResult("Lysos Area",i,LysoArea[i]);
	setResult("Lysos Tot Fluo Int",i,LysoFluoInt[i]);
	setResult("NB Vesicles",i,NbVesicles[i]);
	updateResults();
}
IJ.renameResults("Results","RushResults");
selectWindow("RushResults");
saveAs("Results", dir+name1+"_RushResults2.txt");

selectWindow(name);
run("Duplicate...", "duplicate");
run("8-bit");
rename("duplicata");
run("Merge Channels...", "c1=Stack c2=maskLysos.tif c3=maskGolgi.tif c4=duplicata create keep");
selectWindow("Composite");
saveAs("Tiff", dir+name1+"_composite.tif");

run("Close All");