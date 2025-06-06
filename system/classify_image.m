function [pred, acc, cm] = classify_image(img, classifier, detector, scaling_data, gt)

  arguments
    img (:, :, :)
    classifier (1,1)
    detector (1,1)
    scaling_data (2,:) table
    gt (:, :) = []
  end
  
  mask = segmentation5(img);
  [pred, acc, cm] = classify_multiple(img, mask, classifier, detector, scaling_data, ...
                    labels=gt, standardize=true, DoParallel=false);
end
