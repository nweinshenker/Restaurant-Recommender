close all;
clear all;
clc;

% Restaurant that we did a user-user comparison at
% {
%     'neighborhood': '', 
%     'attributes': {
%         'Smoking': 'no', 
%         'NoiseLevel': 'average', 
%         'HappyHour': 'False', 
%         'GoodForDancing': 'False', 
%         'RestaurantsDelivery': 'False', 
%         'BikeParking': 'False', 
%         'WheelchairAccessible': 'True', 
%         'Caters': 'True', 
%         'RestaurantsAttire': 'casual', 
%         'Music': "{'dj': False, 'background_music': False, 'no_music': False, 'karaoke': False, 'live': False, 'video': False, 'jukebox': False}", 
%         'GoodForMeal': "{'dessert': False, 'latenight': False, 'lunch': False, 'dinner': True, 'breakfast': False, 'brunch': False}", 
%         'RestaurantsGoodForGroups': 'True', 
%         'Alcohol': 'full_bar', 
%         'BestNights': "{'monday': False, 'tuesday': False, 'friday': True, 'wednesday': False, 'thursday': False, 'sunday': True, 'saturday': True}", 
%         'CoatCheck': 'False', 
%         'BusinessParking': "{'garage': False, 'street': False, 'validated': False, 'lot': True, 'valet': False}", 
%         'WiFi': 'free', 
%         'GoodForKids': 'True', 
%         'RestaurantsTableService': 'True', 
%         'RestaurantsReservations': 'True', 
%         'BusinessAcceptsCreditCards': 'True',
%         'RestaurantsTakeOut': 'True',
%         'Ambience': "{'romantic': False, 'intimate': False, 'classy': False, 'hipster': False, 'divey': False, 'touristy': False, 'trendy': False, 'upscale': False, 'casual': True}", 
%         'OutdoorSeating': 'False', 
%         'HasTV': 'True', 
%         'RestaurantsPriceRange2': '2'
%     }, 
%     'review_count': 1412, 
%     'business_id': 'pHJu8tj3sI8eC5aIHLFEfQ', 
%     'name': "Nora's Italian Cuisine", 
%     'postal_code': '89103', 
%     'state': 'NV', 
%     'hours': {'Wednesday': '11:0-22:0', 'Sunday': '16:0-22:0', 'Friday': '11:0-23:0', 'Tuesday': '11:0-22:0', 'Thursday': '11:0-22:0', 'Monday': '11:0-22:0', 'Saturday': '16:0-23:0'}, 
%     'is_open': 1, 
%     'city': 'Las Vegas', 
%     'categories': 'Bars, Italian, Pizza, Event Planning & Services, Venues & Event Spaces, Nightlife, Cocktail Bars, Wine Bars, Restaurants', 
%     'latitude': 36.1150515442, 
%     'longitude': -115.220283569, 
%     'address': '5780 W Flamingo Rd', 'stars': 4.0
% };

load('users.mat');

%% Problem - Configuration
% Features 
% 1 - avg_rating for all businesses
% 2 - avg_restaurant_rating
% 3 - review_count
% 4 - useful
% 5 - cats_pizza: number of pizza restaurants a user has rated
% 6 - cats_bar: number of bars a user has rated
% 7 - cats_italian: number of italian restaurants a user has rated

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% select different values here
features = [1:7]; % select any combination of numbers 1 through 7
k = 3; % for evaluating 1 k value at a time
knn_func = @neareset_neighbors_euclid; % neareset_neighbors_euclid, nearest_neighbors_manhat
rating_func = @compute_rating_majority; % compute_rating_average, compute_rating_majority
num_test_users = 25; % up to 399
k_end = 10; % for iteration, make small to run faster
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[neighbors, test_users] = split_users(users, num_test_users);
%% Problem - 1 K Value

for neighbor_i = 1:height(neighbors)
    [k_users, distances, k_ratings] = knn_func(neighbors(:, features), neighbors(neighbor_i, features), k, neighbors.noras_rating);
    rating = rating_func(k_ratings);
    rating_diff(neighbor_i) = rating - neighbors(neighbor_i, :).noras_rating;
end

