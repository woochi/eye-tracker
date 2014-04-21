parser = Parser;
samples = [];

for n = 1:7
    [filename, path] = uigetfile('*.txt', 'Select ASCII data file');
    parser.parse([path filename]);
end

clear ALL;
