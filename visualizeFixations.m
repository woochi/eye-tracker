clear ALL;

circleRadius = 10;
circleColor = [255 0 0];
outputImageSize = [512 512]; % Width, height
files = getAllFiles('./data/fixations-mapped/');

for i = 1:length(files)
    file = files{i};
    fileInfo = dir(file);
    if ~isempty(strfind(fileInfo.name, '.mat'))
        load(file, 'mappedFixations');
        
        % Parse image name from file name
        [subject, remain] = strtok(fileInfo.name, '.');
        [imageName, remain] = strtok(remain, '.');
        [extension, remain] = strtok(remain, '.');
        
        fullImageName = [imageName '.' extension];
        imagePath = ['./all-images/' fullImageName];
        imageInfo = imfinfo(imagePath);
        
        im = imread(imagePath);
        resizedImage = imresize(im, [outputImageSize(2) outputImageSize(1)]);
        xscale = outputImageSize(1) / imageInfo.Width;
        yscale = outputImageSize(2) / imageInfo.Height;
        
        % Draw fixation points onto image
        fixationCount = size(mappedFixations);
        for j = 1:fixationCount(1)
            x = round(mappedFixations(j,1) * xscale);
            y = round(mappedFixations(j,2) * yscale);
            resizedImage = drawCircle(resizedImage, x, y, circleRadius, [255 0 0], true);
            resizedImage = drawCircle(resizedImage, x, y, circleRadius, [0 0 0], false);
        end
        
        % Save image with fixations
        imwrite(resizedImage, ['./fixation-images/' subject '.' fullImageName], 'jpg');
    end
end

clear ALL;
