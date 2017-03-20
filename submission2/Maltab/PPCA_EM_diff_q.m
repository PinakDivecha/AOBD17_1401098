T = im2double(imread('eight.tif'));
[N, d] = size(T);

q1 = 20:5:100;

for j = 1:d
    mu(j) = mean(T(:,j));
end

S = zeros(d);
for n = 1:N
    S = S + (T(n,:)' - mu') * (T(n,:)' - mu')';
end
S = 1/N * S;        %Covariance matrix
[d, ~] = size(S);

%%%%% EM algorithm

% init
Error=[];
for i=1:length(q1)
    q = q1(i);
    W = ones(d, q);
    sigma = 1;
    epsilon = 0.001;

    % loop
    while (true)
        M = W'*W + sigma^2 * eye(q);
        W_new = S*W*inv(sigma^2 * eye(q) + inv(M)*W'*S*W);
        sigma_new = sqrt(1/d * trace(S - S*W*inv(M)*W_new'));

        if(abs(sigma_new - sigma) < epsilon && max(max(abs(W_new - W))) < epsilon)
            break;
        end

        W = W_new;
        sigma = sigma_new;
    end

    W = W_new;
    sigma = sigma_new;

    [N, d] = size(T);
    [~, q] = size(W);

    M = W'*W + sigma^2 * eye(q);

    for i = 1:N
        Tnorm(i,:) = T(i,:) - mu;
    end

    X = M\W' * Tnorm';
    [~, N] = size(X);

    T_desh = W*X;
    T_desh = T_desh';

    for i=1:N
        T_desh(i,:) = T_desh(i,:) + mu;
    end
    
    difference = im2double(T) - im2double(T_desh);
    squaredError = difference .^ 2;
    meanSquaredError = sum(squaredError(:)) / numel(T);
    rmsError = sqrt(meanSquaredError);

    Error=[Error rmsError];
end

disp(Error);
plot(q1,Error);