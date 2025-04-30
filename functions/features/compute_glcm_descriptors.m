function [features, feature_names] = compute_glcm_descriptors(img, mask)
  % Ritaglia bounding box della regione della maschera
  props = regionprops(mask, 'BoundingBox');
  if isempty(props)
      error('La maschera non contiene regioni valide.');
  end
  bb = round(props(1).BoundingBox);
  roi = imcrop(img, bb);
  roi_mask = imcrop(mask, bb);
  roi(~roi_mask) = 0;

  % Calcolo della GLCM (su ROI)
  offsets = [0 1; -1 1; -1 0; -1 -1];
  glcm = graycomatrix(roi, ...
                      'Offset', offsets, ...
                      'Symmetric', true, ...
                      'NumLevels', 32);

  stats = graycoprops(glcm, {'Contrast', 'Correlation', 'Energy', 'Homogeneity'});

  features = [mean(stats.Contrast), mean(stats.Correlation), ...
              mean(stats.Energy), mean(stats.Homogeneity)];

  feature_names = {'texture.glcm.contrast', 'texture.glcm.correlation', ...
                'texture.glcm.energy', 'texture.glcm.homogeneity'};
end
