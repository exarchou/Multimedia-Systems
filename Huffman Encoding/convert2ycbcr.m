function [imageY, imageCb,imageCr] = convert2ycbcr(imageRGB, subimg)

    image = im2double(imageRGB);
    
    %% Spliting
    R = image(:,:,1);
    G = image(:,:,2);
    B = image(:,:,3);
    
    
    %% Converting
    imageY = 0.299*R + 0.587*G + 0.114*B;
    imageCb = -0.168736*R - 0.331264*G + 0.5*B;
    imageCr = 0.5*R - 0.418688*G - 0.081312*B;
    
    
    %% Subsampling
    if (isequal(subimg, [4 2 2]))
        imageCb = imageCb(:, 1:2:end);
        imageCr = imageCr(:, 1:2:end);
        
    elseif (isequal(subimg, [4 2 0]))
        imageCb = imageCb(1:2:end, 1:2:end);
        imageCr = imageCr(1:2:end, 1:2:end);

    end

end

