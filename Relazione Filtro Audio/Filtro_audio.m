%% LETTURA CAMPIONI
% Nome del file audio da filtrare
filename='audio/Piano.wav'; 

% Frequenza di campionamento del file audio [Hz]
fCampionamento = 44.1e3; 

% Durata del segnale audio (definita per il troncamento) [s]
durata = 4; 

% Calcolo del tempo di campionamento
tempoCampionamento = 1/fCampionamento;

% Numero totale di campioni da leggere
numeroCampioni = durata * fCampionamento;

% Lettura del file audio, estraendo i primi 'numeroCampioni' campioni
[xstereo, fc] = audioread(filename, [1, numeroCampioni]);

% Selezione del canale sinistro del segnale stereo
x = (xstereo(:,1))'; 

%% FILTRO PASSABANDA IDEALE
% Larghezza di banda del filtro [Hz]
B = 3.0e3; 

% Frequenza centrale del filtro [Hz]
f0 = 3.0e3; 

% Durata della risposta impulsiva per limitare la sinc infinita [s]
T = 50 / B; 

% Creazione del vettore dei tempi per il filtro
tempoFiltro = 0:tempoCampionamento:T;

% Definizione della risposta impulsiva del filtro passa-banda
h = 2*B * sinc(B*(tempoFiltro - T/2)) ...
    .* rectpuls((tempoFiltro - T/2) / T) ...
    .* cos(2*pi*f0*(tempoFiltro - T/2));

% La funzione sinc è limitata nel tempo per rendere il filtro realizzabile
% La funzione cos() serve a traslare il filtro nella frequenza centrale f0

%% USCITA FILTRATA
% Convoluzione tra il segnale originale e la risposta impulsiva del filtro
w = conv(h, x) * tempoCampionamento;

% Rimozione della parte iniziale dovuta alla convoluzione
w = w(length(h):length(w)); 

% Creazione del vettore dei tempi per il segnale originale
tempo = 0:tempoCampionamento:durata-tempoCampionamento;

% Correzione del ritardo della convoluzione
tempoW = tempo(1:length(w)) + T/2;

%% GRAFICO DEL SEGNALE FILTRATO
% Definizione della durata del transitorio iniziale da escludere [s]
durataTransitorio = 0.0250; 

% Fattore di amplificazione per compensare la perdita di energia
A = 5; 

% Creazione della finestra della figura
figure;
set(gcf, 'defaultaxesfontname', 'Courier New')

% Disegno del segnale originale in ciano
plot((tempo - durataTransitorio) * 1e3, x, 'Color', 'cyan', 'LineWidth', 2.5);
hold on;

% Disegno del segnale filtrato amplificato in nero
plot((tempoW - durataTransitorio) * 1e3, A * w, 'Color', 'black', 'LineWidth', 1.5);

% Impostazioni del grafico
grid on;
xlabel('Tempo (ms)', 'FontSize', 12);
ylabel('Segnali temporali', 'FontSize', 12);
legend('x(t)', 'A\cdot{w(t)}', 'FontSize', 10);
axis([0 20 -1.2 * max(abs(x)) 1.2 * max(abs(x))]);

%% CALCOLO DELLA TRASFORMATA DI FOURIER DELL'INGRESSO
% Determinazione della lunghezza della FFT come la potenza di 2 più vicina
lunghezzaFft = 2^nextpow2(length(x));

% Calcolo della FFT del segnale di ingresso
X = fft(x, lunghezzaFft) * tempoCampionamento;

% Riordinamento dello spettro per centrarlo intorno a f=0
X = [X(lunghezzaFft/2+1:lunghezzaFft), X(1:lunghezzaFft/2+1)];

% Creazione del vettore delle frequenze per la rappresentazione spettrale
frequenza = fCampionamento * linspace(-0.5, 0.5, lunghezzaFft+1);

%% CALCOLO DELLA TRASFORMATA DI FOURIER DELL'USCITA
% FFT del segnale filtrato
W = fft(w, lunghezzaFft) * tempoCampionamento;

% Riordinamento dello spettro per centrarlo intorno a f=0
W = [W(lunghezzaFft/2+1:lunghezzaFft), W(1:lunghezzaFft/2+1)];

%% GRAFICO DELLO SPETTRO DEL SEGNALE
% Creazione della finestra della figura
figure;
set(gcf, 'defaultaxesfontname', 'Courier New')

% Disegno dello spettro del segnale originale in ciano
plot(frequenza / 1e3, abs(X), 'Color', 'cyan', 'LineWidth', 1.5);
hold on;

% Disegno dello spettro del segnale filtrato in nero
plot(frequenza / 1e3, abs(W), 'Color', 'black', 'LineWidth', 1.5);

% Impostazioni del grafico
grid on;
xlabel('Frequenza (kHz)', 'FontSize', 12);
ylabel('Spettro di ampiezza', 'FontSize', 12);
legend('|X(f)|', '|W(f)|', 'FontSize', 10);
axis([0 8 0 1.2 * max(abs(W))]);

%% SALVATAGGIO DEL SEGNALE FILTRATO
% Normalizzazione del segnale filtrato per evitare clipping
wNorm = w * 0.99 / max(abs(w));

% Salvataggio dell'audio filtrato in un nuovo file
audiowrite('audio/Output_filtro.wav', [wNorm', wNorm'], fCampionamento);

% Viene utilizzato solo il canale sinistro e normalizzato in ampiezza a 0.99 per evitare distorsioni