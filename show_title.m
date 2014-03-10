function [] = show_title( title, screen_number, window )

    % Aseta otiskoissa k?ytett?v? fontti
    Screen('TextFont', window, 'Courier New');
    Screen('TextSize', window, 28);
    Screen('TextStyle', window, 1+2);

    [screen_width, screen_height] = Screen('WindowSize', screen_number);
    screen_padding = 200;

    % Piirr? otsikko
    [nx, ny, bbox] = DrawFormattedText(window, title{1}, ...
        'center', 'center', 0, 100 ); % Keskit? teksti ruudulle

    % N?yt? puskuroitu kuva
    Screen('Flip', window);

end

