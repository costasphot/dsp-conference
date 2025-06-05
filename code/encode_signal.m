% encode_signal
% Converts quantized level indices into a binary bitstream.
% Each index corresponds to a quantization level, and is encoded with log2(levels) bits.

function [padded_encoded_bit_stream, bit_padding, padding_length, bit_depth] = encode_signal(levels, indices, bits_per_symbol, generator_polynomial, block_size, apply_FEC, debug_mode)
  % Define default values if parameters are not provided
  if nargin < 7 || isempty(debug_mode), debug_mode = true;  end
  if nargin < 6 || isempty(apply_FEC), apply_FEC = false;   end
  if nargin < 5 || isempty(block_size), block_size = 4;     end
  if nargin < 4 || isempty(generator_polynomial)
    generator_polynomial = [1 0 1 1];  % Use a default/optimal CRC-3 generator (x^3 + x + 1)
  end

  % 1. Compute the bits required to represent each quantized index
  bit_depth = log2(levels);  % Bits per sample (e.g. 8 levels -> 3 bits/sample)

  % 2. Safety check: ensure that 'levels' is a power of 2
  if mod(bit_depth, 1) ~= 0
    error("[encode_signal] Number of quantization levels must be a power of 2.");
  end

  % 3. Convert the 1-based indices into 0-based binary strings
  bit_stream = dec2bin(indices - 1, bit_depth)';  % Decimal to binary word (gives 'char' type (class))

  % 4. Flatten the char matrix into a numeric row vector
  bit_stream = bit_stream(:)' - '0';  % Convert to a numeric vector (instead of a char matrix)  e.g. '110' -> [1 1 0]

  % % 5. Pad the stream to be divisible by 'block_size'
  % crc_padding_length = mod(-length(bit_stream), block_size)
  % bit_stream = [bit_stream, zeros(1, crc_padding_length)]
  % 
  % % 6. Apply polynomial CRC encoding block-by-block
  % crc_length = length(generator_polynomial) - 1
  % num_of_blocks = length(bit_stream) / block_size
  % encoded_block_size = block_size + crc_length
  % encoded_blocks = zeros(1, num_of_blocks * encoded_block_size)
  % 
  % for i = 1:num_of_blocks
  %   start_index = (i - 1) * block_size + 1;
  %   block = bit_stream(start_index : start_index + block_size - 1);
  % 
  %   encoded_block = polynomial_crc_encode(block, generator_polynomial);
  %   encoded_blocks((i - 1) * encoded_block_size + 1 : i * encoded_block_size) = encoded_block;
  % end
  % 
  % % 7. Apply FEC encoding (just a simple repetitive encoding for now)
  % if apply_FEC
  %   encoded_blocks = repelem(encoded_blocks, 3);
  % end
  % 
  % encoded_bit_stream = encoded_blocks;

  % 8. Apply last bit padding to ensure the bitstream's length is divisible to form k-bit symbols
  % [padded_encoded_bit_stream, bit_padding, padding_length] = add_bit_padding(encoded_bit_stream, bits_per_symbol, debug_mode);
  [padded_encoded_bit_stream, bit_padding, padding_length] = add_bit_padding(bit_stream, bits_per_symbol, debug_mode);
end
