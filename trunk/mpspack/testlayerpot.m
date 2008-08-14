% test routine for layer potential basis objects, interaction with domains
% Also see * testlpquad for more low-level tests of layerpot.S etc.
%          * testbvp.m for GRF test on interior values
% barnett 7/30/08, GRF test 8/4/08

clear classes
sh = 's';                    % 't' or 's' for triangle or smooth curve

if sh=='s', s = segment.smoothstar([], 0.3, 3); Ms = 50:50:150; % periodic anal
elseif sh=='t', s = segment.polyseglist([], [1 1i exp(4i*pi/3)], 'g');  % tri
  Ms = 20:20:100;
end
k = 0;                     % allows tau=1 test to work
d = domain(s, 1);                    % interior domain
[g.x g.ii g.gx g.gy] = d.grid(0.05);                     % some interior points
for m = 1:numel(Ms)
  M = Ms(m); s.requadrature(ceil(M/numel(s))); % can also try 'g', better
  numel(vertcat(s.w))          % show # quad pts total
  d.clearbases; d.addlayerpotbasis([], 'd', k); D = d.evalbases(g);
  tau = ones(size(D,2),1);      % unity col vec
  ug = D * tau;                 % field on interior grid pts
  figure; d.plot; axis equal; u = NaN*zeros(size(g.ii)); u(g.ii)=ug;
  imagesc(g.gx, g.gy, log10(abs(u+1))); colorbar; caxis([-16 0]);
  title('DLP interior error at k=0 (log10 scale)');
end

% interior Helmholtz GRF via SLP&DLP............................................
k = 10;
o = []; if sh=='t', o.quad = 'a'; end     % not default Kress, rather, crude.
d.clearbases;
d.addlayerpotbasis([], 's', k, o); d.addlayerpotbasis([], 'd', k, o);
s.requadrature(100);                   % note you can requad after defining LPs
xsing = 1 + 1i;                        % location of singularity in a Helm soln
u = @(x) bessely(0, k*abs(x - xsing)); % an exact Helmholtz soln in domain
R = @(x) abs(x - xsing);
du = @(x) -k*(x-xsing)./R(x).*bessely(1, k*R(x)); % grad u as C# (why? u=Re)
ux = @(x) real(du(x)); uy = @(x) imag(du(x)); % u_x and u_y funcs
A = []; for seg=s; A = [A; d.evalbases(seg)]; end
x = vertcat(s.x); un = real(conj(du(x)).*vertcat(s.nx));  % u_n exact value
v = A * [un; -u(x)];       % field on bdry generated by GRF sigma=u_n, tau = -u
fprintf('SLP + DLP GRF bdry error L2 norm = %g\n', norm(v-u(x))*sqrt(2*pi/numel(x)))
