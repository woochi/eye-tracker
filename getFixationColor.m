function [ color ] = getFixationColor( subject )

switch subject
    case '1H'
        color = [255 0 0];
    case '1L'
        color = [0 255 0];
    case '2H'
        color = [0 128 255];
    case '2L'
        color = [204 204 0];
    case '3H'
        color = [0 204 204];
    case '3L'
        color = [127 0 255];
    case '4L'
        color = [255 0 127];
end

end

