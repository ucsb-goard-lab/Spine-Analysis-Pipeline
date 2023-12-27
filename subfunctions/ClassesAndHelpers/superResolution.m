function [I, meanImageEnh] = superResolution(mean_image,parameter,diameter)

meanImage = mat2gray(mean_image);

meanImageFiltered   = medfilt2(meanImage,(diameter)*4+1);
meanImageSub        = meanImage - meanImageFiltered;
meanImageFiltered_2 = medfilt2(abs(meanImageSub),(diameter)*4+1);

meanImageDiv   = meanImageSub ./ (1e-10 + meanImageFiltered_2);
meanImageDiv_2 = meanImageSub ./ (1e+10 + meanImageFiltered_2);

meanImageEnh = (meanImageDiv - parameter(2)) / (parameter(1) - parameter(2));
meanImageEnh = max(0,min(1,meanImageEnh));

meanImageEnh_2 = (meanImageDiv_2 - parameter(2)) / (parameter(1) - parameter(2));
meanImageEnh_2 = mat2gray(max(0,min(1,meanImageEnh_2)));

meanImageEnh_2 = imadjust(meanImageEnh_2);
meanImageEnh_2 = medfilt2(meanImageEnh_2,[6 6]);

I = meanImageEnh + meanImageEnh_2;

end