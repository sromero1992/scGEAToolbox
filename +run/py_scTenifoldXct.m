function [T]=py_scTenifoldXct(sce,celltype1,celltype2,twosided,A1,A2)

T=[];
if nargin<6, A2=[]; end
if nargin<5, A1=[]; end
if nargin<4, twosided=true; end

oldpth=pwd();
pw1=fileparts(mfilename('fullpath'));
wrkpth=fullfile(pw1,'external','py_scTenifoldXct');
cd(wrkpth);

isdebug=true;

tmpfilelist={'X.mat','X.txt','g.txt','c.txt','output.txt', ...
             'output1.txt','output2.txt',...
             'gene_name_Source.tsv', 'gene_name_Target.tsv',...
             'pcnet_Source.npz', 'pcnet_Target.npz',...
             'A1.mat','A2.mat','pcnet_Source.mat','pcnet_Target.mat'};

if ~isdebug, pkg.i_deletefiles(tmpfilelist); end

% load(fullfile(pw1,'..','resources','Ligand_Receptor.mat'), ...
%     'ligand','receptor');
% validg=unique([ligand receptor]);
% [y]=ismember(upper(sce.g),validg);
% X=sce.X(y,:);
% g=sce.g(y);
% writematrix(sce.X,'X.txt');

idx=sce.c_cell_type_tx==celltype1 | sce.c_cell_type_tx==celltype2;
sce=sce.selectcells(idx);
sce.c_batch_id=sce.c_cell_type_tx;
sce.c_batch_id(sce.c_cell_type_tx==celltype1)="Source";
sce.c_batch_id(sce.c_cell_type_tx==celltype2)="Target";
% sce=sce.qcfilter;

X=sce.X;
save('X.mat','-v7.3','X');
writematrix(sce.g,'g.txt');
writematrix(sce.c_batch_id,'c.txt');
disp('Input X g c written.');

t=table(sce.g,sce.g,'VariableNames',{' ','gene_name'});
writetable(t,'gene_name_Source.tsv','filetype','text','Delimiter','\t');
writetable(t,'gene_name_Target.tsv','filetype','text','Delimiter','\t');
disp('Input gene_names written.');

if isempty(A1)
    disp('Building A1 network...')
    A1=sc_pcnetpar(sce.X(:,sce.c_cell_type_tx==celltype1));
    disp('A1 network built.')
else
    disp('Using A1 provided.')
end
A1=A1./max(abs(A1(:)));
% A=0.5*(A1+A1.');
A=ten.e_filtadjc(A1,0.75,false);
save('pcnet_Source.mat','A','-v7.3');

if isempty(A2)
    disp('Building A2 network...')
    A2=sc_pcnetpar(sce.X(:,sce.c_cell_type_tx==celltype2));
    disp('A2 network built.')
else
    disp('Using A2 provided.');
end
A2=A2./max(abs(A2(:)));
% A=0.5*(A2+A2.');
A=ten.e_filtadjc(A2,0.75,false);
save('pcnet_Target.mat','A','-v7.3');
clear A A1 A2

x=pyenv;
pkg.i_add_conda_python_path;

if twosided
    cmdlinestr=sprintf('"%s" "%s%sscript.py" 2', ...
        x.Executable,wrkpth,filesep);
else
    cmdlinestr=sprintf('"%s" "%s%sscript.py" 1', ...
        x.Executable,wrkpth,filesep);
end
disp(cmdlinestr)
[status]=system(cmdlinestr,'-echo');
% https://www.mathworks.com/matlabcentral/answers/334076-why-does-externally-called-exe-using-the-system-command-freeze-on-the-third-call

% rt=java.lang.Runtime.getRuntime(); 
% pr = rt.exec(cmdlinestr);
% [status]=pr.waitFor();

if twosided
    if status==0 && exist('output1.txt','file') && exist('output2.txt','file')
        T1=readtable('output1.txt');
        T2=readtable('output2.txt');
        T={T1,T2};
    end
else
    if status==0 && exist('output1.txt','file')
        T=readtable('output1.txt');
    end    
end

if ~isdebug, pkg.i_deletefiles(tmpfilelist); end
cd(oldpth);
end