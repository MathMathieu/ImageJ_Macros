
name=getTitle();
dir=getDirectory("Image");
Stack.getDimensions(width, height, channels, slices, frames);

name1=substring(name,0,lengthOf(name)-4);

if(frames>slices) {
	maxTime=frames+1;
} else {
	maxTime=slices+1;
}

if(isOpen("Log")==true) {
	selectWindow("Log");
	run("Close");
}

roiManager("Reset");

waitForUser("Draw all the ROI");
roiManager("Add");



selectWindow(name);
run("Select None");
run("Split Channels");

nbRois=roiManager("Count");
roiManager("Save", dir+name1+"_RoiSet.zip");

for(roi=0;roi<nbRois;roi++) {

for(i=1;i<maxTime;i++) {

selectWindow("C1-"+name);
setSlice(i);
run("Duplicate...", "title=c1-1");
run("Mean...", "radius=2");

selectWindow("C2-"+name);
setSlice(i);
run("Duplicate...", "title=c2-1");
run("Mean...", "radius=2");



selectWindow("c1-1");
roiManager("Select", roi);


run("Coloc 2", "channel_1=c1-1 channel_2=c2-1 roi_or_mask=[ROI Manager] display_images_in_result psf=3 costes_randomisations=10");

selectWindow("c2-1");
run("Close");
selectWindow("c1-1");
run("Close");



}


selectWindow("Log");
saveAs("Text", dir+name1+"ROI-"+roi+"_Log.txt");
run("Close");


}
