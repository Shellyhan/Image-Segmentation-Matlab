%%
% K-Means Image Segmentation:
%       With both Color and Spatial Features;
%       Use # of peaks in image histogram as the desired number of
%       clusters.
%
% Input: 
%   I = input image
%	Thr = threshold for gaussian kernel for blurring the image
%   filter = range for peak searching in image histogram
%
% Output:
%   Means = Array of mean pixels
%   result = segmented image
% 
% Comments:
% Considering both color and spatial features help to reduce the effect
% from noise.
% However, due to a random selection of pixels to start with, the algorithm
% could have becom arbitary bad.

%%
clc;
clear;
close all;
%% input
% I = imread('bird2.jpg');
I = imread('fruit.jpg');

Thr = 5;
filter = 45;
% Automatic set clustering number to the # of peaks in image histogram
Iblur = imgaussfilt(I, Thr);
K = numel(findpeaks(imhist(rgb2gray(Iblur)),'MinPeakProminence',filter));

%% Image input processing:
IDouble = im2double(I);
imageSize = [size(IDouble,1), size(IDouble,2)];

Color = reshape(IDouble,imageSize(1)*imageSize(2),3);       % Get the Color Featured Array for RBG
[x,y] = meshgrid(1:imageSize(1),1:imageSize(2));            % Get the Spatial Feature Array
Spatial = [y(:)/max(y(:)),x(:)/max(x(:))];
Array = [Color, Spatial*0.5];                   %less weight on spatial feature

%% K-means
Means = Array(ceil(rand(K,1)*size(Array,1)),:);     % Random Cluster Centers
Label = zeros(size(Array,1),K+2);       % Label Array to record distances and the corresponding cluster
index = 15;     % Run for 20 times
iter = 0;
allMeans = [];
previousMeans = [];
firstRound = true;

for n = 1:index
   for i = 1:size(Array,1)
      for j = 1:K
        Label(i,j) = norm(Array(i,:) - Means(j,:));             % Distance between pixels and mean points 
      end
      [Distance, Cluster] = min(Label(i,1:K));      % Find the belonging cluster and distance
      Label(i,K+1) = Cluster;                                % Set the label for current cluster
      Label(i,K+2) = Distance;                          % Record the distance between x and m
   end
   previousMeans = Means;
   for j = 1:K
      A = (Label(:,K+1) == j);                          % All pixels in cluster i
      Means(j,:) = mean(Array(A,:));                      % Recomputer new means
      if sum(isnan(Means(:))) ~= 0                    % Check means exist for now
         No = find(isnan(Means(:,1)) == 1);           % Find those not exist mean
         for k = 1:size(No,1)
         Means(No(k),:) = Array(randi(size(Array,1)),:);    % Assign a random number
         end
      end
   end
   
   %print the segmentated image:----------------------
   X = zeros(size(Array));
    for i = 1:K
        idx = find(Label(:,K+1) == i);
      X(idx,1:3) = repmat(Means(i,1:3),size(idx,1),1); 
    end
    result = reshape(X(:,1:3),imageSize(1),imageSize(2),3);
%     countMeans = num2str(numel(unique(Means(1:3,1))));
    subplot(131), imshow(result), title(['Image with ' num2str(K) ' means']);

   %print the mean changes:----------------------
   iter = iter + 1;
   allMeans(iter) = mean(abs(Means(1:3)-previousMeans(1:3)));
   subplot(132), plot(1:iter, allMeans ), xlabel('iteration #'), title('Averaged mean movement');axis square
   drawnow
end
%%
%plot the clusters:
a = Label(:,K+1);
a = reshape(a,imageSize(1),imageSize(2));
b = label2rgb(a, 'jet', 'w', 'shuffle');
subplot(133), imshow(b),title('Clusters of the result');

%plot the 3D pixel distribution:
figure;
Inew = double(I);
subplot(221), imshow(I);
sample = zeros(size(Inew,1),size(Inew,2));
sample(1:3:end,1:3:end) = 1;
R = Inew(:,:,1); Rx = R(sample==1); Rn = randn( numel(Rx),1 )/3;
G = Inew(:,:,2); Gx = G(sample==1); Gn = randn( numel(Rx),1 )/3;
B = Inew(:,:,3); Bx = B(sample==1); Bn = randn( numel(Rx),1 )/3;
subplot(222),
scatter3( Rx(:)-Rn, Gx(:)-Gn, Bx(:)-Bn, 3, [ Rx(:), Gx(:), Bx(:) ]/255 );
title('Pixel Distribution Before Segementation')
xlim([0,255]),ylim([0,255]),zlim([0,255]);axis square

%the result image:
subplot(223), imshow(result);
maxValue = max(max(max(result)));
result = result*255/maxValue;
sample = zeros(size(result,1),size(result,2));
sample(1:3:end,1:3:end) = 1;
R = result(:,:,1); Rx = R(sample==1); Rn = randn( numel(Rx),1 )/3;
G = result(:,:,2); Gx = G(sample==1); Gn = randn( numel(Rx),1 )/3;
B = result(:,:,3); Bx = B(sample==1); Bn = randn( numel(Rx),1 )/3;
subplot(224),
scatter3( Rx(:)-Rn, Gx(:)-Gn, Bx(:)-Bn, 3, [ Rx(:), Gx(:), Bx(:) ]/255 );
title('Pixel Distribution After Segementation')
xlim([0,255]),ylim([0,255]),zlim([0,255]);axis square


