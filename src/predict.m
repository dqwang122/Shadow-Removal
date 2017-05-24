function [pred, prob] = predict(vector)
	pred = zeros(size(vector, 1),1);
	prob = zeros(size(vector, 1),1);
    feature = vector;
    feature(:, 1:3) = abs(feature(:, 1:3) - 1);
    score = sum(feature .^ 2, 2);
    x = find(score == min(score), 1);
    result = zeros(size(vector, 1), 1);
    result(uint8(x)) = 1;
    pred = result(:,1);
    prob = score(:, 1);
end
