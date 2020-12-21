
TamL=4; %Define a largura das linhas utilizadas
TamF=16; %Define o tamanho das letras nas figuras

%% Acelerações lidas até 16/11, este trecho poderá ser modificado para que possamos ler diretamente do site, ou pelo menos
%% ler as acelerações diretemante de um arquvio de Excel, de qualquer forma uma vez pronto, o resto do arquivo poderá ser executado
%% As três primeiras acelerações são do dia 23 /10/19  (Dia da Instalação) As duas seguintes  são do dia 31/10/19, as  3 segintes são do dia 11/12/19
%% As duas últimas são do dia 06/01
AcelX=[-1.84,-1.83,-1.82,-1.82,-1.79,-2.53, -2.47, -2.45 ,-2.5, -2.48]
AcelY=[2.53,2.51,2.49,2.53,2.49, 2.28, 2.36, 2.33, 2.32,2.24]
AcelZ=[8.16,8.19,8.21,8.24,8.29, 7.83,7.96, 7.93,7.8,7.8]
Medida=1:length(AcelX)  %Calcula o número de medidas feitas pelos sensores

figure(1)  %Na primeira figura serão apresentadas as medições das acelerações em cada eixo
plot(Medida,AcelX,'*-','LineWidth',TamL,Medida,AcelY,'*-','LineWidth',TamL,Medida,AcelZ,'*-','LineWidth',TamL)
legend("AcelX","AcelY","AcelZ")
xlabel("Measurement day",'FontSize',TamF);
ylabel("Aceleration m/s^2",'FontSize',TamF)
grid on

%Na segunda figura serão apresentadas as informações da sumatorias das três componentes X, Y e Z
%O objetivo é verificar se a suma das acelerações da o valor da aceleração gravitacional.
%Neste caso os valores não estão proximos de g, assim que temos um desafio em definir o que esta acontecendo,
% A principal hipotese é a calibração do sensor.....
figure(2)
AcelTotal=sqrt(AcelX.^2+AcelY.^2+AcelZ.^2)  %Cria um vector com o resultado das sumas das componentes
plot(AcelTotal,'*-b','LineWidth',TamL)
xlabel("Measurement day",'FontSize',TamF)
ylabel("Aceleration m/s^2",'FontSize',TamF)
grid on

%%%%%%%%%%%%%%%%%%%%%%%%%
%% Inicio do calculo do giro dados pelos sensores
AnguloGiroX=rad2deg(atan2(AcelZ,AcelY));  %%Calcula o angulo de Giro em X
%vectorU=[AcelX, AcelY, AcelZ]
%vectorV=[AcelX, 0, AcelZ]
%AnguloGiroY=rad2deg(acos((dot(vectorU,vectorV))/(sqrt(sum(vectorU.^2))*sqrt(sum(vectorV.^2)))))
AnguloGiroY=rad2deg(atan2(AcelZ,AcelX));  %%Calcula o angulo de Giro em X

%% Verifica o angulo da instalação, para isso tomamos a media das duas primeiras medições.
AnguloXinstala=mean(AnguloGiroX(1:2))
AnguloYinstala=mean(AnguloGiroY(1:2))

AnguloX1Week=mean(AnguloGiroX(3:5))  %Assume 3 leituras feitas na primeira semana
AnguloY1Week=mean(AnguloGiroY(3:5))   %Assume 3 leituras feitas na primeira semana

AnguloX1Month=mean(AnguloGiroX(6:8))  %Assume 3 leituras feitas no primeiro mes
AnguloY1Month=mean(AnguloGiroY(6:8))   %Assume 3 leituras feitas no primeiro mes

AnguloX2Month=mean(AnguloGiroX(9:10))  %Assume 3 leituras feitas no segundo mes
AnguloY2Month=mean(AnguloGiroY(9:10))   %Assume 3 leituras feitas no segundo mes
%% Calculo do deslocamento em centimetros utilizando matrizes homogeneas

