function [syn_samples, syn_classes] = gen_syn_samples(trainingSet, trainingLabel,params)
    % [C,sigma, labelInd] = centers(features,labels,config.para);
    rbf_centers=  params.rbf_centers;
    rbf_spreads= params.spreads;
    rbf_classes= params.labelInd;
    num = params.num_syn_samples;
    gamma = params.gamma;
    syn_samples=[];
    syn_classes=[];
    parzen_windows = params.parzen_windows;
%     parzen_windows = rbf_spreads./parzen_windows;

    for rbf_class = unique(rbf_classes)
        rbf_centers_k = rbf_centers(:, rbf_classes==rbf_class);
        rbf_spreads_k = rbf_spreads(:, rbf_classes==rbf_class);
        for i = 1:size(rbf_centers_k,2)
            rbf_center=rbf_centers_k(:,i);
            spread=rbf_spreads_k(i);
            parzen_window_rbf = parzen_windows(i);
            new_samples_k = gen_rbf_samples(rbf_center,spread,num);
            [samples,~] = samples_in_rbf(trainingSet, trainingLabel,rbf_center, spread, rbf_class);
            pdf_values=zeros(1,size(new_samples_k,2));
            for j = 1:size(new_samples_k,2)
                new_sample=new_samples_k(:,j);
                pdf_values(j)=new_pdf(new_sample, samples, parzen_window_rbf);
            end

            r_threshold = rand(1,size(new_samples_k,2));
%             size(pdf_values)
%             fprintf("max_pdf: %f and r_threshold: %f \n", max(pdf_values), r_threshold)
            indices = find(pdf_values>=r_threshold);
%             fprintf("%f\n",indices)
%             pause
            if size(indices,2) == 0
                continue
            end
            
            indices_ind = zeros(1,size(indices,2))+1;

            for rbf_other_class = unique(rbf_classes)
                if rbf_other_class==rbf_class
                    continue
                end
                [other_samples_in_rbf, ~] = samples_in_rbf(trainingSet,trainingLabel,rbf_center,spread,rbf_other_class);
                other_pw_ind=vecnorm(rbf_center-rbf_centers)==0;
                other_parzen_window_rbf = parzen_windows(:,other_pw_ind);
                for j = indices
                    new_sample = new_samples_k(:,j);
                    other_pdf_value=new_pdf(new_sample,other_samples_in_rbf,other_parzen_window_rbf);
                    disp(r_threshold(j),other_pdf_value,pdf_values(j))
                    if r_threshold(j)*gamma >= other_pdf_value || other_pdf_value >=pdf_values(j)
                        indices_ind(j)=-1;
                    end 
                end
            end

            indices=indices(indices_ind>0);
            
            syn_samples=[syn_samples, new_samples_k(:,indices)];
            syn_classes=[syn_classes, rbf_class*ones(1,size(indices,2))];

        end
    end
end

function new_samples = gen_rbf_samples(rbf_center,spread,num)
    new_samples=[];
    safe_count= 0;
    while size(new_samples,2)<num
        safe_count = safe_count+1;
        Z = randn(size(rbf_center));
        r = randn();
        
        % Generate samples that are within the desired spread from the center
        tmp = rbf_center + spread .* Z./norm(Z,2)*r;
        if norm(tmp-rbf_center,2)<=spread
            new_samples=[new_samples,tmp];
        end
    end
end

function pdf_value = new_pdf(z,samples,parzen_windows)
    dim = size(samples,1);
    pdf_value = ((1/sqrt(2*pi)/parzen_windows).^dim) .* exp(vecnorm(z-samples).^2./parzen_windows./(-2));
    if size(samples,2)==0
        samples=samples';
    end
    pdf_value = sum(pdf_value,'all')/size(samples,2);
end

function [samples,indices] = samples_in_rbf(trainingSet,classes_ind, rbf_center, spread, rbf_class)
    ind=find(classes_ind==rbf_class);
    indices=ind;
    samples=trainingSet(:,ind);
    distances=vecnorm(samples-rbf_center);
    ind=distances<spread;
    indices=indices(:,ind);
    samples=samples(:,ind);
end