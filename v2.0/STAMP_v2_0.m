%% STAMP v2.0: Spatial Transcript Abundance Mapping Pipeline
% Spatial mapping of HCR RNA FISH intensity in developing chick retina.
%
% This script processes one TIFF image and its corresponding mask. It
% calculates mean intensity within spatial blocks and generates normalized
% intensity maps and 1-D intensity profiles along the image axes.
%
% The user selects the high-acuity area (HAA) center to define the spatial
% origin (0,0). The selected origin can be saved and reused for later runs.
%
% PREPARE THE INPUTS
%   1. Crop and orient the retina image in ImageJ so that the TN axis
%      corresponds to the image x-axis and the DV axis to the image y-axis.
%   2. Create a mask with the same dimensions as the image. The mask should
%      identify the region to include in the analysis and exclude areas
%      such as background.
%   3. Save the image and mask as TIFF files.
%
% INPUTS
%   1. A cropped TIFF image.
%   2. A matching TIFF mask with the same image dimensions.
%   3. Pixel size and block size, set below in the user-defined parameters.
%
% OUTPUTS
%   An "Analyzed" folder containing intensity maps, profile plots, image
%   strips, an Excel workbook of profile measurements, and saved origin
%   coordinates.
%
% REQUIREMENTS
%   - MATLAB R2020b or later.
%   - Image Processing Toolbox (for blockproc).
%   - Colormap functions used by this script: viridis, plasma, cbrewer2,
%     fake_parula, and magma.
%   - cbrewer2 also requires COLORSPACE for its default interpolation.
%
% VERSION
%   STAMP v2.0
%   Written by CP
%   Updated 11 August 2025

clc;  % Clear the command window
close all;  % Close all figure windows
clear all;  % Clear all variables from the workspace

%% 1. Select input files and set analysis parameters (User input steps)

% Add bundled third-party colormap functions.
% Expected location: code/third_party/ relative to this script.
scriptDir = fileparts(mfilename('fullpath'));
thirdPartyDir = fullfile(scriptDir, 'third_party');

if exist(thirdPartyDir, 'dir') == 7
    addpath(genpath(thirdPartyDir));
else
    warning('Third-party folder not found: %s', thirdPartyDir);
end

% Select files - Folder, Image and Mask file

% Select the folder containing the image and mask.
dirName = uigetdir(pwd, 'Select the folder containing the image and mask');
if isequal(dirName, 0)
    error('STAMP:NoFolderSelected', 'No folder was selected.');
end

% Select the retina image.
[fileName, filePathName] = uigetfile( ...
    {'*.tif;*.tiff', 'TIFF images (*.tif, *.tiff)'}, ...
    'Select the retina image', dirName);

if isequal(fileName, 0)
    error('STAMP:NoImageSelected', 'No image was selected.');
end
imagePath = fullfile(filePathName, fileName);

% Select the matching mask.
[maskName, maskPathName] = uigetfile( ...
    {'*.tif;*.tiff', 'TIFF images (*.tif, *.tiff)'}, ...
    'Select the matching mask image', filePathName);

if isequal(maskName, 0)
    error('STAMP:NoMaskSelected', 'No mask was selected.');
end
maskPath = fullfile(maskPathName, maskName);

[~, defaultBaseName, ~] = fileparts(fileName);

prompt = {'Enter name for the image file:'};
dlgtitle = 'Input for Name_file';
dims = [1 50];
definput = {defaultBaseName};
answer = inputdlg(prompt, dlgtitle, dims, definput);

if isempty(answer)
    Name_file = defaultBaseName;
else
    Name_file = answer{1};
end

Name_file_column = [Name_file '_col_norm'];
Name_file_row = [Name_file '_row_norm'];

analyzedDir = fullfile(dirName, 'Analyzed');
if ~exist(analyzedDir, 'dir')
    mkdir(analyzedDir);
end

% Set pixel size (user input, in micrometers)
pixel = 0.3248; % 1 / 3.0717;

% Set averaging block size (25X25, 50X50, 100X100)
block_size = 25;

% Prompt user to select a colormap
colormapOptions = {'viridis', 'plasma', 'cbrewer2 (PRGn)', 'fake_parula', 'turbo', 'magma'};

[selectionIndex, tf] = listdlg(...
    'PromptString', 'Select a colormap:', ...
    'SelectionMode', 'single', ...
    'ListString', colormapOptions, ...
    'InitialValue', find(strcmp(colormapOptions, 'magma')));  % Default selection

