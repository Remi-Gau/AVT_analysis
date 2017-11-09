% create RDM and G for aud-tac simulations and real data analysis
% Johanna Zumer, 2017

% start with generating G matrices: start with dissimilarity matrix and convert to G (second moment)
G_eye=eye(ncond);


% Temporal integration window
% 1) TIW, varying width and centre in 2 different sub-models
rdmodel_1a=1-eye(ncond);
rdmodel_1a(3:5,3:5)=0;
% upper-diagonal norm mentioned in Diedrichsen & Kriegeskorte (2017) just after equation 30
G_1a=nearestSPD(rdm2G(udnorm(rdmodel_1a),plotflag,'model 1a'));

rdmodel_1b=1-eye(ncond);
rdmodel_1b(2:6,2:6)=0;
G_1b=nearestSPD(rdm2G(udnorm(rdmodel_1b),plotflag,'model 1b'));


% 2) Asymmetry: AT will be similar to each other but different from TA (vice versa)
rdmodel_2a=1-eye(ncond);
rdmodel_2a(1:4,1:4)=0;
rdmodel_2a(4:7,4:7)=0;
G_2a=nearestSPD(rdm2G(udnorm(rdmodel_2a),plotflag,'model 2'));

% 3) Symmetric pairs: TA70 will be more like itself and AT70 than others
rdmodel_3a=1-eye(ncond);
rdmodel_3a(1,7)=0;
rdmodel_3a(2,6)=0;
rdmodel_3a(3,5)=0;
rdmodel_3a(4,4)=0;
rdmodel_3a(5,3)=0;
rdmodel_3a(6,2)=0;
rdmodel_3a(7,1)=0;
G_3a=nearestSPD(rdm2G(udnorm(rdmodel_3a),plotflag,'model 3'));


