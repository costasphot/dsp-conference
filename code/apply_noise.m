% apply_noise

function [received_signal] = apply_noise(transmitted_signal, cg_noise_normalized, debug_plot, figure_number)
  % Define default values if parameters are not provided
  if nargin < 4 || isempty(figure_number), figure_number = 16;  end
  if nargin < 3 || isempty(debug_plot), debug_plot = false;     end

  received_signal = transmitted_signal + cg_noise_normalized;

  if debug_plot
    figure(figure_number);
    clf;

    scatter(real(received_signal), imag(received_signal), 'ro', 'LineWidth', 1.5, 'MarkerFaceColor', 'none');
    hold on;
    scatter(real(transmitted_signal), imag(transmitted_signal), 'bo', 'LineWidth', 1.5, 'MarkerFaceColor', 'none');
    
    grid on;
    
    title('Received Signal Constellation (With Noise)');
    
    xlabel('Real Part');
    ylabel('Imaginary Part');
    
    axis equal;

    margin = 0.5;

    real_max = max(abs(real(transmitted_signal)));
    imag_max = max(abs(imag(transmitted_signal)));
    xlim([-real_max, real_max] + [-margin, margin]);
    ylim([-imag_max, imag_max] + [-margin, margin]);
    
    legend('Received Symbols', 'Transmitted Symbols');
  end
end
