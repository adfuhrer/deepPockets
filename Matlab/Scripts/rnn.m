%do parametrization

file = load('training_newWithFutureValue.mat');
trainingSet = file.trainingSet;
%use data to build rnn
net = layrecnet(1:2,38);
%get labels from training set
labels = trainingSet(:,end-1);
x = trainingSet(:,1:end-2);
[Xs,Xi,Ai,Ts] = preparets(net,x,labels);
net =  train(net,Xs,Ts,Xi,Ai);
Y = net(Xs,Xi,Ai);
perf = perform(net,Y,Ts);
