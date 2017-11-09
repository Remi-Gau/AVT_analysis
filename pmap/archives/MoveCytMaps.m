function MoveCytMaps

cd(fullfile(pwd,'..','..','PMap','Cyt'))

ImgLs = dir('*.nii')

for iIMG=1:numel(ImgLs)
    
    Hdr = spm_vol(ImgLs(iIMG).name);
    Vol = spm_read_vols(Hdr);
    
    Hdr.mat(2,4) = Hdr.mat(2,4)+4;
    Hdr.mat(3,4) = Hdr.mat(3,4)-5;
    
    [pth,nam,ext,num] = spm_fileparts(Hdr.fname);
    
    Hdr.fname = fullfile(pth,['m' nam ext])
    
    spm_write_vol(Hdr, Vol)
    
end

end