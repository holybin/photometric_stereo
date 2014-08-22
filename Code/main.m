% main.m
% Entrance of program.

clc;clear all;close all;

% load light directions
load('lighting.mat');

imageMaskName = 'buddha.mask.png';
imageList = char('buddha.0.png','buddha.1.png','buddha.2.png',...
    'buddha.3.png','buddha.4.png','buddha.5.png','buddha.6.png',...
    'buddha.7.png','buddha.8.png','buddha.9.png','buddha.10.png',...
    'buddha.11.png');

% get normals and albedos
[normals, a1, a2, a3] = pv_GetImageNormalAndAlbedo(imageMaskName, imageList, L);

% Method1 - get and draw the depth map using simple integration
pv_GetSurfaceFit(normals);

% Method2 - use given 'refineDepthMap' function
pv_GetSurfaceFit2(imageMaskName, normals);
