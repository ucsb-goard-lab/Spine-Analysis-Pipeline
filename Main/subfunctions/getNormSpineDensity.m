ims = dir('*.png');
microns = 51.8;

% Get length of dendrite in microns
first_name = ims(1).name;
% first_im = imread(['binarized/',first_name(1:end-4),...
%     '_binarized.png']);
first_im = imread(['binarized/',first_name(1:end-4),...
    '_binarized.png']);
skel1 = bwskel(first_im,'MinBranchLength',100); % skeletonize
se = strel('disk',15);
dil = imdilate(skel1,se); % dilate to smooth
skeleton = bwmorph(dil,'thin',inf); % reskeletonize

pixel_length = length(find(skeleton)); % length of dendrite in pixels
micron_ratio = microns/length(first_im); % every pixel is X microns
micron_length = pixel_length*micron_ratio; % length of dendrite in microns

spine_density = zeros(1,length(ims)); % save number of spines per 10 um
cd data
dnames = dir('*.mat');
for ii = 1:length(ims)
    spine_data = importdata(dnames(ii).name);
    curr_spine_density = size(spine_data,1)/(micron_length/10); % spines per 10 microns
    spine_density(ii) = curr_spine_density;
end
cd ..

save('norm_spine_density.mat','spine_density')