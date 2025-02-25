function rettangolare(K, D)

%% CONTROLLO DEGLI INPUT
% Se il numero di input è inferiore a 2, mostra un messaggio di errore e termina l'esecuzione
if nargin < 2
    fprintf('Uso: rettangolare(K,D), dove K è il numero di armoniche e D il duty cycle\n');
    return;
end

%% DEFINIZIONE DEI PARAMETRI DEL SEGNALE
% Duty cycle (rapporto tra durata dell'impulso e periodo del segnale)
dutyCycle = max(0, min(D, 1)); % Assicura che D sia compreso tra 0 e 1
% Ampiezza dell'onda rettangolare
ampiezza = 1.0;

%% DEFINIZIONE DELL'ASSE TEMPORALE
N = 1000; % Numero di campioni per periodo
tempoMin = -1.0; % Limite inferiore della scala temporale
tempoMax = 1.0; % Limite superiore della scala temporale
% Creazione del vettore del tempo con campionamento uniforme
tempo = linspace(tempoMin, tempoMax, N * (tempoMax - tempoMin));

%% GENERAZIONE DEL SEGNALE IDEALE
% Il segnale ideale è un'onda rettangolare perfetta
xIdeale = ampiezza * (abs(tempo - round(tempo)) <= dutyCycle / 2);

%% CALCOLO DEI COEFFICIENTI DELLA SERIE DI FOURIER
% Componente continua (k = 0)
componenteContinua = ampiezza * dutyCycle;
% Vettore degli indici armonici k
k = (1:K);
% Coefficienti della serie di Fourier per le armoniche
coefficienti = ampiezza * sin(pi * dutyCycle * k) ./ (pi * k + eps);

%% RICOSTRUZIONE DEL SEGNALE APPROSSIMANTE
% Matrice dei coseni per le armoniche
coseni = cos(2 * pi * k' * tempo);
% Segnale approssimante usando la serie di Fourier
xApprossimante = componenteContinua + 2 * coefficienti * coseni;

%% GRAFICO DEL SEGNALE IDEALE E DEL SEGNALE APPROSSIMANTE
figure;
plot(tempo, xIdeale, 'k', 'LineWidth', 1.5);
hold on;
plot(tempo, xApprossimante, 'r', 'LineWidth', 2.5);
grid on;
axis([tempoMin, tempoMax, -0.5, 1.5]);
xlabel('Tempo normalizzato, t/T_0', 'FontSize', 12);
legend('x(t) (ideale)', sprintf('x_K(t) (K=%d)', K), 'FontSize', 11);
title(sprintf('Sintesi del treno di impulsi rettangolari\ncon K=%d armoniche', K), 'FontSize', 14);

%% GRAFICO DELLO SPETTRO DI AMPIEZZA
% Calcolo del modulo dei coefficienti di Fourier
c = abs(coefficienti);
c(K+1) = componenteContinua; % Aggiunge la componente continua
k(K+1) = 0; % Inserisce il valore per k=0
figure;
plot(k, c, 'o', 'LineWidth', 2.5);
grid on;
xlabel('Indice armonico k', 'FontSize', 12);
ylabel('|X_k|', 'FontSize', 12);
title(sprintf('Spettro di ampiezza con K=%d armoniche', K), 'FontSize', 14);

end
