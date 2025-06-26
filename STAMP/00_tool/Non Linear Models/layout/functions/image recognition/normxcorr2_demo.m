% Demo to use normxcorr2 to find a template (a white onion)
% in a larger image (of a pile of vegetables)
clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
imtool close all;  % Close all imtool figures.
clear;  % Erase all existing variables.
workspace;  % Make sure the workspace panel is showing.
format long g;
format compact;
fontSize = 20;

% Check that user has the Image Processing Toolbox installed.
hasIPT = license('test', 'image_toolbox');
if ~hasIPT
	% User does not have the toolbox installed.
	message = sprintf('Sorry, but you do not seem to have the Image Processing Toolbox.\nDo you want to try to continue anyway?');
	reply = questdlg(message, 'Toolbox missing', 'Yes', 'No', 'Yes');
	if strcmpi(reply, 'No')
		% User said No, so exit.
		return;
	end
end

% Read in a standard MATLAB color demo image.
folder = fullfile(matlabroot, '\toolbox\images\imdemos');
baseFileName = 'peppers.png';
% Get the full filename, with path prepended.
fullFileName = fullfile(folder, baseFileName);
if ~exist(fullFileName, 'file')
	% Didn't find it there.  Check the search path for it.
	fullFileName = baseFileName; % No path this time.
	if ~exist(fullFileName, 'file')
		% Still didn't find it.  Alert user.
		errorMessage = sprintf('Error: %s does not exist.', fullFileName);
		uiwait(warndlg(errorMessage));
		return;
	end
end
rgbImage = imread(fullFileName);
% Get the dimensions of the image.  numberOfColorBands should be = 3.
[rows, columns, numberOfColorBands] = size(rgbImage);
% Display the original color image.
subplot(2, 2, 1);
imshow(rgbImage, []);
axis on;
caption = sprintf('Original Color Image, %d rows by %d columns.', rows, columns);
title(caption, 'FontSize', fontSize);
% Enlarge figure to full screen.
set(gcf, 'units','normalized','outerposition',[0, 0, 1, 1]);

% Let's get our template by extracting a small portion of the original image.
templateWidth = 71
templateHeight = 49
smallSubImage = imcrop(rgbImage, [192, 82, templateWidth, templateHeight]);
% Get the dimensions of the image.  numberOfColorBands should be = 3.
[rows, columns, numberOfColorBands] = size(smallSubImage);
subplot(2, 2, 2);
imshow(smallSubImage, []);
axis on;
caption = sprintf('Template Image to Search For, %d rows by %d columns.', rows, columns);
title(caption, 'FontSize', fontSize);

% Ask user which channel (red, green, or blue) to search for a match.
% channelToCorrelate = menu('Correlate which color channel?', 'Red', 'Green', 'Blue');
% It actually finds the same location no matter what channel you pick, 
% for this image anyway, so let's just go with red (channel #1).
% Note: If you want, you can get the template from every color channel and search for it in every color channel,
% then take the average of the found locations to get the overall best location.
channelToCorrelate = 1;  % Use the red channel.
tic
correlationOutput = normxcorr2(smallSubImage(:,:,1), rgbImage(:,:, channelToCorrelate));
toc
subplot(2, 2, 3);
imshow(correlationOutput, []);
axis on;
% Get the dimensions of the image.  numberOfColorBands should be = 1.
[rows, columns, numberOfColorBands] = size(correlationOutput);
caption = sprintf('Normalized Cross Correlation Output, %d rows by %d columns.', rows, columns);
title(caption, 'FontSize', fontSize);

% Find out where the normalized cross correlation image is brightest.
[maxCorrValue, maxIndex] = max(abs(correlationOutput(:)));
[yPeak, xPeak] = ind2sub(size(correlationOutput),maxIndex(1))
% Because cross correlation increases the size of the image, 
% we need to shift back to find out where it would be in the original image.
corr_offset = [(xPeak-size(smallSubImage,2)) (yPeak-size(smallSubImage,1))]

