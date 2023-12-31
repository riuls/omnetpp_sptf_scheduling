
clear;
close all;

%%%%%%%%%%%%%%%%%%%% Variable to change %%%%%%%%%%%%%%%%%%%%%

% nome del file di input
name = 'log.txt';

% ampiezza dell'intervallo della distribuzione uniforme
L = 0.8;

% precisione con cui dividere l'intervallo della uniforme
delta = 0.05;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read input file
delimiterIn = '-';
headerlinesIn = 1;
A = importdata(name, delimiterIn, headerlinesIn);

% parametri usati per scandire gli intervalli
from = 0;
to = delta;

% inizializzazione matrice dei risultati
result_size = L/delta;
R = [result_size,5];
for i = 1:result_size
    R(i,1) = from;  % pacchetti con lunghezza compresa da
    R(i,2) = to;    % fino a 
    R(i,3) = 0;     % somma dei tempi di attesa in coda
    R(i,4) = 0;     % numero di pacchetti contati in questo intervallo
    R(i,5) = 0;     % rapporto somma tempo / numero pacchetti
    from = from + delta;
    to = to + delta;
end

% primo ciclo per riempire colonne 3 e 4

for i = 1:length(A.data)
    from = 0;
    to = delta;
    row = 1;
    while to <= L+1
        if ((A.data(i,3) > from) && (A.data(i,3) < to))

            % somma del tempo totale di coda
            R(row, 3) = R(row, 3) + A.data(i,2);

            %incremento delle occorrenze
            R(row, 4) = R(row, 4) + 1;

        end
        from = from + delta;
        to = to + delta;
        row = row +1;
    end
end

% secondo ciclo per calcolare il rapporto in colonna 5

for i = 1:result_size
    if R(i,3) ~= 0
        R(i,5) = R(i,3)/R(i,4);
    end
end

% stampa del grafico dei risultati

figure
hold on

y_axis = (R*[0,0,0,0,1]')';
x_axis = (R*[0,1,0,0,0]')';

bar(x_axis, y_axis)

title('Packet avg queue time based on packet length (service time)')
xlabel('Packet service time [s]')
ylabel('avg queue time [s]')

hold off
