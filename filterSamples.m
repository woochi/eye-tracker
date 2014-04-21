files = getAllFiles('./data/samples/');

sampleCount = 0;

for i = 1:length(files)
    file = files{i};
    fileInfo = dir(file);
    if ~isempty(strfind(fileInfo.name, '.mat'))
        load(file, 'samples');
        filteredSamples = [];
        filteredSampleCount = size(samples);
        sampleCount = sampleCount + filteredSampleCount(1);
        for j = 1:filteredSampleCount(1)
            sample = samples(j);
            if (sample.lporx > 0)&&(sample.lpory > 0)&&(sample.rporx > 0)&&(sample.rpory > 0)
                filteredSamples = [filteredSamples; sample];
            end
        end
        save(['./data/samples-filtered/' fileInfo.name], 'filteredSamples');
    end
end

disp(sampleCount);

clear ALL;
