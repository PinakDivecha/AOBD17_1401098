T1 = (imread('eight.tif'));
[N, d] = size(T1);

pix_no = 20:10:50;
Error1 = [];
Error2 = [];

for k = 1:length(pix_no)
    err1=[];
    err2=[];

    for l = 1:10
        T = im2double(T1);
        T(2:pix_no(k):end)=0;
        
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

        T_desh = W*X;
        T_desh = T_desh';

        for i=1:N
            T_desh(i,:) = T_desh(i,:) + mu;
        end

        difference = im2double(T1) - im2double(T);
        squaredError = difference .^ 2;
        meanSquaredError = sum(squaredError(:)) / numel(T1);
        err1 = [err1 sqrt(meanSquaredError)];
        
        difference = im2double(T) - im2double(T_desh);
        squaredError = difference .^ 2;
        meanSquaredError = sum(squaredError(:)) / numel(T1);
        err2 = [err2 sqrt(meanSquaredError)];
        
        K = imabsdiff(mat2gray(T),mat2gray(T_desh));
        %err = [err norm(K)]; 
    end
    Error1 = [Error1 norm(err1)];
    Error2 = [Error2 norm(err2)];
end

disp(Error1);
disp(Error2);

subplot(1,2,1), imshow(T), title('Missing Value Image')
subplot(1,2,2), imshow(T_desh), title('Recovered Image')