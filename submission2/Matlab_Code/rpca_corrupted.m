addpath('../');

% read image and add the mask
img = im2double(imread('eight.tif'));
 
corr = 0.01:0.01:0.05;
Error=[];

for m=1:length(corr)
    img_corrupted = imnoise(img,'salt & pepper',corr(m));
    ws = 16; % window size
    no_patches = int16(size(img, 1) / ws);
    X = zeros(no_patches^2, ws^2);
    k = 1;
    for i = (1:no_patches*2-1)
        for j = (1:no_patches*2-1)
            r1 = 1+(i-1)*ws/2:(i+1)*ws/2;
            r2 = 1+(j-1)*ws/2:(j+1)*ws/2;
            patch = img_corrupted(r1, r2');
            X(k,:) = patch(:);
            k = k + 1;
        end
    end

    % apply Robust PCA
    lambda = 0.02; % close to the default one, but works better
    tic
    [L, S] = RobustPCA(X, lambda, 1.0, 1e-5);
    toc

    % reconstruct the image from the overlapping patches in matrix L
    img_reconstructed = zeros(size(img));
    img_noise = zeros(size(img));
    k = 1;
    for i = (1:no_patches*2-1)
        for j = (1:no_patches*2-1)
            % average patches to get the image back from L and S
            % todo: in the borders less than 4 patches are averaged
            patch = reshape(L(k,:), ws, ws);
            r1 = 1+(i-1)*ws/2:(i+1)*ws/2;
            r2 = 1+(j-1)*ws/2:(j+1)*ws/2;
            img_reconstructed(r1, r2) = img_reconstructed(r1, r2) + 0.25*patch;
            patch = reshape(S(k,:), ws, ws);
            img_noise(r1, r2) = img_noise(r1, r2) + 0.25*patch;
            k = k + 1;
        end
    end
    img_final = img_reconstructed;
    img_final(~isnan(img_corrupted)) = img_corrupted(~isnan(img_corrupted));
    
    difference = img - img_final;
    squaredError = difference .^ 2;
    meanSquaredError = sum(squaredError(:)) / numel(img);
    rmsError = sqrt(meanSquaredError);
    
    Error = [Error rmsError];
end


% show the results
figure;
subplot(1,2,1), imshow(img_corrupted), title('Corrupted image')
subplot(1,2,2), imshow(img_final), title('Recovered image')

disp(Error);
figure;
plot(corr.*100, Error);
xlabel('% Corruption');
ylabel('Error');
legend('Original-Corrupted Input','Original-Retrived');
title('RPCA');