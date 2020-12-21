function MRota=RotaCubo(Angx,Angy,Angz,LCubo)  %Função que utiliza matrix de rotação Homogenea para descubrir onde fica a ponta do cubo com o sensor
  
MTranslado=[1,0,0,LCubo;0,1,0,LCubo;0,0,1,LCubo;0,0,0,1];

MRotaX=[1,0,0,0;0,cos(Angx),-sin(Angx),0;0,sin(Angx),cos(Angx),0;0,0,0,1];

MRotaZ=[cos(Angz),-sin(Angz),0,0;sin(Angz),cos(Angz),0,0;0,0,1,0;0,0,0,1];
#MRota=MRotaX*MRotaY*MRotaZ*MTranslado
MRota=MRotaX*MRotaZ

Angy=deg2rad(-90);
MRotaY=[cos(Angy),0,sin(Angy),0;0,1,0,0;-sin(Angy),0,cos(Angy),0;0,0,0,1];
MRota=MRota*MRotaY*MTranslado
end
