function [pred, acc, cm] = classify_image(img, classifier, detector, scaling_data, gt, options)

  arguments
    img (:, :, :)
    classifier (1,1)
    detector (1,1)
    scaling_data (2,:) table
    gt (:, :) = []
    options.Visualize (1,1) logical = false
  end
  
  mask = segment(img);
  [pred, acc, cm] = classify_multiple(img, mask, classifier, detector, scaling_data, ...
                    labels=gt, standardize=true, DoParallel=false, Visualize=options.Visualize);
end
