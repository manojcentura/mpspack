% NUFBBASIS - Create a basis of irregular Fourier-Bessel functions.
% This objects creates a basis of irregular Fourier-Bessel functions of
% degree nu*(1:N) (for Fourier-Bessel sine functions) or degree nu*(0:N)
% (for Fourier-Bessel cosine functions). A nufbbasis object is created by
%
% nufb=nufbbasis(origin,nu,offset,branch,N,k,opts)
% origin: The origin of the Fourier-Bessel functions
% nu    : The fractional order of the basis
% offset: The direction that corresponds to the angular variable theta=0
% branch: Direction of the branch cut. It must not point into the domain
% N     : Degree of the basis fct.
% opts  : Optional arguments. Currently supported is
%         - opts.type    : 's'  Create basis of Fourier-Bessel sine fct.
%                          'c'  Create basis of Fourier-Bessel cosine fct.
%                          'cs' Create basis of Fourier-Bessel cosine and
%                               sine functions 

classdef nufbbasis < handle & basis

    % Basis of irregular Fourier-Bessel functions.

    properties
        origin   % Origin of the Fourier-Bessel fct.
        nu       % Real parameter that determines the fractional order of
                 % the Bessel fct.
        branch   % Complex angle that determines the branch cut
        offset   % Complex angle that determines the zero line of the Bessel
                 % fct.
        type     % 'c': Fourier-Bessel cosine basis
                 % 's': Fourier-Bessel sine basis
                 % 'cs': Fourier-Bessel cosine/sine basis (default)
    end

    methods
        function nufb = nufbbasis(origin,nu,offset,branch,N,k,opts)
            % 
            if nargin<7, opts=[]; end;
            if ~isfield(opts,'type'), opts.type='cs'; end;
            if nargin<6, k=NaN; end;
            if nargin<5, N=20; end;

            nufb.k=k;
            nufb.N=N;
            nufb.branch=branch;
            nufb.offset=offset;
            nufb.nu=nu;
            nufb.origin=origin;
            if opts.type=='s', nufb.type='s'; nufb.Nf=N; end;
            if opts.type=='c', nufb.type='c'; nufb.Nf=N+1; end;
            if strcmp(opts.type,'cs'), nufb.type='cs'; nufb.Nf=2*N+1; end;

        end
        function [A, A1, A2] = eval(nufb,pts)

            % Evaluates the basis at a given set of points
            N=nufb.N; k=nufb.k; nu=nufb.nu; origin=nufb.origin;
            np=length(pts.x); % Number of points
            R=abs(pts.x-nufb.origin);
            ang=angle(-(pts.x-nufb.origin)./nufb.branch);
            offang=angle(-nufb.offset./nufb.branch);
            if nufb.type=='s',
                bes=besselj(nu*(0:N+1),k*R);
                s=sin(nu*(ang-offang)*(1:N));
                A=bes(:,2:end-1).*s;
            elseif nufb.type=='c',
                bes=besselj(nu*(-1:N+1),k*R);
                c=cos(nu*(ang-offang)*(0:N));
                A=bes(:,2:end-1).*c;
            elseif strcmp(nufb.type,'cs'),
                bes=besselj(nu*(-1:N+1),k*R);
                s=sin(nu*(ang-offang)*(1:N));
                c=cos(nu*(ang-offang)*(0:N));
                A=[bes(:,2:end-1).*c,bes(:,3:end-1).*s];
            end
            if nargin>1,
                if numel(find(R==0))>0,
                    warning('Computing x/y or normal derivatives of regular Bessel functions at origin not implemented');
                end
                besr=k/2*(bes(:,1:end-2)-bes(:,3:end));
                if nufb.type=='s',
                    Ar=besr.*s;
                    At=nu*repmat(1:N,np,1).*bes(:,2:end-1).*cos(nu*(ang-offang)*(1:N));
                elseif nufb.type=='c',
                    Ar=besr.*c;
                    At=-nu*repmat(0:N,np,1).*bes(:,2:end-1).*sin(nu*(ang-offang)*(0:N));
                elseif strcmp(nufb.type,'cs'),
                    Ar=[besr.*c,besr(:,2:end).*s];
                    At=[-nu*repmat(0:N,np,1).*bes(:,2:end-1).*sin(nu*(ang-offang)*(0:N)),...
                        nu*repmat(1:N,np,1).*bes(:,3:end-1).*cos(nu*(ang-offang)*(1:N))];
                end
                ang0=angle(pts.x-origin); % Angle with respect to the original
                % coordinate system shifted by
                % origin
                cc=repmat(cos(ang0),1,nufb.Nf); ss=repmat(sin(ang0),1,nufb.Nf);
                RR=repmat(R,1,nufb.Nf);
                if nargout==2,
                    nx=repmat(real(pts.nx),1,nufb.Nf); ny=repmat(imag(pts.nx),1,nufb.Nf);
                    A1=Ar.*(nx.*cc+ny.*ss)+At.*(ny.*cc-nx.*ss)./RR;
                end
                if nargout==3,
                    A1=cc.*Ar-ss.*At./RR; A2=ss.*Ar+cc.*At./RR;
                end
            end
        end
    end
end

            
            
            
            
            
            