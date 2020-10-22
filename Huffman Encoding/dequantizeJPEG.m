function dctBlock = dequantizeJPEG(qBlock, qTable, qScale)

    dctBlock = zeros(size(qBlock));
    
    for i = 1:size(qBlock, 1)
        
        for j = 1:size(qBlock, 2)
            
            dctBlock(i,j) = qBlock(i,j)*(qScale * qTable(i,j));
            
        end
        
    end
    
end

