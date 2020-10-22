function qBlock = quantizeJPEG(dctBlock, qTable, qScale)

    qBlock = zeros(size(dctBlock));
    
    for i = 1 : size(dctBlock, 1)
        
        for j = 1 : size(dctBlock, 2)
            
            qBlock(i,j) = fix(dctBlock(i,j) / (qScale * qTable(i,j)));
            
        end
        
    end
    
end

