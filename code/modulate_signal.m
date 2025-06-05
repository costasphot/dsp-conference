% apply_modulation
% Modulates a binary bit stream using the given symbol map (e.g. QPSK, 16-QAM).
% Assumes Gray-coded symbol map.

function [bit_pairs, symbol_indices, modulated_signal, transmitted_signal] = modulate_signal(encoded_bit_stream, symbol_map, gray_labels, modulation_order, debug_plot, figure_number)
  % Define default values if parameters are not provided
  if nargin < 6 || isempty(figure_number), figure_number = 15;  end
  if nargin < 5 || isempty(debug_plot), debug_plot = false;     end

  % 1. Break into k-bit symbols (where k = log2(M))
  bits_per_symbol = log2(modulation_order);

  % 2. Reshape the bitstream into pairs (k-bit symbols)
  bit_pairs = reshape(encoded_bit_stream, bits_per_symbol, [])';

  % 3. Find the matching Gray label (row-wise) for each bit group
  % Convert both bit_pairs and gray_labels to decimal values
  bit_pair_decimals = bi2de(bit_pairs, "left-msb");
  gray_label_decimals = bi2de(gray_labels, "left-msb");
  
  % Use 'ismember()' to find matching indices
  [found, indices] = ismember(bit_pair_decimals, gray_label_decimals);

  % Check if any were not matched
  if any(~found)
    for i = find(~found)'
      error("No match found for 'bit_pair': [%s]\n", num2str(bit_pairs(i, :)));
    end
  end

  symbol_indices = indices;

  % 4. Map the indices to symbols (and ultimately form the modulated signal)
  modulated_signal = symbol_map(symbol_indices);

  % 5. Final (transmitted) signal
  transmitted_signal = modulated_signal;  % It's already normalized inside 'generate_QAM_constellation_from_SNR()'

  % 6. Plot the modulated signal constellation (since it's now complex)
  if debug_plot
    figure(figure_number);
    clf;

    scatter(real(transmitted_signal), imag(transmitted_signal), "bo", "LineWidth", 1.5);
    
    grid on;
    axis equal;
    
    title("Transmitted Signal Constellation (Modulated Symbols)");
    
    xlabel("Real Part");
    ylabel("Imaginary Part");

    % Automatically compute axis limits based on the modulation order
    margin = 0.5;  % Some extra spacing

    real_max = max(abs(real(symbol_map)));
    imag_max = max(abs(imag(symbol_map)));
    xlim([-real_max, real_max] + [-margin, margin]);
    ylim([-imag_max, imag_max] + [-margin, margin]);
    
    legend("Transmitted Symbols");
  end
end
