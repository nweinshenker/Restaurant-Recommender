function [distance] = Mik(test_sample,sample_point, power)
%RTMS Summary of this function goes here
%   Detailed explanation goes here
    distance =  sum(nthroot(abs(test_sample-sample_point).^power,power));
end

