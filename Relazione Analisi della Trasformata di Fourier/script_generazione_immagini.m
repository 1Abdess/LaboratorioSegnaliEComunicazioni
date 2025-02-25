function genera_immagini()
    % Definizione dei parametri
    K_values = [5, 10, 20];  % Numero di armoniche da testare
    D_values = [0.2, 0.5, 0.8]; % Duty cycle da testare
    
    % Creazione cartelle di output
    base_dir = './immagini/';
    rett_dir = fullfile(base_dir, 'rettangolare');
    tri_dir = fullfile(base_dir, 'triangolare');
    
    if ~exist(rett_dir, 'dir')
        mkdir(rett_dir);
    end
    if ~exist(tri_dir, 'dir')
        mkdir(tri_dir);
    end
    
    % Generazione immagini per l'onda rettangolare
    for K = K_values
        for D = D_values
            subdir = fullfile(rett_dir, sprintf('K%d_D%.1f', K, D));
            if ~exist(subdir, 'dir')
                mkdir(subdir);
            end
            
            % Esegue la funzione che genera entrambe le figure
            rettangolare(K, D);
            
            % Trova le figure generate
            figs = findobj('Type', 'figure');
            
            if length(figs) >= 2
                saveas(figs(1), fullfile(subdir, 'segnale.png')); % Primo grafico
                saveas(figs(2), fullfile(subdir, 'spettro_ampiezza.png')); % Secondo grafico
            elseif length(figs) == 1
                saveas(figs(1), fullfile(subdir, 'segnale.png')); % Caso in cui ne venga generata solo una
            end
            
            % Chiude tutte le figure per evitare accumulo di memoria
            close all;
        end
    end
    
    % Generazione immagini per l'onda triangolare
    for K = K_values
        for D = D_values
            subdir = fullfile(tri_dir, sprintf('K%d_D%.1f', K, D));
            if ~exist(subdir, 'dir')
                mkdir(subdir);
            end
            
            % Esegue la funzione che genera entrambe le figure
            triangolare(K, D);
            
            % Trova le figure generate
            figs = findobj('Type', 'figure');
            
            if length(figs) >= 2
                saveas(figs(1), fullfile(subdir, 'segnale.png')); % Primo grafico
                saveas(figs(2), fullfile(subdir, 'spettro_ampiezza.png')); % Secondo grafico
            elseif length(figs) == 1
                saveas(figs(1), fullfile(subdir, 'segnale.png')); % Caso in cui ne venga generata solo una
            end
            
            % Chiude tutte le figure per evitare accumulo di memoria
            close all;
        end
    end
    
    fprintf('Immagini salvate in %s\n', base_dir);
end
