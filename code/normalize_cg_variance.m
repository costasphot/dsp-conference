% normalize_cg_variance
%

function [current_real_noise_variance, current_imag_noise_variance, real_scaling_factor, imag_scaling_factor, cg_noise_real, cg_noise_imag, cg_noise_normalized, total_noise_power_avn] = normalize_cg_variance(cg_noise, sigma_w2, debug_mode)
  % Define default values if parameters are not provided
  if nargin < 3 || isempty(debug_mode), debug_mode = true;  end

  % 1. Compute actual variances and scaling factors for each component
  current_real_noise_variance = var(real(cg_noise));   % Finds the actual variance of the real part of the generated noise
  current_imag_noise_variance = var(imag(cg_noise));   % Finds the actual variance of the imag part of the generated noise
  real_scaling_factor = sqrt(sigma_w2 / current_real_noise_variance);    % Explanation:
      % If the actual variance is smaller than sigma_w2, the factor is greater than 1 (increases the noise power)
      % If the actual variance is larger than sigma_w2, the factor is less than 1 (reduces the noise power)
  imag_scaling_factor = sqrt(sigma_w2 / current_imag_noise_variance);    % Same explanation

  % 2. Rescale real and imaginary parts separately (because of persistent inaccuracy in the imaginary part)
  cg_noise_real = real(cg_noise) * real_scaling_factor;
  cg_noise_imag = imag(cg_noise) * imag_scaling_factor;

  % 3. Recombine to form the corrected (normalized) complex noise
  cg_noise_normalized = cg_noise_real + 1j * cg_noise_imag;  % This rescales the noise so that the variance (borh real and imag) exactly equal to sigma_w2

  total_noise_power_avn = var(real(cg_noise)) + var(imag(cg_noise_normalized));


  % 4. Print noise statistics (after variance normalization)
  if debug_mode
    fprintf("\n[Debug - normalize_cg_variance] Noise Statistics (after variance normalization):\n");
    fprintf("  Mean (Magnitude):\t%.2e\n", max(mean(abs(cg_noise_normalized)), eps));      % Mean noise magnitude
    fprintf("  Variance (Real part):\t%.2e\n", var(real(cg_noise_normalized)));  % Variance of the real part
    fprintf("  Variance (Imag part):\t%.2e\n", var(imag(cg_noise_normalized)));  % Variance of the imaginary part

    fprintf("  Total Noise Power:\t%.2e\n", total_noise_power_avn);          % Should be close to 2 * 10^(-6)
  end
end

