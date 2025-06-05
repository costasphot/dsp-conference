% create_sine_wave
% Creates a sine wave signal based on amplitude, frequency, sampling time, and duration.
% Optionally plots the wave for visualization and debugging.

function [cont_t, sine_wave] = create_sine_wave(A, f0, Tmax, debug_plot, figure_number)
  % Define default values if parameters are not provided
  if nargin < 5 || isempty(figure_number), figure_number = 10;  end  % Default figure number
  if nargin < 4 || isempty(debug_plot), debug_plot = false;     end  % Disable plotting by default

  cont_Ts = 0.001;  % Sampling time       [sec]    (simulation resolution)
  
  % 1. Create time vector from 0 to Tmax with step size 'cont_Ts' (Tmax/cont_Ts + 1 samples)
  cont_t = 0:cont_Ts:Tmax;

  % 2. Create time vector from 0 to Tmax with step size Ts
  sine_wave = A * sin(2 * pi * f0 * cont_t);

  % 3. Plot the generated sine wave (only if debugging is enabled)
  if debug_plot
    figure(figure_number);
    clf;

    plot(cont_t, sine_wave, 'b');  % Plot sine wave in blue

    grid on;

    title("Continuous Sine Wave");
    xlabel("Time (s)");
    ylabel("Amplitude");

    ylim([-A - 0.1, A + 0.1]);  % Adjust Y-axis slightly beyond amplitude for clarity

    legend("Original Continuous Sine Wave");
  end
end

