M = gifti(fullfile(pwd, 'sub-02_ses-1_MP2RAGE_T1map_thresh_clone_transform_strip_clone_transform_bound_mems_lcr_gm_avg_inf.vtk'));
M = export(M, 'patch');
T = randn(size(M.vertices, 1), 1);
T = spm_mesh_smooth(M, T, 100);
H = spm_mesh_render('Disp', M);
H = spm_mesh_render('Overlay', H, T);
H = spm_mesh_render('View', H, [-90 180]);
hold on;
t = linspace(min(T), max(T), 20);
for i = 1:numel(t)
    C = spm_mesh_contour(M, struct('T', T, 't', t(i)));
    for j = 1:numel(C)
        plot3(C(j).xdata, C(j).ydata, C(j).zdata, 'k-');
    end
end
