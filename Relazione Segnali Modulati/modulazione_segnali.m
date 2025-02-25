%% IMPOSTAZIONE PARAMETRI INIZIALI
% Numero di punti con cui viene campionato il segnale per unità di tempo
Npunti = 1000; 
% Durata della finestra temporale per l'analisi della trasformata
Durata = 100;

% Creazione del vettore del tempo con passo di campionamento 1/Npunti
tempo = 0:(1/Npunti):Durata-1/Npunti;

%% DEFINIZIONE DEL SEGNALE MODULANTE
% Definiamo un segnale modulante che è composto da:
% - Un impulso rettangolare di durata 0.5
% - Un impulso triangolare invertito di durata 0.5 a partire da t = 0.5
x = 1*(sign(tempo) - sign(tempo - 0.5)) * 0.5 ...
    - (1 - abs((tempo - 0.75) / 0.25)) .* (sign(tempo - 0.5) - sign(tempo - 1)) * 0.5;

%% PARAMETRI DELLA MODULAZIONE
% Ampiezza della portante
V0 = 10;
% Frequenza normalizzata della portante
f0 = 30;
% Sensibilità alla modulazione per diversi tipi di modulazione
KA = 0.5; % Modulazione di ampiezza (AM)
KP = (2 * pi * 1.5); % Modulazione di fase (PM)
KF = 15; % Modulazione di frequenza (FM)

%% COSTRUZIONE DEI SEGNALI MODULATI
% Modulazione di ampiezza (AM): la portante è moltiplicata per (1 + KA*x)
sAM = V0 * (1 + KA * x) .* cos(2 * pi * f0 * tempo);
% Modulazione di fase (PM): la fase della portante è spostata proporzionalmente a x
tPM = 2 * pi * f0 * tempo + KP * x;
sPM = V0 * cos(tPM);
% Modulazione di frequenza (FM): l'angolo è integrato per simulare la variazione della frequenza
y = zeros(size(x));
for i = 2:length(x)
    y(i) = y(i-1) + x(i) * (1 / Npunti); % Calcolo dell'integrale numerico
end
sFM = V0 * cos(2 * pi * f0 * tempo + (2 * pi * KF) * y);

%% GRAFICI DEI SEGNALI NEL DOMINIO DEL TEMPO
% Segnale modulante
figure;
plot(tempo, x, 'b'); xlabel('Tempo (normalizzato)', 'FontSize', 12); ylabel('x(t)', 'FontSize', 12); grid on; axis([0 1 -1.5 1.5]);
% Segnale modulato in ampiezza (AM)
figure;
plot(tempo, sAM, 'r'); xlabel('Tempo (normalizzato)', 'FontSize', 12); ylabel('s_{AM}(t)', 'FontSize', 12); grid on; axis([0 1 -20 20]);
% Segnale modulato in fase (PM)
figure;
plot(tempo, sPM, 'g'); xlabel('Tempo (normalizzato)', 'FontSize', 12); ylabel('s_{PM}(t)', 'FontSize', 12); grid on; axis([0 1 -20 20]);
% Segnale modulato in frequenza (FM)
figure;
plot(tempo, sFM, 'k'); xlabel('Tempo (normalizzato)', 'FontSize', 12); ylabel('s_{FM}(t)', 'FontSize', 12); grid on; axis([0 1 -20 20]);

%% TRASFORMATA DI FOURIER DEL SEGNALE MODULANTE x(t)
lunghezzaFft = length(x);
X = fft(x, lunghezzaFft) * (1 / Npunti);
X = fftshift(X); % Riordina la trasformata per centrarla in f=0
frequenza = Npunti * linspace(-0.5, 0.5 - 1 / lunghezzaFft, lunghezzaFft);
figure;
plot(frequenza, abs(X), 'b'); xlabel('Frequenza (normalizzata)', 'FontSize', 12); ylabel('|X(f)|', 'FontSize', 12); grid on; axis([-10 10 0 1.2 * max(abs(X))]);

%% TRASFORMATA DI FOURIER DEI SEGNALI MODULATI
% Modulazione di ampiezza (AM)
lunghezzaFft = length(sAM);
S_AM = fft(sAM, lunghezzaFft) * (1 / Npunti);
S_AM = fftshift(S_AM);
figure;
plot(frequenza, abs(S_AM), 'r'); xlabel('Frequenza (normalizzata)', 'FontSize', 12); ylabel('|S_{AM}(f)|', 'FontSize', 12); grid on; axis([-50 50 0 5]);
% Modulazione di fase (PM)
lunghezzaFft = length(sPM);
S_PM = fft(sPM, lunghezzaFft) * (1 / Npunti);
S_PM = fftshift(S_PM);
figure;
plot(frequenza, abs(S_PM), 'g'); xlabel('Frequenza (normalizzata)', 'FontSize', 12); ylabel('|S_{PM}(f)|', 'FontSize', 12); grid on; axis([-60 60 0 5]);
% Modulazione di frequenza (FM)
lunghezzaFft = length(sFM);
S_FM = fft(sFM, lunghezzaFft) * (1 / Npunti);
S_FM = fftshift(S_FM);
figure;
plot(frequenza, abs(S_FM), 'k'); xlabel('Frequenza (normalizzata)', 'FontSize', 12); ylabel('|S_{FM}(f)|', 'FontSize', 12); grid on; axis([-60 60 0 5]);
