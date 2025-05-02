function [normData, minMax] = normalize_features(data, minMax)
% NORMALIZE_FEATURES  Min-max [0,1] con riconoscimento automatico label.
%
%   [normData, minMax] = normalize_features(data)
%   [normData, minMax] = normalize_features(data, minMaxTrain)
%
% IN:
%   data       table           — feature (+ etichette opz.) da normalizzare
%   minMax     table 2×nFeat   — [min ; max] salvati dal TRAIN (passa [] per calcolarli)
%
% OUT:
%   normData   table           — label (se presente) + feature scalate in [0,1]
%   minMax     table 2×nFeat   — min/max usati (salvali al primo call)
%
% NOTE
%   • Se la prima variabile della tabella è di tipo *categorical*, è trattata come label
%     e rimessa in testa invariata.
%   • Al TEST i nuovi campioni sono scalati usando ESATTAMENTE gli stessi min/max del TRAIN.
%   • Se max==min (feature costante) la colonna è azzerata per evitare divisioni per 0.
% ------------------------------------------------------------------------
  arguments
      data    table
      minMax  table = table()
  end

  % --- separa label --------------------------------------------------------
  if iscategorical(data{:,1})
      labelTbl = data(:,1);
      featTbl  = data(:,2:end);
  else
      labelTbl = table();
      featTbl  = data;
  end
  varNames = featTbl.Properties.VariableNames;

  % --- calcola / valida min-max -------------------------------------------
  if isempty(minMax)         % TRAIN
      loVec = min(featTbl{:,:},[],1);
      hiVec = max(featTbl{:,:},[],1);
      minMax = array2table([loVec; hiVec],'VariableNames',varNames);
  else                        % TEST
      if height(minMax)~=2 || width(minMax)~=width(featTbl)
          error('minMax incompatibile con le feature');
      end
  end
  lo = minMax{1,:};
  hi = minMax{2,:};
  range = hi - lo; rangeSafe = range; rangeSafe(range==0)=1;

  Z = (featTbl{:,:} - lo) ./ rangeSafe;
  Z = min(max(Z,0),1);                     % clipping opzionale
  Z(:,range==0) = 0;                       % feature costante ⇒ 0

  featNormTbl = array2table(Z,'VariableNames',varNames);
  normData    = [labelTbl featNormTbl];
end
