clc;clear
close all;

C = 13;lambda = 0.1;
load KSC
load KSC_gt
[xi,yi] =find(KSC_gt==0);
xisize=size(xi);
[r,c,b] = size(img);
GroundT=(GroundT');
img2d=reshape(img,[r*c,b]);

label_C_end = [];label_C_pos = [];

label_spectra_3 = [];
indexes=train_test_random_new(GroundT(2,:));   %%%选取训练样本
train_SL = GroundT(:,indexes);
train_samples = img2d(train_SL(1,:),:);
Test_SL = GroundT;
Test_SL(:,indexes) = [];
Test_SL_samples = img2d(Test_SL(1,:),:);
train_labels_C= train_SL(2,:)'; 
NL_num = 3;                    
[train_labels_noise_1,noise_train_data,noise_train_data1] = LNA_fei(train_SL,Test_SL,train_labels_C,train_samples,Test_SL_samples,NL_num);
train_labels_noise = [noise_train_data1(:,2)';train_labels_noise_1'];
for i = 1:C
    label_kind{i} = train_labels_noise(:,(train_labels_noise(2,:)==i));
    label_row = ceil(label_kind{i}(1,:)/r);
    label_col = label_kind{i}(1,:)-(label_row-1)*r;
    label_spectra_1{i} = [label_kind{i};img2d(label_kind{i}(1,:),:)'];
end
para.method = 'gaussian';
para.percent = 26;
label_spectra_4 = label_spectra_1;
train_sample_correct = [];train_label_correct = [];sample_detect = [];
for i = 1:C
    label_spectra_2{i} = normalize_data(label_spectra_1{i}((3:end),:));
    for z = 1: size(label_spectra_2{i},2)
        for j = 1:size(label_spectra_2{i},2)
            A = corr2(label_spectra_2{i}(:,z),label_spectra_2{i}(:,j));
            label_spectra_3{i}(z,j) = 1-A;
        end
    end
    label_spectra_sum{i} = mean(label_spectra_3{i});
    [rho] = cluster_dp_auto(label_spectra_3{i}, para);
    rho_1_mean = mean(rho);
    rho_1_limit = lambda * rho_1_mean;
    sample_temp = find(rho<rho_1_limit);
    label_spectra_4{i}(:,sample_temp)=[];
    train_sample_correct = [train_sample_correct label_spectra_4{i}(1,:)]; 
    train_label_correct = [train_label_correct label_spectra_4{i}(2,:)];
    sample_detect = [sample_detect;sample_temp+(size(train_labels_noise,2)/C)*(i-1)];
end

for i = 1:size(train_labels_noise,2)
    train_sample_error(i) = find(GroundT(1,:)==train_labels_noise(1,i));
end
test = GroundT;
test(:,train_sample_error) = [];
test_sample = test(1,:);
test_label = test(2,:);
%======================矫正label_noise后的分类结果==========================
fimg = reshape(img,r*c,size(img2d,2));
train_sample_temp = noise_train_data;
[train_sample_temp,M,m] = scale_func(train_sample_temp);    
[fimg] = scale_func(fimg,M,m);
train_samples = train_sample_temp;
train_samples(sample_detect,:) = [];
[Ccv,Gcv,cv,cv_t]=cross_validation_svm(train_label_correct',train_samples);
parameter=sprintf('-c %f -g %f -m 500 -t 2 -q',Ccv,Gcv);
model=svmtrain(train_label_correct',train_samples,parameter);
Result = svmpredict(ones(r*c,1),fimg,model);
GroudTest = double(test_label);
ResultTest = Result(test_sample,:);
[OA,AA,kappa,CA] = confusion(GroudTest,ResultTest)

Result = reshape(Result,r,c);
VClassMap=label2color(Result,'india');
figure()
imshow(VClassMap);