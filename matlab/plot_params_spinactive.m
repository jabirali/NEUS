function plot_params_spinactive(filename)
    % This function can be used to plot the output generated by 'params_spinactive'.
     
    % Load the file
    A = load(filename);
    
    % Figure out the scale
    n = (size(A,2)-1)/2;
    N = (size(A,2))/2;
    
    m = (size(A,1)-1)/2;
    M = (size(A,1))/4;
    
    % Plot the data
    surf((-n:n)/N, (-m:m)/M, A,'EdgeColor','None')
    
    % Set the default viewer angle
    view(2)
    
    % Set the axis labels
    xlabel('Polarization')
    ylabel('Spin-dependent phase shifts')
end