image_names = getAllFiles(['./all-images/']);
subjects = {'1H';'1L';'2H';'2L';'3H';'3L';'4L'};

for i = 1:size(image_names)
    image_name = image_names(i);
    image_name = image_name{1};
    disp(image_name);
    info = imfinfo(image_name);
    [pathstr, name, ext] = fileparts(image_name);
    combined_mask = zeros(info.Height/2, info.Width/2);
    
    for n = 1:length(subjects)
        subject = subjects(n);
        subject = subject{1};
        image_path = ['./fixation-maps/' subject '/' name ext];
        %disp(image_path);
        if exist(image_path)
            subject_image = imread(image_path);
            combined_mask = imfuse(combined_mask, subject_image, 'blend');
        end
    end
    
    composite = imread(image_name);
    disp(size(composite));
    composite = imresize(composite, 0.5);
    disp(size(composite(:,:,1)));
    disp(size(combined_mask));
    composite(:,:,1) = composite(:,:,1) + combined_mask*2;
    imwrite(composite, ['./fixation-maps/combined/' name ext]);
end
