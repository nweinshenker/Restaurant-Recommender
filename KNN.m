load fisheriris
%% Algorithm of K Nearest Neighbors
% Given a data matrix which stores all our suggestive users preferences on
% restaurants and a newpoint which is a simple point (1 x M).
% 1. Find the Euclidean distance between newpoint and every point in x
% 2. Sort all these distances in ascending order
% 3. Return the k data points in x that are closest to newpoint

%// Load the data and create the query points
X = meas;
newpoints = [5 1.45 0.2 0.3; 7 2 4 3; 4 2.5 1 5.5; 2 3.5 1.3 2.4];

%// Define k and the output matrices
k = 10;
x_closest = zeros(k, size(newpoints,1), size(X,2));
index_closest = zeros(size(newpoints,1), k);

%// Loop through each point and do logic as seen above:
for i = 1 : Q
    newpoint = newpoints(i, :);

    dists = sqrt(sum(abs(X(:,i) - newpoint)).^2);
    [d,i] = sort(dists);
    
    index_closest(i, :) = dist(1 : k).';
    x_closest(:, :, i) = x(ind_closest(i, :), :);
end

