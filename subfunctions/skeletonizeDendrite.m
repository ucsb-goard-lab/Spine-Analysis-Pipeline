function image_skeleton = skeletonizeDendrite(BW)
%skeletonizeDendrite creates an image skeleton of a binarized image of
%dendritic branch using morpgological operations and filtering

image_skeleton   = bwmorph(BW,'thin',inf);

filter = [1 1 1 ;
    1 0 1 ;
    1 1 1 ];

imageDisconnect = image_skeleton & ~(image_skeleton & conv2(double(image_skeleton), filter, 'same') > 2);
CC            = bwconncomp(imageDisconnect);
numPixels     = cellfun(@numel,CC.PixelIdxList);
[sorted, ind] = sort(numPixels);

threshold2     = 8;
for i = ind(sorted < threshold2)
    cur_comp = CC.PixelIdxList{i};
    image_skeleton(cur_comp) = 1;
end

%image_skeleton    = bwmorph(image_skeleton, 'spur', 2);

end

