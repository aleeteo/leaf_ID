function [indexes, names] = select_best_features(metrics, cm, features_names, num_features, corr_threshold)
  % Seleziona un numero specifico di features migliori per separabilità e bassa sovrapposizione
  % evitando ridondanza scegliendo la migliore tra le feature con alta correlazione.
  %
  % Input:
  %   metrics - tabella con metriche di valutazione delle feature
  %   cm - matrice di correlazione tra feature
  %   features_names - cell array con i nomi delle feature (primo elemento escluso)
  %   num_features (opzionale) - numero di feature da selezionare (default: 20)
  %   corr_threshold (opzionale) - soglia di correlazione per eliminare feature ridondanti (default: 0.95)
  %
  % Output:
  %   indexes - vettore con gli indici delle feature selezionate
  %   names - cell array con i nomi delle feature selezionate
  
  % controlli sugli argomenti
  arguments
    metrics (:,5) table;
    cm (:,:) double;
    features_names(:,1) cell;
    num_features (1,1) double {mustBeInteger, mustBePositive} = 10;
    corr_threshold (1,1) double {mustBePositive} = 0.95;
  end

  % controllo che il numero di features combaci negli argomenti
  if ~((size(metrics,1)==size(cm,1))&&(size(cm,1)==size(cm,2))&&...
       (size(cm,2)==(size(features_names,1)-1)))
    error("Errore: le dimensioni non di metrics, cm, e feature_names non combaciano");
  end
  
  % controllo che num_features sia minore uguale al numero di features
  if (num_features > size(metrics, 1))
    error("Errore: num_features > numero di features");
  end


  % Escludi il primo elemento da features_names
  features_names = features_names(2:end);
  
  % Calcola un punteggio di qualità combinando Fisher e Bhattacharyya
  quality_score = metrics.norm_fisher + metrics.norm_bhat;
  
  % Ordina le feature in base al punteggio di qualità (descrescente)
  [~, sorted_idx] = sort(quality_score, 'descend');
  
  % Lista iniziale di feature ordinate per qualità
  selected = sorted_idx;
  
  % Iterativamente rimuoviamo le feature con alta correlazione
  i = 1;
  while i <= length(selected)
    j = i + 1;
    while j <= length(selected)
      if abs(cm(selected(i), selected(j))) > corr_threshold
        % Mantieni solo la feature con punteggio qualità più alto
        if quality_score(selected(i)) >= quality_score(selected(j))
          selected(j) = [];
        else
          selected(i) = [];
          j = i; % Ripeti il controllo sulla nuova feature i-esima
        end
      else
          j = j + 1;
      end
    end
    i = i + 1;
  end
  
  % Seleziona il numero esatto di feature richiesto, se disponibili
  selected = selected(1:min(num_features, length(selected)));
  
  % Output finali
  indexes = selected;
  names = features_names(selected);
end
