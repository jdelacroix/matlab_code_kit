
addpath('./matlab_code_kit/');

% [Axis], max elements per node, max tree depth
q = mcodekit.tree.quad_tree([0,0,10,10],4,8);

n = 20;
% X = [logspace(0,log10(6),n)-1]; X = [X 10-X(1:end-1)];
% Y = [logspace(0,log10(6),n)-1]; Y = [Y 10-Y(1:end-1)]
% [x,y] = meshgrid(X,Y);
% x = x(:);
% y = y(:);
% n = length(x);
%
x = 10.*rand(n,1);
y = 10.*rand(n,1);

% x = 10.*normrnd(0,1,n,1);   x = 10*(x-min(x))/(max(x)-min(x));
% y = 10.*normrnd(0,1,n,1);   y = 10*(y-min(y))/(max(y)-min(y));

% Construct quadtree mesh
for i=1:n
    q.insert_point([x(i) y(i)]);
    drawnow;
end

% Mount Poisson system to be solved
