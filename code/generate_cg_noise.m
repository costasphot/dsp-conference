% generate_cg_noise

function [standard_deviation, noise_real, noise_imag, cg_noise, total_noise_power_bvn] = generate_cg_noise(sigma_w2, transmitted_signal, debug_mode)
  % Define default values if parameters are not provided
  if nargin < 3 || isempty(debug_mode), debug_mode = true;  end

  standard_deviation = sqrt(sigma_w2);  % Again, for both Re and Im parts

  noise_real = standard_deviation .* randn(size(transmitted_signal));
  noise_imag = standard_deviation .* randn(size(transmitted_signal));

  % Complex Gaussian noise: N(0, sigma^2) + j * N(0, sigma^2)
  % Due to randomness (statistical fluctuations), actual power will be close to but not exactly 2 * sigma^2
  cg_noise = noise_real + 1j * noise_imag;

  total_noise_power_bvn = var(real(cg_noise)) + var(imag(cg_noise));

  % Print noise statistics (before variance normalization)
  if debug_mode
    fprintf("\n[Debug - generate_cg_noise] Noise Statistics (before variance normalization):\n");
    fprintf("  Mean (Magnitude):\t%.2e\n", max(mean(abs(cg_noise)), eps));  % Mean noise magnitude
    fprintf("  Variance (Real part):\t%.2e\n", var(real(cg_noise)));        % Variance of the real part
    fprintf("  Variance (Imag part):\t%.2e\n", var(imag(cg_noise)));        % Variance of the imaginary part

    fprintf("  Total Noise Power:\t%.2e\n", total_noise_power_bvn);         % Should be close to 2 * sigma^2
  end
end
