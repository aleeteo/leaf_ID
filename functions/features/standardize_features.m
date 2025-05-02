function [stdData, muSig] = standardize_features(data, muSig)
% STANDARDIZE_FEATURES  z-score column-wise with automatic label detection
%
%   [stdData, muSig] = standardize_features(data)
%   [stdData, muSig] = standardize_features(data, muSigTrain)
%
% IN:
%   data        table  — features ( + opzionale colonna label in posizione 1)
%   muSig       table 2×nFeat  — [mu ; sigma] salvate dal TRAIN (passa [] per calcolarle)
%
% OUT:
%   stdData     table  — stesse variabili di 'data' ma con feature standardizzate
%   muSig       table 2×nFeat  — media e σ usate (da salvare al primo call)
%
% NOTE:
%   * Se la prima variabile è 'categorical' viene rimessa in testa invariata.
%   * Se nel TRAIN qualche sigma==0, la colonna viene azzerata anche nel TEST.
% ------------------------------------------------------------------------
  arguments
      data  table
      muSig table = table()
  end

  % --- separa label se c'è -------------------------------------------------
  if iscategorical(data{:,1})
      labelTbl = data(:,1);
      featTbl  = data(:,2:end);
  else
      labelTbl = table();
      featTbl  = data;
  end
  varNames = featTbl.Properties.VariableNames;

  % --- calcola / valida mu-σ ----------------------------------------------
  if isempty(muSig)          % TRAIN
      muVec    = mean(featTbl{:,:}, 1);
      sigmaVec = std (featTbl{:,:}, 0, 1);  % n-1 al denom.
      muSig = array2table([muVec; sigmaVec], 'VariableNames', varNames);
  else                        % TEST
      if height(muSig)~=2 || width(muSig)~=width(featTbl)
          error('muSig incompatibile con le feature');
      end
  end
  mu     = muSig{1,:};
  sigma  = muSig{2,:};

  sigmaSafe = sigma; sigmaSafe(sigma==0)=1;      % evita ÷0
  Z = (featTbl{:,:} - mu) ./ sigmaSafe;
  Z(:,sigma==0) = 0;

  featStdTbl = array2table(Z,'VariableNames',varNames);
  stdData    = [labelTbl featStdTbl];
end
