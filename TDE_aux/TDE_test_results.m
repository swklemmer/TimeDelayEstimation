
% Experiment info
mu = 8500; % shear modulus [Pa]
alg_list = ['ncc'; 'scc'; 'lou']';
alg_list = ['lou']';
exp = 'cum_sum';
param = 1:2:20;
legend_list = cell(length(param)*size(alg_list, 2), 1);

figure(1)
hold on
grid on
title('RMSE')
xlabel('Adquisition #')
ylim([0, 0.5])

figure(2)
hold on
grid on
title('MAE')
xlabel('Adquisition #')
ylim([0, 0.5])

figure(3)
hold on
grid on
title('SD')
xlabel('Adquisition #')
ylim([0, 0.5])

i = 1;
for alg = alg_list

    % Select line style
    if strcmp(alg', 'ncc'); style = '-';
    elseif strcmp(alg', 'scc'); style = 'o'; 
    elseif strcmp(alg', 'lou'); style = '*';
    end

    for par = param
        % Load results
        load(sprintf('MovieData/%s/mu%d_%s_p%d', exp, mu, alg, par));

        % Plot RMSE
        figure(1)
        plot(rmse, style)
 
        % Plot MAE
        figure(2)
        plot(mae, style)
 
        % Plot SD
        figure(3)
        plot(sd, style)

        % Add legend entry
        legend_list{i, :} = [alg', sprintf(' %d', par)];
        i = i + 1;
    end
end

figure(1); legend(legend_list); hold off;
figure(2); legend(legend_list); hold off;
figure(3); legend(legend_list); hold off;