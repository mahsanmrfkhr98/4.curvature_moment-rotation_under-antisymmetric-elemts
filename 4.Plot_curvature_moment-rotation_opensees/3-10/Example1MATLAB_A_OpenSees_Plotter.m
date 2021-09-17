close all
clear all
%% 00 - Pre-Definitions
% Total Number of DoFs
  NSubelements=3;
  EachElementLenght=61.33;
  NIntegrationPointsInEachSubelement=10;
% Incremental Moment Value
  ForceControlMomentIncrementsValue=21000;
% Draw Moment-Rotation Plot or Curvatuers Plot
  MomentRotationPlot=0; RawCurvaturesPlot=0; SmoothenedCurvaturesPlot=0; AllPlots=1;
%% 01 - Calculations
SCAN='%f%f'; for i=1:NSubelements*NIntegrationPointsInEachSubelement-1; SCAN=[SCAN '%f%f'];   end
  NNp=NIntegrationPointsInEachSubelement;
  x=cos(pi*(0:(NNp-1))/(NNp-1))'; 
  P=zeros(NNp,NNp); 
  xold=2;
  while max(abs(x-xold))>eps; xold=x; P(:,1)=1; P(:,2)=x; 
        for k=2:(NNp-1)
            P(:,k+1)=((2*k-1)*x.*P(:,k)-(k-1)*P(:,k-1))/k; 
        end; x=xold-(x.*P(:,NNp)-P(:,(NNp-1)))./(NNp*P(:,NNp)); 
  end
  for i=1:NSubelements 
      for j=1:NIntegrationPointsInEachSubelement
          Stations((i-1)*NIntegrationPointsInEachSubelement+j)=((-0.5*(x(j)-1)*NSubelements*EachElementLenght)/NSubelements)+((i-1)*EachElementLenght); 
      end
  end
system('OpenSees.exe Example1OpenSees_A_3Subelements_4IntegrationPoints_ForceControlAnalysis_ForceBasedElement.tcl');
fid=fopen('OSFCNode1Rotation.txt','r');
a=textscan(fid,'%f','CollectOutput',1); FCDeformations=a{1}; clear a;
fclose(fid);
fid=fopen('OSFCElementsCurvatures.txt','r');
a=textscan(fid,SCAN,'CollectOutput',1); FCCurvatures=a{1}; clear a;
fclose(fid); clear fid;
delete('OSFCNode1Rotation.txt');
delete('OSFCElementsCurvatures.txt');
system('OpenSees.exe Example1OpenSees_B_3Subelements_4IntegrationPoints_ForceControlAnalysis_DisplacementBasedElement.tcl');
fid=fopen('OSDCNode1Rotation.txt','r');
a=textscan(fid,'%f','CollectOutput',1); DCDeformations=a{1}; clear a;
fclose(fid);
fid=fopen('OSDCElementsCurvatures.txt','r');
a=textscan(fid,SCAN,'CollectOutput',1); DCCurvatures=a{1}; clear a;
fclose(fid); clear fid;
delete('OSDCNode1Rotation.txt');
delete('OSDCElementsCurvatures.txt');
OpenSeesForceControlDisplacement=0;
OpenSeesForceControlForce=0;
for i=1:size(FCDeformations,1)
OpenSeesForceControlDisplacement(i+1)=FCDeformations(i);
OpenSeesForceControlForce(i+1)=(i)*ForceControlMomentIncrementsValue;
end
OpenSeesForceControlDisplacement=abs(OpenSeesForceControlDisplacement);
OpenSeesForceControlForce=abs(OpenSeesForceControlForce);
OpenSeesForceControlCurvatures=FCCurvatures(size(FCCurvatures,1),2:2:2*NSubelements*NIntegrationPointsInEachSubelement);
clear FCDeformations; clear FCCurvatures;
OpenSeesDisplacementControlDisplacement=0;
OpenSeesDisplacementControlForce=0;
for i=1:size(DCDeformations,1)
OpenSeesDisplacementControlDisplacement(i+1)=DCDeformations(i);
OpenSeesDisplacementControlForce(i+1)=(i)*ForceControlMomentIncrementsValue;
end
OpenSeesDisplacementControlDisplacement=abs(OpenSeesDisplacementControlDisplacement);
OpenSeesDisplacementControlForce=abs(OpenSeesDisplacementControlForce);
OpenSeesDisplacementControlCurvatures=DCCurvatures(size(DCCurvatures,1),2:2:2*NSubelements*NIntegrationPointsInEachSubelement);
clear DCDeformations; clear DCCurvatures;
SmoothenedStations=Stations;
SmoothenedOpenSeesForceControlCurvatures=OpenSeesForceControlCurvatures;
SmoothenedOpenSeesDisplacementControlCurvatures=OpenSeesDisplacementControlCurvatures;
   for i=NSubelements:-1:2 
       SmoothenedStations((i-1)*NIntegrationPointsInEachSubelement+1)=[];
       SmoothenedOpenSeesForceControlCurvatures((i-1)*NIntegrationPointsInEachSubelement+1)=[];
       SmoothenedOpenSeesDisplacementControlCurvatures((i-1)*NIntegrationPointsInEachSubelement+1)=[];
   end
   for i=1:floor((((NSubelements-1)*(NIntegrationPointsInEachSubelement-1))+NIntegrationPointsInEachSubelement)/2)
       SmoothenedOpenSeesForceControlCurvatures(1,i)=(-1)*SmoothenedOpenSeesForceControlCurvatures(1,(((NSubelements-1)*(NIntegrationPointsInEachSubelement-1))+NIntegrationPointsInEachSubelement)-(i-1));
       SmoothenedOpenSeesDisplacementControlCurvatures(1,i)=(-1)*SmoothenedOpenSeesDisplacementControlCurvatures(1,(((NSubelements-1)*(NIntegrationPointsInEachSubelement-1))+NIntegrationPointsInEachSubelement)-(i-1));
   end
