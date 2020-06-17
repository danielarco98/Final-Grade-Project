function mout= CreateSymm_Pattern(orientation, perc_b, perc_localsymm)
	%Function to create a symmetric pattern (now fixed to 9x9 size) 
	%with a selected orientation and deviation from symmetry
	%Input:
    %Orientation: Axis of symmetry orientation of the desired symmetric
    %pattern
    %perc_b: Percentage of black over white
    %perc_localsymm: Percentage of symmetry of the desired symmetric
    %pattern (0-1)
    %Output:
    %mout: Matrix containing the locations of the center of the points of
    %the symmetric patterns
    
	N= 9; %Fixed pattern size of 9x9 points
    symmobject= zeros(N,N); %intialize the symm pattern
    
    perc_w= 1-perc_b; %Define the percentage of black over white
    %If size is odd a column/row of the image will be the symmetry axis
    if mod(N,2) == 0
        isodd= 0; %if it's even the symmetry axis will be between two row/columns
    else
        isodd=1;
    end
    
    if orientation == 0 || orientation == 90
       isdiag= 0; %Store info about symmetry axis orientation
    else
       isdiag= 1; 
    end
    
    prob_mat_white= rand(N, N); %Decide the locations of white points
    
    if isdiag == 0 %Two different method used for creating diagonal and horitzontal/vertical patterns
			prob_mat_white(int8((N+isodd)/2+1):end,:) = 0; 
            %Matrices for deciding where asymmetries are introduced
            changep1= rand(N, N);
            changep2= rand(N, N);
                        
            %Matrices for symmetric patterns
            half1= zeros(N,N);
            half1(prob_mat_white > perc_w)= 1;
            half2 = half1;
            
            %Write -1 insted of 0 to parts out of symmetric halves
            half1(int8((N+isodd)/2 +1):end, :)= -1;
            half2(int8((N-isodd)/2 +1):end, :)= -1;
            
            copy1= half1;
            copy2= half2;
            
            %Write -1 on one of the pairs of point
            %Only one of both can change
            changep1(changep1< changep2) = -1;
            changep2(changep2< changep1) = -1;

            %Insert asymmetries
            copy2(half2==0 & changep2 > perc_localsymm) = 1;
            copy2(half2==1 & changep2 > perc_localsymm) = 0;
            copy1(half1==0 & changep1 > perc_localsymm) = 1;
            copy1(half1==1 & changep1 > perc_localsymm) = 0;
            copy1(half1==-1) = 0;
            copy2(half2==-1)=0;
            
            symmobject= copy1 + flip(copy2,1);
        
            
        %if orientation == 90
            %symmobject= symmobject';
        %end
        
    else
        %Same procedure is used for diagonal symmetric patterns
  		prob_mat_white= rand(N, N);
        change_chance= rand(N, N);
        
        pm= zeros(size(prob_mat_white));
        pm(prob_mat_white > perc_w)= 1;
        
        %To select the symmetric halves on diagonal patterns
        %Function tril is used
        tpm= tril(pm) + tril(pm,-1)';
        
        half1= tril(tpm);
        half2 = triu(tpm,+1)';
        
        copy1= half1;
        copy2= half2;
       
        %Only one of the pair of symmetric points can change
        changep1= tril(change_chance);
        changep2= triu(change_chance, +1).';
        
        changep1(changep1 < changep2) = -1;
        changep2(changep2 < changep1) = -1;
        
        %Insert asymmetries
        copy2(half2==0 & changep2 > perc_localsymm) = 1;
        copy2(half2==1 & changep2 > perc_localsymm) = 0;
        copy1(half1==0 & changep1 > perc_localsymm) = 1;
        copy1(half1==1 & changep1 > perc_localsymm) = 0;
        
        symmobject= copy1 + copy2';
        
    end 
    
	mout= symmobject;
    
  