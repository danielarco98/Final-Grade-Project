Script used for testing the behaviour of our global symmetry parameter
%The correlation coefficient between each symmetric matrix is computed

perc_white= 0.5; %Define the same proportion of black and white

num_localsymmpattern= 2; %Number of local symmetric patterns, fixed to 2
prop_globalsymm = 0:0.05:1; %Range of values of global symmetry
perc_localsymm = 0.4;  %Random value for local symmetric patterns
ntries= 100; %Number of replicates

C_Scores= zeros(length(prop_globalsymm),1); %Matrix for mean correlation scores
%on each global symmetry value

for x = 1:length(prop_globalsymm) %Iterate over Global symmetry values
    tot_triesC= zeros(ntries, 1);%Store tyhe value for each replicate
    perc_globalsymm= prop_globalsymm(x); %set global symmetry value
    for y= 1:ntries %iterate over replicates 
	   orientation = datasample(0:45:135,1);%set orientation
       [im_mat, dot_mat, labels_mat]= Generate_PartialSymmetricImage(perc_white, perc_globalsymm, perc_localsymm, num_localsymmpattern, orientation);  
       %Generate a replicate
       Corr_Score = Symmetry_Score(dot_mat, orientation);%Compute the correlation coefficient between each symmetric half
       tot_triesC(y,1)= Corr_Score; %Store the Correlation Score
    end

     C_Scores(x,1)= mean(tot_triesC); %Compute the mean of all replicates and store it

end

figure(1);
plot(prop_globalsymm, C_Scores,'-')
xlabel("% Of Global Symmetric Points")
ylabel("Correlation")
