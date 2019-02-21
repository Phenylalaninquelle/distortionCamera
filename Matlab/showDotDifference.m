function showDotDifference(a,c,titleString)
errorI = a-c;
a(isnan(a)) = 0;
c(isnan(c)) = 0;

mse = @(x,y) sum((x(:)-y(:)).^2)/numel(x);
psnr = @(x,y) 10*log(1/mse(x,y))/log(10);
psnrI = string(psnr(a,c));
maxE = string(max(abs(errorI(:))));
%%
imshow(0.5+2*(errorI));
title(titleString);
xlabel(strcat('PSNR: ',psnrI,'dB Max_{error}: ',maxE)); 
    