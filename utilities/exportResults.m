function exportResults(Record, fileName)

numExperiments=Record.numExp;
expectation=Record.exp;
variance=Record.var;
numTrials=Record.numTrials;
dim=Record.dim;
t=Record.t;
x=Record.x;
T=Record.T;

sep = ',';
if exist(fileName, 'file') == 0
    header = strcat('Dimension',sep,'x0',sep,'t',sep,'T',sep,'Number of Experiments', ...
        sep,'Number of Trials per experiment',sep,'Expectation',sep ...
        ,'Variance');
 
    data = strcat(dim,sep,x,sep,t,sep,T,sep,numExperiments,sep,numTrials,sep, ...
        expectation,sep,variance);
 
    fid = fopen(fileName, 'w');
    fprintf(fid, '%s\n', header);
    fprintf(fid, '%s\n', data);
    fclose(fid);
else
    data = strcat(dim,sep,x,sep,t,sep,T,sep,numExperiments,sep,numTrials,sep, ...
        expectation,sep,variance);
 
    fid = fopen(fileName, 'a');
    fprintf(fid, '%s\n', data);
    fclose(fid);
end
end
