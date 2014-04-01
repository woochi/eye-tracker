classdef Parser
    % Luokka RED silm?nliikekameran datan lukemiseen ASCII-tiedostosta.
    
    properties
    end
    
    methods(Access = private)
        function [empty] = isEmpty(file_name)
            finfo = dir(file_name);
            fsize = finfo.bytes;
            empty = fsize <= 0;
        end
    end
    
    methods
        % Lue silm?nliikedata tiedostosta.
        function parse(obj, file_path)
            %disp(file_path);
            
            % Avaa tiedosto
            [fid, error] = fopen(file_path);
            if error
                disp(error)
                return
            end
            
            % Lue tiedoston loppuun asti
            marker = readHeader(fid);
            while size(marker) > 0
                %disp(marker);
                [image_info, filename] = getImageInfoFromMarker(marker);
                [marker, fixations] = readFixations(fid);
                if ~isempty(fieldnames(image_info))
                    %disp(image_info.Filename);
                    img_size = [image_info.Height image_info.Width];
                    img_width = img_size(1);
                    img_height = img_size(2);
                    [X, Y] = mapFixations(fixations, img_width, img_height);
                    attention_map = createAttentionMap(X, Y, img_size);
                    imwrite(attention_map, ['./fixation-maps/' filename], 'png');
                end
            end
            
            % Sulje tiedosto
            fclose(fid);
        end
    end
    
end

function [nextMarker] = readHeader(fid)
    % Read header data and any preceding non-image-specific fixations.
    % Returns the first marker line if available.
    line = fgets(fid);
    nextMarker = [];

    while ischar(line)
        if isComment(line)
            line = fgets(fid);
            continue;
        end
        [time, type, trial, data] = getData(line);
        if strcmp(type, 'MSG')
            nextMarker = line;
            break;
        end
        line = fgets(fid);
    end
end

function [nextMarker, fixations] = readFixations(fid)
    % Read image-specific fixation data.
    % Returns the next marker line if available.
    line = fgets(fid);
    nextMarker = [];
    fixations = [];

    while ischar(line)
        [time, type, trial, data] = getData(line);
        if strcmp(type, 'MSG')
            nextMarker = line;
            break;
        elseif strcmp(type, 'SMP')
            [lx, ly] = parseData(data);
            fixations = [fixations; lx ly];
        end

        line = fgets(fid);
    end
end

function [time, type, trial, data] = getData(line)
    % Separate message time, type, trian no. and data to separate fields.
    data = line;
    [time, data] = strtok(data);
    [type, data] = strtok(data);
    [trial, data] = strtok(data);
end

function [isComment] = isComment(line)
    % Check if the line is a comment row
    isComment = false;
    isComment = strcmp(line(1), '#');
end

function [lx, ly, rx, ry] = parseData(line)
    values = sscanf(line, '%f');
    lx = values(13);
    ly = values(14);
    rx = values(15);
    ry = values(16);
end

function [info, file_name] = getImageInfoFromMarker(line)
    [time, type, trial, data] = getData(line);
    [a, data] = strtok(data);
    [b, data] = strtok(data);
    [file_name, data] = strtok(data);
    path = ['./all-images/' file_name];
    if exist(path, 'file')
        info = imfinfo(['./all-images/' file_name]);
    else
        info = struct();
    end
end

function [X, Y] = mapFixations(fixations, img_width, img_height)
    % Map screen coordinate fixations to image coordinates.
    % Ignores fixations outside the image.
    % Returns X and Y coordinates as separate arrays.
    screen_width = 1920;
    screen_height = 1280;
    X = [];
    Y = [];
    dimensions = size(fixations);
    for row = 1:dimensions(1)
        x = round(fixations(row, 1) - (screen_width - img_width)/2);
        y = round(fixations(row, 2) - (screen_height - img_height)/2);
        if (x > 0 && y > 0 && x <= img_width && y<= img_width)
            X = [X; x];
            Y = [Y; y];
        end
    end
end

function [attention_map] = createAttentionMap(X, Y, img_size)
    % standard deviation of the Gaussian filter for attention maps - it has
    % been set such that the width of the Gaussian filter at half its maximum
    % height approximates the size of the foveal span of a viewer in the
    % current experimental setup (display physical dimensions 474x297mm,
    % display resolution 1680x1050 pixels, viewing distance 620mm, )
    sig = 4.0; 
    % size of the Gaussian filter - 76/2 = 38 pixels equals one degree
    % viewing angle
    h = 76;
    % Gaussian filter
    psf = fspecial('gaussian', h, sig);
    
    mask = makeFixationMask(X, Y, img_size, img_size/2);
    attention_map = imfilter(mask, psf);
end
