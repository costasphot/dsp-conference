% add_bit_padding (used inside 'apply_modulation')
% Pads the bitstream with zeros to ensure it can be divided into 2-bit symbols.
% Also returns a flag indicating whether padding was applied (for demodulation reversal).

function [bit_stream, bit_padding, padding_length] = add_bit_padding(bit_stream, bits_per_symbol, debug_mode)
  % Define default values if parameters are not provided
  if nargin < 3 || isempty(debug_mode), debug_mode = true;  end

  bit_padding = false;    % If it's needed for the modulation, we're keeping track of it for the demodulation
  remainder = mod(length(bit_stream), bits_per_symbol);

  if remainder ~= 0
    padding_length = bits_per_symbol - remainder;
    bit_stream = padarray(bit_stream, [0, padding_length], 0, "post");  % Append 'padding_length' zeros depending on the modulation order
    bit_padding = true;

    if debug_mode
      fprintf("[Debug - add_bit_padding] Bitstream length was not divisible by %d. Appended %d zeros.\n", bits_per_symbol, padding_length);
    end
  else
    padding_length = 0;
  end
end

