function [im_mat, dot_mat, labels_mat]= Generate_PartialSymmetricImage(perc_white, perc_globalsymm, perc_localsymm, num_localsymmpattern, orientation)
  % Function to generate a 1080 x 1080  black and white image with global and local
  % symmetric patterns and display it.
  %
  % Inputs:
  %
  %    ? perc_white: Percentage(0-1) of white points over a black backround    
  %
  %    ? perc_globalsymm: Percentage (0-1) of points that will be
  %    symmetric. Take into account that randomness has symmetry so a 0 pc
  %    symmetric image will be antisymmetric an special case of symmetry.
  %    0.5 will be random. Equal chance of being symmetric or not.
  %
  %    ? perc_localsymm: Percentage (0-1) of points inside local symmetric
  %    figures that will be symmetric.
  %
  %    ? num_localsymmpattern: Integer. Number of symmetric patterns.
  %
  %	   ? orientation: values can be 0,45,90,135 (degrees) with respect to x-axis.
  %	   Desired orientation of the symmetry axis of global and local patterns
  %    (both axis are equal in sake of simplicity).
  %
  % Outputs: 
  %    ? im_mat: Reescaled matrix of 1080x1080 containing the final image
  %    ? dot_mat: Partial symmetric matrix containing the location of the points 
  %               shown on the image
  %    ? labels_mat: Matrix containg the locations of local symmetric
  %    figures.

  
  
  %Constants needed 
  %================================
 
  x_size = 1080; %Size of the image
  shift = 20 ; %black padding
  
  if orientation == 45 || orientation == 135 %two different methods used for 
      %diagonal symmetry
	  oMode = 'D';
  else
      %and for vertical and horitzontal
	  oMode = 'N';
  end

  pixel_size=22;%Size in pixels of a white dot
  perc_black= 1-perc_white; %percentage of black over white points

  % ---------------------------------------------------------------------------

  % Decide where to place a point
  %==============================
  rel_size= 9; %The local symmetric objects are made by 9x9 points
  %Can be changed, better if it's odd

  %some adjustments if image size or rel_size are changed
  shift=  shift + (mod(x_size - shift*2, rel_size* pixel_size))/2;%adjust shift to the relative sizer
  N= idivide(int16(x_size - shift*2),int16(pixel_size)); %find the size in point of the image
  
  %Define tha matrix of points and labels of each mirror part
  p1_mat= zeros(N,N);
  p2_mat= zeros(N,N);
  p1_label= zeros(N,N);
  p2_label= zeros(N,N);
  
  total_figures = num_localsymmpattern; %Number of local symmetric patterns far from symmetry axis

  %Define the background matrix as a random set of white points that are
  %greater than the threshold defined by perc_white or perc_black
  background_mat= rand(N,N);
  background_mat(background_mat > perc_black) = 1;
  background_mat(background_mat < perc_black) = 0;
  
  
  %Select the locations of the local symmetric objects
  %with same symmetry axis as the global one.
  % Don't take into account for local symmetry the zone on the center
  % of the image  that has the same axis of symmetry than global.
  
  prob_mat= rand(idivide(N,rel_size),idivide(N,rel_size)) ;%a matrix containing the possible
    %possitions for local symmetric objects
  
  if oMode=='N' %Vertical or horitzontal symmetry
	
	prob_mat(int8(end/2):end, :) = 0; %Get only one half of the image
	[sortedVals,~]=  sort(prob_mat(:),'descend');%Get the highest scores as their locations
	thresh= sortedVals(total_figures);
	opoints_idx =find(prob_mat >= thresh);

  elseif oMode=='D' %diagonal symmetry

	 prob_mat= tril(prob_mat,-1);%different method for taking one half of the image
	 [sortedVals,~]=  sort(prob_mat(:),'descend');
	 thresh= sortedVals(total_figures);
	 opoints_idx =find(prob_mat >= thresh);  
  end
  
  localsymm_labels= zeros(N,N);
  %Decide the number of local symmetric figures on the first mirror
  
  numo_symm_p1 = randi([0 total_figures],1,1); %Number of local symmetric patterns on first half
  numsymm_p2= total_figures - numo_symm_p1; %Number of local symmetric patterns on second half
  
  %Decide the location of local symmetric objects on the first mirror
  [ind_x, ind_y] = ind2sub([size(prob_mat,1),size(prob_mat,2)],opoints_idx);
  pointzone_coord= [ind_x ind_y];
  
  %Random sample for the location
  localsymm = datasample(pointzone_coord, numo_symm_p1, 1, 'Replace', false);
  
  %Return -1 if there isn't any local symmetric figure
  if numo_symm_p1 == 0
	  localsymm= [-1, -1];
  end
  
  %Create a local symmetric object on each location selected on their
  %corresponding mirrors and copy it on the other mirror,
  %while storing different labels for local symmetric objects and their
  %pairs.
  
  localsymm_obj_num= 1;
  for i = 1:size(pointzone_coord,1)
	  if ismember(pointzone_coord(i,:), localsymm) %Local symmetric patterns for first mirror
          sym_pat= CreateSymm_Pattern(orientation,perc_white, perc_localsymm);%Create a local symmetric pattern
          p1_mat((pointzone_coord(i,1)-1)*rel_size + 1 : pointzone_coord(i,1)*rel_size, (pointzone_coord(i,2)-1)*rel_size +1:pointzone_coord(i,2)*rel_size)= sym_pat; 
          p1_label((pointzone_coord(i,1)-1)*rel_size + 1 : pointzone_coord(i,1)*rel_size, (pointzone_coord(i,2)-1)*rel_size +1:pointzone_coord(i,2)*rel_size)= localsymm_obj_num;
          %Draw the pattern on the first mirror
          p2_mat((pointzone_coord(i,1)-1)*rel_size + 1 : pointzone_coord(i,1)*rel_size, (pointzone_coord(i,2)-1)*rel_size +1:pointzone_coord(i,2)*rel_size)= sym_pat; 
          p2_label((pointzone_coord(i,1)-1)*rel_size + 1 : pointzone_coord(i,1)*rel_size, (pointzone_coord(i,2)-1)*rel_size +1:pointzone_coord(i,2)*rel_size)= -1;
          %Draw the global symm copy on the second mirror
      end
      localsymm_obj_num= localsymm_obj_num+1; %Storee the number for each local symmetric pattern
      %The label oonly correspond to the local symmetric object, not to
      %their global copy
  end
  
