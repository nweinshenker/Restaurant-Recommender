function X = ItSingValThresh(Y,r)

% Iterative Singular Value Thresholding for Matrix Completion
% 
% Assumes elements of Y are integers between 0 and 10^6

tol = 10^(-6); % difference between iterates at termination
[n,p] = size(Y);

% Fill in missing entries with zeros

X = zeros(n,p);
for i=1:n
    for j = 1:p
        if Y(i,j) < 10^6 && Y(i,j) > 0
            X(i,j) = Y(i,j);
        end
    end
end

% Iterate SVD

err = 10^6;


while err > tol
    [U,S,V] = svd(X,'econ');
    Xnew = round(U(:,1:r)*S(1:r,1:r)*V(:,1:r)');
    for i=1:n
        for j = 1:p
            if Y(i,j) < 10^6 && Y(i,j) > 0
                Xnew(i,j) = Y(i,j);
            end
        end
    end
    err = norm(X-Xnew,'fro');
    X = Xnew;
end
            