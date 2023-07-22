clc;
clear;

vhdlHexPRN = 'FF7BAD12';
vhdlPRN = dec2bin(hex2dec(vhdlHexPRN), 32);
vhdlPRN = strrep(vhdlPRN,' ','');
vhdlPRN = strrep(vhdlPRN,'1','2');
vhdlPRN = strrep(vhdlPRN,'0','1');
vhdlPRN = strrep(vhdlPRN,'2','0');
vhdlPRN = reverse(vhdlPRN)

PRNId = 1;
rawCaCode = generateCAcode(PRNId);
caCode = rawCaCode;
% Mapping
caCode(caCode == -1) = 0;
caCode = mat2str(caCode);
caCode = strrep(caCode,' ','');
caCode = caCode(2 : end -1);

k = strfind(caCode, vhdlPRN)

code = gnssCACode(PRNId,'GPS');


% 11001000001110010100100111100101 00010011111010101101000100010101 01011001000111101001111110110111 00110111110010101010000100000000111010100
% 11001000001110010100100111100101 00010011111010100101000110010101 01011001100111101001111100110111 
