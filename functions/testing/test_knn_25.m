close
clear

load('data/training_data.mat', 'trainData');
load('data/testing_data.mat', 'testData');

[sub_train, sub_test, feat_names] = select_top_features(trainData, testData, 25);
save('data/sel_features.mat', 'feat_names');

C = fitcknn(sub_train, 'Label');

pred = predict(C, sub_test);

confusion_matrix = confusionmat(sub_test.Label, pred);
f1_score = compute_f1_score(sub_test.Label, pred);
fprintf('F1 Score: %f\n', f1_score);
fprintf('Confusion Matrix:\n');
fprintf('%d ', confusion_matrix);
confusionchart(abs(confusion_matrix));
