% import EyeTracker

% tracker = EyeTracker.instance();

images_dir = dir('./images');
subdirs = [images_dir(:).isdir];
articles = {images_dir(subdirs).name};
articles(ismember(articles,{'.','..'})) = [];

% Connect to the eye tracker
% tracker.initializeTracker();
% tracker.connect();

% Select whether to run the high or low resolution test

try
    Screen('Preference', 'SkipSyncTests', 1);
    screens = Screen('Screens');
    screenNumber =  max(screens);

    % Open window with default settings:
    w = Screen('OpenWindow', screenNumber);
    
    [screen_width, screen_height] = Screen('WindowSize', screenNumber);
    screen_padding = 200;
    
    for article = articles
        article_name = article{1};
        
        % Select specific text font, style and size:
        Screen('TextFont', w, 'Courier New');
        Screen('TextSize', w, 28);
        Screen('TextStyle', w, 1+2);
        
        % Display news title as text
        [nx, ny, bbox] = DrawFormattedText(w, article_name, ... 
            screen_width/2 - screen_padding*2, ... % Frame x coordinate
            screen_height/2, ... % Frame y coordinate
            0, 100 );
    
        % Show computed text bounding box:
        %          Screen('FrameRect', w, 0, bbox);

        Screen('Flip',w);
        KbStrokeWait; % TODO: replace with sleep in actual implementation

        % tracker.calibrate()
        % tracker.startTracking()
        
        for i = 0:9
            % tracker.setMarker(marker)
            image = imread(strcat('./images/', article_name, '/', num2str(i), '.jpg'), 'jpg');
            Screen('PutImage', w, image); % put image on screen
            Screen('Flip',w); % now visible on screen
            KbStrokeWait;
        end
    end

    close all;
    Screen('CloseAll');
    
catch %#ok<*CTCH>
    % This "catch" section executes in case of an error in the "try"
    % section []
    % above.  Importantly, it closes the onscreen window if it's open.
    Screen('CloseAll');
    fclose('all');
    psychrethrow(psychlasterror);
end

% Save tracking data to a file and disconnect
% tracker.stopRecording()
% tracker.saveData(filename)
% tracker.disconnect();
