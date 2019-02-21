%% Erstelle ein Distortion-Polynom
ptlens = @(a,b,c,d) [1-a-b-c c b a];
poly3 = @(k1) [1-k1 0 k1];

distFun = @(img,invert) distortImage(img,poly3(0.05),'invertDistortion',invert);
%% Erstelle ein Beispielbild:
% Beispielbilder sind 1000x1000px
% Wenn PBRT implementiert ist, hier distortedImg und perspectiveImg aus PBRT übernehmen.
% 1: Punkte Raster
% 2: Schachbrettmuster
% 3: Noise
% 'char': Datei mit gegebenem Namen im PWD
% momemtan nur mit Grayscale Bildern oder Aufteilung der Farbkomponenten
perspectiveImgPbrt = rgb2gray(createTestImg('dot_perspective.png'));
%% Verzerre Bild und entzerre das Ergebnis
testImgPbrt = rgb2gray(createTestImg('dot_test_k005.png'));
invertedImgPbrt = rgb2gray(createTestImg('dot_inverted_k005.png'));
%%
distortedPerspectiveImg = distFun(perspectiveImgPbrt,true);
undistortedPerspectiveImg = distFun(perspectiveImgPbrt,false);
distortedTestImg = distFun(testImgPbrt,true);
undistortedTestImg = distFun(testImgPbrt,false);
distortedInvertedImg = distFun(invertedImgPbrt,true);
undistortedInvertedImg = distFun(invertedImgPbrt,false);
%%
figure(1);
subplot 221;
showDotDifference(perspectiveImg,distortedTestImg,'TestImg Distorted');
subplot 222;
showDotDifference(perspectiveImg,undistortedTestImg,'TestImg Undistorted');
subplot 223;
showDotDifference(perspectiveImg,distortedInvertedImg,'InvertedImg Distorted');
subplot 224;
showDotDifference(perspectiveImg,undistortedInvertedImg,'InvertedImg Undistorted');
