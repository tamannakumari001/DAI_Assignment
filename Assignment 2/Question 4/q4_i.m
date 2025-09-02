im1 = double(imread('T1.jpg'));
im2 = 255 - im1;

tx_range = -10:10;
bin_width = 10;

corr_vals = zeros(size(tx_range));
QMI_vals = zeros(size(tx_range));
MI_vals = zeros(size(tx_range));

[m, n] = size(im1);

minimum = min([im1(:); im2(:)]);
maximum = max([im1(:); im2(:)]);
edges = minimum:bin_width:(maximum + bin_width);

function [jointHist] = joint_histogram(x, y, bin_width, edges)
       
    minimum = min([x; y]);

    jointHist = zeros(length(edges) - 1, length(edges) - 1);

    for k = 1:length(x)
        x1 = x(k);
        y1 = y(k);

        x_bin = floor((x1 - minimum)/bin_width) + 1;
        y_bin = floor((y1 - minimum)/bin_width) + 1;

        jointHist(x_bin, y_bin) = jointHist(x_bin, y_bin) + 1;

    end

    jointHist = jointHist / sum(jointHist(:));

end

function cor = correlation_calc(x, y)

    x_mean = mean(x);
    y_mean = mean(y);

    cov_12 = sum((x - x_mean).*(y - y_mean));
    
    x_sigma = sqrt(sum((x - x_mean).^2));
    y_sigma = sqrt(sum((y - y_mean).^2));

    cor = cov_12 / (x_sigma * y_sigma);

end

for idx = 1:length(tx_range)

    tx = tx_range(idx);
    
    im2_shifted = zeros(m, n);
    mask = false(m, n);
    
    if (tx > 0)
        im2_shifted(:, (1+tx):n) = im2(:, 1:(n-tx));
        mask(:, (1+tx):n) = true;
    elseif tx < 0
        im2_shifted(:, 1:(n+tx)) = im2(:, (1-tx):n);
        mask(:, 1:(n+tx)) = true;
    else
        im2_shifted = im2;
        mask(:,:) = true;
    end
    
   x = im1(:);
   y = im2_shifted(:);
   mask = mask(:);
   
   x = x(mask);
   y = y(mask);

   cor = correlation_calc(x, y);
   corr_vals(idx) = cor;

   [jointHist] = joint_histogram(x, y, bin_width, edges);

   pI1 = sum(jointHist, 2);
   pI2 = sum(jointHist, 1);

   product = pI1 * pI2;
   QMI_vals(idx) = sum((jointHist(:) - product(:)).^2);

   mask = (jointHist > 0) & (product > 0);

   ratio = jointHist(mask) ./ product(mask);

   MI_vals(idx) = sum(jointHist(mask).*log(ratio));

end

figure;
subplot(3,1,1);
plot(tx_range, corr_vals, '-o', 'LineWidth', 1.5);
xlabel('Shift t_x'); ylabel('Correlation \rho');
title('Correlation coefficient vs. shift');

subplot(3,1,2);
plot(tx_range, QMI_vals, '-o', 'LineWidth', 1.5);
xlabel('Shift t_x'); ylabel('QMI');
title('Quadratic Mutual Information vs. shift');

subplot(3,1,3);
plot(tx_range, MI_vals, '-o', 'LineWidth', 1.5);
xlabel('Shift t_x'); ylabel('MI');
title('Mutual Information vs. shift');