if ~tf
    selectedMap = 'magma';
else
    selectedMap = colormapOptions{selectionIndex};
end

switch selectedMap
    case 'viridis'
        cmap = viridis();
    case 'plasma'
        cmap = plasma();
    case 'cbrewer2 (PRGn)'
        cmap = cbrewer2('PRGn', 256);
    case 'fake_parula'
        cmap = fake_parula();
    case 'turbo'
        cmap = turbo;
    case 'magma'
        cmap = magma();
end

% Read Data
data = imread(imagePath);

% Read Masks
mask{1} = uint16(imread(maskPath));

%% 2. Prepare data for analysis : Extract Mask Size and Binarize Masks

% 2a. Create an array to store the dimensions of each mask
size_sample = [];  % Array to hold the sizes of masks

for i = 1:length(mask)
    % Store the size of each mask in size_sample
    size_sample(i,:) = size(mask{i});  
    
    % Normalize each mask by dividing by its maximum value
    mask{i} = mask{i} ./ max(mask{i});  
end
data = double(data.*mask{1});

data(data==0) = NaN;

% 2b. Plotting the density image
temp_mask2 = blockproc(data, [block_size block_size], @(b) nansum(b.data(:)));
divide_mask2 = blockproc(mask{1}, [block_size block_size], @(b) nansum(b.data(:)));

temp_mask2 = temp_mask2./divide_mask2;

% normalize data
temp_mask2 = (temp_mask2 - min(temp_mask2(:)))./(max(temp_mask2 (:)) - min(temp_mask2(:)));

figure; imagesc(temp_mask2);
axis equal;  % Set equal scaling for axes

% Add bblack for background
cmap=[0 0 0; cmap];
colormap(cmap)
colorbarHandle = colorbar; 

ylabel(colorbarHandle, 'Normalized Mean Intensity');  
xlim([1 size(temp_mask2, 2)]);  % Set x-axis limits
ylim([1 size(temp_mask2, 1)]);  % Set y-axis limits

% Set x-tick labels, multiplying by pixel size
xTicks = round([0, size(temp_mask2, 2)] * pixel * block_size);  % Min and max x-tick positions round to closest integer
yTicks = round([0, size(temp_mask2, 1)] * pixel * block_size);  % Min and max y-tick positions round to closest integer

set(gca, 'XTick', [1, size(temp_mask2, 2)]);  % Set the x-tick positions
set(gca, 'YTick', [1, size(temp_mask2, 1)]);  % Set the y-tick positions

% Set x-tick labels and append "µm" to the last tick
xTickLabels = {num2str(xTicks(1)), [num2str(xTicks(2)) ' µm']};  % Convert to micrometers
yTickLabels = {[num2str(yTicks(2)) ' µm'], num2str(yTicks(1))};  % Convert to micrometers

set(gca, 'XTickLabel', xTickLabels);  % Set x-tick labels based on pixel size
set(gca, 'YTickLabel', yTickLabels)  % Set x-tick labels based on pixel size

ax = gca;
exportgraphics(ax, fullfile(analyzedDir, [Name_file,'.tif']),'Resolution',300)
exportgraphics(ax, fullfile(analyzedDir, [Name_file,'.eps']),'Resolution',300)


% 2c. Plotting the density image : Column wise normalization
figure;

temp_mask2 = blockproc(data, [block_size block_size], @(b) nansum(b.data(:)));
divide_mask2 = blockproc(mask{1}, [block_size block_size], @(b) nansum(b.data(:)));

temp_mask2 = temp_mask2./divide_mask2;

% normalize data
temp_mask2 = (temp_mask2 - min(temp_mask2(:)))./(max(temp_mask2) - min(temp_mask2(:)));

imagesc(temp_mask2);
axis equal;  % Set equal scaling for axes
colormap(cmap)
colorbarHandle = colorbar;  % Add color bar and get handle
ylabel(colorbarHandle, 'Normalized Mean Intensity');  % Label the colorbar
xlim([1 size(temp_mask2, 2)]);  % Set x-axis limits
ylim([1 size(temp_mask2, 1)]);

% Set x-tick labels, multiplying by pixel size
xTicks = round([0, size(temp_mask2, 2)] * pixel * block_size);  % Min and max x-tick positions round to closest integer
yTicks = round([0, size(temp_mask2, 1)] * pixel * block_size);  % Min and max y-tick positions round to closest integer

set(gca, 'XTick', [1, size(temp_mask2, 2)]);  % Set the x-tick positions
set(gca, 'YTick', [1, size(temp_mask2, 1)]);  % Set the y-tick positions

