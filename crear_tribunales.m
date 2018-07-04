clc; clear;

%% ------ PARAMETROS GLOBALES  ------
NOMBRE_GRADO='ingmec';
% El parametro `num_tribs_scale` modifica el número total de tribunales
% que se obtendrán:
num_tribs_scale = 0.4;
% ----------------------------------

%% Aleatorizar generador pseudorandom:
rng('shuffle');

%% Cargar lista de asignaturas del plan:
[~,~,datAsig]=xlsread(sprintf('asignaturas_%s.xlsx',NOMBRE_GRADO));
codigosAsign = [datAsig{2:end,1}];

% Quitar NaN (blancos en excel)
codigosAsign(isnan(codigosAsign))=[];

% Get raw cell data:
[~,~,D]=xlsread('Odocente1819.xlsx');
N = size(D,1);

% Numeros de columna:
colCodAsign = 7;
colCurso = 15;
colProfesor = 32;
colProfesorHoras = 33;

% Pesos de las asignaturas por curso: 1,2,3,4
pesoCurso = [0.25 0.75 1.0 1.0];


%% Crear map: profesor -> numero de horas
M = containers.Map;

% para cada fila del excel (menos la primera = header)
for i=2:N
    asign = D(i,colCodAsign);
    asign = asign{1}; % Extraer de cell
    
    % Es del plan que buscamos?
    if (isempty(find(codigosAsign==asign,1)))
        continue;
    end
    
    % Acumular horas profesor:
    prof = D{i,colProfesor};
    % vacio o "PROFESOR XXX PENDIENTE DE CONTRATAR"?
    if (isnan(prof)) 
        continue;
    end
    if (strncmpi(prof,'PROFESOR',8))
        continue;
    end
    
    curso = D(i,colCurso);
    curso = curso{1};
    w = pesoCurso(curso);
    
    horas = D{i,colProfesorHoras} * w;


    if (M.isKey(prof))
        M(prof) = M(prof) + horas;
    else
        M(prof) = horas;
    end
   
end % end for each row

%% Crear una tabla con los profesores y los creditos asignados 
% en total en el plan:
k=M.keys; v=M.values; 
HORAS_TABLA={ k{:};v{:}}';
HORAS_TABLA=sortrows(HORAS_TABLA,2);
horas = HORAS_TABLA(:,2);
horas=[horas{:}];

%disp('    PROFESOR                         HORAS');
%disp(HORAS_TABLA);

%% Hay una gran desigualdad en las horas de docencia de los profesores, 
% por lo que se usara una escala logaritmica al asignar: 
%  P(profesor_i_miembro) \propto log(horas_profesor_i)
horas_log = log(num_tribs_scale * horas);

% Numero de tribunales en que pertenece un profesor: 
num_tribs_profesor = ceil(horas_log);

% Mostrar:
sTableFormat = '%3i  %40s %9i   %10i\n';
sTableHdrFormat = '%3s %40s %9s   %10s\n';
fprintf(sTableHdrFormat, 'ID','PROFESOR', 'HORAS','NUM_TRIBUNALES');
fprintf('----------------------------------------------------------------------\n');
for i=1:length(horas),
    fprintf(sTableFormat,...
        i,HORAS_TABLA{i,1}, uint8(horas(i)), num_tribs_profesor(i) );
end
fprintf('\n');


%% Generar tribunales en si:
N = length(horas);

% Indices de profesor (su nombre esta en HORAS_TABLA(i,1)):

% Generar lista de IDs ponderados por su numero de tribunales:
IDs = [];
for i=1:N
    IDs=[IDs ones(1,num_tribs_profesor(i))*i];
end
nIDs = length(IDs);

%% Random permutation:
while (1)
    IDs=IDs(randperm(nIDs));
    
    % Asegurar que no se repite ningun profesor en cada tribunal, de 3
    % miembros (el suplente se calcula de otra forma, para no contabilizar
    % la participacion como suplente que en teoria no deberia llegar a 
    % concretarse salvo excepciones):
    valido=1;
    for i=1:3:(nIDs-3),
        sub_ids = IDs(i:(i+3-1));
        if (length(sub_ids) ~= length(unique(sub_ids)) )
            % Tenemos duplicados:
            valido=false;
            break;
        end
    end
    if (valido) 
        break;
    end
    % Sino, probar con otra permutacion aleatoria... 
    % Doy por hecho que no tendremos tantas repeticiones como para que 
    % esto se alargue demasiado ;-)
end

%% Imprimir tribunales:
% ----------------------------
sOutFile = sprintf('tribunales_%s.txt',NOMBRE_GRADO);
f=fopen(sOutFile,'wt');
for i=1:3:(nIDs-3),
    sub_ids = IDs(i:(i+3-1));
    id_tribunal = ((i-1)/3)+1;
    fprintf(f,'Tribunal %s_%02i:\n',upper(NOMBRE_GRADO),id_tribunal);
	fprintf(f,' Miembro1: %s\n', HORAS_TABLA{sub_ids(1),1});
	fprintf(f,' Miembro2: %s\n', HORAS_TABLA{sub_ids(2),1});
	fprintf(f,' Miembro3: %s\n', HORAS_TABLA{sub_ids(3),1});
    
    id_suplente = IDs( mod(i+round(nIDs/2),nIDs)+1 );
    while (1)
        if ( 4 == length(unique([sub_ids id_suplente])) )
            break; % OK.
        else
            % Probar con otro:
            id_suplente = id_suplente + 1;
        end
    end
	fprintf(f,' Suplente: %s\n', HORAS_TABLA{id_suplente,1});
    
    fprintf(f,'\n');
end
fclose(f);

fprintf('\nLista de tribunales exportada a: "%s"\n',sOutFile);

