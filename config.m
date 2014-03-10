function [ params ] = config()

% Testiss? k?ytett?v? kuvaresoluutio
params.resolution = 'high';

% Kuvakansio
params.image_dir = './images';

% Otsikon n?ytt?aika sekunteina
params.title_show_time = 0.2;

% Kuvien n?ytt?aika sekunteina
params.image_show_time = 0.2;

% Seurantadatan tallennuskansio
params.save_path = 'C:\tracking.idf'

end