if MomentRotationPlot==1
   figure('units','normalized','outerposition',[0 0 1 1]); 
   ylim([0, 1.1*max(max(OpenSeesDisplacementControlForce),max(OpenSeesForceControlForce))]); 
   xlim([0, 1.1*max(max(OpenSeesDisplacementControlDisplacement),max(OpenSeesForceControlDisplacement))]);
   grid on; grid minor; ax=gca; ax.GridLineStyle='--'; ax.GridAlpha=0.6; ax.GridColor=['k']; ax.FontSize=12; ax.LineWidth=0.8; ax.TickLength=[0.01 0.01];    
   Title=['Moment-Rotation Plot for DoF 3']; title(Title,'fontsize',15,'fontweight','bold'); hold on;
   xlabel('Rotation [rad]','fontsize',13,'fontweight','bold'); ylabel('Moment [lb]','fontsize',13,'fontweight','bold'); 
   P1=plot(OpenSeesForceControlDisplacement,OpenSeesForceControlForce,'b','LineWidth',3);
   P2=plot(OpenSeesDisplacementControlDisplacement,OpenSeesDisplacementControlForce,'r','LineWidth',3);
   leg=legend([P1, P2],{'Force-Control Solution >>>>>>>> Force-Based Element', 'Force-Control Solution >>>>>>>> Displacement-Based Element'},'Location','southeast','fontsize',15); 
   Plot_Name=['OpenSees Results - ' num2str(NSubelements) ' Sub-Elements - ' num2str(NIntegrationPointsInEachSubelement) ' Integration Points']; h1=suptitle(Plot_Name); set(h1,'FontSize',17,'FontWeight','bold'); hold off;
