function avg_bhattacharyya = compute_avg_bhattacharyya(feature, labels)
  % funzione che calcola la metrica (o distanza) di Bhattacharyya media
  % per tutte le coppie di classi secondo i valori della feature forinta 
  % (le popolazioni sono stimate come gaussiane per semplificare i calcoli)
  %
  % input: feature = vettore con le features
  %        labels = vettore con i nomi delle features
  % output: bhattacharyya = metrica di Bhattacharyya
  %
  % https://www.wikiwand.com/en/articles/Bhattacharyya_distance
  
  classes = unique(labels);
  n_classes = length(classes);
  bhattacharyya = zeros(nchoosek(n_classes, 2), 1);
  count = 1;

  for i = 1:n_classes
    for j = i+1:n_classes
      bhat = compute_bhattacharyya(feature, labels, i, j);
      bhattacharyya(count) = bhat;
      count = count + 1;
    end
  end

  avg_bhattacharyya = mean(bhattacharyya);

  % funzione di supporto, calcola la metrica di Bhattacharyya
  % che indica la sovrapposizione delle distribuzioni delle classi
  function bhat = compute_bhattacharyya(feature, labels, p, q)
      idxP = (labels == classes(p));
      idxQ = (labels == classes(q));
      meanP = mean(feature(idxP));
      meanQ = mean(feature(idxQ));
      varP = var(feature(idxP));
      varQ = var(feature(idxQ));
      b1 = ((meanP - meanQ)^2) / (4 * (varP + varQ));
      b2 = 0.5 * log((varP + varQ) / (2 * sqrt(varP * varQ)));
      bhat = b1 + b2;
  end
end
