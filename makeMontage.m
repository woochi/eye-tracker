[fileName, pathName, filterIndex] = uigetfile({'*.jpg'}, 'Select montage images', 'MultiSelect', 'on');

image_size = [300 300];
disp(fileName);
if iscell(fileName)
    disp(fileName);
    disp(fileName(1));
    disp(fileName{1});
    for n = 1:length(fileName)
        fileName(n) = ['./fixation-point-maps/' fileName];
    end
    fisp(fileName);
    for n = 1:length(fileName)
        image = montage(['./fixation-point-maps/' fileName]);
    end
elseif fileName ~= 0
    nbfiles = 1;
else
    nbfiles = 0;
end
