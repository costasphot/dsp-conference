% Full name: George Constantine Fotopoulos
% R.N.: 1117202200234

%% 0. Initialization
program_tic = tic;
init_tic    = tic;

close all; clc;
clearvars -except program_tic init_tic;

% Program config parameters
debug_mode = true;
debug_plot = false;

function_timing = true;
if function_timing, timings = struct();  end

% Modulation, quantization, and detection parameters
modulation_order    = 4;
oversampling_factor = 1;  % Avoids under-quantization, and reduces the quantization noise
quantization_method = "midrise";
detection_method    = "knnsearch";

% Encoding parameters
generator_polynomial = [1 0 1 1];
block_size = 4;  % TODO: Make it dynamic
apply_fec = true;

% Define the SNR_dB for the system
max_SNR_dB = 20;

% if (modulation_order == 4 || modulation_order == 16 || modulation_order == 64)
%   max_SNR_dB = 20;
% else
%   max_SNR_dB = 10 * log10(modulation_order);  % 256-QAM: ~24, 1K-QAM: ~30
% end

% Define the SNR ranges
SNR_dB_range_theoretical  = 0 : 0.1 : round(max_SNR_dB);
SNR_dB_range_experimental = 0 : 1   : round(max_SNR_dB);

% Define the noise variance
sigma_w2 = 1e-6;

if function_timing
  timings.init_time = toc(init_tic);
  fprintf("[0 - Initialization] Time elapsed: %.6f seconds\n", timings.init_time);
end

% Zero-initialize the BER vectors
ber_theoretical  = zeros(size(SNR_dB_range_theoretical));
ber_experimental = zeros(size(SNR_dB_range_experimental));

%% 1. Create the sine wave
sine_wave_creation_tic = tic;

A  = 1;
f0 = 1;

% Dynamic modulation parameters
periods_to_transmit = 400000;
samples_per_period = max(modulation_order, modulation_order * log2(modulation_order));  % TODO: probably remove max()

% Nyquist rate: fs >= 2 * f0
fs = f0 * samples_per_period;
Ts = 1 / fs;
Tmax = periods_to_transmit / f0;

% Quantization parameters
levels = oversampling_factor * modulation_order;
bits_per_symbol = log2(modulation_order);
bits_per_sample = log2(levels);

% Total number of discrete samples
total_samples = ceil(fs * Tmax);

% How many QAM symbols we can transmit with the calculated samples
symbols_to_transmit = floor((total_samples * bits_per_sample) / bits_per_symbol);
num_of_bits_needed  = symbols_to_transmit * bits_per_symbol;

[cont_t, cont_sine_wave] = create_sine_wave(A, f0, Tmax, debug_plot);

if function_timing
  timings.sine_wave_creation_time = toc(sine_wave_creation_tic);
  fprintf("[1 - Sine Wave Creation] Time elapsed: %.6f seconds\n", timings.sine_wave_creation_time);
end

%% 2. Apply an ideal Low-Pass (Anti-Aliasing) Filter
filter_tic = tic;

% 2.1. Define its specifications
fpass = f0 * 1.5;   % Passband frequency (to fully preserve f0 = 1Hz)   [Hz]
fstop = f0 * 5;     % Stopband frequency (remove high-frequency noise)  [Hz]
Apass = 3;          % Max passband attenuation (industry-standard)      [dB]
Astop = 40;         % Min stopband attenuation (for good filtering)     [dB]

% 2.2. Create the filter
% [b, a, fnyquist, normalized_fpass, normalized_fstop, lowest_order, cutoff_freqs] = create_butterworth_filter(fpass, fstop, Apass, Astop, fs, debug_mode);

% 2.3. Apply zero-phase filtering to the initial (continuous) sine wave
% filtered_sine_wave = apply_filter(b, a, cont_sine_wave, true, [], A, cont_t);

if function_timing
  timings.filter_time = toc(filter_tic);
  fprintf("[2 - Filter Creation & Application] Time elapsed: %.6f seconds\n", timings.filter_time);
end

%% 3. Sampling (Discrete-Time Signal)
sampling_tic = tic;

sampled_t = linspace(0, Tmax, round(Tmax/Ts) + 1);   % Time vector (discrete/sampled time)

sampled_signal = sample_signal(cont_t, cont_sine_wave, sampled_t, "linear", debug_plot, [], A);

if function_timing
  timings.sampling_time = toc(sampling_tic);
  fprintf("[3 - Sampling] Time elapsed: %.6f seconds\n", timings.sampling_time);
end

%% 4. Quantization
quantization_tic = tic;

[~, ~, indices, quantized_signal] = quantize_signal(A, levels, sampled_t, sampled_signal, quantization_method, debug_plot, [], cont_t, cont_sine_wave);

if function_timing
  timings.quantization_time = toc(quantization_tic);
  fprintf("[4- Quantization] Time elapsed: %.6f seconds\n", timings.quantization_time);
end

%% 5. Source Encoding (Binary Representation - convert quantized levels to bitstream)
encoding_tic = tic;

[encoded_bit_stream, bit_padding, padding_length, ~] = encode_signal(levels, indices, bits_per_symbol, generator_polynomial, block_size, apply_fec, debug_mode);

