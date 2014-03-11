  clear classes
clc

conf = config();

tracker = EyeTracker.instance();

% Lue artikkelikansion sisÃ¤ltÃ¶
image_dir = dir(conf.image_dir);

% Lue kaikki alakansioiden nimet (yksittÃ¤iset artikkelit)
% Poista nykyinen ja ylÃ¤kansio (., ..)
subdirs = [image_dir(:).isdir];
articles = {image_dir(subdirs).name}; %
articles(ismember(articles, {'.','..'})) = [];

% YhdistÃ¤ seurantakameraan ja kalibroi
tracker.initializeTracker();
tracker.connect();
%tracker.calibrate();

try
    % Alusta nÃ¤yttÃ¶
    % Screen('Preference', 'SkipSyncTests', 1);
    %  Screen('Preference', 'ConserveVRAM', 64);
    screens = Screen('Screens');
    screen =  max(screens);

    % Avaa ikkuna oletusasetuksilla
    window = Screen('OpenWindow', screen);
        
    % Aloita katseenseurannan tallentaminen
    tracker.startRecording();
    
    for article = articles
        % Lue muistiin tÃ¤mÃ¤n artikkelin nimi ja kuvat
        article_dir = article{1};
        article_path = strcat(conf.image_dir, '/', article_dir);
        [title, images, image_names] = load_article(article_path, conf.resolution);
 
        % NÃ¤ytÃ¤ artikkelin otsikko
        show_title(title, screen, window);
        pause(conf.title_show_time);
        
        for i = 1:length(images)
            % LÃ¤hetÃ¤ palvelimelle aikamerkki kuvan nimellÃ¤
            tracker.setMarker(image_names{i});
            
            % PiirrÃ¤ kuva puskuriin
            texture = Screen('MakeTexture', window, images{i});
            Screen('DrawTexture', window, texture);
            
            % NÃ¤ytÃ¤ puskuroitu kuva
            Screen('Flip', window);
            pause(conf.image_show_time); 
        end
        
        show_collage(images, screen, window);
        KbPressWait();
    end
    
catch
    Screen('CloseAll');
    ShowCursor
    psychrethrow(psychlasterror);
end

tracker.stopRecording();
tracker.saveData(conf.save_path, conf.user);

% Sulje ikkuna
Screen('CloseAll');
ShowCursor

% Sulje yhteys
tracker.disconnect();
