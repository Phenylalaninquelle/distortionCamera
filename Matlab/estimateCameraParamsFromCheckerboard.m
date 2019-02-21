function cameraParams = estimateCameraParamsFromCheckerboard(distortedImg,squareSizeInMm)
%%
[imagePoints,boardSize] = detectCheckerboardPoints(distortedImg);
%%
worldPoints = generateCheckerboardPoints(boardSize,squareSizeInMm);
imageSize = [size(distortedImg,1),size(distortedImg,2)];
cameraParams = estimateCameraParameters(imagePoints,worldPoints,'ImageSize',imageSize);
