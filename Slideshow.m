clear classes
clc

conf = config();

%tracker = EyeTracker.instance();

% Lue artikkelikansion sisältö
image_dir = dir(conf.image_dir);

% Lue kaikki alakansioiden nimet (yksittäiset artikkelit)
% Poista nykyinen ja yläkansio (., ..)
subdirs = [image_dir(:).isdir];
articles = {image_dir(subdirs).name}; %
articles(ismember(articles, {'.','..'})) = [];

% Yhdistä seurantakameraan ja kalibroi
tracker.initializeTracker();
tracker.connect();
tracker.calibrate()

try
    % Alusta näyttö
    Screen('Preference', 'SkipSyncTests', 1);
    %Screen('Preference', 'ConserveVRAM', 64);
    screens = Screen('Screens');
    screen =  max(screens);

    % Avaa ikkuna oletusasetuksilla
    window = Screen('OpenWindow', screen);
        
    % Aloita katseenseurannan tallentaminen
    %tracker.startRecording();
    
    for article = articles
        % Lue muistiin tämän artikkelin nimi ja kuvat
        article_dir = article{1};
        article_path = strcat(conf.image_dir, '/', article_dir);
        [title, images, image_names] = load_article(article_path, conf.resolution);

        % Näytä artikkelin otsikko
        show_title(title, screen, window);
        pause(conf.title_show_time);
        
        for i = 1:length(images)
            Screen('PutImage', window, images{i}); % Piirrä kuva puskuriin
            % Lähetä palvelimelle aikamerkki kuvan nimellä
            %tracker.setMarker(image_names{i});
            Screen('Flip', window); % Näytä puskuroitu kuva
            pause(conf.image_show_time);
        end
        
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
tracker.stopRecording();
tracker.saveData(conf.save_path);
tracker.disconnect();
