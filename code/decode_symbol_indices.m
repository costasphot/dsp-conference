% decode_symbol_indices
%

function [recovered_bit_stream, recovered_padded_bit_stream, detected_bits] = decode_symbol_indices(detected_indices, gray_labels, bit_padding, padding_length, generator_polynomial, block_size, apply_FEC, debug_mode)
  % Define default values if parameters are not provided
  if nargin < 8 || isempty(debug_mode), debug_mode = true; end

  % 1. Recover the bit vectors from the detected indices using the Gray label table we automatically generated in the 'generate_QAM_constellation_from_SNR'
  detected_bits = gray_labels(detected_indices, :);

  % 2. Flatten to 1D bitstream
  recovered_padded_bit_stream = reshape(detected_bits', 1, []);

  % 3. Remove padding from the tail if it was added during modulation
  if bit_padding
    recovered_padded_bit_stream = recovered_padded_bit_stream(1 : (end-padding_length));

    if debug_mode
      fprintf("[decode_symbol_indices] Removed %d padding bits to match original length.\n", padding_length);
    end
  end

  % TODO: Remove the line below when I apply the more advanced encoding methods
  recovered_bit_stream = recovered_padded_bit_stream;

  % % 4. Apply FEC decoding
  % if apply_FEC
  %   if mod(length(recovered_padded_bit_stream), 3) ~= 0
  %     error("[decode_symbol_indices] FEC was applied but the bitstream length is not divisible by 3.");
  %   end
  % 
  %   reshaped_bit_stream = reshape(recovered_padded_bit_stream, 3, []);
  % 
  %   majority_voted = sum(reshaped_bit_stream, 1) >= 2;
  %   recovered_padded_bit_stream = majority_voted;
  % end
  % 
  % % 5. Verify CRC block-by-block
  % [decoded_blocks, error_flags] = polynomial_crc_decode(recovered_padded_bit_stream, generator_polynomial, block_size);
  % 
  % % 6. Reconstruct the final bitstream with only the valid blocks
  % recovered_bit_stream = reshape(decoded_blocks', 1, []);
  % 
  % % 7. Optional debug
  % if debug_mode
  %   fprintf("[decode_symbol_indices] CRC Validation - %d out of %d blocks failed CRC.\n", sum(error_flags), length(error_flags));
  % 
  %   if numel(recovered_bit_stream) < 500
  %     fprintf("[decode_symbol_indices] Recovered bits:\n%s\n", num2str(recovered_bit_stream));
  %   end
  % end
end
