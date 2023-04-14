
% Experiment info
mu = 8500; % shear modulus [Pa]
alg_list = {'ncc', 'scc', 'lou'};
exp = 'test';
param = 1.5:1.5:6;
param = {'0'};

% Pre-allocate figures
figure(1)
hold on
grid on
title('RMSE')
xlabel('Adquisition #')
ylabel('Disp. error [lambda]')
ylim([0, 1])

figure(2)
hold on
grid on
title('MAE')
xlabel('Frame #')
ylabel('Disp. error [lambda]')
ylim([0, 1])

figure(3)
hold on
grid on
title('SD')
xlabel('Adquisition #')
ylabel('Disp. error dev. [lambda]')
ylim([0, 1])

% Pre-allocate mean table
value = zeros(length(alg_list), length(param));
rmse_table = table(alg_list', value);
mae_table = table(alg_list', value);
sd_table = table(alg_list', value);

% Create empty legend list
legend_list = cell(length(param)*length(alg_list), 1);
k = 1;

for i = 1:length(alg_list)

    % Select line style
    if strcmp(alg_list{i}, 'ncc'); style = '-';
    elseif strcmp(alg_list{i}, 'scc'); style = 'o'; 
    elseif strcmp(alg_list{i}, 'lou'); style = '*';
    end

    for j = 1:length(param)
        % Load results
        load(sprintf('MovieData/%s/mu%d_%s_p%s',...
            exp, mu, alg_list{i}, param{j}));

        % Plot RMSE
        figure(1)
        plot(rmse, style)
        rmse_table.value(i, j) = mean(rmse);
 
        % Plot MAE
        figure(2)
        plot(mae, style)
        mae_table.value(i, j) = mean(mae);
 
        % Plot SD
        figure(3)
        plot(sd, style)
        sd_table.value(i, j) = mean(sd);

        % Add legend entry
        legend_list{k, :} = [alg_list{i}, sprintf(' %s', param{j})];
        k = k + 1;
    end
end

figure(1); legend(legend_list); hold off;
figure(2); legend(legend_list); hold off;
figure(3); legend(legend_list); hold off;