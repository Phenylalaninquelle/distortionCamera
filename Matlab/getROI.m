% Bestimmt f�r die gegegebene Art der Verzerrung eine Region of
% Interest
function ROI = getROI(perspectiveImg, undistortionFun)
    %%
    border = ones(size(perspectiveImg));
    ROI = undistortionFun(border);
end