elseif RawCurvaturesPlot==1
   figure('units','normalized','outerposition',[0 0 1 1]); 
   ylim([1.1*min(min(OpenSeesDisplacementControlCurvatures),min(OpenSeesForceControlCurvatures)), 1.1*max(max(OpenSeesDisplacementControlCurvatures),max(OpenSeesForceControlCurvatures))]); 
   xlim([Stations(1), Stations(size(Stations,2))]);
   grid on; grid minor; ax=gca; ax.GridLineStyle='--'; ax.GridAlpha=0.6; ax.GridColor=['k']; ax.FontSize=12; ax.LineWidth=0.8; ax.TickLength=[0.01 0.01];    
   Title=['Raw Curvature Values Along the Member Axis']; title(Title,'fontsize',15,'fontweight','bold'); hold on;
   xlabel('Station [in]','fontsize',13,'fontweight','bold'); ylabel('Curvature [rad/in]','fontsize',13,'fontweight','bold'); 
   P1=plot(Stations,OpenSeesForceControlCurvatures,'-bo','LineWidth',3);
   P2=plot(Stations,OpenSeesDisplacementControlCurvatures,'-ro','LineWidth',3);
   leg=legend([P1, P2],{'Force-Based Approach', 'Displacement-Based Approach'},'Location','southeast','fontsize',15); 
   Plot_Name=['OpenSees Results - ' num2str(NSubelements) ' Sub-Elements - ' num2str(NIntegrationPointsInEachSubelement) ' Integration Points']; h1=suptitle(Plot_Name); set(h1,'FontSize',17,'FontWeight','bold'); hold off;  
elseif SmoothenedCurvaturesPlot==1
   figure('units','normalized','outerposition',[0 0 1 1]); 
   ylim([1.1*min(min(SmoothenedOpenSeesDisplacementControlCurvatures),min(SmoothenedOpenSeesForceControlCurvatures)), 1.1*max(max(SmoothenedOpenSeesDisplacementControlCurvatures),max(SmoothenedOpenSeesForceControlCurvatures))]); 
   xlim([SmoothenedStations(1), SmoothenedStations(size(SmoothenedStations,2))]);
   grid on; grid minor; ax=gca; ax.GridLineStyle='--'; ax.GridAlpha=0.6; ax.GridColor=['k']; ax.FontSize=12; ax.LineWidth=0.8; ax.TickLength=[0.01 0.01];    
   Title=['Smoothened Curvature Values Along the Member Axis']; title(Title,'fontsize',15,'fontweight','bold'); hold on;
   xlabel('Station [in]','fontsize',13,'fontweight','bold'); ylabel('Curvature [rad/in]','fontsize',13,'fontweight','bold'); 
   P1=plot(SmoothenedStations,SmoothenedOpenSeesForceControlCurvatures,'-bo','LineWidth',3);
   P2=plot(SmoothenedStations,SmoothenedOpenSeesDisplacementControlCurvatures,'-ro','LineWidth',3);
   leg=legend([P1, P2],{'Force-Based Approach', 'Displacement-Based Approach'},'Location','southeast','fontsize',15); 
   Plot_Name=['OpenSees Results - ' num2str(NSubelements) ' Sub-Elements - ' num2str(NIntegrationPointsInEachSubelement) ' Integration Points']; h1=suptitle(Plot_Name); set(h1,'FontSize',17,'FontWeight','bold'); hold off;  
