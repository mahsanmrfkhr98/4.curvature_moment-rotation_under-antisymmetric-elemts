close all
clear all
%% 00 - Pre-Definitions
% Total Number of DoFs
  NSubelements=3;
  EachElementLenght=48;
  NIntegrationPointsInEachSubelement=7;
%% 01 - Calculations: Gauss-Lobatto Integration Point Positions Along a Single Element

  NPoints=NIntegrationPointsInEachSubelement;
  LElement=EachElementLenght;
  %%%%%%%%%%%%%%%%%%%%%%%%
  x=cos(pi*(0:(NPoints-1))/(NPoints-1))'; 
  P=zeros(NPoints,NPoints); 
  xold=2;
  while max(abs(x-xold))>eps; xold=x; P(:,1)=1; P(:,2)=x; 
        for k=2:(NPoints-1)
            P(:,k+1)=((2*k-1)*x.*P(:,k)-(k-1)*P(:,k-1))/k; 
        end; x=xold-(x.*P(:,NPoints)-P(:,(NPoints-1)))./(NPoints*P(:,NPoints)); 
  end
  %%%%%%%%%%%%%%%%%%%%%%%%
  SingleElementStations=((-0.5*(x-1)*NSubelements*LElement)/NSubelements); 

%% 02 - Calculations: Gauss-Lobatto Integration Point Positions Along the Whole Member (with Repeated Stations)

  NPoints=NIntegrationPointsInEachSubelement;
  LElement=EachElementLenght;
  %%%%%%%%%%%%%%%%%%%%%%%%
  x=cos(pi*(0:(NPoints-1))/(NPoints-1))'; 
  P=zeros(NPoints,NPoints); 
  xold=2;
  while max(abs(x-xold))>eps; xold=x; P(:,1)=1; P(:,2)=x; 
        for k=2:(NPoints-1)
            P(:,k+1)=((2*k-1)*x.*P(:,k)-(k-1)*P(:,k-1))/k; 
        end; x=xold-(x.*P(:,NPoints)-P(:,(NPoints-1)))./(NPoints*P(:,NPoints)); 
  end
  %%%%%%%%%%%%%%%%%%%%%%%%
  for i=1:NSubelements 
      for j=1:NPoints
          WholeMemeberStations((i-1)*NPoints+j)=((-0.5*(x(j)-1)*NSubelements*LElement)/NSubelements)+((i-1)*LElement); 
      end
  end
  
%% 03 - Calculations: Gauss-Lobatto Integration Point Positions Along the Whole Member (without Repeated Stations)
  
  NPoints=NIntegrationPointsInEachSubelement;
  LElement=EachElementLenght;
  %%%%%%%%%%%%%%%%%%%%%%%%
  x=cos(pi*(0:(NPoints-1))/(NPoints-1))'; 
  P=zeros(NPoints,NPoints); 
  xold=2;
  while max(abs(x-xold))>eps; xold=x; P(:,1)=1; P(:,2)=x; 
        for k=2:(NPoints-1)
            P(:,k+1)=((2*k-1)*x.*P(:,k)-(k-1)*P(:,k-1))/k; 
        end; x=xold-(x.*P(:,NPoints)-P(:,(NPoints-1)))./(NPoints*P(:,NPoints)); 
  end
  %%%%%%%%%%%%%%%%%%%%%%%%
  for i=1:NSubelements 
      for j=1:NPoints
          WholeMemeberStations((i-1)*NPoints+j)=((-0.5*(x(j)-1)*NSubelements*LElement)/NSubelements)+((i-1)*LElement); 
      end
  end  
  for i=NSubelements:-1:2 
        Stations((i-1)*NIntegrationPointsInEachSubelement+1)=[];
  end
  
%% 04 - Calculations: Curvature Smoothener

  NPoints=NPoints; 
  % Delete the Repeated Curvature Values at the Ends of the Elements
  for i=NSubelements:-1:2 
      Stations((i-1)*NPoints+1)=[];
      OpenSeesForceControlCurvatures((i-1)*NPoints+1)=[];
      OpenSeesDisplacementControlCurvatures((i-1)*NPoints+1)=[];
  end
  % Copy the First Half of the Curvatures (on the Left Side of the Member) and Mirror them to the Second Half of the Curvatures (on the Right Side of the Member)
  for i=1:floor((((NSubelements-1)*(NPoints-1))+NPoints)/2)
      OpenSeesForceControlCurvatures(1,(((NSubelements-1)*(NPoints-1))+NPoints)-(i-1))=(-1)*OpenSeesForceControlCurvatures(1,i);
      OpenSeesDisplacementControlCurvatures(1,(((NSubelements-1)*(NPoints-1))+NPoints)-(i-1))=(-1)*OpenSeesDisplacementControlCurvatures(1,i);
  end