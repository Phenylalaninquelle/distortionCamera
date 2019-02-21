function showComparison(a,b,c,roi)
    %%
    a(isnan(a)) = 0;
    b(isnan(b)) = 0;
    c(isnan(c)) = 0;
    roi(isnan(roi)) = 0;
    error = roi.*(a-c);
    mse = sum(error(:).^2)/numel(error);
    %%
    figure(1);
    subplot(2,3,1);
    imshow(a);
    title('Perspektivisch');
    subplot(2,3,2);
    imshow(b);
    title('Verzerrt');
    subplot(2,3,3);
    imshow(roi.*c);
    title("Entzerrt (, MSE in ROI:"+string(mse));
    subplot(2,3,4);
    imshow(cat(3,a-c>0.5,a-c<-0.5,zeros(size(a))));
    title("Perspektivisch (rot) und Entzerrt (grün)");
    
end
    