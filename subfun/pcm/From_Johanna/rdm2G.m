function Gout=rdm2G(rdminput,plotflag,plottext)
% function Gout=rdm2G(rdminput,plotflag,plottext)

H=eye(size(rdminput))-ones(size(rdminput))/size(rdminput,1); 
Gout=-0.5*H*rdminput*H;

if plotflag
  figure;subplot(1,2,1);imagesc(rdminput);colorbar;title(['RDM ' plottext])
  subplot(1,2,2);imagesc(Gout);colorbar;title(['G ' plottext])
end

  
