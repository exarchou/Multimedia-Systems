%% Clearing.
clear all;
close all;
clc;


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
         
         

%% Repeat for 2 Images
for im = 1:2
    
    %% Load Images
    str = sprintf("img%d_down.mat", im);
    load (str);
    
    if ( im == 1 )
        
        img = img1_down;
        subimg = [4 2 2];
        qScale = 0.6;
        
    else
        
        img = img2_down;
        subimg = [4 4 4];
        qScale = 5;   
        
    end
    
    %% Croping
    img = img(1:496, 1:496, :);
  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Converting to YCbCr and back
    [imageY, imageCb, imageCr] = convert2ycbcr(img, subimg);

    imageRGB = convert2rgb(imageY, imageCb, imageCr, subimg);

    figure();
    imshow(imageRGB);
    title("Reconstructed Image after Converting to YCbCr");
    str = sprintf("demo1/Reconstructed Image %d after YCbCr Conversion.png", im);
    saveas(gcf, str);


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Converting - DCT - Quantizing and back

    %% Converting to YCbCr
    [imageY, imageCb, imageCr] = convert2ycbcr(img, subimg);

    imageY = imageY * 255;
    imageCb = imageCb * 255 + 128;
    imageCr = imageCr * 255 + 128;



    %% DCT
    DCTimageY = zeros(size(imageY));
    DCTimageCb = zeros(size(imageCb));
    DCTimageCr = zeros(size(imageCr));


    for i = 1:8:size(imageY, 1)
    
        for j = 1:8:size(imageY,2)
        
            block = imageY(i:i+7, j:j+7);
        
            DCTimageY(i:i+7, j:j+7) = blockDCT(block);

        end
    end


    for i = 1:8:size(imageCb, 1)
    
        for j = 1:8:size(imageCb,2)
        
            block = imageCb(i:i+7, j:j+7);
        
            DCTimageCb(i:i+7, j:j+7) = blockDCT(block);
        
            block = imageCr(i:i+7, j:j+7);
        
            DCTimageCr(i:i+7, j:j+7) = blockDCT(block);
            
        end
        
    end


    %% Quantizing
    QuantizedImageY = zeros(size(imageY));
    QuantizedImageCb = zeros(size(imageCb));
    QuantizedImageCr = zeros(size(imageCr));

    
    %% Quantizing Luminance Y   

    for i = 1:8:size(DCTimageY, 1)
    
        for j = 1:8:size(DCTimageY,2)
        
            dctBlock = DCTimageY(i:i+7, j:j+7);
        
            qBlock = quantizeJPEG(dctBlock, qTableL, qScale);

            QuantizedImageY(i:i+7, j:j+7) = qBlock;
        
        end
        
    end


    %% Quantizing Chrominance Cb and Cr 

    for i = 1:8:size(DCTimageCb, 1)
    
        for j = 1:8:size(DCTimageCb,2)
        
            %% Quantization  of Cb
            dctBlock = DCTimageCb(i:i+7, j:j+7);
        
            qBlock = quantizeJPEG(dctBlock, qTableC, qScale);

            QuantizedImageCb(i:i+7, j:j+7) = qBlock;
        
            %% Quantizaation of Cr
            dctBlock = DCTimageCr(i:i+7, j:j+7);
        
            qBlock = quantizeJPEG(dctBlock, qTableC, qScale);

            QuantizedImageCr(i:i+7, j:j+7) = qBlock;
        
        end
    
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Inversing
    
    %% Dequantizing
    DequantizedImageY = zeros(size(QuantizedImageY));
    DequantizedImageCr = zeros(size(QuantizedImageCb));
    DequantizedImageCb = zeros(size(QuantizedImageCr));


    %% Dequantizing Luminance Y   

    for i = 1:8:size(QuantizedImageY, 1)
    
        for j = 1:8:size(QuantizedImageY,2)
        
            qBlock = QuantizedImageY(i:i+7, j:j+7);
        
            dctBlock = dequantizeJPEG(qBlock, qTableL, qScale);

            DequantizedImageY(i:i+7, j:j+7) = dctBlock;
        
        end
        
    end


    %% Dequantizing Chrominance Cb and Cr 

    for i = 1:8:size(QuantizedImageCb, 1)
    
        for j = 1:8:size(QuantizedImageCb, 2)
        
            %% Dequantization  of Cb
            qBlock = QuantizedImageCb(i:i+7, j:j+7);
        
            dctBlock = dequantizeJPEG(qBlock, qTableC, qScale);

            DequantizedImageCb(i:i+7, j:j+7) = dctBlock;
        
            %% Dequantization of Cr
            qBlock = QuantizedImageCr(i:i+7, j:j+7);
        
            dctBlock = dequantizeJPEG(qBlock, qTableC, qScale);

            DequantizedImageCr(i:i+7, j:j+7) = dctBlock;
        
        end
    
    end


    %% Inversing DCT
    NEWimageY = zeros(size(DequantizedImageY));
    NEWimageCb = zeros(size(DequantizedImageCb));
    NEWimageCr = zeros(size(DequantizedImageCr));

    block = zeros(8);

    for i = 1:8:size(DequantizedImageY, 1)
    
        for j = 1:8:size(DequantizedImageY,2)
        
            block = DequantizedImageY(i:i+7, j:j+7);
        
            NEWimageY(i:i+7, j:j+7) = iBlockDCT(block);

        end
        
    end


    for i = 1:8:size(DequantizedImageCb, 1)
    
        for j = 1:8:size(DequantizedImageCb,2)
        
            block = DequantizedImageCb(i:i+7, j:j+7);
        
            NEWimageCb(i:i+7, j:j+7) = iBlockDCT(block);
        
            block = DequantizedImageCr(i:i+7, j:j+7);
        
            NEWimageCr(i:i+7, j:j+7) = iBlockDCT(block);

        end
        
    end


    %% Converting back to RGB
    NEWimageY = NEWimageY /255;
    NEWimageCb = (NEWimageCb - 128) /255;
    NEWimageCr = (NEWimageCr - 128) /255;


    imageRGB2 = convert2rgb(NEWimageY, NEWimageCb, NEWimageCr, subimg);

    figure();
    imshow(imageRGB2);
    title("Reconstructed Image after Converting to YCbCr, DCT and Quantizing");
    str = sprintf("demo1/Reconstructed Image %d after YCbCr, DCT and Quantizing.png", im);
    saveas(gcf, str);

end

