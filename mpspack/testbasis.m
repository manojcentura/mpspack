% test program for all basis types: reg FB (incl fast), real PWs, ...
% barnett 7/10/08
% adapted from ~/bdry/inclus/test_evalbasis.m
%
% To Do:
% * reg FB: fix |x|=0 NaN problem

clear all classes
verb = 0;                            % use verb=0, N=50, for more of a test.
dx = 0.01; g = -1:dx:1;              % plotting region
[xx yy] = meshgrid(g, g);
M = numel(xx);
p = pointset([xx(:) + 1i*yy(:)], ones(size(xx(:)))); % set up n for x-derivs
k = 10;

for type = 1:5
  switch type
   case {1,2,3}             % ................. Reg FB: slow real/cmplx, fast
    N = 10;               
    opts.real = (type==1); opts.fast = (type==3);
    c = 0.5; b = regfbbasis(0, N, k, opts);
    js = 1:b.Nf;             % indices to plot, here all of them
    fprintf('evaluating Reg FB basis... real=%d, fast=%d\n', opts.real, opts.fast)
   case {4,5}              % ................. real plane waves: real/cmplx
    N = 10;
    opts.real = (type==4);
    b = rpwbasis(N, k, opts);
    c = 2.0; js = 1:b.Nf;             % indices to plot, here all of them
    fprintf('evaluating real plane wave basis... real=%d\n', opts.real)
  end
  tic; [A Ax Ay] = b.eval(p); t=toc;
  fprintf('\t%d evals (w/ x,y derivs) in %.2g secs = %.2g us per eval\n',...
          numel(A), t, 1e6*t/numel(A))
  n = numel(js);
  u = reshape(A(:,js), [size(xx) n]);   % make stack of rect arrays
  ux = reshape(Ax(:,js), [size(xx) n]); % from j'th cols of A, Ax, Ay
  uy = reshape(Ay(:,js), [size(xx) n]);
  nnans = numel(find(isnan([u ux uy])));
  if nnans, fprintf('\tproblem: # NaNs = %d\n', nnans); end
  if verb
    showfields(g, g, u, c, sprintf('type %d: u_j', type));         % values
    %showfields(g, g, ux, c*k, sprintf('type %d: du_j/dx', type)); % x-derivs
  end
  % errors in x-derivs...   plots should have no values larger than colorscale
  unje = (u(:,3:end,:)-u(:,1:end-2,:))/(2*dx) - ux(:,2:end-1,:); % FD error
  fprintf('\tmax err in u_x from FD calc = %g\n', max(abs(unje(:))))
  if verb, showfields(g, g(2:end-1), unje, c*(k*dx)^2, ...
                      sprintf('type %d: FD err in du_j/dx', type));
  end
  % errors in y-derivs...   plots should have no values larger than colorscale
  unje = (u(3:end,:,:)-u(1:end-2,:,:))/(2*dx) - uy(2:end-1,:,:); % FD error
  fprintf('\tmax err in u_y from FD calc = %g\n', max(abs(unje(:))))
  if verb, showfields(g(2:end-1), g, unje, c*(k*dx)^2, ...
                      sprintf('type %d: FD err in du_j/dy', type));
  end
end