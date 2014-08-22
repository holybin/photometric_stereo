%     depth = refineDepthMap(surfaceNormals,mask)
%   
%     INPUTS:
%     surfaceNormals - 3D double array (rows,cols,3) with the X, Y, and Z normals for
%     each scene point
%     mask - Logical matrix (rows,cols) of the pixels of interest 
%     
%     OUTPUT:
%     depth - Matrix (rows,cols) of the height of the scene. Note there is a
%     scale ambiguity, this is not an absolute measure of height.
% 
%
