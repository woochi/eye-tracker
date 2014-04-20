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
        function parsedSamples = parse(obj, filename)
            parsedSamples = [];
            [path, name, ext] = fileparts(filename);
            subject = name;
            
            % Avaa tiedosto
            [fid, error] = fopen(filename);
            if error
                disp(error)
                return
            end
            
            % Lue tiedoston loppuun asti
            marker = readHeader(fid);
            while size(marker) > 0
                [imageInfo, imageName, startTime] = getImageInfoFromMarker(marker);
                [marker, samples] = parseSampleBlock(fid, subject, imageName, startTime);
                if ~isempty(fieldnames(imageInfo))
                    blockSize = size(samples);
                    disp(['Parsed ' sprintf('%u', blockSize(1)) ' samples for: ' subject ' ' imageName]);
                    parsedSamples = [parsedSamples; samples];
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

function [nextMarker, samples] = parseSampleBlock(fid, subject, imageName, startTime)
    % Read image-specific fixation data.
    % Returns the next marker line if available.
    IMAGE_SHOW_TIME = 5000000;
    sampleTime = startTime;
    line = fgets(fid);
    nextMarker = [];
    samples = [];

    while ischar(line)
        [sampleTime, type, trial, data] = getData(line);
        if strcmp(type, 'MSG')
            nextMarker = line;
            break;
        elseif strcmpi(imageName(2), '9') && sampleTime - startTime > IMAGE_SHOW_TIME
            line = fgets(fid);
            continue;
        elseif strcmp(type, 'SMP')
            sample = parseSample(data);
            sample.subject = subject;
            sample.image = imageName;
            samples = [samples; sample];
        end

        line = fgets(fid);
    end
end

function [time, type, trial, data] = getData(line)
    % Separate message time, type, trial no. and data to separate fields.
    data = line;
    [timestamp, data] = strtok(data);
    [type, data] = strtok(data);
    [trial, data] = strtok(data);
    time = str2num(timestamp);
end

function [isComment] = isComment(line)
    % Check if the line is a comment row
    isComment = false;
    isComment = strcmp(line(1), '#');
end

function [sample] = parseSample(line)
    values = sscanf(line, '%f');
    fields = {'lrx', 'lry', 'rrx', 'rry', ... % Raw eye coordinates (px)
        'lcr1x', 'lcr1y', 'lcr2x', 'lcr2y', ... % Left CR 1 + 2 (px)
        'rcr1x', 'rcr1y', 'rcr2x', 'rcr2y', ... % Right CR 1 + 2 (px)
        'lporx', 'lpory', 'rporx', 'rpory', ... % Point of regard (px)
        'timing', 'latency', 'lvalid', 'rvalid', 'confidence', ...
        'hposx', 'hposy', 'hposz', ... % Head position (mm)
        'hrotx', 'hroty', 'hrotz', ... % Head rotation (deg)
        'leposx', 'leposy', 'leposz', ... % Left eye position (mm)
        'reposx', 'reposy', 'reposz', ... % Right eye position (mm)
        'lgvecx', 'lgvecy', 'lgvecz', ... % Left gaze vector
        'rgvecx', 'rgvecy', 'rgvecz' % Right gaze vector
        };
    sample = struct;
    fieldCount = size(fields);
    for i = 1:fieldCount(2)
        field = fields(1:i);
        sample.(field{i}) = values(i);
    end
end

function [info, fileName, startTime] = getImageInfoFromMarker(line)
    [startTime, type, trial, data] = getData(line);
    [a, data] = strtok(data);
    [b, data] = strtok(data);
    [fileName, data] = strtok(data);
    path = ['./all-images/' fileName];
    if exist(path, 'file')
        info = imfinfo(['./all-images/' fileName]);
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
