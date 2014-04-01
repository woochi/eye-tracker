function [ params ] = config()

% Testiss? k?ytett?v? kuvaresoluutio
params.resolution = 'low';

% Kuvakansio
params.image_dir = './images';

% Otsikon n?ytt?aika sekunteina
params.title_show_time = 0.2;

% Kuvien n?ytt?aika sekunteina
params.image_show_time = 0.2;

% Tarkennuskuvan n?ytt?aika sekununteina
params.marker_show_time = 0.2;

% Tarkennuskuvan nimi
params.marker_image = 'marker.jpg';

% Seurantadatan tallennuskansio
params.save_path = 'C:\';

end

