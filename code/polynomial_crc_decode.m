% polynomial_crc_decode
%

function [decoded_blocks, error_flags] = polynomial_crc_decode(received_bitstream, generator_poly, block_size)
  crc_length = length(generator_poly) - 1;
  block_total_size = block_size + crc_length;

  num_blocks = length(received_bitstream) / block_total_size;

  if mod(length(received_bitstream), block_total_size) ~= 0
    error("[verify_crc_blockwise] Bitstream length is not divisible by block + CRC length.");
  end

  decoded_blocks = zeros(num_blocks, block_size);  % Only message bits
  error_flags = false(1, num_blocks);              % Error indicator per block

  for i = 1:num_blocks
    start_idx = (i - 1) * block_total_size + 1;
    block = received_bitstream(start_idx : start_idx + block_total_size - 1);

    message_bits = block(1:block_size);
    received_crc = block(block_size + 1:end);

    % Reconstruct full padded message
    padded_block = [message_bits, zeros(1, crc_length)];
    remainder = padded_block;

    % Modulo-2 division
    for j = 1:block_size
      if remainder(j) == 1
        remainder(j:j+crc_length) = xor(remainder(j:j+crc_length), generator_poly);
      end
    end

    calculated_crc = remainder(end - crc_length + 1:end);

    % Check if remainder matches the received CRC
    if any(calculated_crc ~= received_crc)
      error_flags(i) = true;  % CRC mismatch
    end

    decoded_blocks(i, :) = message_bits;  % Save original bits regardless
  end
end
