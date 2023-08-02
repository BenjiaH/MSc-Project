clc;
clear;

addpath include

% Init
% mappingEnable = true;
mappingEnable = false;
PRNId = 2;


fprintf('PRN No.%d for VHDL:\n', PRNId);
rawCaCode = generateCAcode(PRNId);
caCode = [rawCaCode, 0];
caCodeBin = caCode;
caCodeBin(caCodeBin == -1) = 0;
caCode(caCode == -1) = 0;
lenCACode = length(caCode);

% Create CA code for VHDL
lenCAWord = ceil(lenCACode / 32);
CAWord = string(zeros(32, 2));
CAWordChar = char(zeros(32, 2));
for i = 1: lenCAWord
    % Spilt by word
    t = caCode((i - 1) * 32 + 1 : (i - 0) * 32);
    % Convert to string
    t = mat2str(t);
    t = t(2 : end -1);
    % Map to VHDL
    if mappingEnable
        t = strrep(t,'1','#');
        t = strrep(t,'0','1');
        t = strrep(t,'#','0');
    end
    t = strrep(t,' ','');
    % Make it big endian
    t = reverse(t);
    % Feed  bin to vector
    CAWord(i, 2) = t;
    % Convert to Hex
    t = dec2hex(bin2dec(t), 8);
    % Feed hex to vector
    CAWord(i, 1) = t;
    fprintf('x"%s",\n', t);
end
% disp();
fprintf("\nGENERATE CA CODE DONE");

% Generate VHDL type string

% preCharX = repmat('X', lenCAWord, 1);
% charQuote = repmat('''', lenCAWord, 1);
% output = convertStringsToChars([preCharX charQuote CAWord(:, 1) charQuote]);
