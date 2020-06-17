function Corr_Score = Symmetry_Score(I, orientation)
%function used to compute the symmetry score of experimetnal images
%Input:
%   ? I: Black and white image or matrix of centers of the points
%   ? orientation: Axis of symmetry orientation
%Output:
%   ? Corr_Score: Correlation between symmetric halves


N= size(I, 1); %Define size of the pattern

if orientation == 0 || orientation == 90%For horitzontal/vertical symmetry
  if orientation == 0
		I= I.'; %Rotate the image to transform it to vertical symmetric
  end
  
  if mod(N,2) ~= 0 %See if the image size is odd or even
	  s = 1;
  else
	  s=0;
  end
  
  X= I(1:end,  1:idivide(int8(N)+s,2) -s ); %Define symmetric halves
  Y= flip(I(:, idivide(int8(N)+s,2)+1 :end), 2); %If is odd the central column is discarded

else %For diagonal (45 and 135 degrees) symmetry
	if orientation == 45 
		I= flip(I,1);
    end
    aux= zeros(N,N) -1;
	X= tril(I,-1) + triu(aux);%Define symmetric halves
	Y= triu(I,1).'+ triu(aux);
end
X = X(X~=-1);% Discard the values outside the symmetric halves
%This is done for diagonal symmetry
Y = Y(Y~=-1);
C= corrcoef([X(:) Y(:)]); %Compute the correlation coefficient
Corr_Score =C(1,2); % or C(2,1) Correlation coefficient(linear)




