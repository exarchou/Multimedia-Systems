function imageRGB = convert2rgb(imageY, imageCb, imageCr, subimg)

    newY = imageY;

    %% Upsampling
    if (isequal(subimg, [4 4 4]))
        
        newCb = imageCb;
        newCr = imageCr;
        
    elseif (isequal(subimg, [4 2 2]))
        
        newCb = zeros(size(imageCb,1), size(imageCb,2)*2);
        newCr = zeros(size(imageCr,1), size(imageCr,2)*2);
        k = 1;
        
        for j = 1:size(imageCb,2)
            
            newCb(:,k) = imageCb(:,j);
            newCr(:,k) = imageCr(:,j);    
            newCb(:,k+1) = imageCb(:,j);
            newCr(:,k+1) = imageCr(:,j); 
            k = k + 2;
            
        end
        
    elseif (isequal(subimg, [4 2 0]))
        
        tempCb = zeros(size(imageCb,1), size(imageCb,2)*2);
        tempCr = zeros(size(imageCr,1), size(imageCr,2)*2);
        k = 1;
        
        for j = 1:size(imageCb,2)
            
            tempCb(:,k) = imageCb(:,j);
            tempCr(:,k) = imageCr(:,j);    
            tempCb(:,k+1) = imageCb(:,j);
            tempCr(:,k+1) = imageCr(:,j); 
            k = k + 2;
            
        end
        
        newCb = zeros(size(imageCb,1)*2, size(imageCb,2)*2);
        newCr = zeros(size(imageCr,1)*2, size(imageCr,2)*2);
        k = 1;
        
        for i = 1:size(tempCb,1)
            
            newCb(k,:) = tempCb(i,:);
            newCr(k,:) = tempCr(i,:);    
            newCb(k+1,:) = tempCb(i,:);
            newCr(k+1,:) = tempCr(i,:); 
            k = k + 2;
            
        end
            
    else
        
        printf("Wrong Input!");
        
    end
    
    
    %% Converting
    newR = 1*newY + 0*newCb + 1.402*newCr;
    newG = 1*newY - 0.344136*newCb - 0.714136*newCr;
    newB = 1*newY + 1.772*newCb + 0*newCr;

    newR = uint8(newR*255);
    newG = uint8(newG*255);
    newB = uint8(newB*255);
    
    imageRGB = uint8(zeros(496,496,3));
    imageRGB(:,:,1) = newR;
    imageRGB(:,:,2) = newG;
    imageRGB(:,:,3) = newB;
    
end

