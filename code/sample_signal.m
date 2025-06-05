% resample_filtered_signal
% Resamples the filtered continuous-time signal into discrete-time samples
% using the specified interpolation method. Optionally plots the result.

function [sampled_signal] = sample_signal(cont_t, cont_signal, sampled_t, interpolation_method, debug_plot, figure_number, A)
  % Define default values if parameters are not provided
  if nargin < 6 || isempty(figure_number), figure_number = 13;                      end
  if nargin < 5 || isempty(debug_plot), debug_plot = false;                         end
  if nargin < 4 || isempty(interpolation_method), interpolation_method = "linear";  end

  % 1. Resample the filtered sine wave at discrete time points using linear interpolation
  sampled_signal = interp1(cont_t, cont_signal, sampled_t, interpolation_method);

  % 2. Plot the resampled signal if debug mode is enabled
  if debug_plot
    if nargin < 7 || isempty(A)
      A = max(abs(sampled_signal));
      fprintf("[Debug - resample_filtered_signal] Manually calculated amplitude is %.2f.\n", A);
    end

    figure(figure_number);
    clf;

    % For large M-QAMs (with many samples), switch to a line plot (or else they'll get cluttered)
    if length(sampled_t) > 500
      plot(sampled_t, sampled_signal, 'r');
    else
      stem(sampled_t, sampled_signal, 'r');
    end

    grid on;

    title("Sampled Signal");
    xlabel("Time (s)"); ylabel("Amplitude");

    ylim([-A - 0.1, A + 0.1]);

    if length(sampled_t) > 500
      legend("Sampled Signal (Line)");
    else
      legend("Sampled Points");
    end
  end
end
