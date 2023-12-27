%% Use a 2d median filter to bring out the features of images

ims = dir('*.png');
mkdir superResolution
ims = natsortfiles(ims);
first_im = imread(ims(1).name);
superResolution = zeros(size(first_im,1),size(first_im,2),length(ims));
for ii = 1:length(ims)
    mean_image = mat2gray(imread(ims(ii).name));

    diameter   = [12 12];
    parameter  = [6 -6];

    % from superResolution function:
    meanImageFiltered = medfilt2(mean_image,(diameter)*4+1);

    %remove noise with 2d median filter
    meanImageSub        = mean_image - meanImageFiltered;
    meanImageFiltered_2 = medfilt2(abs(meanImageSub),(diameter)*4+1); %empty?

    meanImageDiv   = meanImageSub ./ (1e-10 + meanImageFiltered_2); %r
    meanImageDiv_2 = meanImageSub ./ (1e+10 + meanImageFiltered_2);%empty?

    meanImageEnh = (meanImageDiv - parameter(2)) / (parameter(1) - parameter(2)); %r
    meanImageEnh = max(0,min(1,meanImageEnh)); %r

    meanImageEnh_2 = (meanImageDiv_2 - parameter(2)) / (parameter(1) - parameter(2));
    meanImageEnh_2 = mat2gray(max(0,min(1,meanImageEnh_2)));

    meanImageEnh_2 = imadjust(meanImageEnh_2);
    meanImageEnh_2 = medfilt2(meanImageEnh_2,abs(parameter));

    II = meanImageEnh + meanImageEnh_2; %r

    superResolution(:,:,ii) = II;
    imwrite(II,['superResolution\',ims(ii).name(1:end-4),'_superResolution.png'])
end