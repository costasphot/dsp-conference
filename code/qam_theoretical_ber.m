% Computes the theoretical BER for square Gray-coded M-QAM in AWGN.
%   BER = qam_theoretical_ber(M, EbN0_dB) returns the bit error rate for an M-QAM 
%   modulation (M is a perfect square, e.g. 4,16,64,256) given E_b/N_0 in dB.
%
%   M         - Size of the QAM constellation (power of 4 for square QAM).
%   EbN0_dB   - Bit energy-to-noise ratio in dB.
%   BER       - Theoretical bit error rate (Gray coding assumed).
function BER = qam_theoretical_ber(modulation_order, Eb_N0_dB)
  % Ensure that the modulation order is a square of a power of 2
  bits_per_axis = log2(sqrt(modulation_order));
  if bits_per_axis ~= floor(bits_per_axis)
      error("The modulation order must be of 4^n (for square M-QAM).");
  end

  bits_per_symbol = log2(modulation_order);
  
  % Convert E_b/N_0 from dB to linear scale
  Eb_N0_linear = 10^(Eb_N0_dB/10);

  % Compute half the minimum distance between adjacent constellation points
  d = sqrt( (3 * bits_per_symbol * Eb) / (2 * (modulation_order - 1)) );

  % Initialize the BER accumulator
  BER = 0;
  
  % Loop over each bit position (in one axis/dimension)
  for bit_pos = 1:bits_per_axis
    a = bit_pos;  % For simplicity
    % Determine number of terms for this bit's error probability
    % floor((1 - 2^(-a)) * sqrt(modulation_order)) - 1 gives the maximum index r
    n_max = floor((1 - 2^(-a)) * sqrt(modulation_oerder)) - 1;
    Pb_a = 0;  % Initialize the summation for P_b(a)
    
    for r = 0:n_max
      % Determine the sign for this term based on Gray code pattern
      if a == 1
        term_sign = 1;  % For the most significant bit (MSB), all terms add positively
      else
        % Flip sign every 2^(a-1) terms for bit position a > 1
        term_sign = (-1) ^ floor(r / (2^(a-1)));
      end
      % Compute the argument of the erfc() function:
      % (2*r + 1)*d * sqrt(Eb_N0_linear) = (2*r + 1)*d / (sqrt(2) * sigma_w2), 
      %     since sigma = sqrt(1/(2*Eb_N0_linear)) when Eb is normalized to 1.
      erfn_arg = (2*r + 1) * d * sqrt(Eb_N0_linear);
      
      % Add the term's contribution: sign * erfc(argument)
      Pb_a = Pb_a + term_sign * erfc(erfn_arg);
    end
    % Multiply by the 1/sqrt(M) factor for P_b(a) and accumulate
    BER = BER + (1/sqrt(M)) * Pb_a;
  end
  
  % Finally average over the bit positions (divide by k)
  BER = BER / bits_per_axis;
end
