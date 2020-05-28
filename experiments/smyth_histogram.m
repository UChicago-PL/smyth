experiment = argv(){1};
amount = argv(){2};

nice_experiment = ['Experiment ' strsplit(experiment, '-'){2}];

diffs = csvread(['data/' experiment '/histogram/k' amount '.csv']);

horizontal = min(diffs):1:max(diffs);

figure('visible', 'off');
hist(diffs, horizontal, 'facecolor', [0, 0.4470, 0.7410]);

title([nice_experiment ', k_{' amount '} - k_{expert}']);
xlabel('Difference');
ylabel('Number of Tasks');

saveas(gcf, ['data/' experiment '/histogram/k' amount '.png']);
