%%Test bench for gmeans alghorithm
clear all;

%% Creating Gusian Mixtures
MU = [2 6;-3 -1;-1 2; 2 -1 ; 3 4; 4 2; -3 5;];
SIGMA = cat(3,[1 0;0 .5],[1 0;0 1], [0.1 0;0 0.5], [0.5 0;0 1], [0.1 0;0 0.1], [0.5 0;0 0.5], [1 0;0 1]);
p = ones(1,7)/7;
obj = gmdistribution(MU,SIGMA,p);

%% Draw elements from Gaussian Mixtures and plot it
rng(1); % Seed is constant for reproducibility
numberOfElements = 4500;
X = random(obj,numberOfElements); % Draw
figure(1);
scatter(X(:,1),X(:,2),10,'.')
hold on;

%% Test G-Means
[groups, centers, ad] = gmeans(X, numberOfElements*0.001);

%% Plot for debug
figure(1)
for i = 1:length(MU)
    plot(MU(:,1),MU(:,2), 'g*');
end

for i = 1:length(centers)
    plot(centers(:,1),centers(:,2), 'r*');
end
    