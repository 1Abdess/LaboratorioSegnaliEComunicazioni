function triangolare(K, D)

%% CONTROLLO DEGLI INPUT
% Se il numero di input è inferiore a 2, mostra un messaggio di errore e termina l'esecuzione
if nargin < 2
    fprintf('Uso: triangolare(K,D), dove K è il numero di armoniche e D il duty cycle\n');
    return;
end

%% DEFINIZIONE DEI PARAMETRI DEL SEGNALE
% Duty cycle (rapporto tra semi-durata dell'impulso e periodo del segnale)
dutyCycle = max(0, min(D, 1)); % Assicura che D sia compreso tra 0 e 1
% Ampiezza del segnale triangolare
ampiezza = 1.0;

%% DEFINIZIONE DELL'ASSE TEMPORALE
N = 1000; % Numero di campioni per periodo
tempoMin = -1.0; % Limite inferiore della scala temporale
tempoMax = 1.0; % Limite superiore della scala temporale
% Creazione del vettore del tempo con campionamento uniforme
tempo = linspace(tempoMin, tempoMax, N * (tempoMax - tempoMin));

%% GENERAZIONE DEL SEGNALE IDEALE
% Il segnale ideale è un'onda triangolare perfetta
xIdeale = ampiezza * (1 - abs(tempo - round(tempo)) / dutyCycle) .* (abs(tempo - round(tempo)) <= dutyCycle);

%% CALCOLO DEI COEFFICIENTI DELLA SERIE DI FOURIER
% Componente continua (k = 0)
componenteContinua = ampiezza * dutyCycle;
% Vettore degli indici armonici k
k = (1:K);
% Coefficienti della serie di Fourier per le armoniche
coefficienti = (ampiezza / dutyCycle) * (sin(pi * k * dutyCycle).^2) ./ ((pi * k).^2 + eps);

%% RICOSTRUZIONE DEL SEGNALE APPROSSIMANTE
% Inizializzazione del segnale approssimante con la componente continua
xApprossimante = componenteContinua * ones(1, length(tempo));
% Somma delle armoniche per la ricostruzione
for indicek = 1:K
    coseno = cos(2 * pi * indicek * tempo);
    xApprossimante = xApprossimante + 2 * coefficienti(indicek) * coseno;
end

%% GRAFICO DEL SEGNALE IDEALE E DEL SEGNALE APPROSSIMANTE
figure;
plot(tempo, xIdeale, 'k', 'LineWidth', 1.5);
hold on;
plot(tempo, xApprossimante, 'r', 'LineWidth', 2.5);
grid on;
axis([tempoMin, tempoMax, -0.5, 1.5]);
xlabel('Tempo normalizzato, t/T_0', 'FontSize', 12);
legend('x(t) (ideale)', sprintf('x_K(t) (K=%d)', K), 'FontSize', 11);
title(sprintf('Sintesi onda triangolare\ncon K=%d armoniche', K), 'FontSize', 14);

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