% Set x-tick labels and append "µm" to the last tick
xTickLabels = {num2str(xTicks(1)), [num2str(xTicks(2)) ' µm']};  % Convert to micrometers
yTickLabels = {[num2str(yTicks(2)) ' µm'], num2str(yTicks(1))};  % Convert to micrometers

set(gca, 'XTickLabel', xTickLabels);  % Set x-tick labels based on pixel size
set(gca, 'YTickLabel', yTickLabels)  % Set x-tick labels based on pixel size

ax = gca;
exportgraphics(ax, fullfile(analyzedDir ,[Name_file_column,'.tif']),'Resolution',300)

% 2d. Plotting the density image: Row wise normalization
figure;

temp_mask2 = blockproc(data, [block_size block_size], @(b) nansum(b.data(:)));
divide_mask2 = blockproc(mask{1}, [block_size block_size], @(b) nansum(b.data(:)));

temp_mask2 = temp_mask2./divide_mask2;

%normalize data
temp_mask2 = temp_mask2';
temp_mask2 = (temp_mask2 - min(temp_mask2(:)))./(max(temp_mask2) - min(temp_mask2(:)));
temp_mask2 = temp_mask2';

imagesc(temp_mask2);
axis equal;  % Set equal scaling for axes
colormap(cmap)
colorbarHandle = colorbar;  % Add color bar and get handle
ylabel(colorbarHandle, 'Normalized Mean Intensity');  % Label the colorbar
xlim([1 size(temp_mask2, 2)]);  % Set x-axis limits
ylim([1 size(temp_mask2, 1)]);

% Set x-tick labels, multiplying by pixel size
xTicks = round([0, size(temp_mask2, 2)] * pixel * block_size);  % Min and max x-tick positions round to closest integer
yTicks = round([0, size(temp_mask2, 1)] * pixel * block_size);  % Min and max y-tick positions round to closest integer

set(gca, 'XTick', [1, size(temp_mask2, 2)]);  % Set the x-tick positions
set(gca, 'YTick', [1, size(temp_mask2, 1)]);  % Set the y-tick positions

% Set x-tick labels and append "µm" to the last tick
xTickLabels = {num2str(xTicks(1)), [num2str(xTicks(2)) ' µm']};  % Convert to micrometers
yTickLabels = {[num2str(yTicks(2)) ' µm'], num2str(yTicks(1))};  % Convert to micrometers

set(gca, 'XTickLabel', xTickLabels);  % Set x-tick labels based on pixel size
set(gca, 'YTickLabel', yTickLabels);  % Set x-tick labels based on pixel size

ax = gca;
exportgraphics(ax, fullfile(analyzedDir,[Name_file_row,'.tif']),'Resolution',300)

%% 3. Select the new origin (0,0), plot X and Y intensities.
temp_mask2 = blockproc(data, [block_size block_size], @(b) nansum(b.data(:)));
divide_mask2 = blockproc(mask{1}, [block_size block_size], @(b) nansum(b.data(:)));

temp_mask2 = temp_mask2 ./ divide_mask2;

% Normalize data
temp_mask2 = (temp_mask2 - min(temp_mask2(:))) ./ (max(temp_mask2(:)) - min(temp_mask2(:)));

% Define file name for saved origin coordinates
originFile = fullfile(analyzedDir,'origin_coords.mat');

% Check if the origin coordinate file exists
if exist(originFile, 'file')
    choice = questdlg('Use previously saved origin (0,0)?', ...
                      'Origin Selection', ...
                      'Use saved', 'Select new', 'Use saved');
    
    switch choice
        case 'Use saved'
            load(originFile, 'x_new_origin', 'y_new_origin');
            disp(['Loaded saved origin: (' num2str(x_new_origin) ', ' num2str(y_new_origin) ')']);
            
        case 'Select new'
            figure;
            imagesc(temp_mask2);
            axis equal;
            colormap(cmap)
            colorbarHandle = colorbar;
            ylabel(colorbarHandle, 'Normalized Mean Intensity');
            title('Click to select new origin (0,0)');
            
            [x_new_origin, y_new_origin] = ginput(1);
            title('');
            hold off;
            save(originFile, 'x_new_origin', 'y_new_origin');
            disp('New origin saved.');

    end

