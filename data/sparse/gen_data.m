function  [data, label]= gen_data(n_samples,n_features)
    % Generate a dense matrix with random values
    dense_matrix = rand(n_samples, n_features);
    
    % Make most of the matrix elements zero to create sparsity
    density = 0.1;  % 90% of the matrix will be zeros
    mask = rand(n_samples, n_features) < density;
    data = full(dense_matrix .* mask);
    
    % Generate binary class labels based on a simple rule
    label = sum(data, 2) > (density * n_features / 2);
    data = data';
    label= label';    
%     % Split the data into training and test sets
%     cv = cvpartition(n_samples, 'HoldOut', 0.2);
%     idx = cv.test;
%     
%     % Train and Test
%     X_train = sparse_matrix(~idx,:);
%     Y_train = y(~idx,:);
%     X_test  = sparse_matrix(idx,:);
%     Y_test  = y(idx,:);
    
end