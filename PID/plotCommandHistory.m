clear;clc
close all 

data = csvread("outputData.txt");
yyaxis left
plot(data(:, 1), data(:, 3), LineWidth=2)
yyaxis right
plot(data(:, 1), data(:, 2), LineWidth=2)