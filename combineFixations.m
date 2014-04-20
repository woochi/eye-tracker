image_names = getAllFiles(['./all-images/']);
subjects = {'1H';'1L';'2H';'2L';'3H';'3L';'4L'};

for i = 1:size(image_names)
    image_name = image_names(i);
    image_name = image_name{1};
    disp(image_name);
    info = imfinfo(image_name);
    [pathstr, name, ext] = fileparts(image_name);
    combined_mask = zeros(info.Height/2, info.Width/2);
    
    imwrite(composite, ['./fixations-combined/' name ext]);
end
