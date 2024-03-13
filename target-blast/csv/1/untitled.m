% Suponha que 'posicoes' seja uma tabela com as posições do barco
% 'posicoes' é uma tabela que contém as colunas 'x' e 'y'
% Lendo os dados do arquivo CSV
posicoes = readtable('POSNE.csv');

% Figura existente
figure(100);

% Loop sobre as posições do barco para plotar a trajetória
for i = 1:height(posicoes)
    x = POSNE.XKF10PE; % Coordenada x do barco no momento i
    y = POSNE.XKF10PN; % Coordenada y do barco no momento i
    
    % Plota a posição do barco no momento i
    if i == 1
        plot(x, y, 'o', 'Color', 'blue', 'DisplayName', 'Start'); % Plota o ponto inicial
    else
        plot(x, y, 'o', 'Color', 'blue'); % Plota os pontos seguintes
    end
    
    hold on; % Mantém o gráfico atual
end

% Restante do seu código para plotar as outras partes da figura, como trajetórias de referência, etc.
