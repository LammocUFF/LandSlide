function Pontos=PontosCubo(Angx,Angy,Angz,LCubo)
Angy=deg2rad(-90);
MRotaX=[1,0,0,0;0,cos(Angx),-sin(Angx),0;0,sin(Angx),cos(Angx),0;0,0,0,1];
MRotaY=[cos(Angy),0,sin(Angy),0;0,1,0,0;-sin(Angy),0,cos(Angy),0;0,0,0,1]
MRotaZ=[cos(Angz),-sin(Angz),0,0;sin(Angz),cos(Angz),0,0;0,0,1,0;0,0,0,1]
MRota=MRotaX*MRotaZ*MRotaY;
MTranslado=[1,0,0,LCubo;0,1,0,LCubo;0,0,1,LCubo;0,0,0,1];
Ponto1=MRota*MTranslado;
MTranslado=[1,0,0,-LCubo;0,1,0,LCubo;0,0,1,LCubo;0,0,0,1];
Ponto2=MRota*MTranslado;
MTranslado=[1,0,0,-LCubo;0,1,0,-LCubo;0,0,1,LCubo;0,0,0,1];
Ponto3=MRota*MTranslado;
MTranslado=[1,0,0,LCubo;0,1,0,-LCubo;0,0,1,LCubo;0,0,0,1];
Ponto4=MRota*MTranslado;
MTranslado=[1,0,0,LCubo;0,1,0,LCubo;0,0,1,-LCubo;0,0,0,1];
Ponto5=MRota*MTranslado;
MTranslado=[1,0,0,-LCubo;0,1,0,LCubo;0,0,1,-LCubo;0,0,0,1];
Ponto6=MRota*MTranslado;
MTranslado=[1,0,0,-LCubo;0,1,0,-LCubo;0,0,1,-LCubo;0,0,0,1];
Ponto7=MRota*MTranslado;
MTranslado=[1,0,0,LCubo;0,1,0,-LCubo;0,0,1,-LCubo;0,0,0,1];
Ponto8=MRota*MTranslado;

Pontos=zeros(3,8);
Pontos(1:3,1)=Ponto1(1:3,4);
Pontos(1:3,2)=Ponto2(1:3,4);
Pontos(1:3,3)=Ponto3(1:3,4);
Pontos(1:3,4)=Ponto4(1:3,4);
Pontos(1:3,5)=Ponto5(1:3,4);
Pontos(1:3,6)=Ponto6(1:3,4);
Pontos(1:3,7)=Ponto7(1:3,4);
Pontos(1:3,8)=Ponto8(1:3,4);
  
end