clear;
clc;

x = [-3:0.02:3];
y = 6.5*sin(2.1*x+pi/3);
z = y;

n = numel(z);
f = 0.6; % Alter this to set the fraction of the data to be corrupted
numReplace = round(f*n);

square_sum = 0;

replaceIndex = randperm(n, numReplace);

newVals = 100 + 20*rand(1, numReplace);

z(replaceIndex) = newVals;

y_median = zeros(1,n);



for i = 1:n
    left_index = max(1,i-8);
    right_index = min(n,i+8);

    window = z(left_index:right_index);

    y_median(i) = median(window);
end

y_mean = zeros(1,n);

for i = 1:n
    left_index = max(1,i-8);
    right_index = min(n,i+8);

    window = z(left_index:right_index);

    y_mean(i) = mean(window);
end

y_prctle_25 = zeros(1,n);

for i = 1:n
    left_index = max(1,i-8);
    right_index = min(n,i+8);

    window = z(left_index:right_index);

    y_prctle_25(i) = prctile(window, 25);
end

median_diff_sum = sum((y-y_median).^2);
mean_diff_sum = sum((y-y_mean).^2);
percentile_diff_sum = sum((y-y_prctle_25).^2);

square_sum = sum(y.^2);

median_diff = median_diff_sum/square_sum
mean_diff = mean_diff_sum/square_sum
percentile_diff = percentile_diff_sum/square_sum

figure(1); clf;
plot(x, y, 'DisplayName','Original');
hold on;
plot(x, z, 'DisplayName', 'Corrupted sine wave y');
hold on;
plot(x, y_median, 'DisplayName','Median filtered sine wave');
hold on;
plot(x, y_mean, 'DisplayName','Mean filtered sine wave');
hold on;
plot(x, y_prctle_25, 'DisplayName','25th Percentile filtered sine wave');
legend('Location', 'best');
xlabel('x values');
ylabel('y values');
title('Comparison of Original and Modified sine waves');
hold on;
grid on;
