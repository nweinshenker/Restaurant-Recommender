%% Load review data

fid = fopen('restaurants_subset.json');
raw = fread(fid,inf);
str = char(raw);
fclose(fid);
restaurants = jsondecode(str);

fid = fopen('users_subset.json');
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


%% Plotting
users_list = plot_restaurant_user(4, r_ids, restaurants, u_ids, users_matrix);


%% Access a random user from the user list
test_index = randi(length(users_list), 1);
test_user = users_list(test_index, :);



%% KNN
[close_users, distance] = neareset_neighbors(test_user, users_list, 1);

%% Plot how we want
figure()
scatter(users_list(:,1), users_list(:,2));
line(test_user(:,1),test_user(:,2),'marker','x','color','k',...
   'markersize',10,'linewidth',2)

%// radius
r = max(distance);

%// center
c = test_user;

pos = [c-r 2*r 2*r];
rectangle('Position',pos,'Curvature',[1 1])

%%
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


%% Example of training a 
X = meas;
Y = species;

Mdl = fitcknn(X,Y,'NumNeighbors',5,'Standardize',1);
Mdl.NumNeighbors = 4;


%% Helper Functions
function [users_to_plot] =  plot_restaurant_user(restaurant_i, r_ids, restaurants, u_ids, users_matrix)
    r_id = r_ids(restaurant_i);
    r = restaurants.(r_id{1});
    
    reviewfields = fieldnames(r.reviews);

    users_to_plot = zeros(length(r.reviews), 2);
    
    for review_i = 1:length(r.reviews)
        u_id = r.reviews(review_i).user_id;
        u_id = strrep(string(u_id), '-', '_');
        u_i = find(contains(u_ids,'x' + u_id));
        if isempty(u_i)
            u_i = find(contains(u_ids, u_id));
        end
        
        users_to_plot(review_i, :) = users_matrix(u_i, :);        
    end 
    
%     figure();
%     scatter(users_to_plot(:,1), users_to_plot(:,2));
    

end

function [x_closest, euc_dis] = neareset_neighbors(test_user, user_list, k)
   %% Compute the distance between the test_user and the list of users
    x_closest = zeros(k, size(user_list,2));

    ind_closest = zeros(k, 1);

    distance = euclid_dist(test_user, user_list);

    %sort all the distances
    [sorted_dist,Ind] = sort(distance); 
    
    ind_closest = Ind(1:k);
    x_closest(:, :) = user_list(ind_closest(:), :);
    euc_dis = sorted_dist(1:k);
       
end