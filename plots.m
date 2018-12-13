close all;

load('users.mat');

figure();
scatter(users.avg_restaurant_rating, users.review_count, 15, users.noras_rating)
title('Avg restaurant rating vs Review Count');
xlabel('avg restaurant rating');
ylabel('review count');

figure();
scatter(users.cats_italian, users.useful, 15, users.noras_rating)
title('Cats italian vs useful');
xlabel('cats italian');
ylabel('useful');

figure()
scatter(users.cats_pizza, users.review_count, 15, users.noras_rating)
title('Cats pizza vs review Count');
xlabel('cats pizza');
ylabel('review count');

figure()
scatter(users.avg_restaurant_rating, users.cats_italian, 15, users.noras_rating)
title('avg restaurant rating vs cats italian');
xlabel('avg restaurant rating');
ylabel('cats italian');

figure()
scatter(users.cats_pizza, users.cats_italian, 15, users.noras_rating)
title('cats pizza vs cats italian');
xlabel('cats pizza');
ylabel('cats italian');