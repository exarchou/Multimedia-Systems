function qBlock = irunLength(runSymbols, DCpred)

Route = 64;
ZigZagVector = zeros(Route , 1);
index = 1;

ZigZagVector(index) = runSymbols(1,2) + DCpred;
index = index + 1;

for i = 2:size(runSymbols, 1) - 1  % The last (0,0) is not used
    
    CountZeros = runSymbols(i,1);
    
    if ( CountZeros > 0 )
        
        for k = index:(index + CountZeros - 1)
            
            ZigZagVector(index) = 0;
            index = index + 1;
            
        end
        
    end
    
    ZigZagVector(index) = runSymbols(i,2);
    index = index + 1;
    
end


%% Converting ZigZagVector to qBlock(8x8)
qBlock = zeros(8);
[rows, columns] = size(qBlock);

i = 1;
j = 1;

for x = 1:length(ZigZagVector)
    
    qBlock(i,j) = ZigZagVector(x);
    
    add = i + j;
    
    if ( mod(add,2) == 0 ) % Up and Right
        
        if ( i > 1 )
            
            if ( j < columns )
                % We can go up and right
                i = i - 1;
                j = j + 1;
                
            else
                % We are on the last column
                i = i + 1;
                
            end
            
        else   
            % We are on the first row
            j = j + 1; 
            
        end
        
    else  % Down and Left
    
        if ( j > 1 )
            
            if ( i < rows )
                % We can go down and left
                i = i + 1;
                j = j - 1;
                
            else
                % We are on the last row
                j = j + 1;
                
            end
            
        else
            % We are on the first column
            % I have to pay attention to edge point (8,1).
            % At this point I go right( j = j + 1 ).
            if ( i < rows )
                
                i = i + 1;
                
            else 
                
                j = j + 1;
                
            end
            
        end
        
    end
       
end

end