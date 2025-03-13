
function [indexes, names] = select_best_features(metrics, cm, features_names)
    % Seleziona le 20 features migliori per separabilità e bassa sovrapposizione
    % evitando ridondanza scegliendo la migliore tra le feature con alta correlazione.
    %
    % Input:
    %   metrics - tabella con metriche di valutazione delle feature
    %   cm - matrice di correlazione tra feature
    %   features_names - cell array con i nomi delle feature (primo elemento escluso)
    %
    % Output:
    %   indexes - vettore con gli indici delle feature selezionate
    %   names - cell array con i nomi delle feature selezionate
    
    % Escludi il primo elemento da features_names
    features_names = features_names(2:end);
    
    % Calcola un punteggio di qualità combinando Fisher e Bhattacharyya
    quality_score = metrics.norm_fisher + metrics.norm_bhat;
    
    % Ordina le feature in base al punteggio di qualità (descrescente)
    [~, sorted_idx] = sort(quality_score, 'descend');
    
    % Lista iniziale di feature ordinate per qualità
    selected = sorted_idx;
    
    % Soglia di correlazione elevata
    threshold = 0.95; 
    
    % Iterativamente rimuoviamo le feature con alta correlazione
    i = 1;
    while i <= length(selected)
        j = i + 1;
        while j <= length(selected)
            if abs(cm(selected(i), selected(j))) > threshold
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
    
    % Seleziona solo le feature finali, garantendo al massimo 20 feature
    selected = selected(1:min(20, length(selected)));
    
    % Output finali
    indexes = selected;
    names = features_names(selected);
end