LCubo=30;  #Assumindo que a pilola é um "cubo" de 5 cm de lateral
Angx=deg2rad(AnguloXinstala);
Angy=deg2rad(AnguloYinstala);
Angz=deg2rad(CalcAngleZ(mean(AcelX(1:2)),mean(AcelY(1:2)),mean(AcelZ(1:2))));


Resultado1=RotaCubo(Angx,Angy,Angz,LCubo);  %Chama a 
Pontoso=PontosCubo(Angx,Angy,Angz,LCubo); %Calcula os pontos de um hipotetico cubo na posição original de instalação

Angx=deg2rad(AnguloX1Week);
Angy=deg2rad(AnguloY1Week);
Angz=deg2rad(CalcAngleZ(mean(AcelX(3:5)),mean(AcelY(3:5)),mean(AcelZ(3:5))));

Resultado2=RotaCubo(Angx,Angy,Angz,LCubo);  %Chama a função para o calculo da rotação da extremidade do cubo
Pontos2=PontosCubo(Angx,Angy,Angz,LCubo);

Angx=deg2rad(AnguloX1Month);
Angy=deg2rad(AnguloY1Month);
Angz=deg2rad(CalcAngleZ(mean(AcelX(6:8)),mean(AcelY(6:8)),mean(AcelZ(6:8))));

Resultado3=RotaCubo(Angx,Angy,Angz,LCubo);  %Chama a função para o calculo da rotação da extremidade do cubo
Pontos3=PontosCubo(Angx,Angy,Angz,LCubo);

Angx=deg2rad(AnguloX2Month);
Angy=deg2rad(AnguloY2Month);
Angz=deg2rad(CalcAngleZ(mean(AcelX(9:10)),mean(AcelY(9:10)),mean(AcelZ(9:10))));

Resultado4=RotaCubo(Angx,Angy,Angz,LCubo);  %Chama a função para o calculo da rotação da extremidade do cubo
Pontos4=PontosCubo(Angx,Angy,Angz,LCubo);

ResultadoF=Resultado4;

%Desenha uma linha entre a localização oritinal do vertize (asterisco vermelho) o o ponto final do deslocamento
figure(3)
hold off
plot3([Resultado1(1,4)],[Resultado1(2,4)],[Resultado1(3,4)],'*r')  %%O ponto vermelho indica a localização inical
hold on
plot3([Resultado1(1,4),ResultadoF(1,4)],[Resultado1(2,4),ResultadoF(2,4)],[Resultado1(3,4),ResultadoF(3,4)],'--k')
grid on

Deslocamento=Resultado1(1:3,4)-ResultadoF(1:3,4)
disp("Deslocamento em cm")
Distancia=sqrt(sum(Deslocamento.^2))  %% Calcula a distancia deslocada do vertice do cubo hipotetico, as unidades desta variavel são as mesmas de LCubo


%% Desenha o 
PontosF=PontosCubo(Angx,Angy,Angz,LCubo)
%Pontos=PontosCubo(0,0,0,LCubo)
%%figure (5)
%%hold off
Pontos=PontosF;
TamL=2;
%Desenha o cubo na posição final
face=[5,6,7,8,5];
plot3([Pontos(1,face),Pontos(1,face(1))],[Pontos(2,face),Pontos(2,face(1))],[Pontos(3,face),Pontos(3,face(1))],'-b','LineWidth',TamL)
hold on 
face=[1,2,6,5,1];
plot3([Pontos(1,face),Pontos(1,face(1))],[Pontos(2,face),Pontos(2,face(1))],[Pontos(3,face),Pontos(3,face(1))],'-b','LineWidth',TamL)
face=[3,4,8,7,3];
plot3([Pontos(1,face),Pontos(1,face(1))],[Pontos(2,face),Pontos(2,face(1))],[Pontos(3,face),Pontos(3,face(1))],'-b','LineWidth',TamL)
face=[1,2,3,4,1];
plot3([Pontos(1,face),Pontos(1,face(1))],[Pontos(2,face),Pontos(2,face(1))],[Pontos(3,face),Pontos(3,face(1))],'-b','LineWidth',TamL)

