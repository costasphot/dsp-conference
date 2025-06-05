% quantize_signal
% Performs mid-rise quantization on a sampled signal given a number of levels.
% Returns the quantized levels, the closest level indices, and the quantized signal.

function [delta, quantized_levels, indices, quantized_signal] = quantize_signal(A, levels, sampled_t, sampled_signal, quantization_method, debug_plot, figure_number, cont_t, cont_sine_wave)
  % Define default values if parameters are not provided
  if nargin < 7 || isempty(figure_number), figure_number = 14;                      end
  if nargin < 6 || isempty(debug_plot), debug_plot = false;                         end
  if nargin < 5 || isempty(quantization_method), quantization_method = "midrise";   end

  % 1. Create uniformly spaced quantization levels in the range [-A, A]
  if strcmpi(quantization_method, "midtread")  % -2, -1, 0, 1, 2
    % Fix type inconsistency, because MATLAB expects 'levels' to be of any type, but I later do a numeric operation '+='
    levels = double(levels);
  
    % Even levels would make the mid-tread quantization asymmetrical (one would be left out)
    if mod(levels, 2) == 0
      levels = levels + 1;
    end

    delta = 2 * A / (levels - 1);
    quantized_levels = linspace(-A, A, levels);

  elseif strcmpi(quantization_method, "midrise")  % -1.5, -0.5, 0.5, 1.5
    % Odd levels would make the mid-rise quantization asymmetrical (-//-)
    if mod(levels, 2) == 1
      levels = levels + 1;
    end

    delta = 2 * A / levels;
    quantized_levels = linspace(-A + delta/2, A - delta/2, levels);
  else
    error("Unknown quantization method: %s. Use 'midrise' or 'midtread'.", quantization_method);
  end

  % 2. For each sample, find the nearest quantization level (index)
  [~, indices] = min(abs(sampled_signal - quantized_levels'), [], 1);  % min(|s(t) - <all_quantized_levels>|)
  % Indices show the numbered level (from 1 up to 8) that the sampled wave's point
  %   is the closest. It basically shows the green dots in the printed signal.

  % 3. Map each sample to its closest quantized value
  quantized_signal = quantized_levels(indices);

  % 4. Plot the quantized signal and optionally the original continuous signal
  if debug_plot
    figure(figure_number);
    clf;

    stem(sampled_t, quantized_signal, "g", "LineWidth", 2);  % Quantized points
    hold on;
    stem(sampled_t, sampled_signal, "r*");  % Original sampled points

    % Plot original continuous signal if provided
    if nargin == 8 && ~isempty(cont_t) && ~isempty(cont_sine_wave)
      plot(cont_t, cont_sine_wave, "b--");  % Original continuous sine wave
    end

    grid on;

    yticks(quantized_levels);

    title("Quantized Signal");
    xlabel("Time (s)");
    ylabel("Amplitude");

    ylim([min(quantized_levels) - 0.1, max(quantized_levels) + 0.1]);  % Keep Y-axis limited to quantization range

    if nargin == 8 && ~isempty(cont_t) && ~isempty(cont_sine_wave)
      legend("Quantized Points", "Sampled Points", "Original Continuous Sine Wave");
    else
      legend("Quantized Points", "Sampled Points");
      fprintf("[Debug] To plot the continuous sine wave, provide both 'cont_t' and 'cont_sine_wave'.\n");
    end
  end
end
