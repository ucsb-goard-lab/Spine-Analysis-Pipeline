function dendriteLen = getDendriteLength(imageSkeleton,sBW,micrometers)
% Written by Marie Karpinska
% April 15, 2022
% input image Skeleton of Dendritic Branch and the size of BW (the image of
% the branch) 


% Configuring image skeleton and main branch of dendrite
mainBranch = bwmorph(imageSkeleton,'bridge',inf);
mainBranch = bwmorph(mainBranch,'spur',9);
mainBranch = bwmorph(mainBranch,'hbreak');
mainBranch = bwmorph(mainBranch,'thin');
mainBranch = bwmorph(mainBranch,'spur',50);
%imshowpair(imageSkeleton, mainBranch)

% Extending main branch to get spines at the end
addBack = imageSkeleton - mainBranch;
addBack = bwmorph(addBack,'thicken',1);
addBack = bwmorph(addBack,'diag',inf);
addBack = bwconncomp(addBack,4);
addBackVec = zeros(1,addBack.NumObjects); %initialize vector of size numObjects in addBack
for i = 1:addBack.NumObjects
    addBackVec(i) = length(addBack.PixelIdxList{i});  %put areas of connected objects into a vector
end

[~,idx1] = max((addBackVec),[],'linear');
addBackVec(idx1)= 0;
[~,idx2] = max(addBackVec,[], 'linear');

%If you get an error that says idx1 needs at least one valid index, then
%your binarization has failed. Check your BW image.
one = false(sBW);
one(addBack.PixelIdxList{idx1}) = true;
one =  bwmorph(one,'thin',inf);

two = false(sBW);
two(addBack.PixelIdxList{idx2}) = true;

two =  bwmorph(two,'thin',inf);
mainBranch = one + mainBranch;
mainBranch = two + mainBranch;

mainBranch =  bwmorph(mainBranch,'diag');
mainBranch =  bwmorph(mainBranch,'bridge');
mainBranch =  bwmorph(mainBranch,'thin');
mainBranch =  bwmorph(mainBranch,'spur',15);

dendriteLen = bwarea(mainBranch);


pixels_per_micro = sBW/micrometers;
dendriteLen = dendriteLen / pixels_per_micro; %converting dendriteLen from pixels to micrometers

