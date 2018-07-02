%function [] = plan_areas()
clc; clear;

% Get raw cell data:
[~,~,D]=xlsread('asignaturas_ingmec.xlsx');
N = size(D,1);

M = containers.Map;
for i=2:N
    area = D{i,4};
    creditos = D{i,3};
    if (isnan(area)) 
        continue;
    end
    
    if (M.isKey(area))
        M(area) = M(area) + creditos;
    else
        M(area) = creditos;
    end
end

k=M.keys; v=M.values; 
CREDITOS_TABLA={ k{:};v{:}}';
CREDITOS_TABLA=sortrows(CREDITOS_TABLA,2);
crs = CREDITOS_TABLA(:,2);
SUM_CR=sum([crs{:}]);
for i=1:length(k)
    CREDITOS_TABLA{i,3} = 100 * CREDITOS_TABLA{i,2} / SUM_CR;
end

disp('    AREA                               CREDITOS    (%) TOTAL');
disp(CREDITOS_TABLA);


%end