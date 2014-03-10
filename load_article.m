function [ title, images, image_names ] = load_article( path, resolution )

    % Lue artikkelin otsikko
    title = textread(strcat(path, '/', 'title.txt'), '%s', ...
        'delimiter', '\n');
    
    % Lue kansion kuvatiedostot
    image_path = strcat(path, '/', resolution);
    image_files = dir(strcat(image_path, '/', '*.jpg'));
    
    % Luo taulukko kuville
    images = cell(1, numel(image_files));
    image_names = cell(1, numel(image_files));

    % Lue kuvat taulukkoon
    for i = 1:numel(image_files)
        image_name = image_files(i).name;
        path = strcat(image_path, '/', image_name);
        image_names{i} = image_name;
        images{i} = imread(path);
    end

end

