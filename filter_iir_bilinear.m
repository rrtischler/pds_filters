% UFBA - Universidade Federal da Bahia
% ENGC63 - Processamento Digital de Sinais 2018.2
% Prof: Ant�nio C. L. Fernandes Jr
% Alunos: Virginia Campos
%         Rafael Tischler
% Projeto 2 - Filtro Butterworth Transforma��o Bilinear

%#ok<*NOPTS>
close all
clearvars
clc

%Filtro Butterworth ordem 6, anal�gico, corte em 2pi/3 rad/s
%Retorna o numerador e denominador de H(s)
%Par�metro 's', retorna anal�gico
[numAnalog, denAnalog] = butter(6, 2*pi/3, 's');

%Fun��o de transfer�ncia em S, Filtro de tempo cont�nuo
fprintf('Fun��o de transfer�ncia - Butterworth cont�nuo')
Hanalog = tf(numAnalog, denAnalog)

%Transforma��o Bilinear
%Converter o filtro Butterworth anal�gico
%em um filtro digital S -> Z
[numDirect, denDirect] = bilinear(numAnalog, denAnalog, 1);

%Fun��o de transfer�ncia do filtro Butterworth digital, forma direta
fprintf('Fun��o de transfer�ncia: Forma Direta')
HDirect = tf(numDirect, denDirect, 1, 'variable', 'z^-1')

%An�lise do filtro digital
fvtool(numDirect, denDirect);
set(gcf, 'Name', 'Filtro digital - Forma direta');
title('Filtro digital - Forma direta');
ylim([-130, 10]);

%Forma em cascata
%Converte a fun��o de transferencia na forma de zeros, polos e ganhos
%[z,p,k] = tf2zp(b,a)
[z, p, k] = tf2zp(numDirect,denDirect);
Hsos = zp2sos(z, p, k);

fprintf('Fun��o de transfer�ncia: Forma em Cascata')
[numCascade, denCascade] = sos2tf(Hsos)

%Gr�fico da forma em cascata
fvtool(Hsos);
set(gcf, 'Name', 'An�lise na forma em cascata');
title('Filtro digital - Forma em Cascata');
ylim([-130, 10]);

%Compara a forma direta e a forma em cascata
compare = fvtool(numDirect, denDirect, Hsos);
set(gcf, 'Name', 'Forma direta x Forma em cascata');
title('Forma direta x Forma em cascata');
legend(compare, 'Forma Direta', 'Forma em Cascata')
ylim([-130, 10]);

%Arredondamentos
for casasdec = 4:-1:1
    %Forma direta
    numDirectRounded = round(numDirect, casasdec);
    denDirectRounded = round(denDirect, casasdec);
    fprintf('FT com %d casas decimais na forma direta', casasdec)
    HDirectRounded = tf(numDirectRounded, denDirectRounded, 1, 'variable', 'z^-1')
    
    %Forma em cascata
    HsosRounded = round(Hsos, casasdec);
    fprintf('FT com %d casas decimais na forma em cascata', casasdec)
    [numSosRounded, denSosRounded] = sos2tf(HsosRounded);
    FTsosRounded = tf(numSosRounded, denSosRounded, 1, 'variable', 'z^-1')
    
    %Comparativo das formas com x casas decimais
    compareRounded = fvtool(numDirectRounded,denDirectRounded,HsosRounded);
    set(gcf, 'Name', sprintf('Compara��o dos filtros com %d casas decimais', casasdec));
    title(sprintf('Compara��o dos filtros com %d casas decimais', casasdec))
    legend(compareRounded, 'Forma direta','Forma em cascata');
    ylim([-130, 10]);
    hold on    
end
hold off;

%Transforma��o em frequ�ncia na representa��o da forma direta : -z^-1
numDirectHP = numDirect;
denDirectHP = denDirect;
%Inverter o sinal dos coeficientes impares, os pares n�o altera
for i = 2:2:length(numDirect)
    numDirectHP(i) = -numDirect(i);
    denDirectHP(i) = -denDirect(i);
end

%Comparar o resultado
% compare = fvtool(numDirectHP,denDirectHP,numDirect,denDirect);
% set(gcf, 'Name', 'Compara��o dos filtros ap�s transforma��o em frequ�ncia -Z^-1');
% title('Compara��o dos filtros ap�s transforma��o em frequ�ncia -Z^-1')
% legend(compare, 'Butterworth -Z^-1 ','ButterWorth Z^-1');
% ylim([-130, 10]);

%Fun��o de transfer�ncia do filtro passa-alta
fprintf('Fun��o de transfer�ncia do filtro passa-alta: -Z^-1')
HPfilter = tf(numDirectHP, denDirectHP, 1, 'variable', 'z^-1')


%Transforma��o em frequ�ncia na representa��o da forma direta: z^2
numDirectBR = upsample(numDirect, 2);
denDirectBR = upsample(denDirect, 2);

%Fun��o de transfer�ncia do filtro rejeita-faixa
fprintf('Fun��o de transfer�ncia do filtro rejeita-faixa: Z^2')
BRfilter = tf (numDirectBR, denDirectBR, 1, 'variable', 'z^-1')

%Gr�fico do filtro rejeita-faixa
% fvtool(numDirectBR,denDirectBR);
% set(gcf,'Name','Band Reject Filter - Transforma��o em frequ�ncia');
% title('Band Reject Filter - Transforma��o em frequ�ncia')
% ylim([-130, 10]);

compareTransf = fvtool(numDirectHP,denDirectHP,numDirect,denDirect,numDirectBR,denDirectBR);
set(gcf,'Name','Compara��o dos filtros ap�s transforma��o em frequ�ncia');
title(sprintf('Compara��o dos filtros ap�s transforma��o em frequ�ncia'))
legend(compareTransf, 'HP: -z^-1','LP: z^-1','BR: z^2');
ylim([-130, 10]);

