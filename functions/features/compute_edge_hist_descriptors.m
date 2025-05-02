function [features, feature_names] = compute_edge_hist_descriptors(img, mask, nbins)
% COMPUTE_EDGE_ORIENT_HIST_STATS_DESCRIPTORS
%   Statistiche sull'istogramma delle orientazioni + avg_edge (rotation-inv.).
%
%   OUTPUT (7 valori, tutti non normalizzati):
%     1  texture.edgehist.entropy
%     2  texture.edgehist.energy
%     3  texture.edgehist.peak_prob
%     4  texture.edgehist.peak12_ratio
%     5  texture.edgehist.circ_var
%     6  texture.edgehist.circ_std
%     7  texture.edgehist.avg_edge      ← nuovo nome

  arguments
    img   (:,:,:) uint8
    mask  (:,:)   logical
    nbins (1,1) double {mustBePositive, mustBeInteger} = 18
  end

  % ---------- pre-check & grayscale -------------------------------------
  if size(img,3) ~= 1
      img = rgb2gray(img);
  end

  [Gmag,Gdir] = imgradient(img,'sobel');
  idx = mask & Gmag>0;

  props = regionprops(mask,'Area');
  if isempty(props) || props.Area==0 || ~any(idx(:))
      features = nan(1,7);
      feature_names = { ...
        'texture.edgehist.entropy','texture.edgehist.energy', ...
        'texture.edgehist.peak_prob','texture.edgehist.peak12_ratio', ...
        'texture.edgehist.circ_var','texture.edgehist.circ_std', ...
        'texture.edgehist.avg_edge'};
      return
  end
  area = props.Area;

  % ---------- istogramma orientazioni -----------------------------------
  orient = mod(Gdir(idx),180);
  edges  = linspace(0,180,nbins+1);
  counts = histcounts(orient,edges);
  p      = counts / sum(counts);

  entropy_val  = -sum(p(p>0).*log2(p(p>0)));
  energy_val   = sum(p.^2);
  peak_prob    = max(p);
  p_sorted     = sort(p,'descend');
  peak12_ratio = p_sorted(1)+p_sorted(2);

  centers  = deg2rad(edges(1:end-1)+diff(edges)/2);
  C = sum(p.*cos(centers));  S = sum(p.*sin(centers));
  R = sqrt(C^2+S^2);
  circ_var = 1-R;
  circ_std = sqrt(-2*log(max(R,eps)));

  % ---------- avg_edge ---------------------------------------------------
  [Gx,Gy] = gradient(double(img));
  avg_edge = sqrt(sum((Gx(mask)).^2 + (Gy(mask)).^2) / area);

  % ---------- output -----------------------------------------------------
  features = [entropy_val,energy_val,peak_prob,peak12_ratio, ...
              circ_var,circ_std,avg_edge];

  feature_names = { ...
      'texture.edgehist.entropy', ...
      'texture.edgehist.energy', ...
      'texture.edgehist.peak_prob', ...
      'texture.edgehist.peak12_ratio', ...
      'texture.edgehist.circ_var', ...
      'texture.edgehist.circ_std', ...
      'texture.edgehist.avg_edge'};   % ← nome allineato
end
