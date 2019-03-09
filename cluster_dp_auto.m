function [rho] = cluster_dp_auto(dist, para)
%% Input and Output
% INPUT :
% dist : A nCases*nCases matrix. each dist(i, j) represents the distance
%        between the i-th datapoint and j-th datapoint.
% para : options
%        percent : The parameter to determine dc. 1.0 to 2.0 can often yield good performance.
%        method  : alternative ways to compute density. 'gaussian' or
%                  'cut_off'. 'gaussian' often yields better performance.
% OUTPUT :
% cluster_labels : a nCases vector contains the cluster labls. Lable equals to 0 means it's in the halo region
% center_idxs    : a nCluster vector contains the center indexes.

%% Estimate dc
percent = para.percent;
N = size(dist,1);
position = round(N*(N-1)*percent/100);
tri_u = triu(dist,1);      
sda = sort(tri_u(tri_u~=0));     
dc = sda(position);
clear sda; clear tri_u;
%% Compute rho(density)
switch para.method
        % Gaussian kernel
    case 'gaussian'
        rho = sum(exp(-(dist./dc).^2),2)-1;
        % "Cut off" kernel
    case 'cut_off'
        rho = sum((dist-dc)<0, 2);
end