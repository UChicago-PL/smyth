experiment = argv(){1};
name = argv(){2};

nice_experiment = ['Experiment ' strsplit(experiment, '-'){2}];

data = csvread(['data/' experiment '/csv/' name '.csv']);

timeout = data(2, 2);
trials = data(3, 2);

data = data(5:end,:);

figure('visible', 'off');
plot(data(:, 1), data(:, 2), 'LineWidth', 3);

title([name ' (' nice_experiment ', N = ' num2str(trials) ', timeout = ' num2str(timeout) 's)'], 'Interpreter', 'none');

xlim([0 inf]);
xlabel('Example Set Size');

ylim([0 1]);
ylabel('Success Percent');

saveas(gcf, ['data/' experiment '/png/' name '.png']);
