function compile_RSA_pool_hs_pdf

close all
clear
clc

Do_hs_Idpdtly = 1;
if Do_hs_Idpdtly
    hs_sufix='lhs_-_';
else
    hs_sufix='';
end

start_dir = fullfile(pwd, '..','..','..','..');
cd (start_dir)

RSA_fig_dir = fullfile(start_dir, 'figures', 'RSA','Cdt');
RSA_Dest_fig_dir = fullfile(RSA_fig_dir,'compiled');
mkdir(RSA_Dest_fig_dir);
mkdir(fullfile(RSA_Dest_fig_dir,'Subjects'));

Cor_fig_dir = fullfile(start_dir, 'figures', 'Correlation','Cdt');
Cor_Dest_fig_dir = fullfile(Cor_fig_dir,'compiled');
mkdir(Cor_Dest_fig_dir);
mkdir(fullfile(Cor_Dest_fig_dir,'Subjects'));

Reg_fig_dir = fullfile(start_dir, 'figures', 'Regression','Cdt');
Reg_Dest_fig_dir = fullfile(Reg_fig_dir,'compiled');
mkdir(Reg_Dest_fig_dir);
mkdir(fullfile(Reg_Dest_fig_dir,'Subjects'));


for Cor_Reg_RSA=1:3
    
    switch Cor_Reg_RSA
        case 1
            Distances = {...
                'Correlation_-_All_CV'
                'Correlation_-_Day_CV'
                'Correlation'};
            
            Fig_dir = Cor_fig_dir;
            Dest_fig_dir = Cor_Dest_fig_dir;
            Distances_to_plot = 1:3;
            
        case 2
            Distances = {...
                'Regression_-_All_CV'
                'Regression_-_Day_CV'
                'Regression'};
            
            Fig_dir = Reg_fig_dir;
            Dest_fig_dir = Reg_Dest_fig_dir;
            Distances_to_plot = 1:3;
            
        case 3
            Distances = {...
                'Spearman_distance'
                'Spearman_-_Day_CV_handmade'
                'Spearman_-_All_CV_handmade'
                'Euclidian_distance'
                'Euclidian_-_Day_CV_handmade'
                'Euclidian_-_All_CV_handmade'
                'RSA_toolbox_Euclidian_-_Day_CV'
                'RSA_toolbox_Euclidian_-_All_CV'
                'RSA_toolbox_Mahalanobis_-_Day_CV'
                'RSA_toolbox_Mahalanobis_-_All_CV'
                };
            
            Fig_dir = RSA_fig_dir;
            Dest_fig_dir = RSA_Dest_fig_dir;
            Distances_to_plot = 1:8;
    end
    
    
    %% volume only
    for iDistance = Distances_to_plot
        Pattern = sprintf('%s_-_Stim_and_Targets_-_beta-trim_-_ROI_-_ranktrans-*_-_plotranktrans-*.tiff',...
            Distances{iDistance});
        
        Output_file = sprintf('%s_-_Stim_and_Targets_vol_%s_%s.pdf',Distances{iDistance},hs_sufix,date);
        
        convert_to_pdf(Fig_dir, Pattern, hs_sufix, Dest_fig_dir, Output_file)
    end

    %% volume and surface
    for isStim = 0:1
        
        if isStim
            stim_suffix = 'Stim_VS_Stim';
        else
            stim_suffix = 'Targets_VS_Targets';
        end
        
        
        for isRaw = 0:1
            
            %% volume
            if isRaw
                beta_suffix = 'beta-raw';
                Distances_to_plot = 1:8;
            else
                beta_suffix = 'beta-wht';
                Distances_to_plot = [1:6 9:10];
            end
            
            if Cor_Reg_RSA<3
                Distances_to_plot = 1:3;
            end
            
            for iDistance = Distances_to_plot
                
                Pattern = sprintf('%s_-_%s_-_%s_-_ROI_-_ranktrans-*_-_plotranktrans-*.tiff', ...
                    Distances{iDistance},stim_suffix,beta_suffix);
                
                Output_file = sprintf('%s_-_%s_-_%s_vol_%s_%s.pdf', ...
                    Distances{iDistance},stim_suffix,beta_suffix,hs_sufix,date);
                
                convert_to_pdf(Fig_dir, Pattern, hs_sufix, Dest_fig_dir, Output_file)
            end
            
            
            %% surface
            if ~Do_hs_Idpdtly
                
                if isRaw
                    Distances_to_plot = 1:8;
                else
                    Distances_to_plot = 9:10;
                end
                
                if Cor_Reg_RSA<3
                    Distances_to_plot = 1:3;
                end
                
                
                for isCst = 0:1
                    
                    if isCst
                        To_plot = 'Cst';
                    else
                        To_plot = 'Lin';
                    end
                    
                    for iDistance = Distances_to_plot
                        Pattern = sprintf('%s_-_%s_-_%s_-_ranktrans-*_-_plotranktrans-*.tiff', ...
                            Distances{iDistance},stim_suffix,To_plot);
                        
                        Output_file = sprintf('%s_-_%s_-_%s_surf_%s_%s.pdf', ...
                            Distances{iDistance},stim_suffix,To_plot,hs_sufix,date);
                        
                        convert_to_pdf(Fig_dir, Pattern, hs_sufix, Dest_fig_dir, Output_file)
                    end
                    
                end
            end
        end
        
    end
end
end


function convert_to_pdf(src_dir, pattern, hs_sufix, dest_fig_dir, output_file)

disp([hs_sufix pattern])

% convert files
inputfiles = dir(fullfile(src_dir,[hs_sufix pattern]));

command =[];
for i=1:size(inputfiles,1)
    command = [command ' ' fullfile(src_dir,inputfiles(i).name)];
end

system(['convert ' command ' ' fullfile(dest_fig_dir, output_file)]);


% convert subject file
inputfiles = dir(fullfile(src_dir,'Subjects', ['Subjects_-_' hs_sufix '*_-_' pattern]));

command =[];
for i=1:size(inputfiles,1)
    command = [command ' ' fullfile(src_dir,'Subjects',inputfiles(i).name)];
end

system(['convert ' command ' ' fullfile(dest_fig_dir, 'Subjects', ['Subjects_' output_file])]);


end