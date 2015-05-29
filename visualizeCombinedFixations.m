clear ALL;

circleRadius = 10;
circleColor = [255 0 0];
outputImageSize = [512 512]; % Width, height
files = getAllFiles('./data/fixations-mapped/');
combinedFixations = containers.Map;

letters = ['a'; 'b'; 'c'; 'd'; 'e'; 'f'; 'g'; 'h'; 'i'];

for n = 1:length(letters)
    for i = 0:9
        fileName = [letters(n) num2str(i)];
        for j = 1:length(files)
            file = files{j};
            if ~isempty(strfind(file, fileName)) && isempty(strfind(file, '1L'))
                [path, name, ~] = fileparts(file);
                load(file, 'mappedFixations');
                subject = [name(1) name(2)];
                subjectColor = getFixationColor(subject);
                matSize = size(mappedFixations);
                for f = 1:matSize(1)
                    fixation = {};
                    fixation.color = subjectColor;
                    fixation.position = [mappedFixations(f, 1) mappedFixations(f, 2)];
                    if combinedFixations.isKey(fileName)
                        combinedFixations(fileName) = [combinedFixations(fileName); fixation];
                    else
                        combinedFixations(fileName) = [fixation];
                    end
                end
            end
        end
    end
end

%{
for i = 1:length(files)
    file = files{i};
    fileInfo = dir(file);
    if ~isempty(strfind(fileInfo.name, '.mat'))
        load(file, 'mappedFixations');
        
        % Parse image name from file name
        [subject, remain] = strtok(fileInfo.name, '.');
        [image, remain] = strtok(remain, '.');
        [extension, remain] = strtok(remain, '.');
        
        imageName = [image '.' extension];
        
        % Combined fixations for image
        if ~isempty(combinedFixations{imageName})
            combinedFixations{imageName} = [combinedFixations{imageName}; mappedFixations];
        else
            combinedFixations{imageName} = mappedFixations;
        end
    end
end
%}

disp(combinedFixations('a0'));

for n = 1:length(letters)
    for i = 0:9
        imageId = [letters(n) num2str(i)];
        imageName = [imageId '_h.jpg'];
        disp(imageName);
        imagePath = ['./all-images/' imageName];
        imageInfo = imfinfo(imagePath);

        im = imread(imagePath);
        resizedImage = imresize(im, [outputImageSize(2) outputImageSize(1)]);
        xscale = outputImageSize(1) / imageInfo.Width;
        yscale = outputImageSize(2) / imageInfo.Height;

        mappedFixations = combinedFixations(imageId);
        % Draw fixation points onto image
        fixationCount = size(mappedFixations);
        for j = 1:fixationCount(1)
            fixation = mappedFixations(j);
            x = round(fixation.position(1) * xscale);
            y = round(fixation.position(2) * yscale);
            resizedImage = drawCircle(resizedImage, x, y, circleRadius, fixation.color, true);
            resizedImage = drawCircle(resizedImage, x, y, circleRadius, [0 0 0], false);
        end

        % Save image with fixations
        imwrite(resizedImage, ['./fixation-images-combined/' imageId '.jpg'], 'jpg');
    end
end

clear ALL;
