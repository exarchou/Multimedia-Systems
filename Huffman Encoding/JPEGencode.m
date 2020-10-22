function JPEGenc = JPEGencode(img, subimg, qScale)

global qTableL
global qTableC
global DCL
global DCC 
global ACL
global ACC 
global DC_Table
global AC_Table
global EOB
global ZRL
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Converting - DCT - Quantize - Huffman 


%% Converting to YCbCr
fprintf("10%%...Converting Image to Ycbcr...\n");

[imageY, imageCb, imageCr] = convert2ycbcr(img, subimg);

imageY = imageY * 255;
imageCb = imageCb * 255 + 128;
imageCr = imageCr * 255 + 128;



%% DCT
fprintf("20%%...Transforming Image with DCT...\n");

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
fprintf("30%%...Quantizing Image...\n");

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



%% Zig-Zag Scanning
fprintf("40%%...Zig-Zag Scanning Image....\n");

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



%% Huffman Encoding
fprintf("50%%...Encoding Image with Huffman...\n");

huffStreamY  = cell(1, length(runSymbolsY));
huffStreamCb = cell(1, length(runSymbolsCb));
huffStreamCr = cell(1, length(runSymbolsCr));


%% Huffman Encoding for Luminance
DC_Table = DCL;
AC_Table = ACL;
EOB = [1 0 1 0];
ZRL = [1 1 1 1 1 1 1 1 0 0 1];
    
for i = 1:length(runSymbolsY)
    
    huffStreamY{i} = huffEnc(runSymbolsY{i});
  
end


%% Huffman Encoding for Chrominance
DC_Table = DCC;
AC_Table = ACC;
EOB = [0 0];
ZRL = [1 1 1 1 1 1 1 0 1 0];

for i = 1:length(runSymbolsCb)
        
    huffStreamCb{i} = huffEnc(runSymbolsCb{i});
  
end
 
for i = 1:length(runSymbolsCr)
     
    huffStreamCr{i} = huffEnc(runSymbolsCr{i});
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Converting to Cell of Structs
TotalBlocks = length(huffStreamY) + length(huffStreamCb) + length(huffStreamCr);
JPEGenc = cell(1, TotalBlocks + 1); % cell to return
    
    
%% First Cell for Matrices
JPEGenc{1} = struct;
JPEGenc{1}.qTableL = qTableL * qScale;
JPEGenc{1}.qTableC = qTableC * qScale;
JPEGenc{1}.DCL = DCL;
JPEGenc{1}.DCC = DCC;
JPEGenc{1}.ACL = ACL;
JPEGenc{1}.ACC = ACC;


%% Rest of Cells are structs with Huffman Codes for each block
index = 2;

%% Cells for Luminance Y (3844 when [4 2 2])
for i = 1:length(huffStreamY)
    
    JPEGenc{index}.blkType = "Y";
    blocksHor = 496/8;
    JPEGenc{index}.indHor = floor(i/blocksHor - 0.00001) + 1; 
    JPEGenc{index}.indVer = mod(i,blocksHor);
    if (JPEGenc{index}.indVer == 0 )
        JPEGenc{index}.indVer = blocksHor;
    end
    JPEGenc{index}.huffStream = cell2mat(huffStreamY(i));
    index = index + 1;
    
end


%% Cells for Chrominance Cb (1922 when [4 2 2])
for i = 1:length(huffStreamCb)
    
    JPEGenc{index}.blkType = "Cb";
    
    if (isequal(subimg, [4 4 4]))
        blocksHor = 496/8;
        
    elseif (isequal(subimg, [4 2 2]) || isequal(subimg, [4 2 0]))
        blocksHor = 248/8;

    end
    
    JPEGenc{index}.indHor = floor(i/blocksHor - 0.00001) + 1; 
    JPEGenc{index}.indVer = mod(i,blocksHor);
    if (JPEGenc{index}.indVer == 0 )
        JPEGenc{index}.indVer = blocksHor;
    end    
    
    JPEGenc{index}.huffStream = cell2mat(huffStreamCb(i));
    
    index = index + 1;
    
end


%% Cells for Chrominance Cr (1922 when [4 2 2])
for i = 1:length(huffStreamCr)
    
    JPEGenc{index}.blkType = "Cr";
    
    if (isequal(subimg, [4 4 4]))
        blocksHor = 496/8;
        
    elseif (isequal(subimg, [4 2 2]) || isequal(subimg, [4 2 0]))
        blocksHor = 248/8;

    end
    
    JPEGenc{index}.indHor = floor(i/blocksHor - 0.00001) + 1; 
    JPEGenc{index}.indVer = mod(i,blocksHor);
    if (JPEGenc{index}.indVer == 0 )
        JPEGenc{index}.indVer = blocksHor;
    end    
    
    JPEGenc{index}.huffStream = cell2mat(huffStreamCr(i));
    
    index = index + 1;
    
end

end