%% Desenha o cubo original
Pontos=Pontoso;
face=[5,6,7,8,5];
plot3([Pontos(1,face),Pontos(1,face(1))],[Pontos(2,face),Pontos(2,face(1))],[Pontos(3,face),Pontos(3,face(1))],'--k','LineWidth',TamL)
hold on
face=[1,2,6,5,1];
plot3([Pontos(1,face),Pontos(1,face(1))],[Pontos(2,face),Pontos(2,face(1))],[Pontos(3,face),Pontos(3,face(1))],'--k','LineWidth',TamL)
face=[3,4,8,7,3];
plot3([Pontos(1,face),Pontos(1,face(1))],[Pontos(2,face),Pontos(2,face(1))],[Pontos(3,face),Pontos(3,face(1))],'--k','LineWidth',TamL)
face=[1,2,3,4,1];
plot3([Pontos(1,face),Pontos(1,face(1))],[Pontos(2,face),Pontos(2,face(1))],[Pontos(3,face),Pontos(3,face(1))],'--k','LineWidth',TamL)
axis equal
xlabel("X(cm)",'FontSize',TamF);
ylabel("Y(cm)",'FontSize',TamF)
zlabel("Z(cm)",'FontSize',TamF)
title("Hypothetical cube movement")
a=legend('Start Point','Start Position','Final Position')
set(a,"FontSize",TamF)


###  Medias de deslocamento MS508  Dados Crus de topografia e medição LAMMOC
DatasLeiturasH = ['30/10/2019';'04/11/2019';'13/11/2019';'28/11/2019';'16/12/2019';'06/01/2020']
formatIn = 'dd/mm/yyyy';
DataLeituraHaztec=datenum(DatasLeiturasH,formatIn)

DatasLeiturasLamm = ['23/10/2019';'23/10/2019';'23/10/2019';'30/10/2019';'30/10/2019';'11/12/2019';'11/12/2019';'11/12/2019';'06/01/2020';'06/01/2020']
DataLeituraLammoc=datenum(DatasLeiturasLamm,formatIn)


Vertical=[0,-0.015,-0.065,-0.114,-0.212,-0.245]
Horizontal=[0,0.010,0.0215,0.0385,0.0788,0.1059]

figure(5)
TamF=13
plot(DataLeituraHaztec,Vertical,'*-','LineWidth',TamL)
hold on
plot(DataLeituraHaztec,Horizontal,'-d','LineWidth',TamL)
hold off
xlabel("Dates",'FontSize',TamF);
ylabel("Displacement (m)",'FontSize',TamF)
title("Displacement Measurements",'FontSize',TamF);

datetick('x','mm/dd/yy')
a=legend({'H_{Vertical}','H_{Horizontal}'},'location','northwest')
set(a,"FontSize",TamF)
set(gca,'FontSize',TamF)
grid on

figure(6)

plot(DataLeituraLammoc,AcelX,'-v','LineWidth',TamL)
hold on
plot(DataLeituraLammoc,AcelY,'->','LineWidth',TamL)
plot(DataLeituraLammoc,AcelZ,'-^','LineWidth',TamL)

grid on
hold off
datetick('x','mm/dd/yy')
xlabel("Dates",'FontSize',TamF);
title("Aceleration measurements",'FontSize',TamF);
ylabel("Acel (m/s^2)",'FontSize',TamF)
a=legend('AcelX','AcelY','AcelZ',"location",'north')
set(a,"FontSize",TamF-1)
set(gca,'FontSize',TamF)

