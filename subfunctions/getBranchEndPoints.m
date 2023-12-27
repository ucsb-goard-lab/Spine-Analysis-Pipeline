function [x_branch,y_branch,x_end,y_end,spine_end_points] = getBranchEndPoints(image_skeleton)
% Finding and ordering branches and endpoints for each spine
% Code from section 4 and 5 in dendriticSpineImgPro.m by WTR

image_branchpoint = bwmorph(image_skeleton, 'branchpoints');
image_endp        = bwmorph(image_skeleton, 'endpoints');

[x_branch, y_branch] = find(image_branchpoint');
[x_end   , y_end]    = find(image_endp');

xy_branch = zeros(length(x_end),2);

for i = 1:length(x_end)
    % for each skeleton branch point get the length of the branch
    distance_endpoints = bwdistgeodesic(image_skeleton, x_end(i), y_end(i), 'quasi-euclidean');
    vector_distance    = zeros(length(x_branch),1);
    
    for j = 1:length(x_branch)
        vector_distance(j) = distance_endpoints(y_branch(j),x_branch(j));
    end
    
    if vector_distance(1,1) ~= Inf
        val            = find(vector_distance == min(vector_distance));
        xy_branch(i,:) = [x_branch(val(1)),y_branch(val(1))];
    end
    
end

x_branch = xy_branch(:,1);
y_branch = xy_branch(:,2);
spine_end_points = zeros(2, length(x_end));

end