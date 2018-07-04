%function [] = crear_tribnales()
clc; clear;

% Cargar lista de asignaturas del plan:
[~,~,datAsig]=xlsread('asignaturas_ingmec.xlsx');
codigosAsign = [datAsig{2:end,1}];

% Quitar NaN (blancos en excel)
codigosAsign(find(isnan(codigosAsign)))=[];

% Get raw cell data:
[~,~,D]=xlsread('Odocente1819.xlsx');
N = size(D,1);

% Numeros de columna:
colCodAsign = 7;
colProfesor = 32;
colProfesorHoras = 33;

% Crear map: profesor -> numero de horas
M = containers.Map;

% para cada fila del excel (menos la primera = header)
for i=2:N
    asign = D(i,colCodAsign);
    asign = asign{1}; % Extraer de cell
    
    % Es del plan que buscamos?
    if (isempty(find(codigosAsign==asign,1)))
        continue;
    end
    
    
    horas = D{i,colProfesorHoras};

    % Acumular horas profesor:
    prof = D{i,colProfesor};
    % vacio o "PROFESOR XXX PENDIENTE DE CONTRATAR"?
    if (isnan(prof)) 
        continue;
    end
    if (startsWith(prof,'PROFESOR'))
        continue;
    end

    if (M.isKey(prof))
        M(prof) = M(prof) + horas;
    else
        M(prof) = horas;
    end
   
end % end for each row

% Crear una tabla con los profesores y los creditos asignados 
% en total en el plan:
k=M.keys; v=M.values; 
HORAS_TABLA={ k{:};v{:}}';
HORAS_TABLA=sortrows(HORAS_TABLA,2);
crs = HORAS_TABLA(:,2);

disp('    PROFESOR                         HORAS');
disp(HORAS_TABLA);

%end