function huffStream = huffEnc(runSymbols)

global EOB
global ZRL

huffStream = [];


%% DC coefficient differences (both for Luminance and Chrominance)
global DC_Table

%% Exporting the DC coefficient
DC = runSymbols(1,2);


%% Checking the amplitude of DC
% Initializing CodeWord to 1st Category (DIFF = 0)
CodeWord = DC_Table{1};
   
for i = 1:length(DC_Table)-1 
        
    if ( abs(DC) >= 2^(i-1)  &&  abs(DC) < 2^i )
            
        CodeWord = DC_Table{i+1};

    end

end
    
    
%% Converting Number to Binary
BinaryNumber = de2bi(abs(DC),'left-msb');
    
%% If the number is negative then I inverse the bit sequence
if ( DC < 0 )
        
    for i = 1:length(BinaryNumber)

        BinaryNumber(i) = ~ BinaryNumber(i);
        
    end        
    
end
        

    
%% Merging Code Word for Category and BinaryNumber
if DC ~= 0 
    
    stream = horzcat(CodeWord, BinaryNumber);
    
else
    
    stream = CodeWord;
    
end
    
%% Adding new word to Stream
huffStream = horzcat(huffStream, stream);
    
    
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% AC coefficients (both for Luminance and Chrominance)
global AC_Table
    
%% Exporting the AC coefficients
for i = 2:size(runSymbols,1)
        
    Zeros = runSymbols(i,1);
    AC = runSymbols(i,2);
    
    % Boundary Conditions
    if ( Zeros == 0 && AC == 0)
        
        huffStream = horzcat(huffStream, EOB);
    
    elseif (Zeros == 15 && AC == 0)
    
        huffStream = horzcat(huffStream, ZRL);
        
    else
        
        %% Checking the amplitude of AC
        for j = 1:size(AC_Table,2)-1
        
            if ( abs(AC) >= 2^(j-1)  &&  abs(AC) < 2^j )
            
                CodeWord = AC_Table{Zeros+1, j+1};
            
            end
        
        end
        
        %% Converting Number to Binary
        BinaryNumber = de2bi(abs(AC),'left-msb');
    
        %% If the number is negative then I inverse the bit sequence
        if ( AC < 0 )
        
            for j = 1:length(BinaryNumber)

                BinaryNumber(j) = ~ BinaryNumber(j);
        
            end        
    
        end
        
    
        %% Merging Code Word for Ctegory and BinaryNumber
        stream = horzcat(CodeWord, BinaryNumber);
    
        %% Adding new word to Stream
        huffStream = horzcat(huffStream, stream); 
        
    end
    
end

end

