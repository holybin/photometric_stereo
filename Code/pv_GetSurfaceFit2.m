function [surfaceFit2] = pv_GetSurfaceFit2(imageMask, imageNormals);

disp('Computing depth map by using refineDepthMap...');

% load the mask image and find the valid pixel index
imgMask = rgb2gray(imread(imageMask));

% get mask
[m,n] = size(imgMask);
for i = 1:m
    for j = 1:n
        if imgMask(i,j) == 255
            imgMask0(i,j) = 1;
        else
            imgMask0(i,j) = 0;
        end
    end
end

% convert to logical type
imgMask0 = logical(imgMask0);

% use given refineDepthMap function
depth = refineDepthMap(imageNormals, imgMask0);

figure;
surfl(depth); shading interp; colormap gray; axis tight