% Plot it over the original image.
subplot(2, 2, 4); % Re-display image in lower right.
imshow(rgbImage);
axis on; % Show tick marks giving pixels
hold on; % Don't allow rectangle to blow away image.
% Calculate the rectangle for the template box.  Rect = [xLeft, yTop, widthInColumns, heightInRows]
boxRect = [corr_offset(1) corr_offset(2) templateWidth, templateHeight]
% Plot the box over the image.
rectangle('position', boxRect, 'edgecolor', 'g', 'linewidth',2);
% Give a caption above the image.
title('Template Image Found in Original Image', 'FontSize', fontSize);
uiwait(helpdlg('Done with demo!'));


%% Find buses by bus image

% Demo to use normxcorr2 to find a template (a white onion)
% in a larger image (of a pile of vegetables)
clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
imtool close all;  % Close all imtool figures.
clear;  % Erase all existing variables.
workspace;  % Make sure the workspace panel is showing.
format long g;
format compact;
fontSize = 11;



% Read in a standard MATLAB color demo image.
fullFileName  = 'IEEE-118-bus-test-system.png';
smallFileName = 'bus.png';

rgbImage = imread(fullFileName);
% Get the dimensions of the image.  numberOfColorBands should be = 3.
[rows, columns, numberOfColorBands] = size(rgbImage);
% Display the original color image.
subplot(2, 2, 1);
imshow(rgbImage, []);
axis on;
caption = sprintf('Original Color Image, %d rows by %d columns.', rows, columns);
title(caption, 'FontSize', fontSize);
% Enlarge figure to full screen.
set(gcf, 'units','normalized','outerposition',[0, 0, 1, 1]);


smallSubImage = imread(smallFileName);
% Get the dimensions of the image.  numberOfColorBands should be = 3.
[templateHeight, templateWidth , numberOfColorBands] = size(smallSubImage);
subplot(2, 2, 2);
imshow(smallSubImage, []);
axis on;
caption = sprintf('Template Image to Search For, %d rows by %d columns.', templateHeight, templateWidth);
title(caption, 'FontSize', fontSize);

% Ask user which channel (red, green, or blue) to search for a match.
% channelToCorrelate = menu('Correlate which color channel?', 'Red', 'Green', 'Blue');
% It actually finds the same location no matter what channel you pick, 
% for this image anyway, so let's just go with red (channel #1).
% Note: If you want, you can get the template from every color channel and search for it in every color channel,
% then take the average of the found locations to get the overall best location.
channelToCorrelate = 1;  % Use the red channel.
tic
correlationOutput = normxcorr2(smallSubImage(:,:,1), rgbImage(:,:, channelToCorrelate));
toc
subplot(2, 2, 3);
imshow(correlationOutput, []);
axis on;
% Get the dimensions of the image.  numberOfColorBands should be = 1.
[rows, columns, numberOfColorBands] = size(correlationOutput);
caption = sprintf('Normalized Cross Correlation Output, %d rows by %d columns.', rows, columns);
title(caption, 'FontSize', fontSize);

% Find out where the normalized cross correlation image is brightest.
[maxCorrValue, maxIndex] = max(abs(correlationOutput(:)));


% Find all buses
[sortedX, sortedInds] = sort(abs(correlationOutput(:)),'descend');
top118 = sortedInds(1:118);
[yPeak, xPeak] = ind2sub(size(correlationOutput),top118);

% Because cross correlation increases the size of the image, 
% we need to shift back to find out where it would be in the original image.
corr_offset_118 = [(xPeak-size(smallSubImage,2)) (yPeak-size(smallSubImage,1))];

% Plot it over the original image.
subplot(2, 2, 4); % Re-display image in lower right.
imshow(rgbImage);
axis on; % Show tick marks giving pixels
hold on; % Don't allow rectangle to blow away image.
for bus = 1:length(corr_offset_118)
    corr_offset = corr_offset_118(bus,:);
    % Calculate the rectangle for the template box.  Rect = [xLeft, yTop, widthInColumns, heightInRows]
    boxRect = [corr_offset(1) corr_offset(2) templateWidth, templateHeight]
    % Plot the box over the image.
    rectangle('position', boxRect, 'edgecolor', 'g', 'linewidth',2);
    hold on
