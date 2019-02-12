%% Erstelle ein Distortion-Polynom
ptlens = @(a,b,c) [1-a-b-c c b a];
poly3 = @(k1) [1-k1 0 k1];
poly5 = @(k1,k2) [1 0 k1 0 k2];

mse = @(x,y) sum((x(:)-y(:)).^2)/numel(x);
distFun = @(img,poly,center,mode) distortImage(img,poly,'center',center,'distortionMode',mode);
%% Erstelle ein Beispielbild:
perspectiveImg = createTestImg('dot_perspective.png',true);
shift = zeros(2,1);
shift(1) = 0.8;
shift(end) = 0.2;
testImg = imfilter(perspectiveImg,shift);
testImg2 = imgaussfilt(perspectiveImg,0.7);
%% Verzerre Bild und entzerre das Ergebnis
imginfo1 = {createTestImg('dots_poly3_0.1.png',true), poly3(0.1), [0 0]};
imginfo2 = {createTestImg('dots_poly5_0.07_0.01.png',true), poly5(0.07,0.01), [0 0]};
imginfo3 = {createTestImg('dots_ptlens_0.08_-0.05_0.03.png',true), ptlens(0.08,-0.05,0.03), [0 0]};
imginfo4 = {createTestImg('dots_poly5_0.5_0.1_cxy_0.5_-0.5.png',true), poly5(0.5,0.1), [0.5 -0.5]};
imginfo5 = {createTestImg('dots_poly3_0.5_cxy_1_0.png',true), poly3(0.5), [1 0]};
imginfo_p0 = {createTestImg('dots_poly3_0_cxy_0_0.5.png',true), poly3(0), [0 0.5]};
imginfo_p1 = {createTestImg('dots_poly3_0.0125_cxy_0_0.5.png',true), poly3(0.0125), [0 0.5]};
imginfo_p2 = {createTestImg('dots_poly3_0.025_cxy_0_0.5.png',true), poly3(0.025), [0 0.5]};
imginfo_p3 = {createTestImg('dots_poly3_0.05_cxy_0_0.5.png',true), poly3(0.05), [0 0.5]};
imginfo_p4 = {createTestImg('dots_poly3_0.1_cxy_0_0.5.png',true), poly3(0.1), [0 0.5]};
imginfo_p5 = {createTestImg('dots_poly3_0.2_cxy_0_0.5.png',true), poly3(0.2), [0 0.5]};
imginfo_p6 = {createTestImg('dots_poly3_0.4_cxy_0_0.5.png',true), poly3(0.4), [0 0.5]};
% pbrtDistortedImgInfo = [imginfo1;imginfo2;imginfo3;imginfo4;imginfo5];
% pbrtDistortedImgInfo = [imginfo4;imginfo5];
pbrtDistortedImgInfo = [imginfo_p1;imginfo_p2;imginfo_p3;imginfo_p4;imginfo_p5;imginfo_p6];
titles = {'dots_poly3_0.0125_cxy_0_0.5.png',...
    'dots_poly3_0.025_cxy_0_0.5.png',...
    'dots_poly3_0.05_cxy_0_0.5.png',...
    'dots_poly3_0.1_cxy_0_0.5.png',...
    'dots_poly3_0.2_cxy_0_0.5.png',...
    'dots_poly3_0.4_cxy_0_0.5.png'};
img_n = size(pbrtDistortedImgInfo,1);

undistortedImgInfo = cell(img_n,2);
distortedImgInfo = cell(img_n,2);
undistortedPerspectiveInfo = cell(img_n,2);
distortedPerspectiveInfo = cell(img_n,2);

%%
for index = 1:img_n
   %%
   imginfo = pbrtDistortedImgInfo(index,:);
   [undistortedImg,roi1] = distFun(imginfo{1},imginfo{2},imginfo{3},'undistort');
   [distortedPerspective,roi4] = distFun(perspectiveImg,imginfo{2},imginfo{3},'distort');
   
   %%
   undistortedImgInfo(index,:) = {undistortedImg,roi1};
   distortedPerspectiveInfo(index,:) = {distortedPerspective, roi4};
   
end

%%
figure(1);
img_n = 6;
for index = 1:img_n
%     roi = undistortedImgInfo{index,2};
%     subplot(2,img_n,index);
%     showDotDifference(roi.*perspectiveImg,roi.*undistortedImgInfo{index,1},strcat('Vergleich Perspektivisch mit Entzerrung ',string(index)));
%     roi_inv = distortedPerspectiveInfo{index,2};
%     subplot(2,img_n,index+img_n);
%     showDotDifference(roi_inv.*pbrtDistortedImgInfo{index,1},roi_inv.*distortedPerspectiveInfo{index,1},strcat('Vergleich Matlab/Pbrt Verzerrung ',string(index)));
%     imwrite(undistortedImgInfo{index,1},strcat('pbrtUndistorted/',titles{index}),'PNG');
%     imwrite(pbrtDistortedImgInfo{index,1},strcat('pbrtDistorted/',titles{index}),'PNG');
%     imwrite(distortedPerspectiveInfo{index,1},strcat('matlabDistorted/',titles{index}),'PNG');
 
    getError = @(a,b) 0.5+2*(a-b);
    errorDistorted = getError(distortedPerspectiveInfo{index,1},pbrtDistortedImgInfo{index,1});
    errorUnistorted = getError(perspectiveImg,undistortedImgInfo{index,1});
    imwrite(errorDistorted,strcat('differenceDistorted/',titles{index}),'PNG');
    imwrite(errorUnistorted,strcat('differenceUndistorted/',titles{index}),'PNG');
   
    
end
%%
subplot(2,1,1);
showDotDifference(perspectiveImg,testImg,'Um 20 Pixel verschoben (Fehlermaximum)');
subplot(2,1,2);
showDotDifference(perspectiveImg,testImg2,'Gaussfiltered');
    
%%
% figure(2);
% imshow(distortedPerspectiveInfo{index,1});