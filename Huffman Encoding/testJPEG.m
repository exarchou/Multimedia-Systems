%% Clearing
clear all;
close all;
clc;

tic

%% Loading Images
load('img1_down.mat');
load('img2_down.mat');
myImage = imread('myImage.jpg');

figure(1);
imshow(img1_down);
title("Initial Image 1");
figure(2);
imshow(img2_down);
title("Initial Image 2");
figure(3);
imshow(myImage);
title("Initial myImage");


%% Cropping Images
image1 = img1_down(1:496, 1:496, :);
image2 = img2_down(1:496, 1:496, :);
myImage = myImage(1:496, 1:496, :);


%% Global Tables

%% Table K.1 – Luminance quantization table
global qTableL

qTableL = [  16   11   10   16   24   40   51   61  ;
             12   12   14   19   26   58   60   55  ;
             14   13   16   24   40   57   69   56  ;
             14   17   22   29   51   87   80   62  ;
             18   22   37   56   68  109  103   77  ;
             24   35   55   64   81  104  113   92  ;
             49   64   78   87  103  121  120  101  ;
             72   92   95   98  112  100  103   99  ];
    
         
%% Table K.2 – Chrominance quantization table
global qTableC

qTableC = [  17	  18   24   47   99   99   99   99  ;
             18   21   26   66   99   99   99   99  ;
             24   26   56   99   99   99   99   99  ;
             47   66   99   99   99   99   99   99  ;
             99   99   99   99   99   99   99   99  ;
             99   99   99   99   99   99   99   99  ;
             99   99   99   99   99   99   99   99  ;
             99   99   99   99   99   99   99   99  ];
         
         
%% Table K.3 – Table for luminance DC coefficient differences
global DCL

load('DCL_cell.mat')

DCL = DCL_cell;


%% Table K.4 – Table for chrominance DC coefficient differences
global DCC

load('DCC_cell.mat')

DCC = DCC_cell;
         

%% Table K.5 – Table for luminance AC coefficients
global ACL

load('ACL_cell.mat')

ACL = ACL_cell;


%% Table K.6 – Table for chrominance AC coefficients    
global ACC

load('ACC_cell.mat')
    
ACC = ACC_cell;



%% Inputs 
Initial_Image = image2;
subimg = [4 4 4];


%% Ouputs
qScale = [0.1, 0.3, 0.6, 1, 2, 5, 10];
MSE = zeros(1,length(qScale));
TotalBits = zeros(1,length(qScale));


for i = 1:length(qScale)
    
    fprintf("Loading...\n\n");

    Encoded_Image = JPEGencode(Initial_Image, subimg, qScale(i));

    Reconstructed_Image = JPEGdecode(Encoded_Image);

    figure();
    imshow(Reconstructed_Image);
    str = sprintf("Reconstructed Image after Huffman Encoding with qScale = %.1f", qScale(i));
    title(str);
    
    str = sprintf("Image2/Reconstructed Image with qScale = %.1f .png", qScale(i));
    saveas(gcf, str);
    
    MSE(i) = immse(Reconstructed_Image, Initial_Image);
    
    
    %% Total Bits of Encoded Image
    for j = 2:length(Encoded_Image)
    
        bits = length(Encoded_Image{j}.huffStream);
        TotalBits(i) = TotalBits(i) + bits;
    
    end

end



%% Ploting Mean-Squared Error
figure();
plot(qScale, MSE, 'b')
xlabel("qScale");
ylabel("Mean Squared Error");
title("Mean Squared Error for different numbers of qScale");
saveas(gcf, 'Image2/MSE.png')


%% Ploting Number of bits
figure();
plot(qScale, TotalBits, 'b')
xlabel("qScale");
ylabel("Total Bits of Compressed Image");
title("Bits of Compressed Image");
saveas(gcf, 'Image2/bits.png')


toc