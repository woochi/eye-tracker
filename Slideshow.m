clear classes
clc

conf = config();

%tracker = EyeTracker.instance();

% Lue artikkelikansion sis????lt????
image_dir = dir(conf.image_dir);

% Lue kaikki alakansioiden nimet (yksitt????iset artikkelit)
% Poista nykyinen ja yl????kansio (., ..)
subdirs = [image_dir(:).isdir];
ordered_articles = {image_dir(subdirs).name}; %
ordered_articles(ismember(ordered_articles, {'.','..'})) = [];
permutation = randperm(length(ordered_articles));
articles = ordered_articles(permutation);

% Yhdist???? seurantakameraan ja kalibroi
tracker.initializeTracker();
tracker.connect();
tracker.calibrate();

try
    % Alusta n????ytt????
    Screen('Preference', 'SkipSyncTests', 1);
    % Screen('Preference', 'ConserveVRAM', 64);
    screens = Screen('Screens');
    screen =  max(screens);

    % Avaa ikkuna oletusasetuksilla
    window = Screen('OpenWindow', screen);
    HideCursor();
        
    % Aloita katseenseurannan tallentaminen
    tracker.startRecording();
    
    % Lataa keskimarkkerikuva
    marker_image = imread([conf.image_dir '/' conf.marker_image]);
    marker_texture = Screen('MakeTexture', window, marker_image);

    % N?yt? aloitusviesti
    tracker.setMarker('initial');
    [nx, ny, bbox] = DrawFormattedText(window, ...
        'Paina mit? tahansa n?pp?int? n?ytt??ksesi ensimm?isen uutisotsikon', ...
        'center', 'center', 0, 100 ); % Keskit? teksti ruudulle
    Screen('Flip', window);
    
    for article = articles
        % Lue muistiin t????m????n artikkelin nimi ja kuvat
        article_dir = article{1};
        article_path = strcat(conf.image_dir, '/', article_dir);
        [title, images, image_names] = load_article(article_path, conf.resolution);
 
        % N????yt???? artikkelin otsikko
        tracker.setMarker('title');
        show_title(title, screen, window);
        pause(conf.title_show_time);

        for i = 1:length(images)
            % N?yt? keskimarkkeri          
            tracker.setMarker('centermarker');
            Screen('DrawTexture', window, marker_texture);
            Screen('Flip', window);
            pause(conf.marker_show_time);                                                        
            
            % L????het???? palvelimelle aikamerkki kuvan nimell????
            tracker.setMarker(image_names{i});
            
            % Piirr???? kuva puskuriin
            texture = Screen('MakeTexture', window, images{i});
            Screen('DrawTexture', window, texture);
            
            % N????yt???? puskuroitu kuva
            Screen('Flip', window);
            pause(conf.image_show_time); 
        end
        
        % N?yt? montaasi artikkelin kuvista
        tracker.setMarker('collage');
        show_collage(title, images, screen, window);
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
