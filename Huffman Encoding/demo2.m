%% Clearing
clear all;
close all;
clc;


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
  
    
    fprintf("Entropies for Image %d\n\n", im);
    
    %% Entropy in spatial domain (RGB)
    EntropyRGB = entropy(img);
    fprintf("Spatial Domain : %.3f\n", EntropyRGB);
    
    
    
    %% Converting to YCbCr
    [imageY, imageCb, imageCr] = convert2ycbcr(img, subimg);

    imageY = imageY * 255;
    imageCb = imageCb * 255 + 128;
    imageCr = imageCr * 255 + 128;



    %% DCT
    DCTimageY = zeros(size(imageY));
    DCTimageCb = zeros(size(imageCb));
    DCTimageCr = zeros(size(imageCr));


    %% Transforming Luminance
    for i = 1:8:size(imageY, 1)
    
        for j = 1:8:size(imageY,2)
        
            block = imageY(i:i+7, j:j+7);
        
            DCTimageY(i:i+7, j:j+7) = blockDCT(block);

        end
        
    end


    %% Transforming Chrominance
    for i = 1:8:size(imageCb, 1)
    
        for j = 1:8:size(imageCb,2)
        
            block = imageCb(i:i+7, j:j+7);
        
            DCTimageCb(i:i+7, j:j+7) = blockDCT(block);
        
            block = imageCr(i:i+7, j:j+7);
        
            DCTimageCr(i:i+7, j:j+7) = blockDCT(block);

        end
        
    end



    %% Quantizing
    QuantizedImageY = zeros(size(DCTimageY));
    QuantizedImageCb = zeros(size(DCTimageCb));
    QuantizedImageCr = zeros(size(DCTimageCr));


    %% Quantizing Luminance   
    for i = 1:8:size(DCTimageY, 1)
    
        for j = 1:8:size(DCTimageY,2)
        
            dctBlock = DCTimageY(i:i+7, j:j+7);
        
            qBlock = quantizeJPEG(dctBlock, qTableL, qScale);

            QuantizedImageY(i:i+7, j:j+7) = qBlock;
        
        end
        
    end


    %% Quantizing Chrominance
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
    
    
    %% Entropy of quantized DCTs 
    EntropyDCT = (entropy(QuantizedImageY) + entropy(QuantizedImageCb) + entropy(QuantizedImageCr)) / 3;
    fprintf("Quantized DCTs : %.3f\n", EntropyDCT);
    
    
    
    %% Zig-Zag Scanning
    runSymbolsY  = cell(1, size(QuantizedImageY, 1)*size(QuantizedImageY, 2) / 64);
    runSymbolsCr = cell(1, size(QuantizedImageCr,1)*size(QuantizedImageCr,2) / 64);
    runSymbolsCb = cell(1, size(QuantizedImageCb,1)*size(QuantizedImageCb,2) / 64);


    %% Zig-Zag Scanning for Luminance
    DCpred = 0;
    x = 1;

    for i = 1:8:size(QuantizedImageY, 1)
    
        for j = 1:8:size(QuantizedImageY, 2)
        
            qBlock = QuantizedImageY(i:i+7, j:j+7);
            runSymbolsY{x} = runLength(qBlock, DCpred); 
            DCpred = qBlock(1,1);
            x = x + 1;
        
        end
        
    end



    %% Zig-Zag Scanning for Chrominance
    DCpred = 0;
    x = 1;

    for i = 1:8:size(QuantizedImageCr, 1)
    
        for j = 1:8:size(QuantizedImageCr, 2)
        
            qBlock = QuantizedImageCr(i:i+7, j:j+7);
            runSymbolsCr{x} = runLength(qBlock, DCpred); 
            DCpred = qBlock(1,1);
            x = x + 1;
        
        end
        
    end


    DCpred = 0;
    x = 1;

    for i = 1:8:size(QuantizedImageCb, 1)
    
        for j = 1:8:size(QuantizedImageCb, 2)
        
            qBlock = QuantizedImageCb(i:i+7, j:j+7);
            runSymbolsCb{x} = runLength(qBlock, DCpred); 
            DCpred = qBlock(1,1);
            x = x + 1;
        
        end
        
    end


    %% Entropy of RunLengths 
    EntropyRunLengthY  = 0;
    EntropyRunLengthCb = 0;
    EntropyRunLengthCr = 0;
    
    %% Entropies of RunSymbols for Luminance Y
    for i = 1:length(runSymbolsY)
        
        EntropyRunLengthY = EntropyRunLengthY + entropy(runSymbolsY{i});
        
    end
        
    EntropyRunLengthY = EntropyRunLengthY / length(runSymbolsY);
    
    
    %% Entropies of RunSymbols for Chrominance Cb
    for i = 1:length(runSymbolsCb)
        
        EntropyRunLengthCb = EntropyRunLengthCb + entropy(runSymbolsCb{i});
        
    end
        
    EntropyRunLengthCb = EntropyRunLengthCb / length(runSymbolsCb);
    
    
    %% Entropies of RunSymbols for Chrominance Cr
    for i = 1:length(runSymbolsCr)
        
        EntropyRunLengthCr = EntropyRunLengthCr + entropy(runSymbolsCr{i});
        
    end
        
    EntropyRunLengthCr = EntropyRunLengthCr / length(runSymbolsCr);
    
        
    %% Total Run Length Entropy
    EntropyRunLength = (EntropyRunLengthY + EntropyRunLengthCb + EntropyRunLengthCr) / 3;
    fprintf("Run Lengths    : %.3f\n\n\n", EntropyRunLength);
    
    
end