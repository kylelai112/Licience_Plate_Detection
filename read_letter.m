function letter=read_letter(imagn)
%Computes the correlation between template and input image
%and its output is a string containing the letter.
%Size of 'imagn' must be 42 x 24 pixels
%Example:
% imagn=imread('D.bmp');
% letter=read_letter(imagn)
comp=[];
load templates
for n=1:34
    sem=corr2(templates{1,n},imagn);
    comp=[comp sem];
end
vd=find(comp==max(comp));
%*-*-*-*-*-*-*-*-*-*-*-*-*-
if vd==1
    letter='A';
elseif vd==2
    letter='B';
elseif vd==3
    letter='C';
elseif vd==4
    letter='D';
elseif vd==5
    letter='E';
elseif vd==6
    letter='F';
elseif vd==7
    letter='G';
elseif vd==8
    letter='H';
elseif vd==9
    letter='J';
elseif vd==10
    letter='K';
elseif vd==11
    letter='L';
elseif vd==12
    letter='M';
elseif vd==13
    letter='N';
elseif vd==14
    letter='P';
elseif vd==15
    letter='Q';
elseif vd==16
    letter='R';
elseif vd==17
    letter='S';
elseif vd==18
    letter='T';
elseif vd==19
    letter='U';
elseif vd==20
    letter='V';
elseif vd==21
    letter='W';
elseif vd==22
    letter='X';
elseif vd==23
    letter='Y';
elseif vd==24
    letter='Z';
    %*-*-*-*-*
elseif vd==25
    letter='1';
elseif vd==26
    letter='2';
elseif vd==27
    letter='3';
elseif vd==28
    letter='4';
elseif vd==29
    letter='5';
elseif vd==30
    letter='6';
elseif vd==31
    letter='7';
elseif vd==32
    letter='8';
elseif vd==33
    letter='9';
else
    letter='0';
end

