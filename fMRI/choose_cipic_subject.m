function [subuse]=choose_cipic_subject(xsub,cdir,whitenx)
% function [hrir,dist]=choose_cipic_subject(xsub,cdir,whitenx)
%
% xsub:    size 1 x 17 of headshape measurements; if not using an entry, fill it with NaN
% cdir:    directory path of CIPIC 
% whitenx: =1 means to normalise the values prior to dsearchn (it may not
%          make a difference if dsearchn whitens anyway!? I haven't found it to make
%          a difference).  =0 if not prewhiten.

load(fullfile(pwd, 'CIPIC_hrtf_database', 'anthropometry', 'anthro.mat'));

if nargin<3
  whitenx=0;
end
if ~all(size(xsub)==[1 17])
  error('xsub wrong size')
end


X(dsearchn(id,28),find(~isnan(xsub)))=nan;
X(dsearchn(id,33),find(~isnan(xsub)))=nan;
X(dsearchn(id,48),find(~isnan(xsub)))=nan;
X(dsearchn(id,124),find(~isnan(xsub)))=nan;
X(dsearchn(id,127),find(~isnan(xsub)))=nan;
X(dsearchn(id,135),find(~isnan(xsub)))=nan;
X(dsearchn(id,137),find(~isnan(xsub)))=nan;
X(dsearchn(id,152),find(~isnan(xsub)))=nan;
X(dsearchn(id,155),find(~isnan(xsub)))=nan;
X(dsearchn(id,162),find(~isnan(xsub)))=nan;
X(dsearchn(id,163),find(~isnan(xsub)))=nan;



if whitenx
  % normalised version;
  normfactor=sqrt(nansum(X.^2));
  xnorm=X./repmat(normfactor,[size(X,1) 1]);
  xsubnorm=xsub./normfactor;
  [ind,dist]=dsearchn(xnorm(:,~isnan(xsubnorm)),xsubnorm(~isnan(xsubnorm)));
else
  [ind,dist]=dsearchn(X(:,~isnan(xsub)),xsub(~isnan(xsub)));
end

subnums=id;

subuse=subnums(ind+1);





