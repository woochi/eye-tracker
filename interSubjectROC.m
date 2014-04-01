function [intersubj_roc_area, intersubj_roc_x, intersubj_roc_y] = interSubjectROC(fixationdatafile, mapsize, duration)

% INPUT PARAMETERS
%   FIXATIONDATAFILE filename <string>, including path, of the fixation datafile with data
%   for one image (all subjects).
%   MAPSIZE <1x2 int> attention maps and fixation masks will be scaled to
%   this size
%   DURATION <1x2 int> what temporal part of fixation data will be included in the analysis, 
%   e.g. [0 5] --> entire five seconds, [0 1] only first second, [4 5] only last second

% According to Harel et al. (2006) Graph-Based Visual Saliency:
% A single subject's fixation points are taken as targets at a time. A
% saliency map is formed from the fixations of all other subjects. With the
% target points being set to the fixations of the first subject, an ROC
% area is computed for that single subject. The mean of these ROC area
% values for all subjects is termed "inter-subject ROC value".

% The function calculates the inter-subject ROC value for each image and
% also draws an ROC curve from the mean values of all images

% standard deviation of the Gaussian filter for attention maps - it has
% been set such that the width of the Gaussian filter at half its maximum
% height approximates the size of the foveal span of a viewer in the
% current experimental setup (display physical dimensions 474x297mm,
% display resolution 1680x1050 pixels, viewing distance 620mm, )
sig = 16.14; 
% size of the Gaussian filter - 76/2 = 38 pixels equals one degree
% viewing angle
h = 76; 
% Gaussian filter
psf = fspecial('gaussian', h, sig);

% FIXATIONS is a matrix of fixations with subject ID in first column, x
% coord in second column and y coord in third column - the function
% FIXATIONSVECTOR only gets the accurate fixations for color image data
[fixations, X, Y, imnum] = fixationsVector(fixationdatafile, duration);

[group1, group2] = getParticipants;    
if ( imnum < 51 )       
    subjects = group1;
elseif ( imnum > 50 )   
    subjects = group2;  
end

% text file with columns IMAGE NUMBER, IMAGE WIDTH, IMAGE HEIGHT
[dpath,dname,dext] = fileparts(fixationdatafile);
info = dlmread(fullfile(dpath,'../','imagesizes.txt'));
imgwidth = info(info(:,1)==imnum,2);
imgheight = info(info(:,1)==imnum,3);

ROC = zeros(length(subjects),1);

% for each subject
for s=1:length(subjects)
    
    currentsubj = subjects(s);
    % fprintf('Processing subject %g...\n', currentsubj);
    
    % coordinate vectors for the fixations of the current subject
    Xcurrent = fixations(fixations(:,1)==currentsubj,2);
	Ycurrent = fixations(fixations(:,1)==currentsubj,3);

    % check if any fixations are found for current subject
    if ~isempty(Xcurrent)
    
        % create target mask of the fixations of the current subject 
        currentsubjmask = makeFixationMask( Xcurrent , Ycurrent , [imgheight imgwidth] , mapsize );
        currentsubjmask = imresize(currentsubjmask, mapsize);        

        % get coordinates of the fixations of all but the current subject
        Xothers = fixations(fixations(:,1)~=currentsubj,2);
        Yothers = fixations(fixations(:,1)~=currentsubj,3);

        % create attentionmap of the fixations of the rest of the subjects
        othersmask = makeFixationMask( Xothers , Yothers , [imgheight imgwidth] , mapsize );
        othersmask = imresize(othersmask, mapsize);
        othersattmap = imfilter(othersmask, psf);
        othersattmap = imresize(othersattmap, mapsize);
        % scale to 0-1
        othersattmap = othersattmap - min(min(othersattmap));
        othersattmap = othersattmap / max(max(othersattmap));

        % calculate ROC value
        [a, p] = rocSal( othersattmap , currentsubjmask );
        [x, y] = rocCurve( p, 'r' );
        roccurve_x(:,s) = x;
        roccurve_y(:,s) = y;             
    else
        % if no fixations found for the current subject
        a = NaN;
    end

    % fprintf('\tROC area value is : %3.3f\n', a);
    ROC(s) = a;

end

% "inter-subject ROC value" is calculated as the mean of ROC area
% values for all subjects
intersubj_roc_area = mean(ROC(~isnan(ROC)));
fprintf('\tIntersubject ROC area value is : %3.3f\n', intersubj_roc_area );
intersubj_roc_x = mean(roccurve_x,2);
intersubj_roc_y = mean(roccurve_y,2);
% line(intersubj_roc_x, intersubj_roc_y, 'Color','b','Marker','.');


