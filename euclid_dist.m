function [d] = euclid_dist(test_point, sample_point)
%EUCLID_DIS Summary of this function goes here
%   Detailed explanation goes here
d = sqrt(sum((test_point - sample_point).^2, 2));

return 
end

