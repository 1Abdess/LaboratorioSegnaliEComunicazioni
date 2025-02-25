% un esempio che si può usare per provare il codice è:
% Convoluzione_e_spettri(1, -2, 2, -2, 2, 1000)


function Convoluzione_e_spettri(T, tMinX, tMaxX, tMinY, tMaxY, numeroCampioni)

%% CONTROLLO DEL NUMERO DI ARGOMENTI
% Se il numero di input è inferiore a 6, mostra un messaggio di errore e termina l'esecuzione
if nargin < 6 
    fprintf('Sintassi: Convoluzione_e_spettri(T, tMinX, tMaxX, tMinY, tMaxY, numeroCampioni in T)\n');
    return;
end

%% IMPOSTAZIONE DEI PARAMETRI DI CAMPIONAMENTO
% Definizione del passo di campionamento basato sul numero di campioni in un periodo T
deltaT = T / numeroCampioni;

%% DEFINIZIONE DELL'IMPULSO RETTANGOLARE
% Creazione del vettore dei tempi per il segnale rettangolare
tX = tMinX:deltaT:tMaxX;
% Generazione dell'impulso rettangolare di durata T
X = 0.5 * (sign(tX) - sign(tX - T));

%% DEFINIZIONE DELL'ESPONENZIALE MONOLATERO
% Creazione del vettore dei tempi per il segnale esponenziale
tY = tMinY:deltaT:tMaxY;
% Generazione del segnale esponenziale monolatero
Y = exp(-tY / T) .* (0.5 * (1 + sign(tY))); 

%% DEFINIZIONE DEL VETTORE TEMPO PER LA CONVOLUZIONE
% Il tempo risultante dalla convoluzione è la somma degli intervalli dei segnali
tConvoluzione = tMinX + tMinY:deltaT:tMaxX + tMaxY;

%% CALCOLO DELLA CONVOLUZIONE APPROSSIMATA
% Uso della funzione conv() con il passo di campionamento per approssimare la convoluzione
Z = deltaT * conv(X, Y);

%% CALCOLO DELLA CONVOLUZIONE TEORICA
% Creazione del vettore della convoluzione teorica inizialmente nullo
zTeorica = zeros(size(tConvoluzione));
% Definizione delle regioni per la convoluzione teorica
intervallo = (tConvoluzione >= 0 & tConvoluzione <= T);
% Calcolo della risposta per 0 ≤ t ≤ T
zTeorica(intervallo) = T * (1 - exp(-tConvoluzione(intervallo) / T));
% Calcolo della risposta per t > T
intervallo = (tConvoluzione > T);
zTeorica(intervallo) = T * exp(-tConvoluzione(intervallo) / T) * (exp(1) - 1);

%% CALCOLO DELL'ENERGIA DEI SEGNALI
% Energia dell'impulso rettangolare troncato
energiaXtroncato = min(T, tMaxX) - max(0, tMinX);
% Percentuale dell'energia rispetto al totale
percentualeEnergiaX = 100.0 * energiaXtroncato / T;
% Energia dell'esponenziale monolatero troncato
energiaYtroncato = T / 2 * (exp(-2 * max(0, tMinY) / T) - exp(-2 * max(0, tMaxY) / T));
% Percentuale dell'energia rispetto al totale
percentualeEnergiaY = 100.0 * energiaYtroncato / (T / 2);

%% GRAFICO DELLA CONVOLUZIONE
figure;
% Disegna la convoluzione teorica in blu tratteggiato
plot(tConvoluzione, zTeorica, 'b--', 'LineWidth', 2);
hold on;
% Disegna la convoluzione approssimata in rosso
plot(tConvoluzione, Z, 'r', 'LineWidth', 2);
grid on;
xlabel('Tempo (s)', 'FontSize', 12);
ylabel('z(t) = rect(t/T) \otimes exp(-t/T)\cdotu(t)', 'FontSize', 12);
legend('Teorica', 'Approssimata', 'FontSize', 11);
title(sprintf('Convoluzione \n(T = %.1f s, E_{X} = %.2f%%, E_{Y} = %.2f%%)', T, percentualeEnergiaX, percentualeEnergiaY), 'FontSize', 14);

%% CALCOLO DELLA FFT APPROSSIMATA
% Se la lunghezza di Z è dispari, aggiunge uno zero per renderlo pari
if mod(length(Z), 2) ~= 0 
    Z = [Z 0];
end
% Calcolo della FFT del segnale convoluto
TZ = deltaT * fft(Z);
% Riordinamento per mettere la parte positiva e negativa della FFT nella posizione corretta
TZ = [TZ(length(TZ)/2+1:end), TZ(1:length(TZ)/2)];
% Creazione del vettore delle frequenze
frequenza = linspace(-1/(2*deltaT), 1/(2*deltaT), length(TZ));

%% CALCOLO DELLA FFT TEORICA
% Normalizzazione della frequenza rispetto a T
frequenzaNormalizzata = frequenza * T;
% Calcolo della trasformata teorica dell'impulso rettangolare
TZteorica_rect = sinc(frequenzaNormalizzata);
% Formula teorica per la trasformata della convoluzione
TZteorica = TZteorica_rect * T^2 ./ (1 + 1j * 2 * pi * frequenzaNormalizzata);

%% GRAFICO DELLO SPETTRO
maxfrequenza = 3.0 / T;
figure;
% Disegna lo spettro teorico in blu tratteggiato
plot(frequenza, abs(TZteorica), 'b--', 'LineWidth', 2);
hold on;
% Disegna lo spettro approssimato in rosso
plot(frequenza, abs(TZ), 'r', 'LineWidth', 2);
grid on;
axis([-maxfrequenza, maxfrequenza, 0, 1.2 * T * T]);
xlabel('Frequenza (Hz)', 'FontSize', 12);
ylabel('Z(f) = X(f) \cdot Y(f)', 'FontSize', 12);
legend('Teorica', 'Approssimata', 'FontSize', 11);
title(sprintf('Spettro della convoluzione \n(T = %.1f s, E_{X} = %.2f%%, E_{Y} = %.2f%%)', T, percentualeEnergiaX, percentualeEnergiaY), 'FontSize', 14);

end