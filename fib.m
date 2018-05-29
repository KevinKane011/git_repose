function [fib_seq] = fib(n)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

fib_seq = [1,1];
for i = 3:n
    fib_seq(i) = fib_seq(i-1) + fib_seq(i-2);
end

fib_seq(n)

