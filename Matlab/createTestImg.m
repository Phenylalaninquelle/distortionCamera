%% create test img
function img = createTestImg(choice)

%%
zero_img = zeros(1000,1000,3);
img = zero_img;
%%
if choice == 1
    point_img = zero_img;
    point_img(100:100:900,100:100:900,:) = 1;
    for dim = 1:3
        point_img(:,:,dim) = 1-conv2(point_img(:,:,dim),ones(13,13),'same');
    end
    img = point_img;
end
if choice == 2
    %%
    checkerboard_img = zero_img;
    checkerboard_img(:,:,1) = 1;
    cb = repmat(checkerboard(50,10,9),1,1,3);
    cb = cb(1:500,1:450,:);
    %%
    checkerboard_img(250:749,250:699,:) = cb;
    checkerboard_img(checkerboard_img > 0.4) = 1;
    img = checkerboard_img;
end
if choice == 3
   img = rand(1000,1000,3);
end
if ischar(choice)
    %%
    img = double(imread(choice))/256;
end