if function_timing
  timings.encoding_time = toc(encoding_tic);
  fprintf("[5 - Encoding] Time elapsed: %.6f seconds\n", timings.encoding_time);
end

%% 6. Channel Modulation (M-QAM - symbol mapping for transmission)
SNR_loop_tic = tic;

for i = 1:length(SNR_dB_range_experimental)
  modulation_tic = tic;

  SNR_dB = SNR_dB_range_experimental(i)
  
  % 6.1. Generate the QAM constellation
  [levels_per_axis, IQ_levels, I, Q, symbols, Es, Eb, symbol_map, gray_labels] = generate_QAM_constellation(modulation_order, SNR_dB, sigma_w2);
  
  % 6.2. Modulate the signal
  [bit_pairs, symbol_indices, ~, transmitted_signal] = modulate_signal(encoded_bit_stream, symbol_map, gray_labels, modulation_order, true, []);
  
  if function_timing
    timings.modulation_time = toc(modulation_tic);
    fprintf("[6 - Modulation] Time elapsed: %.6f seconds\n", timings.modulation_time);
  end
  
  %% 7. Add complex gaussian noise
  noise_tic = tic;
  
  % 7.1. Generate a complex gaussian noise
  [~, ~, ~, cg_noise, ~] = generate_cg_noise(sigma_w2, transmitted_signal, debug_mode);
  
  % 7.2. Because of the possible variance inaccuracy, apply variance normalization
  [~, ~, ~, ~, ~, ~, cg_noise_normalized, ~] = normalize_cg_variance(cg_noise, sigma_w2, debug_mode);
  
  % 7.3. Apply noise to the transmitted signal
  received_signal = apply_noise(transmitted_signal, cg_noise_normalized, true);
  
  if function_timing
    timings.noise_time = toc(noise_tic);
    fprintf("[7 - Noise Application] Time elapsed: %.6f seconds\n", timings.noise_time);
  end
  
  %% 8. Demodulation (detect the symbols)
  detection_tic = tic;
  
  [detected_indices, symbol_map_2D, received_signal_2D] = detect_symbols(symbol_map, received_signal, detection_method);
  
  if function_timing
    timings.detection_time = toc(detection_tic);
    fprintf("[8- Symbol Detection] Time elapsed: %.6f seconds\n", timings.detection_time);
  end
  
  %% 9. Bitstream Recovery (recover the bits from the detected indices)
  recovery_tic = tic;
  
  [recovered_bit_stream, recovered_padded_bit_stream, detected_bits] = decode_symbol_indices(detected_indices, gray_labels, bit_padding, padding_length, generator_polynomial, block_size, apply_fec, true);
  
  if function_timing
    timings.recovery_time = toc(recovery_tic);
    fprintf("[9 - Bit Recovery] Time elapsed: %.6f seconds\n", timings.recovery_time);
  end
  
  %% 10. BER Comparison (experimental vs. theoretical)
  ber_tic = tic;

  min_length = min(length(encoded_bit_stream), length(recovered_bit_stream));
  ber_experimental(i) = sum(encoded_bit_stream(1:min_length) ~= recovered_bit_stream(1:min_length)) / min_length;

  if function_timing
    timings.ber_time = toc(ber_tic);
    fprintf("[10 - BER Calculation] Time elapsed: %.6f seconds\n", timings.ber_time);
  end
end  % End of experimental BER calculation for-loop

Eb_N0_dB = zeros(length(SNR_dB_range_theoretical));

% Theoretical BER calculation
for i = 1:length(SNR_dB_range_theoretical)
  SNR_dB = SNR_dB_range_theoretical(i);
  
  Es = sigma_w2 * 10^(SNR_dB / 10);
  Eb = Es / bits_per_symbol;
  Eb_N0 = Eb / sigma_w2;
  Eb_N0_dB(i) = 10 * log10(Eb_N0);
  
  % Works perfectly for 4-QAM; and for M-QAM the experimental converges only in higher SNR values
  erfn_arg = sqrt((3 * bits_per_symbol / (2 * (modulation_order - 1))) * (Eb_N0));
  Pe = (4 / bits_per_symbol) * (1 - 1/sqrt(modulation_order)) * qfunc(erfn_arg);

  ber_theoretical(i) = Pe;
end

figure(18);

semilogy(SNR_dB_range_theoretical, ber_theoretical, "b", "LineWidth", 1.5);
hold on;
semilogy(SNR_dB_range_experimental, ber_experimental, "r*", "LineWidth", 1.5);

grid on;

title(sprintf("BER Comparison for %d-QAM (σ_w^2 = %.0e)", modulation_order, sigma_w2));
subtitle(sprintf("Number of bits needed: %d (%d periods)", num_of_bits_needed, periods_to_transmit));

xlabel("E_b/N_0 [dB]");
ylabel("BER");

legend("Theoretical BER", "Experimental BER");

timings.SNR_loop_time = toc(SNR_loop_tic);
fprintf("[6...10 - SNR for-loop] Time elapsed: %.6f seconds\n", timings.SNR_loop_time);

timings.program_time = toc(program_tic);
fprintf("\n===== TOTAL EXECUTION TIME: %.4f seconds =====\n", timings.program_time);
