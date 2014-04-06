[fileName, pathName, filterIndex] = uigetfile({'*.jpg'}, 'Select montage images', 'MultiSelect', 'on');

image_size = [300 300];

if iscell(fileName)
    for n = 1:length(fileName)
        image = montage(fileName);
    end
elseif fileName ~= 0
    nbfiles = 1;
else
    nbfiles = 0;
end
