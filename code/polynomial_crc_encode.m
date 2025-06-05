% polynomial_crc_encode
%

function [encoded_block] = polynomial_crc_encode(block, generator_polynomial)
  % Number of redundancy (CRC) bits = degree of the generator polynomial
  redundancy_bits = length(generator_polynomial) - 1;

  % Append zeros for the redundancy bits
  block_with_zeros = [block, zeros(1, redundancy_bits)];

  % Perform the modulo-2 division using XOR
  working_bits = block_with_zeros;
  for i = 1:length(block)
    if working_bits(i) == 1
      working_bits(i : i + redundancy_bits) = xor(working_bits(i : i + redundancy_bits), generator_polynomial);
    end
  end
  
  % Extract the CRC bits (remainder)
  crc_bits = working_bits(end - redundancy_bits + 1 : end);

  % Form the final encoded block
  encoded_block = [block, crc_bits];
end
