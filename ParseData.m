parser = Parser;
samples = [];
sampleCount = 0;

for n = 1:7
    [filename, path] = uigetfile('*.txt', 'Select ASCII data file');
    samples = [samples; parser.parse([path filename])];
    sampleSize = size(samples);
end

save(['./data/samples.mat'], 'samples');

clear ALL;
