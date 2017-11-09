function [ rdm_norm ] = udnorm(rdm)
% function [ rdm_norm ] = udnorm(rdm)
% Takes norm of upper diagonal elements
% Johanna Zumer, 2017

rdm_norm=squareform(squareform(rdm)/norm(squareform(rdm)));

end

