function Elabora_immagini()
% ELABORA_IMMAGINI Carica immagini da una cartella, le elabora e salva i risultati

%% DEFINIZIONE DELLE CARTELLE
input_folder = './immagini_input';
output_folder = './immagini_output';

% Creazione della cartella output se non esiste
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% Legge tutte le immagini dalla cartella di input
file_ext = {'*.jpg', '*.png', '*.tif', '*.bmp'}; % Formati supportati
image_files = [];
for i = 1:length(file_ext)
    image_files = [image_files; dir(fullfile(input_folder, file_ext{i}))];
end

%% PARAMETRO DEL FILTRO GAUSSIANO
sigma_h = 2; % Modificare se necessario

%% PROCESSO DI ELABORAZIONE
if isempty(image_files)
    fprintf('Nessuna immagine trovata nella cartella %s\n', input_folder);
    return;
end

for i = 1:length(image_files)
    % Percorso completo dell'immagine
    input_path = fullfile(input_folder, image_files(i).name);
    
    % Richiama la funzione di filtraggio
    Filtro_immagine(input_path, output_folder, sigma_h);
end

fprintf('Tutte le immagini sono state elaborate e salvate in %s\n', output_folder);
end
