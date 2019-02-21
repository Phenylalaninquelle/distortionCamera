%% Erstelle ein Distortion-Polynom
ptlens = @(a,b,c,d) [1-a-b-c c b a];
poly3 = @(k1) [1-k1 0 k1];

distFun = @(img,invert) distortImage(img,poly3(-0.05),'invertDistortion',invert);
%% Erstelle ein Beispielbild:
% Beispielbilder sind 1000x1000px
% Wenn PBRT implementiert ist, hier distortedImg und perspectiveImg aus PBRT übernehmen.
% 1: Punkte Raster
% 2: Schachbrettmuster
% 3: Noise
% momemtan nur mit Grayscale Bildern oder Aufteilung der Farbkomponenten
perspectiveImg = rgb2gray(createTestImg('dot_perspective.png'));
%% Verzerre Bild und entzerre das Ergebnis
distortedImg = rgb2gray(createTestImg('dot_test_k005.png'));
%%
undistortedImg = distFun(distortedImg,false);
    
%% Zeige Ergebnis
roi = getROI(perspectiveImg,@(x) distFun(x,false));
%%
showComparison(perspectiveImg,distortedImg,undistortedImg,roi);

% differenceEstimationPBRT(perspectiveImg,undistortedImg);