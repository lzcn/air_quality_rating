% Extract feture of transmission
% ExtractFeature_Transmission(dataset,FeatureFile,flag,TransmissionFile)
% Input:
%       'dataset' : the format is 
%                   dataset =
%                           num:
%                           path: {cell}
%                           aqi: []
%                           class: []
%
% Output:
%       'FeatureFile':file name which will be saved under directory 'Features'
%  
%
function ExtractFeature_pss(dataset,out_folder,feature_file,flag,pss_file_name)
if (nargin == 5 && flag == 1)
    SAVE_PSS_IMGAE = true; 
elseif (nargin == 4 && flag == 1)
    SAVE_PSS_IMGAE = true;
    pss_file_name = 'PorwerSpectrumSlope';
elseif (nargin == 3)
    SAVE_PSS_IMGAE = false;
end

if exist(out_folder,'file')==0 
             mkdir(out_folder);
end;
% the name of feature file 
feature_file_path = fullfile(out_folder,feature_file);

%% Compute Power Spectrum Slope
fprintf('>>Computing Power Spectrum Slope...\n');
fprintf('>>Dealing with   0/%4d',dataset.num);

file = fopen(feature_file_path,'wb');% saving the vector of features

for i = 1:dataset.num
     fprintf('\b\b\b\b\b\b\b\b\b');
     fprintf('%4d/%4d',i,dataset.num);
     im = imread(dataset.path{i});
     q = LocalPowerSpectrumSlope(im,17);
     fprintf(file,'%s\n%d\n',dataset.path{i},dataset.aqi(i));
     for j = 1:numel(q)
         fprintf(file,'%2.5f ',q(j));
     end;
     fprintf(file,'\n');
     if SAVE_PSS_IMGAE
         pss_folder = fullfile(out_folder,pss_file_name);
         if exist(pss_folder,'file')==0
             mkdir(pss_folder);
         end
         pss_image_path = fullfile(pss_folder,dataset.name{i});
         MaxValue = max(max(q));
         MinValue = min(min(q));
         im_q = uint8(255*(q - MinValue)/(MaxValue - MinValue));
         imwrite(im_q,pss_image_path);
     end
end
fclose all;
fprintf('\n');
disp('>>Done for compute Power Spectrum Slope!');