end

% Give a caption above the image.
title('Template Image Found in Original Image', 'FontSize', fontSize);


%% Find buses by number image

% Demo to use normxcorr2 to find a template (a white onion)
% in a larger image (of a pile of vegetables)
clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
imtool close all;  % Close all imtool figures.
clear;  % Erase all existing variables.
workspace;  % Make sure the workspace panel is showing.
format long g;
format compact;
fontSize = 11;


% Read in a standard MATLAB color demo image.
fullFileName  = 'IEEE-118-bus-test-system.png';
smallFileName = 'bus.png';

rgbImage = imread(fullFileName);
% Get the dimensions of the image.  numberOfColorBands should be = 3.
[rows, columns, numberOfColorBands] = size(rgbImage);
% Display the original color image.
subplot(2, 2, 1);
imshow(rgbImage, []);
axis on;
caption = sprintf('Original Color Image, %d rows by %d columns.', rows, columns);
title(caption, 'FontSize', fontSize);
% Enlarge figure to full screen.
set(gcf, 'units','normalized','outerposition',[0, 0, 1, 1]);


smallSubImage = imread(smallFileName);
% Get the dimensions of the image.  numberOfColorBands should be = 3.
[templateHeight, templateWidth , numberOfColorBands] = size(smallSubImage);
subplot(2, 2, 2);
imshow(smallSubImage, []);
axis on;
caption = sprintf('Template Image to Search For, %d rows by %d columns.', templateHeight, templateWidth);
title(caption, 'FontSize', fontSize);

% Ask user which channel (red, green, or blue) to search for a match.
% channelToCorrelate = menu('Correlate which color channel?', 'Red', 'Green', 'Blue');
% It actually finds the same location no matter what channel you pick, 
% for this image anyway, so let's just go with red (channel #1).
% Note: If you want, you can get the template from every color channel and search for it in every color channel,
% then take the average of the found locations to get the overall best location.
channelToCorrelate = 1;  % Use the red channel.
tic
correlationOutput = normxcorr2(smallSubImage(:,:,1), rgbImage(:,:, channelToCorrelate));
toc
subplot(2, 2, 3);
imshow(correlationOutput, []);
axis on;
% Get the dimensions of the image.  numberOfColorBands should be = 1.
[rows, columns, numberOfColorBands] = size(correlationOutput);
caption = sprintf('Normalized Cross Correlation Output, %d rows by %d columns.', rows, columns);
title(caption, 'FontSize', fontSize);

% Find out where the normalized cross correlation image is brightest.
[maxCorrValue, maxIndex] = max(abs(correlationOutput(:)));


% Find all buses
[sortedX, sortedInds] = sort(abs(correlationOutput(:)),'descend');
top118 = sortedInds(1:118);
[yPeak, xPeak] = ind2sub(size(correlationOutput),top118);


% Because cross correlation increases the size of the image, 
% we need to shift back to find out where it would be in the original image.
corr_offset_118 = [(xPeak-size(smallSubImage,2)) (yPeak-size(smallSubImage,1))];

% Plot it over the original image.
subplot(2, 2, 4); % Re-display image in lower right.
imshow(rgbImage);
axis on; % Show tick marks giving pixels
hold on; % Don't allow rectangle to blow away image.
for bus = 1:length(corr_offset_118)
    corr_offset = corr_offset_118(bus,:);
    % Calculate the rectangle for the template box.  Rect = [xLeft, yTop, widthInColumns, heightInRows]
    boxRect = [corr_offset(1) corr_offset(2) templateWidth, templateHeight]
    % Plot the box over the image.
    rectangle('position', boxRect, 'edgecolor', 'g', 'linewidth',2);
    hold on
end

% Give a caption above the image.
title('Template Image Found in Original Image', 'FontSize', fontSize);
uiwait(helpdlg('Done with demo!'));
