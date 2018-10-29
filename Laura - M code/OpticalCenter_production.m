function [Ix, Iy] = OpticalCenter_production(image_name)
% Optical Center Calculation using flat field image.
% Written 3/23/17 By Laura Boon
%
% This function calculates the optical center of the lens using a flat
% field image from the module.  First the debayered image is converted to
% grayscale.  It is then convolved with a gaussian (sigma TBD).
%
% inputs: flat field file path and name
% outputs, optical center position, or errors
% -1 = file does not exist
% -2 = File is over exposed
% -3 = file is under exposed

% Check if the file exists
A = exist(image_name, 'file');
if A == 0
    exit(-1)
end
% load image
I_lum = imread(image_name);
% Convert to grayscale
%image_gray = im2double(rgb2gray(image));
%image_gray = image;
I_lum = I_lum.*(2^16/2^12);
% Assuming a 'rggb' order
% Calculate lumination-
I_lum = demosaic(I_lum, 'rggb');
[hres,vres,~] = size(I_lum);
Green = double(I_lum(floor(hres*0.25):ceil(hres*0.75),floor(vres*0.25):ceil(vres*0.75),2));
Green_percent = Green/(2^16);
Max_green_percent = max(max(Green_percent))*100;

if Max_green_percent > 90
   exit(-2)
elseif Max_green_percent < 70
    exit(-3)
end

% demosaic the image and convert to double type
image = im2double(rgb2gray(I_lum));

mask = 350;
% y = 1:size(image,1);
% x = 1:size(image,2);
%image = image(mask:end-mask,mask:end-mask);
y = 1:size(image,1);
x = 1:size(image,2);
W = ones(size(image));
W([1:mask,end-mask:end],:) = 0.01;
W(:,[1:mask,end-mask:end]) = 0.01;
P = polyfitweighted2(x,y,image,5, W);
image_gaus = polyval2(P,x,y);

% Calc max index
Max_val = max(image_gaus(:));
In = find(image_gaus(:) == Max_val);
[Ix, Iy] = ind2sub(size(image_gaus),In);

x_vec = Ix-5:0.01:Ix+5;
y_vec = Iy-5:0.01:Iy+5;
image_finer = polyval2(P,y_vec,x_vec);

[~,In] = max(image_finer(:));
[x_ind,y_ind] = ind2sub(size(image_finer),In);
Ix = x_vec(x_ind);
Iy = y_vec(y_ind);
output = sprintf('Ix = %0.2f, Iy = %0.2f',Iy,Ix);
disp(output);