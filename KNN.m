%% load review data
% 
% fid = fopen('restaurants_subset.json');
% raw = fread(fid,inf);
% str = char(raw);
% fclose(fid);
% restaurants = jsondecode(str);
% 
% fid = fopen('users_subset.json');
% raw = fread(fid, inf);
% str = char(raw);
% fclose(fid);
% users = jsondecode(str);
% 
% clear str;
% clear raw;
% clear fid;



%% Algorithm of K Nearest Neighbors
% Given a data matrix which stores all our suggestive users preferences on
% restaurants and a newpoint which is a simple point (1 x M).
% 1. Find the Euclidean distance between newpoint and every point in x
% 2. Sort all these distances in ascending order
% 3. Return the k data points in x that are closest to newpoint

%% Test the RMSE error
test_point = [3 , 2];
array_point = [3 4; 5 3; 2 8];

squared_error = RMSE(test_point, array_point);
%%

% Test points for the knn algorithm
load fisheriris;
x = meas(:,3:4);
newpoints = [5 1.45 ; 7 2 ; 4 2.5 ; 2 3.5];

%% Test Euclidean distance and Mikowski distance
[euclid_distance] = euclid_dist(x, newpoints(1,:));
% [mik_distance] = Mik(x(1,:), newpoints(1,:), 10);
% bsxfun(@minus, x, newpoints(1,:)).^2
%% KNN Algorithm

%// Define k and the output matrices
N = size(newpoints, 1);
M = size(x, 2);
k = 10;
x_closest = zeros(k, M, N);
ind_closest = zeros(N, k);

distance = zeros(150,1);
%// Loop through each point and do logic as seen above:
for i = 1 : N
    %// Get the point
    newpoint = newpoints(i, :);

    
    %// Use Euclidean
%     for j = 1:150
%         [dista] = euclid_dist(x(j,:), newpoint);
%         distance(j) = dista;
%     end
    dists = sqrt(sum(bsxfun(@minus, x, newpoint).^2,2));
    %sort the index for closest points
    [d,close] = sort(dists);

    %// New - Output the IDs of the match as well as the points themselves
    ind_closest(i, :) = close(1 : k).';
    x_closest(:, :, i) = x(ind_closest(i, :), :);
end

figure();

PL = meas(:,3);
PW = meas(:,4);

h1 = gscatter(PL,PW,species,'krb','ov^',[],'off');
h1(1).LineWidth = 2;
h1(2).LineWidth = 2;
h1(3).LineWidth = 2;
legend('Setosa','Versicolor','Virginica','Location','best')
hold on;


%% Example of training a 
X = meas;
Y = species;

Mdl = fitcknn(X,Y,'NumNeighbors',5,'Standardize',1);
Mdl.NumNeighbors = 4;


% %% Graph the decision boundaries of the 
% gscatter(x(:,1),x(:,2),group,'rb','+x');
% hold on;
% 
% c3 = knnclassify(species, X, group, k);
% gscatter(species(:,1),c3,'mc','o');
% legend('Training group 1','Training group 2','Data in group 1','Data in group 2');