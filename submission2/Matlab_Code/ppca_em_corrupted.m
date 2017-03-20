%filename = 'virus3.dat';
%T = importdata(filename);
T1 = (imread('eight.tif'));
T = (imread('eight.tif'));

[N, d] = size(T);

corr = 0.01:0.01:0.01;
Error1 = [];
Error2 = [];

tic
for k = 1:length(corr)
    T = imnoise(T1,'salt & pepper',corr(k));
    T = im2double(T);

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
    q = 100;
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

    for j = 1:d
        mu(j) = mean(T(:,j));
    end
    for i = 1:N
        Tnorm(i,:) = T(i,:) - mu;
    end

    X = M\W' * Tnorm';

    %T_desh = ((W/(W'*W)*M*X))';
    T_desh = W*X;
    T_desh = T_desh';

    for i=1:N
        T_desh(i,:) = T_desh(i,:) + mu;
    end

    difference = im2double(T1) - im2double(T);
    squaredError = difference .^ 2;
    meanSquaredError = sum(squaredError(:)) / numel(T1);
    rmsError1 = sqrt(meanSquaredError);

    difference = im2double(T1) - im2double(T_desh);
    squaredError = difference .^ 2;
    meanSquaredError = sum(squaredError(:)) / numel(T1);
    rmsError2 = sqrt(meanSquaredError);
        
    Error1 = [Error1 rmsError1];
    Error2 = [Error2 rmsError2];
end
toc

disp(Error1);
disp(Error2);

figure;
subplot(1,2,1), imshow(T), title('Corrupted image')
subplot(1,2,2), imshow(T_desh), title('Recovered image')


% plot(corr.*100, Error1);hold on;
% xlabel('% Corruption');
% ylabel('Error');
% 
% plot(corr.*100, Error2, '-r');hold on;
% xlabel('% Corruption');
% ylabel('Error');
% legend('Original-Corrupted Input','Original-Retrived');
% title('PPCA with EM');