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
  users_matrix(i, 1) = users.(u_ids{i}).average_stars;
  users_matrix(i, 2) = users.(u_ids{i}).review_count;
end

save('user_matrix.mat', 'users_matrix', 'u_ids');

%% Apply knn to a restaurant
[users_list, ratings] = get_users_for_restaurant(1, r_ids, restaurants, u_ids, users_matrix);
[neighbors, train_users, test_users, neighbor_ratings, train_ratings, test_ratings] = split_users(users_list, ratings, 10, 1);
[k_users, distances, k_ratings] = neareset_neighbors(neighbors, neighbor_ratings, test_users, 8);


%% 3D plot
figure();
scatter3(neighbors(:,1), neighbors(:,2), neighbor_ratings);

%% Plot how we want
figure()
scatter(train_user(:,1), train_user(:,2));
line(test_user(:,1),test_user(:,2),'marker','x','color','k',...
   'markersize',10,'linewidth',2)
r = max(distance);
c = test_user;
pos = [c-r 2*r 2*r];
rectangle('Position',pos,'Curvature',[1 1])


%% Helper Functions
function [users, user_review] =  get_users_for_restaurant(restaurant_i, r_ids, restaurants, u_ids, users_matrix)
    r_id = r_ids(restaurant_i);
    r = restaurants.(r_id{1});
    users = zeros(length(r.reviews), 2);
    
    for review_i = 1:length(r.reviews)
        u_id = r.reviews(review_i).user_id;
        u_id = strrep(string(u_id), '-', '_');
        u_i = find(contains(u_ids,'x' + u_id));
        if isempty(u_i)
            u_i = find(contains(u_ids, u_id));
        end
        
        users(review_i, :) = users_matrix(u_i, :);
        user_review(review_i) = r.reviews(review_i).stars;
    end  
end


function [closest_users, euc_dis, ratings] = neareset_neighbors(neighbor_list, neighbor_ratings, user, k)
    distance = euclid_dist(neighbor_list, user);
    [sorted_dist, Ind] = sort(distance); 
    ind_closest = Ind(1:k);
    ratings = neighbor_ratings(ind_closest);
    closest_users = neighbor_list(ind_closest(:), :);
    euc_dis = sorted_dist(1:k);
end


function [squared_error] = RMSE(test_point,sample_points)
%RMSE Summary of this function goes here
% Detailed explanation goes here
squared_error = sqrt(sum((test_point - sample_points).^2,2) / length(sample_points));
end


function [neighbors, train_users, test_users, neighbor_reviews, train_reviews, test_reviews] = split_users(users, reviews, num_train, num_test)
    test_indices = randperm(length(users), num_test);
    remaining_indices = setdiff(1:length(users), test_indices);
    remaining_users = users(remaining_indices, :);
    train_indices = randperm(length(remaining_users), num_train);
    neighbor_indices = setdiff(1:length(remaining_users), train_indices);
    
    test_users = users(test_indices, :);
    train_users = users(train_indices, :);
    neighbors = users(neighbor_indices, :);

    train_reviews = reviews(train_indices)';
    test_reviews = reviews(test_indices)';
    neighbor_reviews = reviews(neighbor_indices)';
end


function [d] = euclid_dist(neighbor_list, users)
%EUCLID_DIS Summary of this function goes here
%   Detailed explanation goes here
    d = sqrt(sum((neighbor_list - users).^2, 2));
end

