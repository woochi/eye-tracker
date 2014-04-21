clear ALL;

circleRadius = 10;
circleColor = 255;
outputImageSize = [512 512]; % Width, height
files = getAllFiles('./mapped-fixation-data/');

for i = 1:length(files)
    file = files{i};
    fileInfo = dir(file);
    if ~isempty(strfind(fileInfo.name, '.mat'))
        load(file, 'mapped_fixations');
        
        % Parse image name from file name
        [subject, remain] = strtok(fileInfo.name, '.');
        [image, remain] = strtok(remain, '.');
        [extension, remain] = strtok(remain, '.');
        
        imageName = [image '.' extension];
        imagePath = ['./all-images/' imageName];
        imageInfo = imfinfo(imagePath);
        
        im = imread(imagePath);
        resizedImage = imresize(im, [outputImageSize(2) outputImageSize(1)]);
        xscale = outputImageSize(1) / imageInfo.Width;
        yscale = outputImageSize(2) / imageInfo.Height;
        fig = figure('Position', [100, 100, outputImageSize(1), outputImageSize(2)]);
        set(fig, 'visible', 'off');
        set(gca, 'visible', 'off');
        set(gca,'xtick',[],'ytick',[])
        imshow(resizedImage);
        hold on;
        
        % Draw fixation points onto image
        fixationCount = size(mapped_fixations);
        for j = 1:fixationCount(1)
            x = mapped_fixations(j,1) * xscale;
            y = mapped_fixations(j,2) * yscale;
            drawCircle(x, y, circleRadius);
        end
        
        % Save image with fixations
        saveas(fig, ['./fixation-point-maps/' subject '.' imageName], 'jpg');
        hold off;
        close(fig);
    end
end

clear ALL;
