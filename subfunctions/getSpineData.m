function spineDataCell = getSpineData(image,label)
% Classifying Spines Take 2 using single spine images
% This function is to gather the data on the spine to train on
% spine data is a cell array storing the features

%image = "single_spine10"; %!todo delete bc it is input
[~, ~,third] = size(image);
BW = imread(image);

% Reading and cleaning image
if third > 1
    BW = im2gray(BW);
end
BW = bwmorph(BW, 'clean');
BW = bwmorph(BW, 'fill');
BW = bwmorph(BW, 'close');
imshow(BW);

% Gathering regionprops data and creating struct to export selected data
imStats = regionprops(BW,'all');

spineData = struct;

spineData.spineLabel = label; %spine class label

if length(imStats) > 1
    temp = struct2cell(imStats);
    temp = cell2mat(temp(1,:));
    [~,pos] = max(temp); %test
    imStats = imStats(pos,:);
    
    %     disp(strcat([image,' was not properly cleaned! moving to dirty folder...']));
    %     spineDataCell = {};
    %     return
end

% Bounding box height and width

[h,~]=size(imStats.FilledImage); %h = neck length + head diameter
spineData.neckHeadLength = h;

spineData.EquivDiameter = imStats.EquivDiameter;
spineData.Eccentricity = imStats.Eccentricity;
spineData.Extent = imStats.Extent;
spineData.aspectRatio = imStats.BoundingBox(:,3) / imStats.BoundingBox(:,4);
spineData.Solidity = imStats.Solidity;


spineData.BBoxH = imStats.BoundingBox(:,3);
spineData.BBoxW = imStats.BoundingBox(:,4);

% Fill ratio - White to Black Pixels ratio in bounding box
imshow(BW);
r = drawrectangle('Position',[imStats.BoundingBox(:,1),...
    imStats.BoundingBox(:,2),...
    imStats.BoundingBox(:,1)+ imStats.BoundingBox(:,3), ...
    imStats.BoundingBox(:,2)+ imStats.BoundingBox(:,4)]);
fillMask = createMask(r);
fill = BW .* fillMask;
spineData.fillRatio = sum(sum(fill))/(numel(fill)-sum(sum(fill)));

% Shape Factor
imshow(BW);
% fits a circle inside bounding box
x = (imStats.BoundingBox(:,3)/4);
y = (imStats.BoundingBox(:,4)/4);
c = drawcircle('Center',[imStats.BoundingBox(:,1) + x*2,...
    imStats.BoundingBox(:,2) + y*2],'Radius',min(x,y));
shapeMask = createMask(c);
shape = BW .* shapeMask;
antiShape = BW .* (~shapeMask);
%   1. num white pixels inside circle
spineData.whiteInShape = sum(sum(shape));
%   2. num black pixels inside circle
spineData.blackInShape = (numel(shape)-sum(sum(shape)));
%   3. num white pixels outside circle
spineData.whiteOutShape = sum(sum(antiShape));

spineData.Circularity = imStats.Circularity;
spineData.MajorAxisLength = imStats.MajorAxisLength;
spineData.MinorAxisLength = imStats.MinorAxisLength;
spineData.MinFeretDiameter = imStats.MinFeretDiameter;
spineData.MaxFeretDiameter = imStats.MaxFeretDiameter;
spineData.Perimeter = imStats.Perimeter;


spineDataCell = {spineData.spineLabel,...
    spineData.neckHeadLength,...
    spineData.BBoxH,spineData.BBoxW,spineData.aspectRatio,...
    spineData.fillRatio,...
    spineData.whiteInShape,...
    spineData.blackInShape,...
    spineData.whiteOutShape,...
    spineData.Extent,... % similar to fillRatio
    spineData.Circularity,...
    spineData.Eccentricity,...
    spineData.MajorAxisLength,spineData.MinorAxisLength,...
    spineData.MinFeretDiameter,spineData.MaxFeretDiameter,...
    spineData.Perimeter,...
    spineData.Solidity,...
    spineData.EquivDiameter};

end
