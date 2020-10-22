function runSymbols = huffDec(huffStream)

global EOB
global ZRL


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Luminance DC coefficient differences
global DC_Table

flag = 0; % Variable to find CodeWord
CodeLength = 0;

%% Exporting the DC coefficient
for i = 1:length(huffStream)
    
    CodeWord = huffStream(1:i);
    
    for j = 1:length(DC_Table) 
        
        if ( isequal(CodeWord, DC_Table{j}) ) 
            flag = 1;
            CodeLength = j - 1;
            break;
        end 
        
    end
    
    if ( flag == 1 )
        
        break;    
        
    end   
    
end


%% Resizing Index
index = i ;


if (isequal(CodeWord, [0 0])) 
    
    runSymbols(1,1) = 0;
    runSymbols(1,2) = 0;
    index = index + 1;
    
end



%% Generally
if ( CodeLength > 0 )
    
    %% Taking codeLength bits of huffStream
    BinaryNumber = zeros(1,CodeLength);

    for i = 1:CodeLength
    
        BinaryNumber(i) = huffStream(index + i);
        
    end



    %% Resizing Index
    index = index + CodeLength + 1;


    %% If the number is negative then I inverse the bit sequence
    isNegative = 0;

    if ( BinaryNumber(1) == 0 )
        
        for i = 1:length(BinaryNumber)

            BinaryNumber(i) = ~ BinaryNumber(i);  
        
        end      
    
        isNegative = 1;
        
    end


    %% Converting to Decimal
    DC = bi2de(BinaryNumber,'left-msb');

    if (isNegative == 1) 
    
        DC = DC * (-1); 
    
    end


    %% Putting DC-coefficien to runSymbols
    runSymbols(1,1) = 0;
    runSymbols(1,2) = DC;

end


    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% AC coefficients
global AC_Table
    
x = 2;

while(1)

    flag = 0; % Variable to find CodeWord
    Zeros = 0;
    CodeLength = 0;
    
    %% Exporting the AC coefficients
    for i = index:length(huffStream)
    
        CodeWord = huffStream(index:i);
        
        for j = 1:size(AC_Table,1) 
        
            for k = 1:size(AC_Table,2)
            
                if ( isequal(CodeWord, AC_Table{j,k}) ) 
                    flag = 1;
                    Zeros = j - 1;
                    CodeLength = k - 1;
                    break;
                    
                end 
                
            end
            
            if ( flag == 1 )
                
                break;    
                
            end  
            
        end
        
        if ( flag == 1 )
            
            break;    
            
        end   
        
    end

    
    %% Resizing Index
    index = i ;
    
       
    %% Boundary Conditions
    if (isequal(CodeWord, ZRL)) % This is the special (15,0)
        
        index = index + 1;
        runSymbols(x,1) = 15;
        runSymbols(x,2) = 0;
        x = x + 1;
        continue;
        
    end
    
    if (isequal(CodeWord, EOB)) % This is the End of Stream
        
        runSymbols(x,1) = 0;
        runSymbols(x,2) = 0;
        break;
        
    end
        
    
    
    %% Taking codeLength bits of huffStream
    BinaryNumber = zeros(1,CodeLength);
       
    for i = 1:CodeLength
        
        BinaryNumber(i) = huffStream(index + i);
        
    end


    %% Resizing Index
    index = index + CodeLength + 1;
    
    
    %% If the number is negative then I inverse the bit sequence
    isNegative = 0;

    if ( BinaryNumber(1) == 0 )
        
        for i = 1:length(BinaryNumber)

            BinaryNumber(i) = ~ BinaryNumber(i);  
        
        end      
    
        isNegative = 1;
        
    end


    %% Converting to Decimal
    AC = bi2de(BinaryNumber,'left-msb');

    if (isNegative == 1) 
    
        AC = AC * (-1); 
    
    end


    %% Putting AC-coefficients to runSymbols
    runSymbols(x,1) = Zeros;
    runSymbols(x,2) = AC;
    
    x = x + 1;
      
end   

end