##  Interpolação de dados de leitura
NAcelX=[mean(AcelX(1:2)),mean(AcelX(2:5)),mean(AcelX(6:8)),mean(AcelX(9:10))]
NAcelY=[mean(AcelY(1:2)),mean(AcelY(2:5)),mean(AcelY(6:8)),mean(AcelY(9:10))]
NAcelZ=[mean(AcelZ(1:2)),mean(AcelZ(2:5)),mean(AcelZ(6:8)),mean(AcelZ(9:10))]
NDatasLeiturasLamm = ['23/10/2019';'31/10/2019';'11/12/2019';'06/01/2020']
NDataLeituraLammoc=datenum(NDatasLeiturasLamm,formatIn)
Dinicial=737721;
Dfinal=737796;
Tempo=Dinicial:10:Dfinal;  %Cria um vector com 10 dias de interface

Int_AcelX = interp1(NDataLeituraLammoc,NAcelX,Tempo)
Int_AcelY = interp1(NDataLeituraLammoc,NAcelY,Tempo)
Int_AcelZ = interp1(NDataLeituraLammoc,NAcelZ,Tempo)

figure(7)
plot(Tempo,Int_AcelX,'-v','LineWidth',TamL)
hold on
plot(Tempo,Int_AcelY,'->','LineWidth',TamL)
plot(Tempo,Int_AcelZ,'-^','LineWidth',TamL)
hold off
grid on
datetick('x','mm/dd/yy')

xlabel("Dates",'FontSize',TamF);
ylabel("Acceleration (m/s^2)",'FontSize',TamF)
title("Interpolated Acceleration")
a=legend('AcelX','AcelY','AcelZ')
set(a,"FontSize",TamF)
set(gca,'FontSize',TamF)

## Normalizar Dados
pkg load ltfat  #Carrega programa para normalizar dados
NormAcelX=normalize(Int_AcelX);
NormAcelY=normalize(Int_AcelY);
NormAcelZ=normalize(Int_AcelZ);
IntHori=interp1(DataLeituraHaztec,Horizontal,Tempo,'extrap');
IntVert=interp1(DataLeituraHaztec,Vertical,Tempo,'extrap');
NormHori = normalize(IntHori);
NormVert = normalize(IntVert);

figure (71)
TamF=13
plot(Tempo,IntVert,'*-','LineWidth',TamL)
hold on
plot(Tempo,IntHori,'-d','LineWidth',TamL)
hold off
title("Frame dislocation",'FontSize',TamF);
xlabel("Dates",'FontSize',TamF);
ylabel("Deslocation (m)",'FontSize',TamF)

datetick('x','mm/dd/yy')
a=legend({'H_{Vertical}','H_{Horizontal}'},'location','northwest')
set(a,"FontSize",TamF)
set(gca,'FontSize',TamF)
grid on


figure(8)
plot(Tempo,NormVert,'*-','LineWidth',TamL)
hold on
plot(Tempo,NormHori,'d-','LineWidth',TamL)

plot(Tempo,NormAcelX,'-v','LineWidth',TamL)

plot(Tempo,NormAcelY,'->','LineWidth',TamL)
plot(Tempo,NormAcelZ,'-^','LineWidth',TamL)
hold off
grid on
datetick('x','mm/dd/yy')
xlabel("Datas",'FontSize',TamF);
ylabel("Aceleração (m/s^2)",'FontSize',TamF)

a=legend('Haztec_{Vertical}','Haztec_{Horizontal}','AcelX','AcelY','AcelZ')
set(a,"FontSize",TamF)
set(gca,'FontSize',TamF)


## Normalizar Dados (Escalados)

EscAcelX=(Int_AcelX-min(Int_AcelX))/(max(Int_AcelX)-min(Int_AcelX));
EscAcelY=(Int_AcelY-min(Int_AcelY))/(max(Int_AcelY)-min(Int_AcelY));
EscAcelZ=(Int_AcelZ-min(Int_AcelZ))/(max(Int_AcelZ)-min(Int_AcelZ));

