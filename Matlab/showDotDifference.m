function showDotDifference(a,c,titleString)
imshow(cat(3,a-c>0.5,a-c<-0.5,zeros(size(a))));
title(titleString);
    