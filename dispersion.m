function dispersion = dispersion(samples)
%DISPERSION Calculate dispersion value for a sample window
%   Takes in an array of samples and calculates a dispersion value for
%   the sample POR (point of regard) coordinates.

    % Set initial values based on the first point
    sample = samples(1);
    minx = (sample.lporx + sample.rporx) * 0.5;
    maxx = (sample.lporx + sample.rporx) * 0.5;
    miny = (sample.lpory + sample.lporx) * 0.5;
    maxy = (sample.lpory + sample.lporx) * 0.5;
    
    % Find the sample window max and min coordinates.
    for i = 1:length(samples)
        sample = samples(i);
        porx = (sample.lporx + sample.rporx) * 0.5;
        pory = (sample.lpory + sample.lporx) * 0.5;
        
        if porx < minx
            minx = porx;
        end
        if porx > maxx
            maxx = porx;
        end
        if pory < miny
            miny = pory;
        end
        if pory > maxy
            maxy = pory;
        end
    end

    % Calculate dispersion as a sum of x and y change.
    dispersion = (maxx - minx) + (maxy - miny);
end
