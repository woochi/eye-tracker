parser = Parser;

[filename, path] = uigetfile('*.txt', 'Select ASCII data file');
parser.parse([path filename]);

clear ALL;
