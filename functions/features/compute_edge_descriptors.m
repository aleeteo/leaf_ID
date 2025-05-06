function edge_table = compute_edge_descriptors(mask, options)
% COMPUTE_EDGE_DESCRIPTORS Calcola descrittori basati sul contorno.
%
%   edge_table = COMPUTE_EDGE_DESCRIPTORS(mask, options) restituisce una tabella
%   con feature basate sulla firma polare del bordo (e opzionalmente Fourier).
%
%   Parametri in options:
%     - edge_features: cell array con i blocchi da attivare tra:
%         'signature' : statistiche sulla shape signature
%         'fourier'   : descrittori di Fourier (TODO)
%
%     Default: {'signature'}

  arguments
    mask (:,:) logical
    options.edge_features cell = {'signature', 'fourier'}
  end

  valid_features = {'signature', 'fourier'};
  if ~all(ismember(options.edge_features, valid_features))
    error('Valori non validi in options.edge_features. Ammessi: signature, fourier.');
  end

  features = [];
  feature_names = {};

  if any(ismember({'signature', 'fourier'}, options.edge_features))
    signature = extract_polar_edge_signature(mask);
  end

  if ismember('signature', options.edge_features)
    mean_val    = mean(signature);
    var_val     = var(signature);
    kurt_val    = kurtosis(signature);
    entropy_val = -sum(signature .* log2(signature + eps));

    feature_names = [feature_names, {'edge.signature.mean', 'edge.signature.var', ...
                     'edge.signature.kurtosis', 'edge.signature.entropy'}];
    features = [features, mean_val, var_val, kurt_val, entropy_val];
  end

  if ismember('fourier', options.edge_features)
    % Fourier Descriptors dalla firma polare
    fft_coeffs = fft(signature);                  % Trasformata di Fourier
    mag_coeffs = abs(fft_coeffs);                 % Moduli (invarianti a traslazione e fase)

    % Numero di coefficienti da mantenere (escludendo il primo che rappresenta la media)
    num_coeffs = min(10, floor(numel(mag_coeffs)/2));  % Primi 10 (escluso il DC)
    selected_coeffs = mag_coeffs(2:num_coeffs+1);      % Salta il coefficiente DC

    % Nomina delle feature
    fourier_names = strcat("edge.fourier.c", string(1:num_coeffs));
    feature_names = [feature_names, fourier_names];
    features = [features, selected_coeffs];
  end

  edge_table = array2table(features, 'VariableNames', feature_names);
end
