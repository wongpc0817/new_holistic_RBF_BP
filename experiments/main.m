addpath('../utilities')
addpath('../data')

% Main Config
% dim=2;
% num=32;
% modelMethod="Hybrid";
% to_syn=true;

toDraw=false;
% layers = {[30]};
% LRs = 10.^[-2];
% for learning
Trialtemp =1;


% for centers selection
Ts = [50];
para.beta=[1.3];
% para.delta = [0.01];
% para.T = Ts;
para.NEpoch = [10];
para.M = [100];
% ConfSig=3;
para.sigma = ConfSig;
sigmas = para.sigma;
para.alpha = [25];
para.lambda = [1.3];
config.to_syn=to_syn;
config.para=  para;
sep=',';
Setting
trialCount = 0;
for layer = layers
    for sigma= sigmas
%         for T = Ts
            config.T= T; trial = Trialtemp;
            Acc = 0; Pr = 0; Re = 0; F1 = 0;
            test_Acc = 0; test_Pr = 0; test_Re = 0; test_F1 = 0;
            config.logbook=logbook;
            config.normalise = normalise;
            logbook.write("Begin Training ...")
            for lr = LRs
                for counter = 1:trial
                    rng(counter,'twister')
                    training_setup
                    experiment_config
                    if to_syn
                        config.old_trainingSet = old_trainingSet;
                        config.old_trainingTarget=old_trainingTarget;
                    end

                    config.random_seed=counter;
                    rng(counter);
                    tic;
    %                 chooseModel
                    switch modelMethod
                        case "Hybrid"
                            network = noldILRBF(trainingSet,trainingLabel,trainingTarget,config);
                            outputs = newILRBFapplynetwork(old_trainingSet,network);
                            test_outputs = newILRBFapplynetwork(testingSet,network);
                        case "mHybrid"
                            network = newILRBF(trainingSet,trainingLabel,trainingTarget,config);
                            outputs = newILRBFapplynetwork(old_trainingSet,network);
                            test_outputs = newILRBFapplynetwork(testingSet,network);
                    end
                    trainingTime=toc;
                    tic;
                    performance_measuring
                    testingTime=toc;
                    performance_recording
                end
                logbook.write("Finished training. Start recording. Acc:%f, test_Acc",...
                    accuracy ,test_accuracy)
                record_saving
                logbook.write("Record saved.")
            end
%         end
    end
    model_path=sprintf("%s/%s_model_syn%s_T%d_delta_%d_l%d_s%s.mat",model_folder,modelMethod,num2str(to_syn),...
        para.T, log10(para.delta), layers{1}, replace(num2str(ConfSig),'.','_'));
    R.minRecord = minRecord;
    R.cm = mincm;
    R.beta1= minbeta1;
    R.beta2=minbeta2;
    R.lr = minlr;
    R.mom = minmom;
    R.T = minT;
    R.sigma = minsigma;
    R.model = network;
    R.layers= config.layers;
    save(model_path,"R");
end
