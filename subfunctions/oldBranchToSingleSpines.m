function branchToSingleSpines(imageName)
% Polynomial and nonlinear gaussian curve fitting and morphological analysis
%  of dendritic branches to segment them into singular spines
% NOTE: Use DendriticSpineImgPro.m instead of this function!

if nargin == 0
    imageName = uigetfile('Select data file');
    
elseif nargin ~= 1
    error('Invalid Input to branchToSingleSpines')
end

% Areas of improvements:
% - Gather more spines; This function gathered 6 single spine images from a
% dendritic branch image with 31 spines :(
% - use sparse matrices to reduce memory/cpu usage
% - improve rotation angle selection
% - implement slope at point of nonlinear gaussian curve fit

%% Random selection of spine image used for testing
%images = dir('**/*.*');

% for i = 1:1
%     r = randi(546);
%     imageName = images(r).name;
%     if ~contains(imageName,'gaus_') 
%         disp(strcat(imageName,' continued')); %checking if the image is valid
%         continue;
%     end
%     disp(strcat(["r = ",r,"\n image = ", imageName]));

BW1 = binarizeMeanGausProjection(mean_image);
%imshow(BW);

%% Counting Dendrites
dendriteList = bwconncomp(BW); %counting spines
dendritesSkipped = 0;
branchesSkipped = 0;
numBranches = 0;
disp(strcat(["# dendrite objects :", dendriteList.NumObjects]));

for  dendriteIdx = 1:dendriteList.NumObjects
    %% Finding Main Branch, Spines, and Spine Branch Points
    disp(strcat(["dendriteIdx = ", dendriteIdx])); %test

    if length(dendriteList.PixelIdxList{dendriteIdx}) < 500 %adjustable threshold
        dendritesSkipped = dendritesSkipped + 1;
        continue; %test
    end

    currDendrite = false(size(BW));
    currDendrite(dendriteList.PixelIdxList{dendriteIdx}) = true;
    %imshowpair(currDendrite,BW)
    if (regionprops(currDendrite, 'Circularity').Circularity) > 0.75
        dendritesSkipped = dendritesSkipped + 1;
        continue; %test
    end
    
    % Configuring image skeleton and main branch of dendrite
    imageSkeleton = bwmorph(currDendrite,'skel',inf);
    imageSkeleton = bwmorph(imageSkeleton,'bridge',inf);
    imageSkeleton = bwmorph(imageSkeleton,'spur',9);
    mainBranch = bwmorph(imageSkeleton,'hbreak');
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
    
    one = false(size(BW));
    one(addBack.PixelIdxList{idx1}) = true;
    one =  bwmorph(one,'thin',inf);
    
    two = false(size(BW));
    two(addBack.PixelIdxList{idx2}) = true;
    
    two =  bwmorph(two,'thin',inf);
    mainBranch = one + mainBranch;
    mainBranch = two + mainBranch;
   
    mainBranch =  bwmorph(mainBranch,'diag');
    mainBranch =  bwmorph(mainBranch,'bridge');
    mainBranch =  bwmorph(mainBranch,'thin');
    mainBranch =  bwmorph(mainBranch,'spur',15);
    
    branchpoints = bwmorph(imageSkeleton,'branchpoints').*bwmorph(mainBranch,'diag');
    branchpoints = sparse(branchpoints);
    
    % getting branch lines without main branch
    delMain = bwmorph(mainBranch,'close',5);
    delMain = bwmorph(delMain,'diag',inf);
    delMain = bwmorph(delMain,'bridge',inf);
    delMain = bwmorph(delMain,'thicken',8);
    delMain = imfill(delMain,'holes');
    branches = currDendrite .* ~delMain;
    branches = branches .* ~(bwareafilt(logical(branches),[5 100]));
    imshowpair(branches,currDendrite)
    
    branchList = bwconncomp(branches,4); %counting spines
    clearvars two one addBack delMain branches idx1 idx2
    
    %% Getting approximate linear fit of main branch
    
    % Getting linear least squares fit of main branch
    [x,y] = find(mainBranch);
    p = polyfit(x,y,3);
    
    % R^2 = 1 - Total Sum-Of-Squares / Residual Sum-Of-Squares
    Rsq = 1-(sum((y-(polyval(p, x))).^2))/(sum((y-mean(y)).^2)); 
    disp(strcat(['r^2 = ',num2str(Rsq)])); %test
    
    if (Rsq < 0.5)
        %then use nonlinear least squares Gaussian curve fitting
        opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts.Display = 'Off';
        f = fit(y,x,'gauss3',opts);
        h = figure;
        imshow(currDendrite);
        hold all;
        plot(f,y,x,'c');
        
    else
         h = figure;
         imshow(currDendrite);
         hold all;
         yy = linspace( 1, size(mainBranch,1), 50 );
         plot( polyval( p, yy ), yy, '.-', 'LineWidth', 1 );
        
    end
    
    %% Extracting Single Spines
    disp(strcat(["# branch objects :", branchList.NumObjects]));
    for branchIdx = 1:branchList.NumObjects
        
        disp(strcat(['branchIdx = ', num2str(branchIdx)])); %test

        if length(branchList.PixelIdxList{branchIdx}) < 50 %adjustable threshold
           branchIdx = branchIdx +1;
           disp("skipped")
           % branchesSkipped = branchesSkipped + 1;
            % continue; %test
        end
       
        % Getting Spine from list of disconnected potential spine objects
        currBranch = false(size(BW));
        currBranch(branchList.PixelIdxList{branchIdx}) = true;
        currBranch = bwmorph(currBranch,'thicken',6) .* currDendrite;
        
        delMain2 = bwmorph(mainBranch,'close',5);
        delMain2 = bwmorph(delMain2,'diag',inf);
        delMain2 = bwmorph(delMain2,'bridge',inf);
        delMain2 = bwmorph(delMain2,'thicken',12);
        delMain2 = imfill(delMain2,'holes');
        currBranch = currBranch .* ~delMain2;
        
        imshowpair(currBranch,currDendrite) %test
        
        % getting main branch of the spine and finding neck + head length
        neckHeadLength =  currBranch.*imageSkeleton;
        neckHeadLength =  bwmorph(neckHeadLength,'spur');
        %imshowpair(neckHeadLength,currBranch); %test
        neckHeadLength = bwarea(neckHeadLength);
        
        % finding branch point
        currBranchPoint = (bwmorph(currBranch,'thicken',15)) .* branchpoints;
        
        %disp(sum(currBranchPoint,'all')); %test
        [xBase, yBase] = find(currBranchPoint);
        xBase = mean(xBase);
        yBase = mean(yBase);
       
        % !todo
        %if spine is at the edges of the image, then thicken delMain so
        %that only the spine remains and none of the main branch
        value = 160; %threshold assumes input is 760x760 images
        if or(or((xBase > length(currBranch) - value),(xBase < value)),or((yBase > length(currBranch) - value),(yBase < value)))
            %currBranch = currBranch - bwmorph(delMain,'thicken',3);
            %!todo, skip these branches for now, implement if time.
            %efficiency and automation > more spines? analyze later if the
            %trade off is worth it or implement solution
            continue;
        end
        
        % Make sure a branch point and branch of the spine was found
        if or(neckHeadLength == 0,(sum(currBranchPoint,'all')==0))
            branchesSkipped = branchesSkipped + 1;
            continue; %testing - !todo remvoe %
        end
        
        disp(strcat(['neck + head length = ',num2str(neckHeadLength)])); %test
        
        %% Rotating Spine
        % Getting angle of rotation
        
        if (Rsq >= 0.5) %match threshold at line 93
            theta =90*(polyval(polyder(p),xBase)); %get slope of branchpoint & mutliply by 90 degrees
            %assert(isnumeric(theta)); %testing
        else
            % Guassian curve fitting !todo
            error("needs implementation");
            %fx = differentiate(f, yBase); %try xBase too
            %theta =(atand(feval(fx,(feval(f,xBase) + yBase)/2)));
        end
        
        %average points of current spine
        [x, y] = find(currBranch);
        x = mean(x);
        y = mean(y);
        
        % sqrt(x^2+y^2) = currBranchLocation
        % sqrt(xBase^2+yBase^2) = branchPoint on MainBranch Location
        
        %%
        t = floor(neckHeadLength);
        if t < 10
            t = 10;
        end
        
        if sqrt(x^2+y^2) > sqrt(xBase^2+yBase^2)
            % if the curr branch is on the right side of or under the main
            % branch, then add a 90 degree counter clockwise rotation
            rotAngleSpine = 90+theta; 
            rotAngleData = 270-theta; %test this- why would it be different
            sBox = [yBase-t xBase-2*t,t*5 t*5]; %testing
            
        else
            rotAngleSpine = 275-theta; %if spine on right side rotate by 90-theta
            rotAngleData = 90+theta; %!todo double check this number
            sBox = [yBase-(5*t) xBase-t*2.5,t*5 t*5]; %testing
        end
        
        RotatedSpine = imrotate(currBranch,rotAngleSpine,'nearest','crop');
        % Rotate spine base points
        R = [cosd(rotAngleData) -sind(rotAngleData); sind(rotAngleData) cosd(rotAngleData)];
        base = [xBase, yBase];
        rotBase = ((base-380)*R)+380;
        
        %TESTING
        figure, imshowpair(currBranch, RotatedSpine)
        spineBox = drawrectangle('Position',sBox,'StripeColor','g','Rotatable',true);
        rotSpineBox = drawrectangle('Position',[rotBase(2)-2.5*t rotBase(1)-5*t,t*5 t*5],'StripeColor','g','Rotatable',true);
        
        %%
        currBranch = imcrop(RotatedSpine,[rotBase(2)-(2.5*t) rotBase(1)-t*5,t*5 t*5]);
        currBranch = imresize(currBranch, (250/length(currBranch)));
        currBranch = imbinarize(imgaussfilt(currBranch,5),0.8); %imgaussfilt,medfilt2,
        
        imshow(currBranch)
        
        %!todo update rotatedSpine to be just spine so you save time and memory
        %from creating too many large variables
        %%
        % Saving image of single spine with data: 
        % mean guas proj ID _ dendrite ID _ spine ID _ neck+head length
        oldFolder = cd('singleSpines');
        imwrite(currBranch,(strcat(erase(imageName,'_gaus_mean_projection.mat'),'-',num2str(dendriteIdx),'_',num2str(branchIdx),'_',num2str(neckHeadLength),'.png')));
        cd(oldFolder);
        
        numBranches = numBranches + 1;
        
    end
    
end

print(strcat(["dendritesSkipped = ",dendritesSkipped]));
print(strcat(["branchesSkipped = ",branchesSkipped]));
print(strcat(["numBranches = ",numBranches]));

end