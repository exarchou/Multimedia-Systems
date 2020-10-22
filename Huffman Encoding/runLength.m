function runSymbols = runLength(qBlock, DCpred)

[rows, columns] = size(qBlock);

ZigZagVector = zeros(rows * columns , 1);

i = 1;
j = 1;

for x = 1:length(ZigZagVector)
    
    ZigZagVector(x) = qBlock(i,j);
    
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
            % At this point i go right( j = j + 1 ).
            if ( i < rows )
                
                i = i + 1;
                
            else 
                
                j = j + 1;
                
            end
            
        end
        
    end
      
end
    
    
%% Coding R x (precedingZeros, quantSymbol)
index = 1;
counter = 0; % Counting continious  Zeros

runSymbols(index, 1) = 0;
runSymbols(index, 2) = ZigZagVector(1) - DCpred; 


%% I have to assure that Values are inside the permissible space
if ( runSymbols(index, 2) > 2047 )
    
    runSymbols(index, 2) = 2047;
    
elseif ( runSymbols(index, 2) < -2047 ) 
    
    runSymbols(index, 2) = -2047;
    
end

index = index + 1;

for i = 2:length(ZigZagVector)
    
    if ( ZigZagVector(i) == 0 )
        
        counter = counter + 1;
    
    else
        
        runSymbols(index, 1) = counter;
        runSymbols(index, 2) = ZigZagVector(i);
        
        % I have to assure that the maximum absoute value is 1023
        if ( runSymbols(index, 2) > 1023 )
            
            runSymbols(index, 2) = 1023;
    
        elseif ( runSymbols(index, 2) < -1023 ) 
            
            runSymbols(index, 2) = -1023;
    
        end
        
        index = index + 1;
        counter = 0;
        
    end
    
    %% I need to check if counter is more than 15
    if ( counter > 15 )
        
        runSymbols(index, 1) = 15;
        runSymbols(index, 2) = 0;
        index = index + 1;
        counter = 0;
    
    end
    
end

runSymbols(index, 1) = counter - 1; % I subtract 1 because the last zero is an indepedent value in 2nd column
runSymbols(index, 2) = 0;
 

%% Deleting only-zero rows and adding EOB (0,0)
LastNonZero = 1; % I must not delete the DC coeffcient.

for i = 2:size(runSymbols,1)
    
    if (runSymbols(i,2) ~= 0)
        
        LastNonZero = i;
        
    end
    
end


for i = size(runSymbols,1): -1: LastNonZero+1
    
        runSymbols(i,:) = [];
    
end

runSymbols( (size(runSymbols,1) + 1), 1) = 0;
runSymbols( (size(runSymbols,1)), 2) = 0;

end