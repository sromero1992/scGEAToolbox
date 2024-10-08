function [Tbp, Tmf] = r_enrichR(genelist, wkdir, isdebug)

if nargin < 2, wkdir = tempdir; end
if nargin < 3, isdebug = true; end

Tmf = []; Tbp = [];
oldpth = pwd();
[isok, msg, codepth] = commoncheck_R('R_enrichR');
if ~isok, error(msg); end
if ~isempty(wkdir) && isfolder(wkdir), cd(wkdir); end

tmpfilelist = {'input.txt', 'output1.txt', 'output2.txt'};
if ~isdebug, pkg.i_deletefiles(tmpfilelist); end

T = table(genelist);
writetable(T, 'input.txt');

Rpath = getpref('scgeatoolbox', 'rexecutablepath',[]);
if isempty(Rpath)
    error('R environment has not been set up.');
end

codefullpath = fullfile(codepth,'script.R');
pkg.i_addwd2script(codefullpath, wkdir, 'R');  % save a local, runnable code copy for debugging
pkg.RunRcode(codefullpath, Rpath);
warning off
if exist('output1.txt', 'file')
    Tbp = readtable('output1.txt');
    [Tbp] = in_trimT(Tbp);
end
if exist('output2.txt', 'file')
    Tmf = readtable('output2.txt');
    [Tmf] = in_trimT(Tmf);
end
warning on
if ~isdebug, pkg.i_deletefiles(tmpfilelist); end
cd(oldpth);
end

function [T] = in_trimT(T)
    if ~isempty(T)
    a = string(T.Overlap);
    b = extractBefore(a, cell2mat(strfind(a,'/')));
    idx = double(b)>=5 & T.P_value < 0.05;
    T=T(idx,:);
    end
end