%Decide the local figures locations for the second mirror
if numsymm_p2 ~=0
  C = intersect(pointzone_coord, localsymm,'rows'); %Extract previous locations
  points_idx2 = ~ismember(pointzone_coord,C, 'rows'); %And delete them
  g_pointzone_coord = pointzone_coord(points_idx2,:);
  localsymm2= datasample(g_pointzone_coord, numsymm_p2, 1, 'Replace', false); %Select the locations from the possible ones
  
  for i = 1:size(localsymm2,1) %Local symmetric patterns for second mirror
	    sym_pat= CreateSymm_Pattern(orientation,perc_white, perc_localsymm); %Create a local symmetric pattern
		p2_mat((localsymm2(i,1)-1)*rel_size + 1 : localsymm2(i,1)*rel_size, (localsymm2(i,2)-1)*rel_size +1:localsymm2(i,2)*rel_size)= sym_pat;	
        %Draw the pattern on the second mirror
        p2_label((pointzone_coord(i,1)-1)*rel_size + 1 : pointzone_coord(i,1)*rel_size, (pointzone_coord(i,2)-1)*rel_size +1:pointzone_coord(i,2)*rel_size)= localsymm_obj_num;
        if ~(ismember(localsymm2(i,:), localsymm,'rows')) %To avoid overwritting
			p1_mat((localsymm2(i,1)-1)*rel_size + 1 : localsymm2(i,1)*rel_size, (localsymm2(i,2)-1)*rel_size +1:localsymm2(i,2)*rel_size)= sym_pat;
			p1_label((pointzone_coord(i,1)-1)*rel_size + 1 : pointzone_coord(i,1)*rel_size, (pointzone_coord(i,2)-1)*rel_size +1:pointzone_coord(i,2)*rel_size)= -1;
            %Draw the global symm copy pattern on the first mirror
        end
        localsymm_obj_num= localsymm_obj_num+1;
  end
  
  end
  %Once the local symmetric patterns are defined; create a symmetric
  %background, erease the points where local symmetric figures are drawn and paste
  %them. 
  %Then, insert asymetry makin that only one of the points changes if a uniform 
  %distributed random value assigned to that event is higher than erc_globalsymm.
  position_choice= rand(N,N);
  
  change_chance =  rand(N,N);
  if oMode=='D'
    %Create the symmetric background
    %For the creation of the diagonal symmetric matrix,
    %Sum lower diagonal half and upper diagonal on correct orientation.
	localsymm_labels= tril(p1_label) + tril(p2_label,-1)';
    background_mat = tril(background_mat) + tril(background_mat ,-1)';
    
    %Delete the background on the locations of local symmetric patterns and
    %their copies
    background_mat(localsymm_labels ~= 0) = 0;
    %Then paste the local symmetric patterns on the background to obtain
    %the mixed figure
    background_mat= tril(p1_mat) + tril(p2_mat,-1)'  + background_mat;
    
     %Local symmetic figures don't change
	position_choice= rand(N,N);
    position_choice(localsymm_labels > 0) = -1;
    
    %Make that only one point of the symmetric pairs changes.
    changep1= tril(position_choice);
    changep2= triu(position_choice).';
    changep1aux = changep1;
    changep1aux(changep1< changep2) = -1;
    changep2(changep2< changep1) = -1;
    change_mat= changep1aux + changep2';
  
  elseif oMode=='N'
    %Create the symmetric background
    %for vertical and horitzontal symmetry matrix, 
    %sum both mirror parts and one flipped for correct orientation.
    localsymm_labels= p1_label + flip(p2_label, 1);
    background_mat((N+1)/2 +1:end, :)= 0;
    background_mat= background_mat + flip(background_mat, 1); 
   
    %Delete the background where lcoal symmetric patterns will be placed
    %and paste them on the background
    background_mat(localsymm_labels ~= 0) = 0;
	background_mat= p1_mat + flip(p2_mat, 1) + background_mat; 
    
    position_choice(localsymm_labels > 0) = -1;
    
    %Make that only one point of the symmetric pairs changes.
    changep1= position_choice;
    changep2= flip(position_choice,1);
    changep1(changep1< changep2) = -1;
    changep2(changep2< changep1) = -1;   
    changep1((N-1)/2 +1:end, :)= 0;
    changep2((N-1)/2 +1:end, :)= 0;
    change_mat= changep1 + flip(changep2, 1);
    
  end
  
  %Change the points greater than the gloabl symmetry threshold.
  localsymm_labels(localsymm_labels <= 0 ) = 0;
  final_points= background_mat;
  final_points(localsymm_labels==0 & change_mat~=-1 & change_chance > perc_globalsymm & background_mat == 1) = 0;
  final_points(localsymm_labels==0 & change_mat~=-1 & change_chance  > perc_globalsymm & background_mat == 0) = 1;
  
 %doing rotations to get all four orientations
  if orientation == 45
	 localsymm_labels= flip(localsymm_labels, 1);
	 final_points= flip(final_points, 1);
 
 elseif orientation == 0
	 localsymm_labels= localsymm_labels.';
	 final_points= final_points.';
 end


  % Store information 
  %====================

  final_points = final_points.'; 
  
  %Doing bicubic resizing will result on a blurry version of the partial
  %symmetric image form by squares on a greyscale. If some threshold is
  %applied for generating a binary image of it (from greyscale to black and
  %white) you will obtain an image made by blobs.
  
  imr= imresize(final_points, [1080,1080], 'bicubic');
  imr(imr< 0.5)=0;
  imr(imr>=0.5) = 1;
  
  im_mat= imr;
  dot_mat= final_points;
  labels_mat= localsymm_labels;
  
  

  