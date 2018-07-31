% UFBA - Universidade Federal da Bahia
% ENGC63 - Processamento Digital de Sinais 2018.2
% Prof: Antônio C. L. Fernandes Jr
% Alunos: Virginia Campos
%         Rafael Tischler
% Projeto 2 - Filtro Butterworth Transformação Bilinear

%#ok<*NOPTS>
close all
clearvars
clc

%Filtro Butterworth ordem 6, analógico, corte em 2pi/3 rad/s
%Retorna o numerador e denominador de H(s)
%Parâmetro 's', retorna analógico
[numAnalog, denAnalog] = butter(6, 2*pi/3, 's');

%Função de transferência em S, Filtro de tempo contínuo
fprintf('Função de transferência - Butterworth contínuo')
Hanalog = tf(numAnalog, denAnalog)

%Transformação Bilinear
%Converter o filtro Butterworth analógico
%em um filtro digital S -> Z
[numDirect, denDirect] = bilinear(numAnalog, denAnalog, 1);

%Função de transferência do filtro Butterworth digital, forma direta
fprintf('Função de transferência: Forma Direta')
HDirect = tf(numDirect, denDirect, 1, 'variable', 'z^-1')

%Análise do filtro digital
fvtool(numDirect, denDirect);
set(gcf, 'Name', 'Filtro digital - Forma direta');
title('Filtro digital - Forma direta');
ylim([-130, 10]);

%Forma em cascata
%Converte a função de transferencia na forma de zeros, polos e ganhos
%[z,p,k] = tf2zp(b,a)
[z, p, k] = tf2zp(numDirect,denDirect);
Hsos = zp2sos(z, p, k);

fprintf('Função de transferência: Forma em Cascata')
[numCascade, denCascade] = sos2tf(Hsos)

%Gráfico da forma em cascata
fvtool(Hsos);
set(gcf, 'Name', 'Análise na forma em cascata');
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
    set(gcf, 'Name', sprintf('Comparação dos filtros com %d casas decimais', casasdec));
    title(sprintf('Comparação dos filtros com %d casas decimais', casasdec))
    legend(compareRounded, 'Forma direta','Forma em cascata');
    ylim([-130, 10]);
    hold on    
end
hold off;

%Transformação em frequência na representação da forma direta : -z^-1
numDirectHP = numDirect;
denDirectHP = denDirect;
%Inverter o sinal dos coeficientes impares, os pares não altera
for i = 2:2:length(numDirect)
    numDirectHP(i) = -numDirect(i);
    denDirectHP(i) = -denDirect(i);
end

%Comparar o resultado
% compare = fvtool(numDirectHP,denDirectHP,numDirect,denDirect);
% set(gcf, 'Name', 'Comparação dos filtros após transformação em frequência -Z^-1');
% title('Comparação dos filtros após transformação em frequência -Z^-1')
% legend(compare, 'Butterworth -Z^-1 ','ButterWorth Z^-1');
% ylim([-130, 10]);

%Função de transferência do filtro passa-alta
fprintf('Função de transferência do filtro passa-alta: -Z^-1')
HPfilter = tf(numDirectHP, denDirectHP, 1, 'variable', 'z^-1')


%Transformação em frequência na representação da forma direta: z^2
numDirectBR = upsample(numDirect, 2);
denDirectBR = upsample(denDirect, 2);

%Função de transferência do filtro rejeita-faixa
fprintf('Função de transferência do filtro rejeita-faixa: Z^2')
BRfilter = tf (numDirectBR, denDirectBR, 1, 'variable', 'z^-1')

%Gráfico do filtro rejeita-faixa
% fvtool(numDirectBR,denDirectBR);
% set(gcf,'Name','Band Reject Filter - Transformação em frequência');
% title('Band Reject Filter - Transformação em frequência')
% ylim([-130, 10]);

compareTransf = fvtool(numDirectHP,denDirectHP,numDirect,denDirect,numDirectBR,denDirectBR);
set(gcf,'Name','Comparação dos filtros após transformação em frequência');
title(sprintf('Comparação dos filtros após transformação em frequência'))
legend(compareTransf, 'HP: -z^-1','LP: z^-1','BR: z^2');
ylim([-130, 10]);

