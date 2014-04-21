files = getAllFiles('./data/samples-filtered/');

% How many samples to include in initial window.
% Ideal sample window should include samples from a duration of 100-200ms.
% Used sampling speed is 60Hz => 1000ms / 60ms * 9 = 200ms.
window_size = 9;

% Dispersion threshold should be a visual angle of 0.5 deg - 1.5 deg.
% The corresponding pixel count is:
% V = 2*arctan(S/2D)     || V = Visual angle (1.5 deg = 0.0261799388 rad)
%                           S = Linear size of angle
%                           D = Distance to screen (70mm)
% S = 18.327 (mm)
% Pixels in length of 18.327 mm on a 24'' 1920x1200 screen =>  92 px

dispersion_threshold = 92; % px
fixationCount = 0; % Counter

for i = 1:length(files)
    file = files{i};
    fileInfo = dir(file);
    if ~isempty(strfind(fileInfo.name, '.mat'))
        load(file, 'filteredSamples');
        matSize = size(filteredSamples);
        sampleCount = matSize(1);
        fixations = [];

        start_index = 1;
        end_index = window_size;
        while end_index <= sampleCount
            % Initialize window
            window = filteredSamples(start_index:end_index);
            
            % Calculate window dispersion
            d = dispersion(window);
            
            % If dispersion below threshold
            if d <= dispersion_threshold
                % While dispersion is below threshold increase window size
                while (d <= dispersion_threshold) && (end_index + 1 <= sampleCount)
                    end_index = end_index + 1;
                    window = filteredSamples(start_index:end_index);
                    d = dispersion(window);
                end
                
                % Note a new fixation at the centroid of window points
                [x, y] = centroid(window);
                fixations = [fixations; x y];
                
                % Set new window limits
                start_index = end_index;
                end_index = start_index + window_size;
            else
                % Shrink window from the start
                start_index = start_index + 1;
            end
        end
        
        
        matSize = size(fixations);
        fixationCount = fixationCount + matSize(1);
        save(['./data/fixations/' fileInfo.name], 'fixations');
    end
end

disp(fixationCount);

clear ALL;
