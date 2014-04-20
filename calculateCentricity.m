clear ALL;

circleRadius = 10;
circleColor = 255;
outputImageSize = [512 512]; % Width, height
files = getAllFiles('./mapped-fixation-data/');

centricity = zeros(1, 100);
fixationTotal = 0;

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
        matSize = size(mapped_fixations);
        fixationTotal = fixationTotal + matSize(1);
        
        for p = 1:100
            sum = 0;
            matSize = size(mapped_fixations);
            for f = 1:matSize(1)
                if mapped_fixations(f, 3) <= p
                    sum = sum + 1;
                end
            end
            centricity(p) = centricity(p) + sum;
        end
    end
end

centricity = centricity / fixationTotal * 100;
plot(centricity);
xlabel('% kuvan keskipisteest? suuremman dimension reunaan');
ylabel('% kokonaisfiksaatioista');

clear ALL;
