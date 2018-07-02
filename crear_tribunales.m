%function [] = crear_tribnales()
clc; clear;

MAX_PROF = 5; % El excel tiene hasta 5 columnas de profesor por asignatura

% Get raw cell data:
[~,~,D]=xlsread('asignaturas_ingmec.xlsx');
N = size(D,1);

% Crear map: profesor -> creditos
M = containers.Map;

% para cada fila del excel (menos la primera = header)
for i=2:N
    creditos = D{i,3};

    % Puede haber hasta MAX_PROF profesores:
    NUM_PROFS = 0; % para esta asignatura concreta
    for ind_prof = 1:MAX_PROF
        prof = D{i,4+ind_prof};
        if (~isnan(prof))
            NUM_PROFS = NUM_PROFS + 1;
        end
    end
    
    % Acumular creditos a cada profesor:
    for ind_prof = 1:MAX_PROF
        prof = D{i,4+ind_prof};
        if (isnan(prof)) % vacio?
            continue;
        end
        
        cr = creditos / NUM_PROFS;
        
        if (M.isKey(prof))
            M(prof) = M(prof) + cr;
        else
            M(prof) = cr;
        end
                       
    end % end for each profesor
   
end % end for each row

% Crear una tabla con los profesores y los creditos asignados 
% en total en el plan:
k=M.keys; v=M.values; 
CREDITOS_TABLA={ k{:};v{:}}';
CREDITOS_TABLA=sortrows(CREDITOS_TABLA,2);
crs = CREDITOS_TABLA(:,2);

disp('    PROFESOR                         CREDITOS');
disp(CREDITOS_TABLA);

%end