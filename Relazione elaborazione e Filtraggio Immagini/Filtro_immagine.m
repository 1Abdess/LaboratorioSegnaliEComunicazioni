function Filtro_immagine(input_path, output_folder, sigma_h)
%% CONTROLLO DEGLI INPUT
if nargin < 3
    fprintf('Uso: Filtro_immagine(input_path, output_folder, sigma_h)\n');
    return;
end

% Lettura dell'immagine
x = imread(input_path); 

% Creazione cartella di output specifica per l'immagine
[~, img_name, ~] = fileparts(input_path);
img_output_folder = fullfile(output_folder, img_name);
if ~exist(img_output_folder, 'dir')
    mkdir(img_output_folder);
end

%% FILTRAGGIO PASSA-BASSO
h1 = fspecial('gaussian', 6 * sigma_h, sigma_h); 
y1 = imfilter(x, h1); 

% Salvataggio dell'immagine filtrata passa-basso
imwrite(y1, fullfile(img_output_folder, 'Filtro_PB.png'));

%% FILTRAGGIO PASSA-ALTO
z1 = x - y1; % Segnale originale - segnale passa-basso

% Salvataggio dell'immagine filtrata passa-alto
imwrite(z1, fullfile(img_output_folder, 'Filtro_PA.png'));

%% NEGATIVO ED ESTRAZIONE DI CONTORNO
ImmagineBianca = 255 * ones(size(x), 'uint8');
y2 = ImmagineBianca - 2 * z1; 

% Salvataggio dell'immagine negativa con estrazione di contorno
imwrite(y2, fullfile(img_output_folder, 'Negativo_Contorni.png'));

fprintf('Elaborazione completata: risultati salvati in %s\n', img_output_folder);
end
