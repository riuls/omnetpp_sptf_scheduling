clear;
close all;

%%%%%%%%%%%%%%%%%%%% Variable to change %%%%%%%%%%%%%%%%%%%%%

% nome del file di input
name = 'log.txt';

% lunghezza della uniforme
L = 0.8;

% intervallo con cui dividere la lunghezza dei pacchetti
delta_length = 0.05;

% intervallo con cui dividere i tempi di coda
delta_time = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read input file
delimiterIn = '-';
headerlinesIn = 1;
A = importdata(name, delimiterIn, headerlinesIn);

% asse x contiene gli intervalli di lunghezza del pacchetto
X_length = L/delta_length;

% asse Y contiene intervallo dei tempi di attesa
max = max(A.data);
max_qlen = ceil(max(2));
Y_length = max_qlen/delta_time;

% matrice delle occorrenze
Occorrenze = zeros(Y_length, X_length);

% matrice della probabilità congiunta CPM
Congiunta = zeros(Y_length, X_length);

% matrice della probabilità condizionata
Condizionata = zeros(Y_length, X_length);

% P(A|B) = P(A∧B)/P(B)

% calclo di P(A∧B)

% init parametri per scandire gli intervalli
length_start = 0;
length_end = delta_length;
time_start = 0;
time_end = delta_time;

% ciclo la matrice delle occorrenze e in ogni cella metto quanti pacchetti
% conto con quella coppia (tempo coda, lunghezza)

%ciclo la lunghezza del pacchetto
for len = 1:X_length
    
    for time = 1:Y_length
        
        for k = 1:length(A.data)

            % se il qtime è compreso nell'intervallo... 
            % e se il qlen è compreso nell'intervallo
            if   (((A.data(k,3) >= length_start) && (A.data(k,3) < length_end)) &&...
                    ((A.data(k,2) >= time_start) && (A.data(k,2) < time_end)))

                % allora ho un'occorrenza
                Occorrenze(time,len) = Occorrenze(time,len) +1;                                   
            end

        end

        % increment time range by a delta 
        time_start = time_start + delta_time;
        time_end = time_end + delta_time;
        
    end

    % increment length range by a delta
    length_start = length_start + delta_length;
    length_end = length_end + delta_length;

    %reset time range 
    time_start = 0;
    time_end = delta_time;
    
end

% dalla matrice delle occorrenze ricavo la matrice delle probabilità
% congiunte dividendo ogni occorrenza per le occorrenze totali

% le occorrenze totali son nel vettre max
tot = max(1);

% divido la matrice delle occorrenze per il totale
for y = 1:Y_length
    for x = 1:X_length
        Congiunta(y,x) = Occorrenze(y,x)/tot;
    end
end

% P(B=b) is the probability of a packet having length b in delta_length
B = (L/delta_length)^(-1);

% ora calcoliamo P(A|B) utilizzando la formula P(A∧B)/P(B)

for y = 1:Y_length
    for x = 1:X_length
        Condizionata(y,x) = Congiunta(y,x)/B;
    end
end

writematrix(Condizionata, "condizionata.csv")

figure

imagesc(Condizionata)
colorbar;
xlabel("packet length");
ylabel("packet queue time");
title("P(A|B) = P(A∧B)/P(B)");