EscVert = (IntVert-min(IntVert))/(max(IntVert)-min(IntVert));
EscHori = (IntHori-min(IntHori))/(max(IntHori)-min(IntHori));




figure(9)
plot(Tempo,EscVert ,'*-','LineWidth',TamL)
hold on
plot(Tempo,EscHori ,'d-','LineWidth',TamL)

plot(Tempo,EscAcelX,'-v','LineWidth',TamL)

plot(Tempo,EscAcelY,'->','LineWidth',TamL)
plot(Tempo,EscAcelZ,'-^','LineWidth',TamL)
hold off
grid on
datetick('x','mm/dd/yy')
xlabel("Dates",'FontSize',TamF);
ylabel("Scaled data",'FontSize',TamF)
a=legend('H_{Vertical}','H_{Horizontal}','AcelX','AcelY','AcelZ')
title("Scaled Dislocation vs Scaled aceleration")
set(a,"FontSize",TamF)
set(gca,'FontSize',TamF)

## Definição dos coeficientes de correlação
CorrelaVert=[corr(EscVert,EscAcelX),corr(EscVert,EscAcelY),corr(EscVert,EscAcelZ)]
CorrelaHori=[corr(EscHori,EscAcelX),corr(EscHori,EscAcelY),corr(EscHori,EscAcelZ)]


## Dados de deslocamento de ponto hipotetico (Logo depois de observar os movimentos dos vertices
figure(11)
ColunaPonto=8;
DeslocaX=[Pontoso(1,ColunaPonto),Pontos2(1,ColunaPonto),Pontos3(1,ColunaPonto),PontosF(1,ColunaPonto)];
DeslocaY=[Pontoso(2,ColunaPonto),Pontos2(2,ColunaPonto),Pontos3(2,ColunaPonto),PontosF(2,ColunaPonto)];
DeslocaZ=[Pontoso(3,ColunaPonto),Pontos2(3,ColunaPonto),Pontos3(3,ColunaPonto),PontosF(3,ColunaPonto)];


Int_DeslocaX = interp1(NDataLeituraLammoc,DeslocaX,Tempo)
Int_DeslocaZ = interp1(NDataLeituraLammoc,DeslocaZ,Tempo)

plot(Tempo,[Int_DeslocaX;Int_DeslocaZ],'*-','LineWidth',TamL)
datetick('x','mm/dd/yy')
xlabel("Datas",'FontSize',TamF);
ylabel("Medições Deslocamento (cm)",'FontSize',TamF)
a=legend('X','Z');
set(a,"FontSize",TamF);
set(gca,'FontSize',TamF)
grid on

figure(12)

EscDeslocaX=(Int_DeslocaX-min(Int_DeslocaX))/(max(Int_DeslocaX)-min(Int_DeslocaX));
EscDeslocaZ=(Int_DeslocaZ-min(Int_DeslocaZ))/(max(Int_DeslocaZ)-min(Int_DeslocaZ));

plot(Tempo,EscVert ,'s-','LineWidth',TamL)
hold on
plot(Tempo,EscHori ,'+-','LineWidth',TamL)

plot(Tempo,EscDeslocaX,'-v','LineWidth',TamL)
plot(Tempo,EscDeslocaZ,'-^','LineWidth',TamL)
hold off
grid on
datetick('x','mm/dd/yy')
xlabel("Dates",'FontSize',TamF);
ylabel("Scaled data",'FontSize',TamF);
title("Scaled data Vertize dislocations vs Measurements");

a=legend('H_{Vertical}','H_{Horizontal}','VdX','VdY','location',"east")
set(a,"FontSize",TamF)
set(gca,'FontSize',TamF)

CorrelaVert=[corr(EscVert,EscDeslocaX),corr(EscVert,EscDeslocaZ)]
CorrelaHori=[corr(EscHori,EscDeslocaX),corr(EscHori,EscDeslocaZ)]
