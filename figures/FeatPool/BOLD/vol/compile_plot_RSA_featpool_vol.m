function compile_plot_RSA_featpool_vol

close all
clear
clc

start_dir = fullfile(pwd, '..','..','..','..','..');
cd (start_dir)

RSA_fig_dir = fullfile(start_dir, 'figures', 'RSA','Cdt');
RSA_Dest_fig_dir = fullfile(RSA_fig_dir,'compiled');


Distances = {...
    'RSA_toolbox_Euclidian_-_All_CV'
    'RSA_toolbox_Mahalanobis_-_All_CV'
    };

Fig_dir = RSA_fig_dir;
Dest_fig_dir = RSA_Dest_fig_dir;




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
            Distances_to_plot = 1;
        else
            beta_suffix = 'beta-wht';
            Distances_to_plot = 2;
        end
        
        for iHS = 1:2
            if iHS==1
                hs_sufix = 'LHS';
            else
                hs_sufix = 'RHS';
            end
            
            for iDistance = Distances_to_plot
                
                Pattern = sprintf('%s_-_*%s_-_%s_-_%s_-_ranktrans-*_-_plotranktrans-*.tiff', ...
                    Distances{iDistance},stim_suffix,beta_suffix,hs_sufix);
                
                Output_file = sprintf('%s_-_%s_-_%s_vol_%s_%s.pdf', ...
                    Distances{iDistance},stim_suffix,beta_suffix,hs_sufix,date);
                
                convert_to_pdf(Fig_dir, Pattern, Dest_fig_dir, Output_file)
            end
        end
        
        
    end
    
end

end


function convert_to_pdf(src_dir, pattern, dest_fig_dir, output_file)

disp(pattern)

% convert files
inputfiles = dir(fullfile(src_dir,['NEW_-_' pattern]));

command =[];
for i=1:size(inputfiles,1)
    command = [command ' ' fullfile(src_dir,inputfiles(i).name)];
end

system(['convert ' command ' ' fullfile(dest_fig_dir, ['NEW_-_' output_file])]);


% convert subject file
inputfiles = dir(fullfile(src_dir,'Subjects', ['NEW_-_Subjects_-_' pattern]));

command =[];
for i=1:size(inputfiles,1)
    command = [command ' ' fullfile(src_dir,'Subjects',inputfiles(i).name)];
end

system(['convert ' command ' ' fullfile(dest_fig_dir, 'Subjects', ['NEW_-_Subjects_' output_file])]);


end