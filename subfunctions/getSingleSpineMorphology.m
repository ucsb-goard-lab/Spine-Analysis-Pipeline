function [midpoint_base, spine_fill, im, class] = getSingleSpineMorphology(i,mask,BW)
%% Single spine analysis
%-------------------------------------------------------------------------%
%   This function displays is called in the manual spine curation step of
%   dendrite analysis, and determines the physical characteristics of the
%   single spine.
%
%   Written by NSW 06/08/2023 // Last updated by NSW 06/08/2023
%-------------------------------------------------------------------------%

BW(~mask) = false; % isolate spine in image

image_skeleton    = bwmorph(BW,'thin',inf);
image_perimeter   = bwmorph(BW,'remove');

[x_end   , y_end]    = find((bwmorph(image_skeleton, 'endpoints'))');
[x_perim , y_perim]  = find(image_perimeter');
[x_branch, y_branch] = getBranchPoints_NSWEdit(image_skeleton,x_end, y_end);

max_geodesic_dist = 500; min_geodesic_dist = 10; %!TODO make these parameters?

spine_end_points       = zeros(2, length(x_end));
image_spine_end_points = zeros(size(BW));

%get index of branch pt with min distance between every branch point to given end point
[~, end_ii_branchpoint] = min(sqrt((x_branch - x_end(i)).^2 + (y_branch - y_end(i)).^2));


ii_dist = sqrt((x_branch(end_ii_branchpoint) - x_perim).^2 + (y_branch(end_ii_branchpoint) - y_perim).^2);

Q1 = find(y_perim > y_branch(end_ii_branchpoint) & x_perim > x_branch(end_ii_branchpoint));
Q2 = find(y_perim > y_branch(end_ii_branchpoint) & x_perim < x_branch(end_ii_branchpoint));
Q3 = find(y_perim < y_branch(end_ii_branchpoint) & x_perim < x_branch(end_ii_branchpoint));
Q4 = find(y_perim < y_branch(end_ii_branchpoint) & x_perim > x_branch(end_ii_branchpoint));

[~, Q1_pt] = min(ii_dist(Q1));
[~, Q2_pt] = min(ii_dist(Q2));
[~, Q3_pt] = min(ii_dist(Q3));
[~, Q4_pt] = min(ii_dist(Q4));

pts             = [Q1(Q1_pt), Q2(Q2_pt), Q3(Q3_pt), Q4(Q4_pt)];
dist2end        = sqrt((x_perim(pts) - x_end(i)).^2 + (y_perim(pts) - y_end(i)).^2);
[~, sorted_ids] = sort(dist2end);

geodesic_distance = bwdistgeodesic(image_perimeter, x_perim(pts(sorted_ids(1))), y_perim(pts(sorted_ids(1))));
if find(sorted_ids) <= 1
    spine_end_points(:, i) = 1;
else

    if geodesic_distance(y_perim(pts(sorted_ids(2))), x_perim(pts(sorted_ids(2)))) < max_geodesic_dist
        if geodesic_distance(y_perim(pts(sorted_ids(2))), x_perim(pts(sorted_ids(2)))) < min_geodesic_dist
            spine_end_points(:, i) = pts(sorted_ids([1, 3]));
        else
            spine_end_points(:, i) = pts(sorted_ids(1:2));
        end
        image_spine_end_points(y_perim(spine_end_points(1, i)), x_perim(spine_end_points(1, i))) = 1;
        image_spine_end_points(y_perim(spine_end_points(2, i)), x_perim(spine_end_points(2, i))) = 1;
    end
end

% Spine extrapolation
[x,y]      = find(image_spine_end_points');
if isempty(x)
    x = [1,2];
end
if isempty(y)
    y = [1,2];
end
D1         = bwdistgeodesic(image_perimeter, x(1), y(1), 'quasi-euclidean');
D2         = bwdistgeodesic(image_perimeter, x(2), y(2), 'quasi-euclidean');
D_sum      = D1 + D2;
D_sum      = round(D_sum*8)/8;
D_sum(isnan(D_sum)) = inf;
spine_form = imregionalmin(D_sum);
spine_form = bwmorph(spine_form, 'thin', inf);
spine_base        = linept(zeros(size(image_perimeter)),y(1),x(1),y(2),x(2));
spine             = spine_form + spine_base;
spine(spine ~= 0) = 1;

% Find base center point & top point
[x_base,y_base] = find(spine_base');
midpoint_base   = [round(mean(x_base)),round(mean(y_base))];
yx_base         = [x_base,y_base];
min_distance    = sum((yx_base - midpoint_base).^ 2, 2);
midpoint_base   = yx_base(min_distance == min(min_distance),:);

spine_top                   = bwdistgeodesic(logical(spine), midpoint_base(1,1),midpoint_base(1,2),'quasi-euclidean');
spine_top(isnan(spine_top)) = 0;
[~,loc]                     = max(spine_top,[],'all','linear');
[y_top,x_top]               = ind2sub(size(spine),loc);

% Head/Dock/Tail Extraction
pt_base     = [midpoint_base(1,1) midpoint_base(1,2)];
pt_top      = [x_top  y_top ];
spine_fill  = imfill(spine,'holes');

DD1         = bwdistgeodesic(logical(spine_fill),pt_base(1),pt_base(2),'quasi-euclidean');
DD2         = bwdistgeodesic(logical(spine_fill),pt_top(1),pt_top(2),'quasi-euclidean');
DD_sum      = round((DD1+DD2)*32)/32;
DD_sum(isnan(DD_sum)) = max(DD_sum(:));
spine_bones = imregionalmin(DD_sum);
spine_bones = bwmorph(spine_bones, 'thin', inf);

n = 3;
t = linspace(0,1,n+4);   % evenly spaced img.parameters
t = t([2 4 6]);          % we don't need the start and end points [t(2:(end-1)); t(1) = t(1)-0.05; % t(3) = t(3)+0.05]
v  = pt_base - pt_top;
yy = pt_top(1) + t*v(1); % p(t) = p1 + t*(p2-p1)
xx = pt_top(2) + t*v(2);
v  = 15*v / norm(v);

perpendiculars = zeros(size(spine,1),size(spine,2),3);

for ii = 1:n
    preliminar_line        = linept(zeros(size(spine)),round(xx(ii)-v(1)),round(yy(ii)+v(2)),round(xx(ii)+v(1)),round(yy(ii)-v(2)));
    perpendiculars(:,:,ii) = preliminar_line(1:size(spine,1),1:size(spine,2));
end

perpendiculars  = perpendiculars.*spine_fill;

length_sections = zeros();

for j = 1:size(perpendiculars,3)
    segment            = bwmorph(perpendiculars(:,:,j), 'endpoints');
    [pp_y,pp_x]        = find(segment);
    if numel(pp_y) <= 1 || numel(pp_x) <= 1
        length_sections(j) = 1;
    else
        length_sections(j) = round(sqrt((pp_x(1)-pp_x(2))^2+(pp_y(1)-pp_y(2))^2))-1;
    end
end

im.spine_length  = round(sqrt((x_top-midpoint_base(1,1))^2+(y_top-midpoint_base(1,2))^2));
im.bottom_length = length_sections(3); im.middle_length = length_sections(2);
im.upper_length  = length_sections(1); im.aspect_ratio  = round(im.spine_length/im.middle_length,1);

% Neck extraction
interesection    = pixel_intersection(perpendiculars(:,:,2),spine_bones);
im.spine_neck    = round(sqrt((interesection(1)-midpoint_base(1,1))^2+(interesection(2)-midpoint_base(1,2))^2));

% Head extraction
distance_head  = spine;
distance_head(find(perpendiculars(:,:,2))) = 0;
distance_head  = bwdistgeodesic(logical(distance_head),pt_top(1),pt_top(2),'quasi-euclidean');
distance_head(distance_head == inf) = nan;
distance_head(~isnan(distance_head))= 1;
distance_head(isnan(distance_head)) = 0;
distance_head   = distance_head + perpendiculars(:,:,2);
distance_head   = imfill(distance_head,'holes');
stat_spine_head = regionprops(distance_head,'all');



% Morpohological Classification
prompt = {'Enter the most plausible spine classification (i.e. stubby, mushroom, thin, or filopodium:)'};
dlgtitle = 'Input';
dims = [1 35];
definput = {'1'};
answer = inputdlg(prompt,dlgtitle,dims,definput);
class = cell2mat(answer);
end
