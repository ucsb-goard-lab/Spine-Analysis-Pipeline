classdef getDendriteInfoClass < handle
    %GETDENDRITEINFO Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = public)
        image_skeleton;
        image_perimeter;
        x_end;
        y_end;
        x_perim;
        y_perim;
        x_branch;
        y_branch;
    end
    
    methods
        function obj = getDendriteInfoClass(BW)
           %% CONSTRUCTOR: Skeletonization: Skeletonization of dendrite and trimming of "extra" spines
            obj.image_skeleton = bwmorph(BW,'thin',inf);
            obj.image_perimeter = bwmorph(BW,'remove');
            obj.getEndPoints();
            obj.getPerimeter();
            obj.getBranchPoints();
            %figure,imshow(image_skeleton) %uncomment to show image skeleton
        end

        % function dendriteLen = getDendriteLengthObj(obj,sBW,micrometers)
        %     % Written by Marie Karpinska
        %     % April 15, 2022
        %     % input image Skeleton of Dendritic Branch and the size of BW (the image of
        %     % the branch) 
        % 
        %     % Configuring image skeleton and main branch of dendrite
        %     mainBranch = bwmorph(obj.image_skeleton,'bridge',inf);
        %     mainBranch = bwmorph(mainBranch,'spur',9);
        %     mainBranch = bwmorph(mainBranch,'hbreak');
        %     mainBranch = bwmorph(mainBranch,'thin');
        %     mainBranch = bwmorph(mainBranch,'spur',50);
        %     %imshowpair(imageSkeleton, mainBranch)
        % 
        %     % Extending main branch to get spines at the end
        %     addBack = obj.image_skeleton - mainBranch;
        %     addBack = bwmorph(addBack,'thicken',1);
        %     addBack = bwmorph(addBack,'diag',inf);
        %     addBack = bwconncomp(addBack,4);
        %     addBackVec = zeros(1,addBack.NumObjects); %initialize vector of size numObjects in addBack
        %     for i = 1:addBack.NumObjects
        %         addBackVec(i) = length(addBack.PixelIdxList{i});  %put areas of connected objects into a vector
        %     end
        % 
        %     [~,idx1] = max((addBackVec),[],'linear');
        %     addBackVec(idx1)= 0;
        %     [~,idx2] = max(addBackVec,[], 'linear');
        % 
        %     %If you get an error that says idx1 needs at least one valid index, then
        %     %your binarization has failed. Check your BW image.
        %     one = false(sBW);
        %     one(addBack.PixelIdxList{idx1}) = true;
        %     one =  bwmorph(one,'thin',inf);
        % 
        %     two = false(sBW);
        %     two(addBack.PixelIdxList{idx2}) = true;
        % 
        %     two =  bwmorph(two,'thin',inf);
        %     mainBranch = one + mainBranch;
        %     mainBranch = two + mainBranch;
        % 
        %     mainBranch =  bwmorph(mainBranch,'diag');
        %     mainBranch =  bwmorph(mainBranch,'bridge');
        %     mainBranch =  bwmorph(mainBranch,'thin');
        %     mainBranch =  bwmorph(mainBranch,'spur',15);
        % 
        %     dendriteLen = bwarea(mainBranch);
        % 
        % 
        %     pixels_per_micro = sBW / micrometers;
        %     dendriteLen = dendriteLen / pixels_per_micro; %converting dendriteLen from pixels to micrometers
        % end

        function getBranchPoints(obj)
            % GETBRANCHPOINTS takes in branchpoints taken from a skeleton with
            % morphological operations, separates them into x and y components, and
            % cleans the data
            
            [x_branchval, y_branchval] = find((bwmorph(obj.image_skeleton, 'branchpoints'))');
            xy_branch = zeros(length(obj.x_end),2);
            
            for i = 1:length(obj.x_end)
                
                distance_endpoints = bwdistgeodesic(obj.image_skeleton, obj.x_end(i), obj.y_end(i), 'quasi-euclidean');
                vector_distance = zeros(length(x_branchval),1);
              
                for j = 1:length(x_branchval) %for every branch point to this end point
                    vector_distance(j) = distance_endpoints(y_branchval(j),x_branchval(j));
                end
                
                if isempty(vector_distance) || vector_distance(1,1) == Inf
                    continue 
                else 
                    % find which branch has the smallest distance to endpoint
                    [~,val] = min(vector_distance); 
                    xy_branch(i,:) = [x_branchval(val(1)),y_branchval(val(1))];
                end
            end
            
            obj.x_branch = xy_branch(:,1); 
            obj.y_branch = xy_branch(:,2);
            
        end

        function getEndPoints(obj)
            [x_endval, y_endval] = find((bwmorph(obj.image_skeleton, 'endpoints'))');
            obj.x_end = x_endval;
            obj.y_end = y_endval;
        end
        
        function getPerimeter(obj)
            [x_perval, y_perval] = find(obj.image_perimeter');
            obj.x_perim = x_perval;
            obj.y_perim = y_perval;
        end
    end
end

