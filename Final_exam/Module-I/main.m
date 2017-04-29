fprintf('Loading Skill ratings dataset.\n\n');

%  Load data
%load ('Skills.mat');

Y = randi([0,5],10,10)
R = zeros(10,10);
for i=1:10
    for j=1:10
        if Y(i,j)>0
        R(i,j)=1;
        else
        R(i,j)=0;
        end
    end
end
disp(R)

imagesc(Y);
ylabel('Skills');
xlabel('Users');

fprintf('\nProgram paused. Press enter to continue.\n');
pause;
X = randi([-1,2],10,10);
Theta = randi([-1,2],10,10);
num_users = 10; num_Skills = 10; num_features = 10;    
X = X(1:num_Skills, 1:num_features);
Theta = Theta(1:num_users, 1:num_features);
Y = Y(1:num_Skills, 1:num_users);
R = R(1:num_Skills, 1:num_users);

J = cofiCostFunc([X(:) ; Theta(:)], Y, R, num_users, num_Skills, ...
               num_features, 0);
           

fprintf('\nProgram paused. Press enter to continue.\n');
pause;



checkCostFunction;

fprintf('\nProgram paused. Press enter to continue.\n');
pause;


J = cofiCostFunc([X(:) ; Theta(:)], Y, R, num_users, num_Skills, ...
               num_features, 1.5);
           
fprintf('\nProgram paused. Press enter to continue.\n');
pause;


%  Check gradients by running checkNNGradients
checkCostFunction(1.5);

fprintf('\nProgram paused. Press enter to continue.\n');
pause;


skillList = loadSkillList();

my_ratings = zeros(10, 1);

my_ratings(1) = 5;
my_ratings(2) = 2;
 my_ratings(3) = 3;
fprintf('\n\nNew user ratings:\n');
for i = 1:length(my_ratings)
    if my_ratings(i) > 0 
        fprintf('Rated %d for %s\n', my_ratings(i), ...
                 SkillList{i});
    end
end

fprintf('\nProgram paused. Press enter to continue.\n');
pause;



fprintf('\nTraining collaborative filtering...\n');

Y = [my_ratings Y];
R = [(my_ratings ~= 0) R];

%  Normalize Ratings
[Ynorm, Ymean] = normalizeRatings(Y, R);

%  Useful Values
num_users = size(Y, 2);
num_Skills = size(Y, 1);
num_features = 10;

% Set Initial Parameters (Theta, X)
X = randn(num_Skills, num_features);
Theta = randn(num_users, num_features);

initial_parameters = [X(:); Theta(:)];

% Set options for fmincg
options = optimset('GradObj', 'on', 'MaxIter', 100);

% Set Regularization
lambda = 10;
theta = fmincg (@(t)(cofiCostFunc(t, Y, R, num_users, num_Skills, ...
                                num_features, lambda)), ...
                initial_parameters, options);

% Unfold the returned theta back into U and W
X = reshape(theta(1:num_Skills*num_features), num_Skills, num_features);
Theta = reshape(theta(num_Skills*num_features+1:end), ...
                num_users, num_features);

fprintf('Recommender system learning completed.\n');

fprintf('\nProgram paused. Press enter to continue.\n');
pause;


p = X * Theta';
my_predictions = p(:,1) + Ymean;

SkillList = loadSkillList();

[r, ix] = sort(my_predictions, 'descend');
fprintf('\nTop recommendations for you:\n');
for i=1:10
    j = ix(i);
    fprintf('Predicting rating %.1f for Skill %s\n', my_predictions(j), ...
            SkillList{j});
end

fprintf('\n\nOriginal ratings provided:\n');
for i = 1:length(my_ratings)
    if my_ratings(i) > 0 
        fprintf('Rated %d for %s\n', my_ratings(i), ...
                 SkillList{i});
    end
end

