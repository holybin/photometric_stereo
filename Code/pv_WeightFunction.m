function weightedMatrix = pv_WeightFunction(matrix);

% apply a weight function
for i=1:length(matrix(:))
  if matrix(i) >= 128
    matrix(i) = 255 - matrix(i);
  end
end

weightedMatrix = matrix;
