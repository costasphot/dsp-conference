function [detected_indices, symbol_map_2D, received_signal_2D, labels, SVM_model] = detect_symbols(symbol_map, received_signal, detection_method)
  % Define default values if parameters are not provided
  if nargin < 3 || isempty(detection_method), detection_method = "knnsearch";  end

  % 1. Convert to 2D real-valued space
  symbol_map_2D = [real(symbol_map(:)), imag(symbol_map(:))];
  received_signal_2D = [real(received_signal(:)), imag(received_signal(:))];

  % Detect the indices either with the k-NN algorithm or an SVM
  if strcmpi(detection_method, "knnsearch")
    % Nearest-neighbor detection (returns indices into the symbol_map)
    detected_indices = knnsearch(symbol_map_2D, received_signal_2D);
    
  elseif strcmpi(detection_method, "svm")
    % Train an SVM model using the ideal constellation
    labels = (1:size(symbol_map_2D, 1))';  % Ground truth: index per symbol
    SVM_model = fitcecoc(symbol_map_2D, labels);

    % Predict classes of received signal
    detected_indices = predict(SVM_model, received_signal_2D);

  else
    error("Unknown detection technique: %s", detection_technique);
  end
end
