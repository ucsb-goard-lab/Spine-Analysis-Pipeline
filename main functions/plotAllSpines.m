figure
imshow(curr_im)
hold on
for ii = 1:length(new_centers)
    curr_center = new_centers(ii,:);
    plot(curr_center(1),curr_center(2),'o')
end

ims = dir('*.png');
ims = natsortfiles(ims); 
first_im = imread(ims(1).name);
 % avg_ims = zeros(size(first_im,1),size(first_im,2),length(ims)); % initiate 3d array of all averaged and binary images
 superResolution_ims = zeros(size(first_im,1),size(first_im,2),length(ims)); 
% binary_ims = zeros(size(first_im,1),size(first_im,2),length(ims));
for ii = 1:length(ims)
    curr_im = imread(ims(ii).name);
    double_im = im2double(curr_im);
    superResolution_ims(:,:,ii) = double_im;
end

data = dir('*.mat');
data = natsortfiles(data); 
all_spine_data = cell(length(ims),1);
for ii = 1:length(ims)
    curr_data = importdata(data(ii).name);
    all_spine_data{ii} = curr_data;
end

figure
for i = 1:length(ims)
    for ii = 1:size(avg_spines,4)
        curr_spine = avg_spines(:,:,i,ii);
        imshow(curr_spine)
        pause
    end
end

figure
for i = 1:length(ims)
    curr_im = binary_ims(:,:,i);
    imshow(curr_im)
    pause
end

figure
for i = 1:size(avg_timeseries,3)
    curr_spine = binary_timeseries(:,:,i);
    subplot(1,size(binary_timeseries,3),i)
    imshow(curr_spine)
end

figure
for i = 1:size(binary_registered,3)
    curr_spine = binary_registered(:,:,i);
    subplot(1,size(binary_registered,3),i)
    imshow(curr_spine)
end