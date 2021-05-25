%% Aqcuired images
% img = imread('images\b1.jpg');
% img = imread('images\b2.jpg');
% img = imread('images\b3.jpg');
% img = imread('images\e1.jpg');
% img = imread('images\e2.jpg');
% img = imread('images\e3.jpg');
% img = imread('images\n1.jpg'); % Cannot detect plate location
% img = imread('images\n2.jpg');
% img = imread('images\car1.jpg');
% img = imread('images\car2.jpg');

%% Test images
% img = imread('images\MCC86.png');
% img = imread('images\MCG7722.png');
% img = imread('images\AHA236.png');
% img = imread('images\HWD3092.jpg');
% img = imread('images\KA555ZG.jpg');
% img = imread('images\PEN15.jpg');
img = imread('images\WVS7250.jpg');




%% Image Pre-processing 

% Gamma Contrast Enhancement
Contrast_img = AGCWD(img);

figure,subplot(231), imshow(Contrast_img), title('Contrast adjusted');
subplot(235), imshow(img), title('Original Image');

% Change to gray, rescale
gimg = rgb2gray(Contrast_img);
gimg = rescale(gimg);
subplot(232), imshow(gimg), title('Grayscale Image');



%% Licence Plate  Extraction

% Sobel edge detection own code
Gx = [1 2 1; 0 0 0; -1 -2 -1]; 
Gy = Gx';
tempx = conv2(gimg,Gx,'same');
tempy = conv2(gimg,Gy,'same');
Sobel_img = sqrt(tempx.^2 + tempy.^2);
Sobel_img = imbinarize(Sobel_img,'adaptive','Sensitivity',0.1);
% Sobel edge detection obuild in
Sobel_img1 = edge(gimg, 'Sobel');
% Sobel edge detection 
Sobel_img = (Sobel_img) & (Sobel_img1);

% Dilate the edge
se02 = strel('line',2,2);
Dilate_img = imdilate(Sobel_img, se02);
subplot(233), imshow(Dilate_img), title('Sobel edge');


% Select the bounding box(Width is more than height)
% Remove small area
% Cut in the middle of the photo and select most edge character area
s_area=regionprops(Dilate_img,'BoundingBox','Area', 'Image');
count = numel(s_area);
soe=0;
for i=1:count
    width = s_area(i).BoundingBox(3);
    height = s_area(i).BoundingBox(4);
    
   if (s_area(i).Area>100)&&(width> 2.5*height) && (width < 6*height) && (s_area(i).Area<4000)
       boundingBox=s_area(i).BoundingBox;
       im = imcrop(gimg, boundingBox);
       ime2 = edge(im, 'Sobel', 'vertical');
%        figure, imshow(ime2); % Check which region can be detected
       [rows, cols] = size(ime2);
       numberOfedge = 0;
       if (mod(rows,2)~=0)
           h = rows/2+0.5;
       else
           h = rows/2;
       end
       
          for j = 1:cols
            if ime2(h,j) == 1
               numberOfedge = numberOfedge +1;
            end
          end

       sumall = numberOfedge;
       if sumall > soe
           soe = sumall;
           fboundingBox=s_area(i).BoundingBox;
       end
       
   end
end  



% Crop the plate area

Crop_img = imcrop(img, fboundingBox);
Crop_img = rgb2gray(Crop_img);
subplot(234), imshow(Crop_img), title('Crop image');





%% Characters Segmentation
% Process the number plate
Inc_size = imresize(Crop_img,3);
bw3 = imbinarize(Inc_size, 0.55);
figure;
subplot (211),imshow(bw3), title('Binary image of Cropped image');

% Check if taxi, white black ground, invert the colour
[row2, col2] = size(bw3);
   if (mod(row2,2)~=0)
       h2 = row2/2+0.5;
   else
       h2 = row2/2;
   end

 onecount = 0;
 zerocount = 0;
   
  for j2 = 1:col2
    if bw3(h2,j2) == 1
       onecount = onecount +1;
    else
        zerocount = zerocount +1;
    end
  end
  
if onecount > zerocount
    bw3 = imcomplement(bw3);
end

% Remove small area and clear border
bw3 = bwareaopen(bw3,220);
c_border = imclearborder(bw3);
subplot (212), imshow(c_border), title('Binary image after clear border');


% Character Segmentation
Cgrp=regionprops(c_border,'BoundingBox','Area', 'Image');
area = Cgrp.Area;
Ccount = numel(Cgrp);
boundingBox = Cgrp.BoundingBox;

%% Characters Recognition 
% OCR read for whole image
Fchr = ocr(c_border, 'CharacterSet', '0123456789ABCDEFGHJKLMNPQRSTUVWXYZ');
Full_OCR = Fchr.Text;

% OCR and template matching to read the character
PlateDetail=[];
PlateDetail1=[];
figure, title('Segmented Characters');
pf =2;
for i=1:Ccount
    % only crop the box where height is more than width
    width2 = Cgrp(i).BoundingBox(3);
    height2 = Cgrp(i).BoundingBox(4);
    if (width2 < 0.72*height2) && (width2 > 0.2*height2)
          CboundingBox=Cgrp(i).BoundingBox;
          Chr = imcrop(c_border, CboundingBox);
          % Recognize using nuild in OCR
          Chr_pad = padarray(Chr,[5 5],0,'both');
          se = strel('disk',1);
          erode_img = imerode(Chr_pad, se);
          Dchr = ocr(erode_img,'TextLayout','Word', 'CharacterSet', '0123456789ABCDEFGHJKLMNPQRSTUVWXYZ');
          PlateDetail=strcat(PlateDetail,Dchr.Text);
          
          % Recognize using templete
          Template_resize = imresize(Chr,[42 24]);
          letter=read_letter(imcomplement(Template_resize));
          PlateDetail1=strcat(PlateDetail1,letter);
          
          % Print the segment character
          subplot(1,10,pf), imshow(erode_img);
          pf = pf +1;


   end
end

f = msgbox({strcat('OCR Full plate reading   :',Full_OCR);
    strcat('OCR Segmented            :',PlateDetail);
    strcat('Template Matchiing        :',PlateDetail1)});





