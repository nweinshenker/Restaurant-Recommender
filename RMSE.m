
function [squared_error] = RMSE(test_point,sample_points)
%RMSE Summary of this function goes here
%   Detailed explanation goes here
squared_error = sqrt(sum((test_point - sample_points).^2,2)/ length(sample_points));
end

