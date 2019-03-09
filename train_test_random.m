function [indexes]=train_test_random(y)
K = max(y);

indexes = [];
indexes_c=[];
Value=[20,20,20,20,20,20,20,20,20,20,20,20,20]';    % 10%

for i=1:K
    index1 = find(y == i);
    per_index1 = randperm(length(index1));   %%%randperm 为随机打乱一个数字序列  randperm(5)  = 2 4 1 5 3
    Number=per_index1(1:Value(i));
    indexes_c=[indexes_c index1(Number)];
     
end  
indexes = indexes_c(:);




                  