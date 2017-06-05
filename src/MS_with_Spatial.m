%%
% Mean-Shift Image Segmentation:
%       with both Color and Spatial Features
%
% Input: 
%   I = input image
%	bwS = the bandwidth of spatial kernel
%	bwC = the bandwidth of color kernel
%	Thr = the threshod of the convergence
%   toPlot = to display the result for each iteration
%
% Output:
%   Means = Array of mean pixels
%   result = segmented image
% 
% Comments:
%   With a Gaussian kernel which take spatial correlation into
%   consideration, the result gets much better.
% 
% Reference: This algorithm is introduced in Cmaniciu etal.'s PAMI paper 
% "Mean shift: a robust apporach toward feature space analysis", 2002.
%% initialization

clear; 
close all;
clc;
%% read image and inputs:
I = double( imread('fruit.jpg') );
bwS = 20;       %Bandwidth for spatial
bwC = 32;       %Bandwidth for color
Thr = 0.5;        %Threshold for stoping iteration 
toPlot = true;

%% reshape:
I = double(I);
[a,b,c] = size(I);
result = I;
conv = 0;
iter = 0;

% reshape the image to array:
Array = padarray(I,[a,b,0],'symmetric');
% pre-set table:
wTable = exp( -(0:255^2)/bwC^2 );
Means = [];
%%for plotting:
if toPlot 
    figure(randi(1000)+1000); 
end

%% main loop
while ~conv
    Votes = 0;
    newVotes = 0;
    for i = -bwS:bwS
        for j = -bwS:bwS
            if ( i~=0 || j~=0 )
                % Added a gaussian kernel:
                Spatial = exp(-(i^2+j^2)/(bwS/3)^2/2);
                CurrX =  Array(a+i:2*a+i-1, b+j:2*b+j-1, 1:c);
                DiffX = (result-CurrX).^2;
                % color feature:
                CSMeans = repmat(prod(reshape(wTable(DiffX+1), a, b, c), 3), [1, 1, c]);
                % taking different weights from two feature array:
                newFeature = Spatial.*CSMeans;
                Votes = Votes+ newFeature;
                newVotes = newVotes+CurrX.*newFeature;
            end
        end
    end
    % normalized the value of mean:
    CurrY = newVotes./(Votes + eps);
    % Calculate the changed distances:
    myMeans = mean(abs(round(CurrY(:))-round(result(:))));
    result = round(CurrY);    
    Means(iter+1) = myMeans;
            
    %% ploting:
    if toPlot
        subplot(121), imshow(uint8(result)),axis image, title(['iteration # ' num2str(iter) ]);
        % num2str(myMeans)
        subplot(122), plot(0:iter, Means ), xlabel('iteration #'), title('averaged mean-shift'); axis square
        drawnow
    end
    
    %% check for satisfying the threshold:
    % finish if converge:
    if myMeans <= Thr
        conv = 1;
    else % otherwise iterate:
        iter = iter+1;
    end
end

%% plot result:
sample = zeros(size(I,1),size(I,2));
sample(1:3:end,1:3:end) = 1;

R = I(:,:,1); Rx = R(sample==1); Rn = randn( numel(Rx),1 )/3;
G = I(:,:,2); Gx = G(sample==1); Gn = randn( numel(Rx),1 )/3;
B = I(:,:,3); Bx = B(sample==1); Bn = randn( numel(Rx),1 )/3;
figure, 
subplot(221), imshow(uint8(I)), axis image;
subplot(223), imshow(uint8(result)), axis image;
subplot(222)
scatter3( Rx(:)-Rn, Gx(:)-Gn, Bx(:)-Bn, 3, [ Rx(:), Gx(:), Bx(:) ]/255 );
title('Pixel Distribution Before Meanshift')
xlim([0,255]),ylim([0,255]),zlim([0,255]);axis square

R = result(:,:,1); Ry = R(sample==1); Rn = randn( numel(Rx),1 )/3;
G = result(:,:,2); Gy = G(sample==1); Gn = randn( numel(Rx),1 )/3;
B = result(:,:,3); By = B(sample==1); Bn = randn( numel(Rx),1 )/3;
subplot(224)
scatter3( Ry(:)-Rn, Gy(:)-Gn, By(:)-Bn, 3, [ Rx(:), Gx(:), By(:) ]/255 );
title('Pixel Distribution After Meanshift')
xlim([0,255]),ylim([0,255]),zlim([0,255]);axis square;

