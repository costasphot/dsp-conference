% generate_QAM_constellation
% Generates an M-QAM constellation with Gray ordering (Q-axis first, then I-axis).

function [levels_per_axis, IQ_levels, I, Q, symbols, Es, Eb, symbol_map, gray_labels] = generate_QAM_constellation(modulation_order, SNR_dB, sigma_w2)
  % 1. Check if M-QAM is a perfect square
  if mod(log2(modulation_order), 2) ~= 0
    error("Only square QAM is supported.");
  end

  % 2. Calculate bit and level info
  bits_per_symbol = log2(modulation_order);
  bits_per_axis = bits_per_symbol / 2;
  levels_per_axis = 2^bits_per_axis;
  IQ_levels = -(levels_per_axis - 1) : 2 : (levels_per_axis - 1);

  % 3. Generate meshgrid for I and Q
  [I, Q] = meshgrid(IQ_levels);  % I = columns, Q = rows, meshgrid(nxn) OR meshgrid(nxm)
  symbols = I(:) + 1j * Q(:);
  % IDK if it breaks for M-QAM
  % symbols = (I(:) + 1j * Q(:)).* (1 / sqrt(modulation_order));

  % 4. Set average Es from SNR_dB and noise power (sigma^2 = N_0)
  SNR_linear = 10^(SNR_dB / 10);  % Convert relative quantity (dB) to absolute quantity (linear)
  Es = SNR_linear * sigma_w2;  % Es = SNR * N_0
  Eb = Es / bits_per_symbol;  % Eb = Es / log2(modulation_order)

  % 5. Normalize average energy to 1 and scale with variable SNR
  current_Es = mean(abs(symbols).^ 2);  % For 4-QAM: At first this is equal to 2 -> Σ(1 + 1) / 4 = (2 + 2 + 2 + 2) / 4 = 8 / 4 = 2
  normalized_symbols = symbols / sqrt(current_Es);  % Normalize each symbol so that Σ(s_i)^2 = 1 (instead of the previous 2) -> 0.7071 ^ 2 = ~0.5 -> Σ(0.5 + 0.5 = 1) / 4 = 4 / 4 = 1
  scaled_symbols = normalized_symbols * sqrt(Es);  % Scale the normalized constellation, so that the average energy equals to SNR_linear * sigma_w2
  symbol_map = scaled_symbols;

  % 6. Generate Gray code labels along one axis
  gray_axis = generate_gray_axis(bits_per_axis);

  % 7. Combine Gray labels for 2D Gray coding (Q-first order)
  gray_labels = zeros(modulation_order, bits_per_symbol);
  i = 1;
  for row = 1:levels_per_axis
    for col = 1:levels_per_axis
      gray_labels(i, :) = [gray_axis(row, :), gray_axis(col, :)];  % Q-bits first, then I-bits
      i = i + 1;
    end
  end
end


% Helper function: generate Gray code labels of length n
function gray_axis = generate_gray_axis(bits_per_axis)
  if bits_per_axis == 1
    gray_axis = [0; 1];
  else
    previous = generate_gray_axis(bits_per_axis - 1);
    gray_axis = [ ...
      [zeros(size(previous, 1), 1), previous];        % prefix 0
      [ones(size(previous, 1), 1), flipud(previous)]  % prefix 1 to reversed previous
    ];
  end
end
