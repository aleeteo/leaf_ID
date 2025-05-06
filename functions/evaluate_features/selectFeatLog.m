function [bestSet, logInfo] = selectFeatLog(data, labelVar, opts)
%SELECTFEATLOG  Recursive-Feature-Elimination con log + pruning correlazione
%
%   [bestSet, logInfo] = selectFeatLog(dataTbl,"Label", ...
%                       MinFeat = 10,          ...
%                       RhoMax  = 0.90,        ...   % soglia corr.
%                       Importanza = "mrmrRank", ... % o "oobPermuted"
%                       Classifier = @(X,Y)fitcknn(X,Y,'NumNeighbors',3), ...
%                       Verbose = true, LogFile = "")
%
% INPUT
%   dataTbl   : table (una col. categorical = etichetta)
%   labelVar  : nome o indice colonna label
%
% OPZIONI
%   MinFeat   : arresto quando restano queste feature            (default 10)
%   RhoMax    : |ρ| oltre cui due feature sono considerate “doppioni” (0.90)
%   Importanza: "mrmrRank" (default) | "oobPermuted"
%   Classifier: function handle  (default k-NN-3)
%   CV        : cvpartition      (default 5-fold stratificata)
%   Verbose   : stampa log a console
%   LogFile   : salva il log su file ("" → disattivato)
%
% OUTPUT
%   bestSet   : indici delle colonne feature scelte (riferiti a dataTbl)
%   logInfo   : struct con iter, cvLoss, feature rimosse, ecc.
%
% RICHIEDE Statistics and Machine Learning Toolbox
% ------------------------------------------------------------------------
arguments
    data              table
    labelVar
    opts.MinFeat   (1,1) double  {mustBeInteger, mustBeNonnegative} = 10
    opts.RhoMax    (1,1) double  {mustBePositive, mustBeLessThan(opts.RhoMax,1)} = 0.90
    opts.Verbose   (1,1) logical = true
    opts.Classifier           function_handle = @(X,Y) fitcknn(X,Y,'NumNeighbors',3)
    opts.CV                   = cvpartition(height(data),'KFold',5)
    opts.Importanza (1,1) string {mustBeMember(opts.Importanza,["mrmrRank","oobPermuted"])} = "mrmrRank"
    opts.LogFile             string = ""
end

%% 1.   separa label & feature -------------------------------------------
if isnumeric(labelVar)
    y        = data{:, labelVar};
    featTbl  = data;  featTbl(:,labelVar) = [];
else
    y        = data.(labelVar);
    featTbl  = removevars(data, labelVar);
end
X         = featTbl{:,:};
varNames  = featTbl.Properties.VariableNames;
featCols  = find(~ismember(data.Properties.VariableNames, labelVar)); % mapping

%% 2.   ranking iniziale mRMR --------------------------------------------
[rankInit, scoreInit] = fscmrmr(X, y);

%% 3.   pruning per correlazione (facoltativo) ----------------------------
if opts.RhoMax < 1
    rankInit = pruneCorrelatedByMRMR(X, rankInit, scoreInit, opts.RhoMax);
end
currentSet = rankInit;

if opts.Verbose
    fprintf('[Pruning] Restano %d feature dopo correzione |ρ|>%.2f\n', ...
             numel(currentSet), opts.RhoMax);
end

%% 4.   setup log ---------------------------------------------------------
fid = -1;
if opts.LogFile ~= ""
    fid = fopen(opts.LogFile,'w');  cleanupObj = onCleanup(@()fclose(fid)); %#ok<NASGU>
end
logFcn = @(fmt,varargin)fprintf(fid*(fid>0) + 1*(fid<=0), [fmt '\n'], varargin{:});

step = 0;  bestLoss = inf;  bestSet = currentSet;  logInfo = struct([]);

%% 5.   RFE loop ----------------------------------------------------------
while numel(currentSet) >= opts.MinFeat
    step = step + 1;

    mdl   = opts.Classifier(X(:,currentSet), y);
    cvmdl = crossval(mdl,'CVPartition',opts.CV);
    loss  = kfoldLoss(cvmdl);

    logInfo(step).iter      = step;
    logInfo(step).remaining = currentSet;
    logInfo(step).cvLoss    = loss;

    if loss < bestLoss
        bestLoss = loss;   bestSet = currentSet;
    end

    logFcn('Iter %02d | %2d feat | CV-loss %.4f', step, numel(currentSet), loss);
    if numel(currentSet) == opts.MinFeat, break, end

    % --- importanza ------------------------------------------------------
    switch opts.Importanza
        case "oobPermuted"
            t = templateTree('Reproducible',true);
            ens = fitcensemble(X(:,currentSet), y, ...
                               'Method','Bag', ...
                               'NumLearningCycles',40, ...
                               'Learners',t);
            imp = oobPermutedPredictorImportance(ens);
        otherwise                      % "mrmrRank"
            [~,imp] = fscmrmr(X(:,currentSet), y);
    end

    [impVal,worst] = min(imp);
    featRem   = currentSet(worst);
    currentSet(worst) = [];

    logInfo(step).removed = featRem;
    logInfo(step).impVal  = impVal;
    logFcn('          ↳ rimossa %-25s (imp %.3g)', varNames{featRem}, impVal);
end

%% 6.   mappa sugli indici della tabella originale ------------------------
bestSet = featCols(bestSet);
end
% ========================================================================
% ==========  helper: pruneCorrelatedByMRMR  =============================
function keptIdx = pruneCorrelatedByMRMR(X, idx, score, rhoThr)
% Rimuove in ciascuna coppia |ρ|>rhoThr la feature con score mRMR minore
R = corrcoef(X(:,idx));
n = numel(idx);
keep = true(1,n);
for i = 1:n-1
    if ~keep(i), continue, end
    corrJ = find(abs(R(i,i+1:end))>rhoThr)+i;
    for j = corrJ
        if ~keep(j), continue, end
        if score(i) >= score(j)
            keep(j) = false;
        else
            keep(i) = false; break
        end
    end
end
keptIdx = idx(keep);
end
