files = getAllFiles('./fixation-data/');

% Stimulus screen size
screenWidth = 1920;
screenHeight = 1200;

sampleCount = 0;
fixationTotal = 0;
lowFixationCount = 0;
highFixationCount = 0;

for i = 1:length(files)
    file = files{i};
    fileInfo = dir(file);
    if ~isempty(strfind(fileInfo.name, '.mat'))
        load(file, 'fixations');
        
        % Parse image name from file name
        [subject, remain] = strtok(fileInfo.name, '.');
        [image, remain] = strtok(remain, '.');
        [extension, remain] = strtok(remain, '.');
        
        imageName = [image '.' extension];
        imageInfo = imfinfo(['./all-images/' imageName]);
        imageHeight = imageInfo.Height;
        imageWidth = imageInfo.Width;
        bigDimension = max([imageWidth imageHeight]);
        
        % Map and filter fixations based on image size
        mapped_fixations = [];
        fixationCount = size(fixations);
        for j = 1:fixationCount(1)
            xoffset = (screenWidth - imageWidth) / 2;
            yoffset = (screenHeight - imageHeight) / 2;
            x = floor(fixations(j,1) - xoffset);
            y = floor(fixations(j,2) - yoffset);
            
            % If the fixation is inside the image area
            if (x > 0)&&(x <= imageWidth)&&(y > 0)&&(y <= imageHeight)
                % Store the image mapped fixations
                centerDistance = pdist([imageWidth*0.5 imageHeight*0.5; x y]);
                centerPercentage = floor(centerDistance / (bigDimension * 0.5) * 100);
                mapped_fixations = [mapped_fixations; x y centerPercentage];
            end
        end
        
        matSize = size(mapped_fixations);
        fixationTotal = fixationTotal + matSize(1);
        if ~isempty(strfind(fileInfo.name, 'H.'))
            highFixationCount = highFixationCount + matSize(1);
        elseif ~isempty(strfind(fileInfo.name, 'L.'))
            lowFixationCount = lowFixationCount + matSize(1);
        end
        save(['./mapped-fixation-data/' fileInfo.name], 'mapped_fixations');
    end
end

disp(highFixationCount);
disp(lowFixationCount);
disp(fixationTotal);

clear ALL;
