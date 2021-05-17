///Macro  Nathalie Coloc mask 3 marqueur
/// part 3

/// measure overlaps


/// peut etre convertit en µm3 si besoin


dir=getDirectory("output Directory with crops");

list=getFileList(dir);

dirOut=dir+"Masks"+File.separator();

if(isOpen("Results")) {
	selectWindow("Results");
	run("Close");
}

nbRes=0;

for(i=0;i<lengthOf(list);i++) {
	if(endsWith(list[i],".tif")) {
		roiManager("reset");
		
		ShortName=substring(list[i],0,lengthOf(list[i])-4);

		open(dirOut+ShortName+"_MaskRab7.tif");
		run("Select None");
		Stack.getStatistics(voxelCount, mean, min, max, stdDev);
		voxelRab7=voxelCount*mean/255;
		
		open(dirOut+ShortName+"_MaskCD9.tif");
		run("Select None");
		Stack.getStatistics(voxelCount, mean, min, max, stdDev);
		voxelCD9=voxelCount*mean/255;
		
		open(dirOut+ShortName+"_MaskCD63.tif");
		run("Select None");
		Stack.getStatistics(voxelCount, mean, min, max, stdDev);
		voxelCD63=voxelCount*mean/255;
		
		imageCalculator("AND create stack", ShortName+"_MaskCD63.tif",ShortName+"_MaskCD9.tif");
		rename("CD63_CD9");
		Stack.getStatistics(voxelCount, mean, min, max, stdDev);
		voxelCD63_CD9=voxelCount*mean/255;

		imageCalculator("AND create stack", ShortName+"_MaskCD63.tif",ShortName+"_MaskRab7.tif");
		rename("CD63_Rab7");
		Stack.getStatistics(voxelCount, mean, min, max, stdDev);
		voxelCD63_Rab7=voxelCount*mean/255;

		imageCalculator("AND create stack", ShortName+"_MaskCD9.tif",ShortName+"_MaskRab7.tif");
		rename("CD9_Rab7");
		Stack.getStatistics(voxelCount, mean, min, max, stdDev);
		voxelCD9_Rab7=voxelCount*mean/255;

		imageCalculator("AND create stack", ShortName+"_MaskRab7.tif","CD63_CD9");
		rename("triplepos");
		Stack.getStatistics(voxelCount, mean, min, max, stdDev);
		voxeltriplePos=voxelCount*mean/255;

		imageCalculator("Substract create stack", ShortName+"_MaskCD63.tif",ShortName+"_MaskCD9.tif");
		rename("CD63");
		Stack.getStatistics(voxelCount, mean, min, max, stdDev);
		voxelCD63CD9neg=voxelCount*mean/255;

		imageCalculator("Substract create stack", ShortName+"_MaskCD9.tif",ShortName+"_MaskCD63.tif");
		rename("CD9");
		Stack.getStatistics(voxelCount, mean, min, max, stdDev);
		voxelCD9CD63neg=voxelCount*mean/255;

		imageCalculator("AND create stack", "CD9",ShortName+"_MaskRab7.tif");
		rename("CD9CD63neg_Rab7");
		Stack.getStatistics(voxelCount, mean, min, max, stdDev);
		voxelCD9CD63neg_Rab7=voxelCount*mean/255;

		imageCalculator("AND create stack", "CD63",ShortName+"_MaskRab7.tif");
		rename("CD63CD9neg_Rab7");
		Stack.getStatistics(voxelCount, mean, min, max, stdDev);
		voxelCD63CD9neg_Rab7=voxelCount*mean/255;

		setResult("Image Name",nbRes,ShortName);
		setResult("VolumeCD9",nbRes,voxelCD9);
		setResult("VolumeCD9Rab7",nbRes,voxelCD9_Rab7);
		setResult("Manders %CD9 in Rab7",nbRes,voxelCD9_Rab7/voxelCD9);
		setResult("VolumeCD9CD63neg",nbRes,voxelCD9CD63neg);
		setResult("VolumeCD9CD63negRab7",nbRes,voxelCD9CD63neg_Rab7);
		setResult("Manders %CD9+CD63- in Rab7",nbRes,voxelCD9CD63neg_Rab7/voxelCD9CD63neg);
		setResult("VolumeCD63",nbRes,voxelCD63);
		setResult("VolumeCD63Rab7",nbRes,voxelCD63_Rab7);
		setResult("Manders %CD63 in Rab7",nbRes,voxelCD63_Rab7/voxelCD63);
		setResult("VolumeCD63CD9neg",nbRes,voxelCD63CD9neg);
		setResult("VolumeCD63CD9negRab7",nbRes,voxelCD63CD9neg_Rab7);
		setResult("Manders %CD63+CD9- in Rab7",nbRes,voxelCD63CD9neg_Rab7/voxelCD63CD9neg);
		setResult("VolumeCD9CD63",nbRes,voxelCD63_CD9);
		setResult("VolumeCD9CD63Rab7",nbRes,voxeltriplePos);
		setResult("Manders %CD63+CD9+ in Rab7",nbRes,voxeltriplePos/voxelCD63_CD9);
		updateResults();
		nbRes=nbRes+1;
		
		run("Close All");
		
	}
}

selectWindow("Results");
saveAs("Results",dirOut+"Results.xls");
