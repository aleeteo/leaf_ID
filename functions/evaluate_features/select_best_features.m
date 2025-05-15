function bestSet = select_best_features(data, labelVar, opts)
%SELECTFEATLOG  Selezione ricorsiva di feature con pruning per correlazione
%
%   bestSet = select_best_features(dataTbl, "Label", ...
%                NumFeatRange = [10, 40],      ...
%                RhoMax       = 0.90,          ...
%                Importanza   = "mrmrRank",    ...  % o "oobPermuted"
%                Classifier   = @(X,Y)fitcknn(X,Y,'NumNeighbors',3), ...
%                Verbose      = true)
%
% INPUT
%   dataTbl   : tabella (una colonna categorical = etichetta)
%   labelVar  : nome o indice della colonna etichetta
%
% OPZIONI (in struttura opts)
%   NumFeatRange: [min,max] numero feature da selezionare          (default [10, inf])
%   RhoMax      : soglia di correlazione oltre cui due feature sono considerate ridondanti (default 0.90)
%   Importanza  : "mrmrRank" (default) | "oobPermuted"
%   Classifier  : function handle che restituisce un classificatore MATLAB    (default k-NN con 3 vicini)
%   CV          : oggetto cvpartition per validazione incrociata              (default 5-fold stratificata)
%   Verbose     : se true, stampa i messaggi di log a console
%
% OUTPUT
%   bestSet   : indici (colonne) delle feature selezionate, riferiti alla tabella originale
%
% RICHIEDE: Statistics and Machine Learning Toolbox

  arguments
    data              table
    labelVar
    opts.NumFeatRange (1,2) double {mustBeNonnegative, mustBeIncreasing} = [10, inf]
    opts.RhoMax       (1,1) double  {mustBePositive, mustBeLessThan(opts.RhoMax,1)} = 0.90
    opts.Verbose      (1,1) logical = true
    opts.Classifier   function_handle = @(X,Y) fitcknn(X,Y,'NumNeighbors',3)
    opts.CV           = cvpartition(height(data),'KFold',5)
    opts.Importanza   (1,1) string {mustBeMember(opts.Importanza,["mrmrRank","oobPermuted"])} = "mrmrRank"
    opts.saveFlag     (1,1) logical = false
  end

  minFeat = opts.NumFeatRange(1);
  maxFeat = opts.NumFeatRange(2);

  %% 1. separa label & feature
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

  %% 2. ranking iniziale mRMR
  [rankInit, scoreInit] = fscmrmr(X, y);

  %% 3. pruning per correlazione
  if opts.RhoMax < 1
    rankInit = pruneCorrelatedByMRMR(X, rankInit, scoreInit, opts.RhoMax);
  end

  % Taglio a MaxFeat iniziale, se necessario
  if isfinite(maxFeat) && numel(rankInit) > maxFeat
    rankInit = rankInit(1:maxFeat);
  end

  currentSet = rankInit;

  if opts.Verbose
    fprintf('[Pruning] Restano %d feature dopo correzione |ρ|>%.2f\n', ...
            numel(currentSet), opts.RhoMax);
  end

  %% 4. RFE loop
  step = 0;
  bestLoss = inf;
  bestSet = currentSet;

  while numel(currentSet) >= minFeat && numel(currentSet) <= maxFeat
    step = step + 1;

    mdl   = opts.Classifier(X(:,currentSet), y);
    cvmdl = crossval(mdl, 'CVPartition', opts.CV);
    loss  = kfoldLoss(cvmdl);

    if loss < bestLoss
        bestLoss = loss;
        bestSet  = currentSet;
    end

    if opts.Verbose
        fprintf('Iter %02d | %2d feat | CV-loss %.4f\n', step, numel(currentSet), loss);
    end
    if numel(currentSet) == minFeat
      break
    end

    switch opts.Importanza
      case "oobPermuted"
        t = templateTree('Reproducible',true);
        ens = fitcensemble(X(:,currentSet), y, ...
                          'Method','Bag', ...
                          'NumLearningCycles',40, ...
                          'Learners',t);
        imp = oobPermutedPredictorImportance(ens);
      otherwise
        [~, imp] = fscmrmr(X(:,currentSet), y);
    end

    [~, worst] = min(imp);
    featRem = currentSet(worst);
    currentSet(worst) = [];

    if opts.Verbose
        fprintf('          ↳ rimossa %-25s (imp %.3g)\n', varNames{featRem}, imp(worst));
    end
  end

  %% 5. mappa sugli indici originali
  bestSet = featCols(bestSet);

  %% 6. salva
  if opts.saveFlag
    save('data/selected_features.mat', 'bestSet');
    fprintf('Feature selezionate salvate in data/sel_features.mat\n');
  end
end

function keptIdx = pruneCorrelatedByMRMR(X, idx, score, rhoThr)
  R = corrcoef(X(:,idx));
  n = numel(idx);
  keep = true(1,n);
  for i = 1:n-1
      if ~keep(i), continue, end
      corrJ = find(abs(R(i,i+1:end)) > rhoThr) + i;
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



