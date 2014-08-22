function [imageNormals, albedoR, albedoG, albedoB] = pv_GetImageNormalAndAlbedo(imageMask, imageList, lightVectors);

disp('Loading images...');
% load the mask image and find the valid pixel index
img_m = imread(imageMask);
if size(img_m,3)>1
    imgMask = rgb2gray(img_m);
else
    imgMask = img_m;
end

% get region of interest
[validPixelY, validPixelX] = find(imgMask > 127);% == 255);

% allocate the array sizes
imgHeight = length(imgMask(:,1));
imgWidth = length(imgMask(1,:));
imgListSize = length(imageList(:,1));

L = zeros(imgListSize,3);
I = zeros(imgListSize,1);
J = zeros(imgListSize,1);

imageNormals = zeros(imgHeight, imgWidth, 3);
imagesGray = zeros( length(imageList(:,1)), imgHeight, imgWidth );
imagesR = zeros( length(imageList(:,1)), imgHeight, imgWidth );
imagesG = zeros( length(imageList(:,1)), imgHeight, imgWidth );
imagesB = zeros( length(imageList(:,1)), imgHeight, imgWidth );

albedoR = zeros(imgHeight, imgWidth);
albedoG = zeros(imgHeight, imgWidth);
albedoB = zeros(imgHeight, imgWidth);

%%
% load all the images into 3 matrices for RGB
index = 1;
for i=1:length(imageList(:,1))

  % load the image 
  img = imread(deblank(imageList(i,:)));
  imgR = img(:,:,1);
  imgG = img(:,:,2);
  imgB = img(:,:,3);
  imagesGray(i,:,:) = rgb2gray(img);
  imagesR(i,:,:) = imgR;
  imagesG(i,:,:) = imgG;
  imagesB(i,:,:) = imgB;
end
imagesR = im2double(imagesR);
imagesG = im2double(imagesG);
imagesB = im2double(imagesB);

%%
disp('Computing normals...');
% compute image normals and sovle for the albedos
for j=1:length(validPixelY(:))

  for i=1:length(imageList(:,1))
    % multiply by the image intensity to help deal with shadows and noise in dark pixels 
    I(i) = imagesGray(i, validPixelY(j), validPixelX(j));
    %%I(i) = pv_WeightFunction(I(i));
    L(i,:) = I(i) .* lightVectors(i,:);
    I(i) = I(i) .* I(i);
  end 

  
  % solve the least squares and compute the length and normalized vector
  normal = L \ I;
  vLength = sqrt(dot(normal, normal));
  normal = normal ./ vLength;

  % save the result
  imageNormals(validPixelY(j), validPixelX(j), :) = normal;

end

imageNormalsRGB = (imageNormals + 1) ./ 2;
imwrite(imageNormalsRGB, 'imageNormals.bmp');
figure;imshow(imageNormalsRGB);

%%
disp('Computing albedos...');

% solve for the red albedo
for j=1:length(validPixelY(:))
  for i=1:length(imageList(:,1))
    % multiply by the image intensity to help deal with shadows and noise in dark pixels 
    I(i) = imagesR(i, validPixelY(j), validPixelX(j));
    %%I(i) = pv_WeightFunction(I(i));
    J(i) = dot(lightVectors(i,:), reshape(imageNormals(validPixelY(j), validPixelX(j),:),1,3));
  end

  % compute the albedo and save the result
  albedo = dot(I, J) / dot(J, J);
  albedoR (validPixelY(j), validPixelX(j)) = albedo;
end


% solve for the green albedo
for j=1:length(validPixelY(:))
  for i=1:length(imageList(:,1))
    % multiply by the image intensity to help deal with shadows and noise in dark pixels 
    I(i) = imagesG(i, validPixelY(j), validPixelX(j));
    %%I(i) = pv_WeightFunction(I(i));
    J(i) = dot(lightVectors(i,:), reshape(imageNormals(validPixelY(j), validPixelX(j),:),1,3));
  end

  % compute the albedo and save the result
  albedo = dot(I, J) / dot(J, J);
  albedoG (validPixelY(j), validPixelX(j)) = albedo;
end


% solve for the blue albedo
for j=1:length(validPixelY(:))
  for i=1:length(imageList(:,1))
    % multiply by the image intensity to help deal with shadows and noise in dark pixels 
    I(i) = imagesB(i, validPixelY(j), validPixelX(j));
    %%I(i) = pv_WeightFunction(I(i));
    J(i) = dot(lightVectors(i,:), reshape(imageNormals(validPixelY(j), validPixelX(j),:),1,3));
  end


  % compute the albedo and save the result
  albedo = dot(I, J) / dot(J, J);
  albedoB (validPixelY(j), validPixelX(j)) = albedo;
end

% create the albedo represented in an image
albedoImg = zeros(imgHeight, imgWidth, 3);
albedoImg(:,:,1) = albedoR;
albedoImg(:,:,2) = albedoG;
albedoImg(:,:,3) = albedoB;
maxR = max(albedoR);
maxG = max(albedoG);
maxB = max(albedoB);
albedoImg = albedoImg ./ max([maxR maxG maxB]);
%albedoImg = albedoImg ./ 255;
figure;imshow(albedoImg);
imwrite(albedoImg, 'imageAlbedos.bmp');
