path = argv(){1};
prefix = argv{2};

data = csvread(path);

total = rows(data);
the_median = median(data);
the_max = max(data);

med_plus_one = sum(data > the_median + 1);
med_plus_one_percent = round(100 * (med_plus_one / total));

med_plus_two = sum(data > the_median + 2);
med_plus_two_percent = round(100 * (med_plus_two / total));

disp(['\newcommand{\k' prefix 'Median}{' num2str(the_median) '}'])
disp(['\newcommand{\k' prefix 'Max}{' num2str(the_max) '}'])
disp(['\newcommand{\k' prefix 'AboveOne}{' num2str(med_plus_one) ' (' num2str(med_plus_one_percent) '\%)}'])
disp(['\newcommand{\k' prefix 'AboveTwo}{' num2str(med_plus_two) ' (' num2str(med_plus_two_percent) '\%)}'])
