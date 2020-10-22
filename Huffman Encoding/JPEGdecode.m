function imgRec = JPEGdecode(JPEGenc)

global DCL
global DCC 
global ACL
global ACC 
global DC_Table
global AC_Table
global EOB
global ZRL



%% Extracting Huffman Tables
qTableL = JPEGenc{1}.qTableL;
qTableC = JPEGenc{1}.qTableC;
DCL = JPEGenc{1}.DCL;
DCC = JPEGenc{1}.DCC;
ACL = JPEGenc{1}.ACL;
ACC = JPEGenc{1}.ACC;



%% Huffman Decoding
fprintf("60%%...Decoding Image with Huffman...\n");

DCpredY  = 0;
DCpredCb = 0;
DCpredCr = 0;


for i = 2:length(JPEGenc)
    
    blkType = JPEGenc{i}.blkType;
    indHor = JPEGenc{i}.indHor;
    indVer = JPEGenc{i}.indVer;
    huffStream = JPEGenc{i}.huffStream;
    
    
    if (isequal(blkType, "Y"))
        
        DC_Table = DCL;
        AC_Table = ACL;
        EOB = [1 0 1 0];
        ZRL = [1 1 1 1 1 1 1 1 0 0 1];
        
        OUTPUT_runSymbols = huffDec(huffStream);
        
        %% Inverse Zig-Zag Scanning
        qBlock = irunLength(OUTPUT_runSymbols, DCpredY);             
        OUTPUT_QuantizedImageY(((indHor-1)*8 + 1):((indHor-1)*8 + 8), ((indVer-1)*8 + 1):((indVer-1)*8 + 8)) = qBlock;
        DCpredY = qBlock(1,1);
        
        
    elseif (isequal(blkType, "Cb"))

        DC_Table = DCC;
        AC_Table = ACC;
        EOB = [0 0];
        ZRL = [1 1 1 1 1 1 1 0 1 0];
        
        OUTPUT_runSymbols = huffDec(huffStream);
        
        %% Inverse Zig-Zag Scanning
        qBlock = irunLength(OUTPUT_runSymbols, DCpredCb);             
        OUTPUT_QuantizedImageCb(((indHor-1)*8 + 1):((indHor-1)*8 + 8), ((indVer-1)*8 + 1):((indVer-1)*8 + 8)) = qBlock;
        DCpredCb = qBlock(1,1);


    else

        DC_Table = DCC;
        AC_Table = ACC;
        EOB = [0 0];
        ZRL = [1 1 1 1 1 1 1 0 1 0];
        
        OUTPUT_runSymbols = huffDec(huffStream);
        
        %% Inverse Zig-Zag Scanning

        qBlock = irunLength(OUTPUT_runSymbols, DCpredCr);             
        OUTPUT_QuantizedImageCr(((indHor-1)*8 + 1):((indHor-1)*8 + 8), ((indVer-1)*8 + 1):((indVer-1)*8 + 8)) = qBlock;
        DCpredCr = qBlock(1,1);

    end
    
end

fprintf("70%%...Inverse Zig-Zag Scanning Image.\n");



%% Dequantizing
fprintf("80%%...Dequantizing Image...\n");

OUTPUT_DCTimageY  = zeros(size(OUTPUT_QuantizedImageY));
OUTPUT_DCTimageCb = zeros(size(OUTPUT_QuantizedImageCb));
OUTPUT_DCTimageCr = zeros(size(OUTPUT_QuantizedImageCr));


%% DeQuantizing Luminance Y   
qScale = 1; % Because qTables are multiplied with qScale

for i = 1:8:size(OUTPUT_DCTimageY, 1)
    
    for j = 1:8:size(OUTPUT_DCTimageY, 2)
        
        qBlock = OUTPUT_QuantizedImageY(i:i+7, j:j+7);
        
        dctBlock = dequantizeJPEG(qBlock, qTableL, qScale);

        OUTPUT_DCTimageY(i:i+7, j:j+7) = dctBlock;
        
    end
    
end


%% DeQuantizing Chrominance Cb and Cr
for i = 1:8:size(OUTPUT_DCTimageCb, 1)
    
    for j = 1:8:size(OUTPUT_DCTimageCb, 2)
        
        %% Dequantization  of Cb
        qBlock = OUTPUT_QuantizedImageCb(i:i+7, j:j+7);
        
        dctBlock = dequantizeJPEG(qBlock, qTableC, qScale);

        OUTPUT_DCTimageCb(i:i+7, j:j+7) = dctBlock;
        
        %% Dequantizaation of Cr
        qBlock = OUTPUT_QuantizedImageCr(i:i+7, j:j+7);
        
        dctBlock = dequantizeJPEG(qBlock, qTableC, qScale);

        OUTPUT_DCTimageCr(i:i+7, j:j+7) = dctBlock;
        
    end
    
end



%% Inversing DCT
fprintf("90%%...Transforming Image with inverse DCT...\n");

imageY_OUTPUT  = zeros(size(OUTPUT_DCTimageY));
imageCb_OUTPUT = zeros(size(OUTPUT_DCTimageCb));
imageCr_OUTPUT = zeros(size(OUTPUT_DCTimageCr));


%% Inversing Luminance Y
for i = 1:8:size(imageY_OUTPUT, 1)
    
    for j = 1:8:size(imageY_OUTPUT, 2)
        
        block = OUTPUT_DCTimageY(i:i+7, j:j+7);
        
        imageY_OUTPUT(i:i+7, j:j+7) = iBlockDCT(block);

    end
    
end


%% Inversing Chrominance Cb and Cr
for i = 1:8:size(imageCb_OUTPUT, 1)
    
    for j = 1:8:size(imageCb_OUTPUT, 2)
        
        block = OUTPUT_DCTimageCb(i:i+7, j:j+7);
        
        imageCb_OUTPUT(i:i+7, j:j+7) = iBlockDCT(block);
        
        block = OUTPUT_DCTimageCr(i:i+7, j:j+7);
        
        imageCr_OUTPUT(i:i+7, j:j+7) = iBlockDCT(block);

    end
    
end



%% Converting back to RGB
fprintf("100%%..Converting Image back to RGB...\n\n");


% Finding subimg
if (size(imageCb_OUTPUT, 2) == size(imageY_OUTPUT, 2))
    
    subimg = [4 4 4];
    
else
    
    if (size(imageCb_OUTPUT, 1) == size(imageY_OUTPUT, 1))
        
        subimg = [4 2 2];
        
    else
        
        subimg = [4 2 0];
        
    end
    
end
    

imageY_OUTPUT  = imageY_OUTPUT / 255;
imageCb_OUTPUT = (imageCb_OUTPUT - 128) / 255;
imageCr_OUTPUT = (imageCr_OUTPUT - 128) / 255;


imgRec = convert2rgb(imageY_OUTPUT, imageCb_OUTPUT, imageCr_OUTPUT, subimg);


end
