files = getAllFiles('./sample-data/');

sampleCount = 0;

for i = 1:length(files)
    file = files{i};
    fileInfo = dir(file);
    if ~isempty(strfind(fileInfo.name, '.mat'))
        load(file, 'fixations');
        samples = [];
        sampleCount = sampleCount + length(fixations);
        for j = 1:length(fixations)
            sample = fixations(j);
            if (sample.lporx > 0)&&(sample.lpory > 0)&&(sample.rporx > 0)&&(sample.rpory > 0)
                samples = [samples; sample];
            end
        end
        save(['./filtered-sample-data/' fileInfo.name], 'samples');
    end
end

disp(sampleCount);

clear ALL;
