name = argv(){1};
trials = argv(){2};
timeout = argv(){3};
kind = argv(){4};

data = csvread(['csv/' name '.csv']);

figure('visible', 'off')
plot(data(:, 1), data(:, 2), 'LineWidth', 3);

title([name ' (' kind ', N = ' trials ', timeout = ' timeout 's)'], 'Interpreter', 'none');

xlim([0 inf])
xlabel('Example Set Size');

ylim([0 1])
ylabel('Success Percent');

saveas(gcf, ['png/' name '.png']);