% plot
figure();
plot(1:height(neighbors), rating_diff);
title(sprintf('Predicted - actual for K = %d', k));
xlabel('User ID');
ylabel('Difference');

k_errors(k) = nnz(rating_diff);

%% Iteration over K for the Problem
for k = 1:k_end
    for neighbor_i = 1:height(neighbors)
        [k_users, distances, k_ratings] = knn_func(neighbors(:, features), neighbors(neighbor_i, features), k,  neighbors.noras_rating);
        rating = rating_func(k_ratings);
        rating_diff(neighbor_i) = rating - neighbors(neighbor_i, :).noras_rating;
    end
    
    k_errors(k) = nnz(rating_diff);
    k_errors_rmse(k) = sqrt(sum(rating_diff.^2)/length(rating_diff));
end

figure();
plot(1:k_end, k_errors);
xlabel('k');
ylabel('Number of Misratings');
title('Neighbors');

figure();
plot(1:k_end, k_errors_rmse);
xlabel('k');
ylabel('Root Mean Squared Error');
title('Neighbors');

%% Iteration over Validation Data
rating_diff = [];
for k = 1:k_end
    for neighbor_i = 1:height(test_users)
        [k_users, distances, k_ratings] = knn_func(test_users(:, features), test_users(neighbor_i, features), k,  test_users.noras_rating);
        rating = rating_func(k_ratings);
        rating_diff(neighbor_i) = rating - test_users(neighbor_i, :).noras_rating;
    end
    k_errors(k) = nnz(rating_diff);
    k_errors_rmse(k) = sqrt(sum(rating_diff.^2)/length(rating_diff));
end

figure();
plot(1:k_end, k_errors);
xlabel('k');
ylabel('Number of Misratings');
title('Validation Users');

figure();
plot(1:k_end, k_errors_rmse);
xlabel('k');
ylabel('Root Mean Squared Error');
title('Validation Users');

%% Problem Choosing Features
k = 3;
rating_diff = [];
k_errors = [];
k_errors_rmse = [];
for features = 1:7
    for neighbor_i = 1:height(neighbors)
        [k_users, distances, k_ratings] = knn_func(neighbors(:, features), neighbors(neighbor_i, features), k, neighbors.noras_rating);
        rating = rating_func(k_ratings);
        rating_diff(neighbor_i) = rating -  neighbors(neighbor_i, :).noras_rating;
    end
    
    k_errors(features) = nnz(rating_diff);
    k_errors_rmse(features) = sqrt(sum(rating_diff.^2)/length(rating_diff));    
end

figure();
plot(1:7, k_errors);
xlabel('k');
ylabel('Number of Misratings');
title('Feature Selection');

figure();
plot(1:7, k_errors_rmse);
xlabel('k');
ylabel('Root Mean Squared Error');
title('Feature Selection');

%% Data Helper Functions
function [neighbors, test_users] = split_users(users, num_test)
    test_indices = randperm(height(users), num_test);
    neighbor_indices = setdiff(1:height(users), test_indices);
    
    test_users = users(test_indices, :);
    neighbors = users(neighbor_indices, :);
end


function [user, user_rating] = get_random_user(neighbors, neighbor_ratings)
    rand_i = randi(length(neighbor_ratings), 1);
    user = neighbors(rand_i);
    user_rating = neighbors(rand_i);
end


%% KNN helper functions
function [closest_users, distance, k_ratings] = neareset_neighbors_euclid(neighbor_list, user, k, ratings)
    k = min(k, height(neighbor_list));

    distance = euclid_dist(neighbor_list, user);
    [distance, Ind] = sort(distance); 
    ind_closest = Ind(1:k);
    closest_users = neighbor_list(ind_closest(:), :);
    k_ratings = ratings(ind_closest);
    distance = distance(1:k);
end


function [closest_users, distance, k_ratings] = neareset_neighbors_manhat(neighbor_list, user, k, ratings)
    distance = manhattan_dist(neighbor_list, user);
    [distance, Ind] = sort(distance); 
    ind_closest = Ind(1:k);
    closest_users = neighbor_list(ind_closest(:), :);
    k_ratings = ratings(ind_closest);
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


function rating = compute_rating_average(rating)
    rating = mean(rating);
end
