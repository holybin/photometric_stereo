function [surfaceFit] = pv_GetSurfaceFit(imageNormals);

disp('Computing depth map...');

% allocate the vector sizes
imgWidth = length(imageNormals(1,:,1));
imgHeight = length(imageNormals(:,1,1));
numPixels = imgWidth * imgHeight;
v = zeros(numPixels * 2, 1);
xIndexM = zeros(1, numPixels * 2 * 2);
yIndexM = zeros(1, numPixels * 2 * 2);
valueM = zeros(1, numPixels * 2 * 2);
%imageNormals = reshape(imageNormals, numPixels, 3);

% create the matrix v and sparse matrix M
index = 0;
rowIndex = 0;
pixelIndex = 0;

% direct integration to get depth map
for x=1:imgWidth
  for y=1:imgHeight

    % increment the pixel index traversing in the y direction
    pixelIndex = pixelIndex + 1;


    % create the equation for the pixel xy and it's right neighbor
    rowIndex = rowIndex + 1;
    v(rowIndex) = -imageNormals(y, x, 1);
    if pixelIndex + imgHeight <= numPixels % make sure the right pixel is valid
      index = index + 1;
      xIndexM(index) = pixelIndex + imgHeight;
      yIndexM(index) = rowIndex;
      valueM(index) = imageNormals(y, x, 3);
    end
    index = index + 1;
    xIndexM(index) = pixelIndex;
    yIndexM(index) = rowIndex;
    valueM(index) = -imageNormals(y, x, 3);
  
    % create the equation for the pixel xy and it's bottom neighbor
    rowIndex = rowIndex + 1;
    v(rowIndex) = -imageNormals(y, x, 2);
    if mod(pixelIndex + 1, imgHeight) ~= 1 % make sure the bottom pixel is valid
      index = index + 1;
      xIndexM(index) = pixelIndex+1;
      yIndexM(index) = rowIndex;
      valueM(index) = imageNormals(y, x, 3);
    end
    index = index + 1; 
    xIndexM(index) = pixelIndex;
    yIndexM(index) = rowIndex;
    valueM(index) = -imageNormals(y, x, 3); 

  end
end

% resize the vector since too much memory was allocated
xIndexM = xIndexM(1:index);
yIndexM = yIndexM(1:index);
valueM = valueM(1:index);
v = v(1:rowIndex);

% create the sparse M matrix and solve for z using pcg
M = sparse(yIndexM, xIndexM, valueM, rowIndex, numPixels);

% solve for the depth
z = M \ v;
surfaceFit = z;

% [xx,yy] = meshgrid(1:imgWidth, 1:imgHeight);
% surfl(xx, yy, zz);

% show the 3d image
figure;
z0 = reshape(z, imgHeight, imgWidth);
surfl(z0);
shading interp
colormap(gray);
