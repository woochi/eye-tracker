clear classes
clc

conf = config();

%tracker = EyeTracker.instance();

% Lue artikkelikansion sis?lt?
image_dir = dir(conf.image_dir);

% Lue kaikki alakansioiden nimet (yksitt?iset artikkelit)
% Poista nykyinen ja yl?kansio (., ..)
subdirs = [image_dir(:).isdir];
articles = {image_dir(subdirs).name}; %
articles(ismember(articles, {'.','..'})) = [];

% Yhdist? seurantakameraan ja kalibroi
%tracker.initializeTracker();
%tracker.connect();
%tracker.calibrate()

try
    % Alusta n?ytt?
    Screen('Preference', 'SkipSyncTests', 1);
    %Screen('Preference', 'ConserveVRAM', 64);
    screens = Screen('Screens');
    screen =  max(screens);

    % Avaa ikkuna oletusasetuksilla
    window = Screen('OpenWindow', screen);
        
    % Aloita katseenseurannan tallentaminen
    %tracker.startRecording();
    
    for article = articles
        % Lue muistiin t?m?n artikkelin nimi ja kuvat
        article_dir = article{1};
        article_path = strcat(conf.image_dir, '/', article_dir);
        [title, images, image_names] = load_article(article_path, conf.resolution);

        % N?yt? artikkelin otsikko
        show_title(title, screen, window);
        pause(conf.title_show_time);
        
        %{
        for i = 1:length(images)
            Screen('PutImage', window, images{i}); % Piirr? kuva puskuriin
            % L?het? palvelimelle aikamerkki kuvan nimell?
            %tracker.setMarker(image_names{i});
            Screen('Flip', window); % N?yt? puskuroitu kuva
            pause(conf.image_show_time);
        end
        %}
        show_collage(images, screen, window);
        KbPressWait();
    end

    close all;
    Screen('CloseAll');
    
catch
    Screen('CloseAll');
    fclose('all');
    psychrethrow(psychlasterror);
end

% Tallenna seurantadata ja sulje yhteys
%tracker.stopRecording();
%tracker.saveData('recording');
%tracker.disconnect();
