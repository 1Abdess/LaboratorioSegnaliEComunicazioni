%% LETTURA CAMPIONI
% Definizione del nome del file audio da leggere
filename = 'audio/Handel.wav'; % Nome del file audio

% Definizione della frequenza di campionamento
fCampionamento = 44.1e3; % Frequenza di campionamento [Hz]

% Calcolo del tempo tra due campioni successivi
tempoCampionamento = 1 / fCampionamento; % Tempo di campionamento

% Durata da escludere all'inizio per eliminare il transitorio iniziale
durataTransitorio = 0.1; % Durata del transitorio iniziale [s]

% Definizione della durata del segmento da analizzare
durata = 6.0; % Durata dell'estratto [s]

% Calcolo del numero di campioni da estrarre
numeroCampioni = durata * fCampionamento; % Numero di campioni da acquisire

% Calcolo dell'indice di inizio dei campioni (escludendo il transitorio)
inizioCampioni = durataTransitorio * fCampionamento;

% Lettura del file audio selezionando solo una porzione specifica
[xstereo, fc] = audioread(filename, [inizioCampioni+1, inizioCampioni+1+numeroCampioni]);

% Estrazione del canale sinistro del segnale stereo
x = (xstereo(:,1))'; % Selezione del canale sinistro

% Creazione del vettore dei tempi associato ai campioni estratti
tempo = (0:length(x)-1) * tempoCampionamento; % Vettore dei tempi corretto

%% FILTRO PASSA-BASSO APPROSSIMATO
% Definizione della banda del filtro passa-basso
B = 5000; % Banda del filtro [Hz]

% Calcolo del tempo di troncamento del filtro
T = 20 / B; % Tempo di troncamento [s]

% Creazione del vettore dei tempi per il filtro
tempoFiltro = 0:tempoCampionamento:T;

% Definizione della risposta impulsiva del filtro passa-basso
h = 2 * B * sinc(2 * B * (tempoFiltro - T/2)) .* rectpuls((tempoFiltro - T/2) / T);

%% FILTRAGGIO
% Convoluzione del segnale con il filtro per applicare il filtraggio
y = conv(x, h) * tempoCampionamento;

% Rimozione della parte iniziale del segnale filtrato dovuta alla convoluzione
y = y(length(h):length(y)); % Eliminazione del transitorio iniziale

% Correzione del ritardo temporale del segnale filtrato
tempoY = tempo(1:length(y)) + T/2; % Correzione del ritardo

%% GRAFICO SEGNALI FILTRATI
% Creazione di una nuova finestra per il grafico
figure;
set(gcf, 'defaultaxesfontname', 'Courier New')

% Plot del segnale originale in ciano
plot(tempo - durataTransitorio, x, 'Color', 'cyan', 'LineWidth', 1.5);
hold on;

% Plot del segnale filtrato in nero
plot(tempoY - durataTransitorio, y, 'Color', 'black', 'LineWidth', 1.5);
grid on;

% Etichette degli assi e legenda
xlabel('Tempo (s)', 'FontSize', 12);
ylabel('Segnali temporali', 'FontSize', 12);
legend('x(t)', 'y(t)', 'FontSize', 10);
axis([0 0.4 -0.8001 0.8001]);

%% BLOCCO NON LINEARE (CLIPPING)
% Definizione della soglia di saturazione
yM = 0.10; % Ampiezza di saturazione

% Creazione della copia del segnale filtrato
z = y;

% Applicazione del clipping per limitare l'ampiezza del segnale
z(y > yM) = yM; % Limitazione positiva
z(y < -yM) = -yM; % Limitazione negativa

%% GRAFICO SEGNALI DISTORTI
% Creazione di una nuova finestra per il grafico
figure;
set(gcf, 'defaultaxesfontname', 'Courier New')

% Plot del segnale filtrato in ciano
plot(tempoY - durataTransitorio, y, 'Color', 'cyan', 'LineWidth', 1.5);
hold on;

% Plot del segnale distorto in nero
plot(tempoY - durataTransitorio, z, 'Color', 'black', 'LineWidth', 1.5);
grid on;

% Etichette degli assi e legenda
xlabel('Tempo (s)', 'FontSize', 12);
ylabel('Segnali temporali', 'FontSize', 12);
legend('y(t)', 'z(t)', 'FontSize', 10);
axis([0 0.4 -0.8001 0.8001]);

%% TRASFORMATA DI FOURIER
% Calcolo della dimensione della FFT come la potenza di 2 più vicina
lunghezzaFft = 2^nextpow2(length(y));

% Calcolo della trasformata di Fourier del segnale filtrato
Y = fft(y, lunghezzaFft) * tempoCampionamento;
Y = [Y(lunghezzaFft/2+1:end), Y(1:lunghezzaFft/2)];

% Calcolo della trasformata di Fourier del segnale distorto
Z = fft(z, lunghezzaFft) * tempoCampionamento;
Z = [Z(lunghezzaFft/2+1:end), Z(1:lunghezzaFft/2)];

% Creazione del vettore delle frequenze
frequenza = fCampionamento * linspace(-0.5, 0.5, lunghezzaFft);

%% GRAFICO SPETTRO DI AMPIEZZA
% Creazione di una nuova finestra per il grafico
figure;
set(gcf, 'defaultaxesfontname', 'Courier New')

% Plot dello spettro di ampiezza del segnale filtrato
plot(frequenza(1:length(Y)) / 1e3, 20 * log10(abs(Y) ./ max(abs(Y))), 'Color', 'cyan', 'LineWidth', 1.5);
hold on;

% Plot dello spettro di ampiezza del segnale distorto
plot(frequenza(1:length(Z)) / 1e3, 20 * log10(abs(Z) ./ max(abs(Y))), 'Color', 'black', 'LineWidth', 1.5);
grid on;

% Etichette degli assi e legenda
xlabel('Frequenza (kHz)', 'FontSize', 12);
ylabel('Spettro di ampiezza (dB)', 'FontSize', 12);
legend('|Y(f)|', '|Z(f)|', 'FontSize', 10);
axis([0 8 -120 0]);

%% SALVATAGGIO AUDIO
% Salvataggio del segnale filtrato su file
audiowrite('audio/Output_filtro.wav', [y.', y.'], fCampionamento);

% Salvataggio del segnale distorto su file
audiowrite('audio/Output_dist.wav', [z.', z.'], fCampionamento);