elseif AllPlots==1
   figure('units','normalized','outerposition',[0 0 1 1]); 
   ylim([1.1*min(min(SmoothenedOpenSeesDisplacementControlCurvatures),min(SmoothenedOpenSeesForceControlCurvatures)), 1.1*max(max(SmoothenedOpenSeesDisplacementControlCurvatures),max(SmoothenedOpenSeesForceControlCurvatures))]); 
   xlim([SmoothenedStations(1), SmoothenedStations(size(SmoothenedStations,2))]);
   grid on; grid minor; ax=gca; ax.GridLineStyle='--'; ax.GridAlpha=0.6; ax.GridColor=['k']; ax.FontSize=12; ax.LineWidth=0.8; ax.TickLength=[0.01 0.01];    
   Title=['Smoothened Curvature Values Along the Member Axis']; title(Title,'fontsize',15,'fontweight','bold'); hold on;
   xlabel('Station [in]','fontsize',13,'fontweight','bold'); ylabel('Curvature [rad/in]','fontsize',13,'fontweight','bold'); 
   P1=plot(SmoothenedStations,SmoothenedOpenSeesForceControlCurvatures,'-bo','LineWidth',3);
   P2=plot(SmoothenedStations,SmoothenedOpenSeesDisplacementControlCurvatures,'-ro','LineWidth',3);
   leg=legend([P1, P2],{'Force-Based Approach', 'Displacement-Based Approach'},'Location','southeast','fontsize',15); 
   Plot_Name=['OpenSees Results - ' num2str(NSubelements) ' Sub-Elements - ' num2str(NIntegrationPointsInEachSubelement) ' Integration Points']; h1=suptitle(Plot_Name); set(h1,'FontSize',17,'FontWeight','bold'); hold off;  
   figure('units','normalized','outerposition',[0 0 1 1]); 
   ylim([1.1*min(min(OpenSeesDisplacementControlCurvatures),min(OpenSeesForceControlCurvatures)), 1.1*max(max(OpenSeesDisplacementControlCurvatures),max(OpenSeesForceControlCurvatures))]); 
   xlim([Stations(1), Stations(size(Stations,2))]);
   grid on; grid minor; ax=gca; ax.GridLineStyle='--'; ax.GridAlpha=0.6; ax.GridColor=['k']; ax.FontSize=12; ax.LineWidth=0.8; ax.TickLength=[0.01 0.01];    
   Title=['Raw Curvature Values Along the Member Axis']; title(Title,'fontsize',15,'fontweight','bold'); hold on;
   xlabel('Station [in]','fontsize',13,'fontweight','bold'); ylabel('Curvature [rad/in]','fontsize',13,'fontweight','bold'); 
   P1=plot(Stations,OpenSeesForceControlCurvatures,'-bo','LineWidth',3);
   P2=plot(Stations,OpenSeesDisplacementControlCurvatures,'-ro','LineWidth',3);
   leg=legend([P1, P2],{'Force-Based Approach', 'Displacement-Based Approach'},'Location','southeast','fontsize',15); 
   Plot_Name=['OpenSees Results - ' num2str(NSubelements) ' Sub-Elements - ' num2str(NIntegrationPointsInEachSubelement) ' Integration Points']; h1=suptitle(Plot_Name); set(h1,'FontSize',17,'FontWeight','bold'); hold off; 
   figure('units','normalized','outerposition',[0 0 1 1]); 
   ylim([0, 1.1*max(max(OpenSeesDisplacementControlForce),max(OpenSeesForceControlForce))]); 
   xlim([0, 1.1*max(max(OpenSeesDisplacementControlDisplacement),max(OpenSeesForceControlDisplacement))]);
   grid on; grid minor; ax=gca; ax.GridLineStyle='--'; ax.GridAlpha=0.6; ax.GridColor=['k']; ax.FontSize=12; ax.LineWidth=0.8; ax.TickLength=[0.01 0.01];    
   Title=['Moment-Rotation Plot for DoF 3']; title(Title,'fontsize',15,'fontweight','bold'); hold on;
   xlabel('Rotation [rad]','fontsize',13,'fontweight','bold'); ylabel('Moment [lb]','fontsize',13,'fontweight','bold'); 
   P1=plot(OpenSeesForceControlDisplacement,OpenSeesForceControlForce,'b','LineWidth',3);
   P2=plot(OpenSeesDisplacementControlDisplacement,OpenSeesDisplacementControlForce,'r','LineWidth',3);
   leg=legend([P1, P2],{'Force-Control Solution >>>>>>>> Force-Based Element', 'Force-Control Solution >>>>>>>> Displacement-Based Element'},'Location','southeast','fontsize',15); 
   Plot_Name=['OpenSees Results - ' num2str(NSubelements) ' Sub-Elements - ' num2str(NIntegrationPointsInEachSubelement) ' Integration Points']; h1=suptitle(Plot_Name); set(h1,'FontSize',17,'FontWeight','bold'); hold off;
end