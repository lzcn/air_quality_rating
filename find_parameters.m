function [best_c,best_g,best_rate] = find_parameters(varargin)
if nargin < 1
    error(message('stats:grid:TooFewInputs'));
end

pnames = { 'svm_type',....
           'c_range' 'c_step' 'g_range' 'g_step',...
           'fold' ,...
           'train_filename' 'test_filename' ,...
           'svm_path'};
dflts =  { 5 ...
           [-5 15] 2 [3 -15] -2 ...
           5 ...
           'train' 'test' ...
           '.\bin' };
[ svm_type,...
  c_range,c_step,g_range,g_step,...
  fold,...
  train_filename,test_filename,...
  svm_path ] ...
  = internal.stats.parseArgs(pnames, dflts, varargin{:});
% init paras and feature files
best_c = c_range(1);
best_g = g_range(1);
best_rate = 0;
% scale the file
fprintf('>> Scaling file: ''%s'' , ''%s'',train_filename.test_filename);
train_scale = strcat(train_filename,'.scale');
cmdline = get_cmd('path',svm_path,...
                  'svm_bin','svm-scale',...
                  'l','-1','u','1',...
                  'train_filename',train_filename,...
                  'scale_file',train_scale);
%command = ['!',svm_scale,' -l -1 -u 1 -s  range ',train_filename,' > ',train_scale];
eval(cmdline);
test_scale = strcat(test_filename,'.scale');
cmdline = get_cmd('path',svm_path,...
                  'svm_bin','svm-scale',...
                  'l','-1','u','1',...
                  'train_filename',test_filename,...
                  'scale_file',test_scale);
%command = ['!',svm_scale,' -l -1 -u 1 -s  range ',test_filename, ' > ', test_scale];
eval(cmdline);

% find paras
fprintf('>> Finding Parameters !');
for i = c_range(1):c_step:c_range(2)
    for j = g_range(1):g_step:g_range(2)
        c_tmp =  2^i;
        g_tmp =  2^j;
        switch(svm_type)
            case 5 % do ranksvm
                cmdline = get_cmd('path',svm_path,...
                                  'svm_bin','svm-train',...
                                  'svm_type',svm_type,...
                                  'c',c_tmp,'g',g_tmp,...
                                  'train_filename',train_filename);
                evalc(cmdline);
                model_file = strcat(train_filename,'.model');
                output_file = strcat(test_filename,'.out');
                cmdline = get_cmd('path',svm_path,...
                                  'svm_bin','svm-predict',...
                                  'test_filename',test_filename,...
                                  'model_file',model_file,...
                                  'output_file',output_file);
                result = evalc(cmdline);
            case 0 % 
            otherwise %
        end
        best_rate_new = result(20:27);
        if best_rate_new > best_rate
          best_rate = best_rate_new;
          best_c = c_tmp;
          best_g = g_tmp;
        end         
    end
end





function cmdline = get_cmd(varargin)
pnames = { 'path'  'svm_bin' 'svm_type' 'c' 'g' 'l' 'u' 'fold' 'train_filename' 'test_filename' 'model_file' 'scale_file' 'output_file'};
dflts =  { '.\bin' 'svm-scale'    5      1   1  '0' '1'    5         []               []             []           []            []     };
[path,svm_bin,svm_type,c,g,l,u,fold,train_filename,test_filename,model_file,scale_file,output_file] ...
    = internal.stats.parseArgs(pnames, dflts, varargin{:});
dflts_svm_bin = {'svm-scale','svm-train','svm-predict'};
svm_bin = internal.stats.getParamVal(svm_bin,dflts_svm_bin,'''SVMBIN''');
switch (svm_bin)
    case 'svm-scale'
        cmdline = [ '!',fullfile(path,svm_bin),...
                    ' -l ',l...
                    ' -u ',u,...
                    ' -s range ',...
                    ' ',train_filename,' > ',...
                    ' ',scale_file];
    case 'svm-train'
        if svm_type == 0;
            cmdline = [ '!',fullfile(path,svm_bin),...
                        ' -s ',num2str(svm_type)...
                        ' -t 2',...
                        ' -c ',num2str(c),...
                        ' -g ',num2str(g),...
                        ' -v ',num2str(fold),...
                        ' ',train_filename];
        elseif svm_type == 5
            cmdline = [ '!',fullfile(path,svm_bin),...
                        ' -s ',num2str(svm_type)...
                        ' -t 2',...
                        ' -c ',num2str(c),...
                        ' -g ',num2str(g),...
                        ' ',train_filename];
        end
     case 'svm-predict'
        cmdline = [ '!',fullfile(path,svm_bin),...
                    ' ',test_filename,...
                    ' ',model_file,...
                    ' ',output_file];
        
    otherwise
end