else
    figure;
    imagesc(temp_mask2);
    axis equal;
    colormap(cmap)
    colorbarHandle = colorbar;
    ylabel(colorbarHandle, 'Normalized Mean Intensity');
    title('Click to select new origin (0,0)');
    [x_new_origin, y_new_origin] = ginput(1);
    title('');
    hold off;

    save(originFile, 'x_new_origin', 'y_new_origin');
    disp('Origin saved.');
end

% Calculate new x and y offsets in terms of pixel positions
x_offset = x_new_origin * pixel * block_size;
y_offset = y_new_origin * pixel * block_size;

% Plot the new image with adjusted origin
figure;
imagesc(temp_mask2);
axis equal;  % Set equal scaling for axes
colormap(cmap)
colorbarHandle = colorbar;  % Add color bar and get handle
ylabel(colorbarHandle, 'Normalized Mean Intensity');  % Label the colorbar

% Set x-tick and y-tick labels, adjusting by the new origin
xTicks = round([0, size(temp_mask2, 2)] * pixel * block_size - x_offset);  % Min and max x-tick positions
yTicks = round([0, size(temp_mask2, 1)] * pixel * block_size - y_offset);  % Min and max y-tick positions

set(gca, 'XTick', [1, size(temp_mask2, 2)]);  % Set the x-tick positions
set(gca, 'YTick', [1, size(temp_mask2, 1)]);  % Set the y-tick positions

% Set x-tick labels and append "µm" to the last tick
xTickLabels = {[num2str(xTicks(1)) ' µm'], [num2str(xTicks(2)) ' µm']};  % Convert to micrometers
yTickLabels = {[num2str(yTicks(2)) ' µm'], [num2str(yTicks(1)) ' µm']};  % Convert to micrometers

set(gca, 'XTickLabel', xTickLabels);  % Set x-tick labels based on pixel size
set(gca, 'YTickLabel', yTickLabels);  % Set y-tick labels based on pixel size

% Calculate range in pixels for a 500 µm strip around the origin
pixel_range = round(500 / (pixel * block_size));  % Convert microns to pixel units

% Extract the image strip in x and y around the new origin
x_start = max(1, round(x_new_origin) - pixel_range / 2);
x_end = min(size(temp_mask2, 2), round(x_new_origin) + pixel_range / 2);
y_start = max(1, round(y_new_origin) - pixel_range / 2);
y_end = min(size(temp_mask2, 1), round(y_new_origin) + pixel_range / 2);

% Extract strips
x_strip = temp_mask2(:, x_start:x_end);
y_strip = temp_mask2(y_start:y_end, :);

% consider rows/columns which are atleast 80% non-NaN (to avoid edge
% effects)

x_data = x_strip;  % Rows = blocks, columns = positions
y_data = y_strip;   % Rows = positions, columns = blocks

% Calculate valid counts
x_valid_counts = sum(~isnan(x_data), 2); 
y_valid_counts = sum(~isnan(y_data), 1); 

% Total number of samples per profile
x_total = size(x_data, 2);
y_total = size(y_data, 1);

% Threshold for valid data
x_thresh = floor(0.80 * x_total);
y_thresh = floor(0.80 * y_total);

for i = 1: length(x_valid_counts)
    if x_valid_counts(i) < x_thresh
        x_data(i,:)= NaN(size(x_data(i,:)));
    end
end

for i = 1: length(y_valid_counts)
    if y_valid_counts(i) < y_thresh
        y_data(:,i)= NaN(size(y_data(:,i)));
    end
end

