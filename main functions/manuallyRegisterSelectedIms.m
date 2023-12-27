function [] = manuallyRegisterSelectedIms()
%% Manually register selected dendrites
%-------------------------------------------------------------------------%
%   This function finds the average offset between image skeletons, and if
%   it is greater than a specified threshold asks the user to manually
%   re-register that image. 
%
%   Written by NSW 10/27/2023 // Last updated by NSW 10/27/2023
%-------------------------------------------------------------------------%

reg_thresh = 15; % average pixel difference to qualify for re-registration
maxOffset = 25;
overwrite = 1;

ims = dir('*.png');
imnames = natsortfiles({ims.name});

figure('Position',[50 100 500 500]) % show first 4 images and ask which you would like to register to
for ii = 1:4
    subplot(2,2,ii)
    curr_im = imread(imnames{ii});
    imshow(curr_im)
    title(['Image #',num2str(ii)])
end
prompt = 'Which image would you like to register to?';
dlgtitle = 'Input';
fieldsize = [1 45];
definput = {'1','Fixed Image'};
answer = inputdlg(prompt,dlgtitle,fieldsize,definput);

fixed = imread(cell2mat(imnames(str2double(answer{1}))));
close all

fixed_binary = imbinarize(fixed);
f_skeleton = bwskel(fixed_binary);
f_skeleton_major = bwareaopen(f_skeleton,10); % remove extraneous pixels

moving_indices = 1:length(ims);
moving_indices(str2double(answer{1})) = []; % get rid of fixed image
skeleton_diff_vecs = zeros(size(fixed,1),length(ims)-1); 
for ii = 1:length(moving_indices)
    moving = imread(imnames{moving_indices(ii)});
    m_binary = imbinarize(moving);
    m_skeleton2 = bwskel(m_binary);
    m_skeleton_major = bwareaopen(m_skeleton2,10); % remove extraneous pixels
    diff_vec = zeros(size(moving,1),1);
    for i = 1:size(moving,1) % get difference between fixed and moving skeleton at every x point and average to get diff idx
        fixed_row = find(f_skeleton_major(i,:));
        moving_row = find(m_skeleton_major(i,:));
        if ~isempty(fixed_row) && ~isempty(moving_row) % as long as there is a point
            diff_vec(i) = abs(mean(fixed_row)-mean(moving_row)); % get diff between average points
        end
    end
    skeleton_diff_vecs(:,ii) = diff_vec;
end
avg_skeleton_diff = mean(skeleton_diff_vecs);
registration_idx = find(avg_skeleton_diff > reg_thresh);
ims2register = moving_indices(registration_idx);

% moving = struct; %set up input data structure for subroutine
% moving.numFrames = 1;
% moving.xPixels = size(m_binary,1);
% moving.yPixels = size(m_binary,2);

% Register
for rr = 1:length(ims2register)
    mname = cell2mat(imnames(ims2register(rr)));
    curr_moving = imread(mname); % filenames of moving files
    [registered, ~, ~] = subroutine_manualAnchorPoints(fixed, curr_moving);
    delete(mname) % delete old image
    imwrite(registered,[mname(1:end-4) '_reregistered.png']) % save newly registered image
end