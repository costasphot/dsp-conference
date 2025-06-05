% compare_practical_with_theoretical_BER
% Compares practical vs theoretical BER for square M-QAMs

function compare_ber(modulation_order, sigma_w2, SNR_dB, ber_practical, debug_plot, figure_number)
  % Define default values if parameters are not provided
  if nargin < 6 || isempty(figure_number), figure_number = 17;  end
  if nargin < 5 || isempty(debug_plot), debug_plot = true;      end

  % 1. Ensure square QAM
  if mod(log2(modulation_order), 2) ~= 0
    error("Only square M-QAM (e.g. 4, 16, 64, ...) is supported.");
  end

  % 2. Bits per symbol and Eb/N0
  bits_per_symbol = log2(modulation_order);
  Es_theoretical = sigma_w2 * 10^(SNR_dB / 10);
  Eb = Es_theoretical / bits_per_symbol;
  % N0 = 2 * sigma_w2;  % One-sided noise PSD
  N0 = sigma_w2;
  Eb_N0 = Eb / N0;
  Eb_N0_dB = 10 * log10(Eb_N0);

  % 3. Theoretical BER for square M-QAM
  sqrt_M = sqrt(modulation_order);
  erfn_arg = sqrt((3 * bits_per_symbol / (modulation_order - 1)) * (Eb / N0));  % 'erfn_arg' stands for Error function argument
  Pe = (4 / bits_per_symbol) * (1 - 1/sqrt_M) * qfunc(erfn_arg);
  ber_theoretical = Pe;  % I'm already using 'Eb' so I'm calculating the BER, not the SER

  % 4. Plot both on a semilogy scale
  if debug_plot
    figure(figure_number);

    semilogy(Eb_N0_dB, ber_theoretical, "r*-", "LineWidth", 1.5);
    hold on;
    semilogy(Eb_N0_dB, ber_practical, "bo-", "LineWidth", 1.5);
    
    grid on;
    
    title(sprintf("BER Comparison for %d-QAM", modulation_order));
    % text(EbN0_dB, BER_practical, sprintf("  BER=%.2e", BER_practical), "VerticalAlignment", "bottom");

    xlabel("E_b/N_0 [dB]");
    ylabel("Bit Error Rate (BER)");
    
    legend('Theoretical BER', 'Practical BER');
  end
end