% Create 1D intensity profiles
x_profile = mean(x_data', 1, 'omitnan');
y_profile = mean(y_data', 2, 'omitnan');

% Calculate std
x_profile_std = std(x_data', 0, 1, 'omitnan');
y_profile_std = std(y_data', 0, 2, 'omitnan');

% Calculate SEM
x_valid_counts(x_valid_counts == 0) = NaN;
x_profile_sem = x_profile_std./sqrt(x_valid_counts');
y_valid_counts(y_valid_counts == 0) = NaN;
y_profile_sem = y_profile_std./sqrt(y_valid_counts');

% Plot the image strip in the Y direction and its 1D profile
figure;
imagesc(x_strip);
axis equal;
set(gca, 'XTick', [], 'YTick', []);
xlim([0.5 size(x_strip, 2) + 0.5]);
ylim([0.5 size(x_strip, 1) + 0.5]);             
colormap(cmap)
colorbarHandle = colorbar;  % Add color bar and get handle
ylabel(colorbarHandle, 'Normalized Mean Intensity');  % Label the colorbar
title('Y-direction Strip');

% Save the Y strip
ax = gca;
exportgraphics(ax, fullfile(analyzedDir, [Name_file, '_Y.tif']), 'Resolution', 300);

% Plot the image strip in the X direction and its 1D profile
figure;
imagesc(y_strip);
axis equal;
colormap(cmap)
set(gca, 'XTick', [], 'YTick', []);
xlim([0.5 size(y_strip, 2) + 0.5]);
ylim([0.5 size(y_strip, 1) + 0.2]);             
colormap(cmap)
colorbarHandle = colorbar;  % Add color bar and get handle
ylabel(colorbarHandle, 'Normalized Mean Intensity');  % Label the colorbar
title('X-direction Strip');

% Save the X strip
ax = gca;
exportgraphics(ax, fullfile(analyzedDir, [Name_file, '_X.tif']), 'Resolution', 300);

figure;
% subplot(1,4,1)
ax1 = axes('Position', [0.2, 0.2, 0.2, 0.6]);  % Define plot area (left, bottom, width, height)
h=errorbar(ax1,((1:size(x_profile, 2)) * pixel * block_size - y_offset), ...
    x_profile, x_profile_std, '-.', 'LineWidth', 0.01, 'Color', 'red','CapSize',0);
hold on;
plot(ax1,(1:size(x_profile, 2)) * pixel * block_size - y_offset, x_profile, 'k-', 'LineWidth', 0.75);
xline(0, '--');  
ylabel('Mean Intensity');
xlabel('Distance (µm)');
title(Name_file,'Interpreter','None');
x = ((1:size(x_profile, 2)) * pixel * block_size - y_offset);
xlim([round(min(x))-5 round(max(x)+5)]);
ylim([0 1.0]);
yticks([0 0.2 0.4 0.6 0.8 1]);
ytickangle(45);
% Add D and V labels to top-right and bottom-right corners
text(500, 0.2, 'V', ...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12, 'FontWeight', 'bold');
text(-500, 0.2, 'D', ...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12, 'FontWeight', 'bold');
view([90,90])

% Save the plots
ax = gca;
exportgraphics(ax, fullfile(analyzedDir, [Name_file, '_yplots.tif']), 'Resolution', 300);

figure;
ax1 = axes('Position', [0.2, 0.2, 0.6, 0.267]);  % Define plot area (left, bottom, width, height)
errorbar(ax1,(1:size(y_profile, 1)) * pixel * block_size - x_offset, ...
         y_profile, y_profile_std, '-.','LineWidth', 0.01, 'Color', 'red','CapSize',0);
hold on;
plot(ax1,(1:size(y_profile, 1)) * pixel * block_size - x_offset, ...
         y_profile, 'k-', 'LineWidth', 0.75);
xline(0, '--');
xlabel('Distance (µm)');
ylabel('Mean Intensity');
title(Name_file,'Interpreter','None');
x = ((1:size(y_profile, 1)) * pixel * block_size - x_offset);
xlim([round(min(x))-5 round(max(x)+5)]);
ylim([0 1.0]);
yticks([0 0.2 0.4 0.6 0.8 1]);
ytickangle(45);
% Add D and V labels to top-right and bottom-right corners
text(500, 0.2, 'N', ...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12, 'FontWeight', 'bold');
text(-500, 0.2, 'T', ...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12, 'FontWeight', 'bold');
% set(gca, 'Position',[0.2, 0.2, 0.6, 0.2])

% Save the plots
ax = gca;
exportgraphics(ax, fullfile(analyzedDir, [Name_file, '_xplots.tif']), 'Resolution', 300);

%% 4. Save data on excel sheet
x_distances = (1:size(x_profile, 2)) * pixel * block_size - y_offset;
y_distances = (1:size(y_profile, 1)) * pixel * block_size - x_offset;

x_profile_table = table(x_distances', x_profile', x_profile_std', x_profile_sem',...
    'VariableNames', {'Y_Distance_um', 'Y_Profile_MeanIntensity','Y_Std','Y_SEM'});

y_profile_table = table(y_distances', y_profile, y_profile_std, y_profile_sem,...
    'VariableNames', {'X_Distance_um', 'X_Profile_MeanIntensity','X_Std','X_SEM'});

excel_file = fullfile(analyzedDir,'intensity_profiles.xlsx');

writetable(x_profile_table, excel_file, 'Sheet', Name_file, 'Range', 'A1');
writetable(y_profile_table, excel_file, 'Sheet', Name_file, 'Range', 'E1');
