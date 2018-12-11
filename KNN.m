close all;
clear all;

%% Code to preprocess some data

%% Load review data from JSON files
fid = fopen('restaurants_1000_subset.json');
raw = fread(fid,inf);
str = char(raw);
fclose(fid);
restaurants = jsondecode(str);

fid = fopen('users_1000_subset.json');
raw = fread(fid, inf);
str = char(raw);
fclose(fid);
users = jsondecode(str);

clear str;
clear raw;
clear fid;


%% Make data matrix
r_ids = fieldnames(restaurants);
u_ids = fieldnames(users);
users_matrix = zeros(numel(u_ids), 2);

for i=1:numel(u_ids)
    avg_stars(i) = users.(u_ids{i}).average_stars;
    review_count(i) = users.(u_ids{i}).review_count;
    useful(i) = users.(u_ids{i}).useful;
    fans(i) = users.(u_ids{i}).fans;
end

avg_stars = avg_stars';
review_count = review_count';
useful = useful';

users_table = table(avg_stars, review_count, useful);
users_table.Properties.RowNames = u_ids;

save('user_matrix.mat', 'users_table', 'r_ids', 'restaurants');

load('user_matrix.mat');

%% Apply knn to a restaurant
[users_list, ratings] = get_users_for_restaurant(1, r_ids, restaurants, users_table);
[neighbors, test_users, neighbor_ratings, test_ratings] = split_users(users_list, ratings, 10);


%% Probelm 1: Varying the K Value
% k = 1;
% 
% for neighbor_i = 1:length(neighbor_ratings)
%     [k_users, distances, k_ratings] = neareset_neighbors(neighbors, neighbor_ratings, neighbors(neighbor_i,:), k);
%     rating = compute_rating_majority(k_ratings);
%     rating_diff(neighbor_i) = rating - neighbor_ratings(neighbor_i);
% end
% 
% figure();
% plot(1:length(neighbors), rating_diff);
% title('Rating Difference');
% xlabel('User');
% ylabel('Difference in actual vs predicted rating on neighbors');
% 
% k_errors(k) = nnz(rating_diff);

%% Solution 1
for k = 1:50
    for neighbor_i = 1:length(neighbor_ratings)
        [k_users, distances, k_ratings] = neareset_neighbors_euclid(neighbors, neighbor_ratings, neighbors(neighbor_i,:), k);
        rating = compute_rating_majority(k_ratings);
        rating_diff(neighbor_i) = rating - neighbor_ratings(neighbor_i);
    end
   
    k_errors(k) = nnz(rating_diff);

end

figure();
plot(1:50, k_errors);
xlabel('k');
ylabel('Number of Misratings');
title('Problem 1: Number Errors');

%% Problem 2: Using different distance functions
for k = 1:50
    for neighbor_i = 1:length(neighbor_ratings)
        [k_users, distances, k_ratings] = neareset_neighbors_manhat(neighbors, neighbor_ratings, neighbors(neighbor_i,:), k);
        rating = compute_rating_majority(k_ratings);
        rating_diff(neighbor_i) = rating - neighbor_ratings(neighbor_i);
    end
    
    k_errors(k) = nnz(rating_diff);
end

figure();
plot(1:50, k_errors);
xlabel('k');
ylabel('Number of Misratings');
title('Problem 2: Number Errors');

%% 3D plot
figure();
scatter(neighbors.useful, neighbors.review_count, 15, neighbor_ratings);
title('Users that have rated the restaurant');
%% Plot how we want
% figure()
% scatter(neighbors(:,1), neighbors(:,2));
% line(test_user(:,1),test_user(:,2),'marker','x','color','k',...
%    'markersize',10,'linewidth',2)
% r = max(distance);
% c = test_user;
% pos = [c-r 2*r 2*r];
% rectangle('Position',pos,'Curvature',[1 1])


%% Data Helper Functions
function [ret_users, ret_user_review] =  get_users_for_restaurant(restaurant_i, r_ids, restaurants, users_table)
    r_id = r_ids(restaurant_i);
    r = restaurants.(r_id{1});
    
    u_ids = users_table.Properties.RowNames;
    
    for review_i = 1:length(r.reviews)
        u_id = r.reviews(review_i).user_id;
        u_id = strrep(string(u_id), '-', '_');
        u_i = find(contains(u_ids,'x' + u_id));
        if isempty(u_i)
            u_i = find(contains(u_ids, u_id));
        end
        
        user_indices(review_i) = u_i;
        users(review_i, :) = users_table(u_i, :);
        user_review(review_i) = r.reviews(review_i).stars;
    end 
    
    % reduce number of users
    ret_users = users(1:500, :);
    ret_user_review = user_review(1:500);
end


function [neighbors, test_users, neighbor_reviews, test_reviews] = split_users(users, reviews, num_test)
    test_indices = randperm(length(reviews), num_test);
    neighbor_indices = setdiff(1:length(reviews), test_indices);
    
    test_users = users(test_indices, :);
    neighbors = users(neighbor_indices, :);

    test_reviews = reviews(test_indices)';
    neighbor_reviews = reviews(neighbor_indices)';
end


function [user, user_rating] = get_random_user(neighbors, neighbor_ratings)
    rand_i = randi(length(neighbor_ratings), 1);
    user = neighbors(rand_i);
    user_rating = neighbors(rand_i);
end


%% KNN helper functions
function [closest_users, distance, ratings] = neareset_neighbors_euclid(neighbor_list, neighbor_ratings, user, k)
    distance = euclid_dist(neighbor_list, user);
    [distance, Ind] = sort(distance); 
    ind_closest = Ind(1:k);
    ratings = neighbor_ratings(ind_closest);
    closest_users = neighbor_list(ind_closest(:), :);
    distance = distance(1:k);
end


function [closest_users, distance, ratings] = neareset_neighbors_manhat(neighbor_list, neighbor_ratings, user, k)
    distance = manhattan_dist(neighbor_list, user);
    [distance, Ind] = sort(distance); 
    ind_closest = Ind(1:k);
    ratings = neighbor_ratings(ind_closest);
    closest_users = neighbor_list(ind_closest(:), :);
    distance = distance(1:k);
end


function [distance] = manhat_distance(test_point, sample_points)
    % Computes |x1 - x2| + |y1 - y2|
    distance = zeros(length(sample_points),1);
    for i = 1:length(sample_points)
        distance(i,1) = sum(abs((test_point - sample_points(i,:))));
    end
end


function [squared_error] = RMSE(test_point,sample_points)
%RMSE Summary of this function goes here
% Detailed explanation goes here
squared_error = sqrt(sum((test_point - sample_points).^2,2) / length(sample_points));
end


function [d] = euclid_dist(neighbor_list, users)
%EUCLID_DIS Summary of this function goes here
%   Detailed explanation goes here
neighbor_list = table2array(neighbor_list);
users = table2array(users);
d = sqrt(sum((neighbor_list - users).^2, 2));
end


function [d] = manhattan_dist(neighbor_list, users)
%EUCLID_DIS Summary of this function goes here
%   Detailed explanation goes here
neighbor_list = table2array(neighbor_list);
users = table2array(users);
d = sqrt(sum(abs(neighbor_list - users), 2));
end


function rating = compute_rating_majority(rating)
    rating = mode(rating);
end
