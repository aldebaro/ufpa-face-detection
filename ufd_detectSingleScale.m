function [x,y] = ufd_detectSingleScale(x, y, scale, integralImages, w, h, haarCascade)
% This function detects objects using a fixed scale through a Haar cascade
% classifier. Returns coordinates [x,y] where objects were detected
% (Based on code by D. Kroon)

%Calculation the inverse area of the matrix
InverseArea = 1/(w*h);

%Calculated the average in relation sum of rectangles(utilizing integral image) matrix and matrix area
average = GetSumRect(IntegralImages.ii,x,y,w,h)*InverseArea;

%Calculation of variance in each sub-windows of the classifiers
Variance = GetSumRect(IntegralImages.ii2,x,y,w,h)*InverseArea - (average.^2);

%Using a Variance to calculate the standard deviation
Variance(Variance<1) = 1;
DeviationStandard = sqrt(Variance);

%Os "haarcarscade" contém uma série de arvores de classificadores que serão executados um a um. Caso a coordenada fornecida não passe do classificador, ela é eliminada. Caso ela seja aceita pelo classificador será passada para o próximo classificador.

%Laço que percorrerá cada tipo de classificador
for i_stage = 1:length(HaarCasade.stages) %i_stage receberá o indice de cada classe de classificador
    stage = HaarCasade.stages(i_stage); %stage recebe a classe de classificador referente ao indice i_stage
    Trees=stage.trees; %Acessa a árvore da classe de classificadores do elemento
    StageSum = zeros(size(x)); %Cria uma matriz de zeros com tamanho igual ao de x (size talvez devesse ser (x,y))

    %Laço que percorre a árvore de classificadores
    for i_tree=1:length(Trees) %i_tree receberá o índice de cada árvore acessada
        Tree = Trees(i_tree).value; %Tree recebe o valor da árvore especificada pelo i_tree
        % Executando o classificador
        TreeSum=TreeObjectDetection(zeros(size(x)),Tree,Scale,x,y,IntegralImages.ii,StandardDeviation,InverseArea); %TreeSum armazena da execução do classificador
        StageSum = StageSum + TreeSum; %Soma as duas matrizes
    end

    check=StageSum < stage.stage_threshold; %A variável Check vai indicar se StageSum é menor que o valor minimo determinado pelo classificador
    
    x=x(~check); %Remove as coordenadas cujo valores são menores que o valor minimo determinado pelo classificador

    if(isempty(x)) %Se nenhuma coordenada satisfez o valor minimo determinado pelo classificador então o laço é interrompido, pois nenhum resquicio de objeto foi detectado
    	i_stage = length(HaarCasade.stages)+1; %i_stage recebe um valor que encerra o laço
    end 

    y=y(~check);%Remove as coordenadas cujo valores são menores que o valor minimo determinado pelo classificador

    StandardDeviation=StandardDeviation(~check); %Remove os desvios padrões cuja os valores das coordenadas são menores que o valor minimo determinado pelo classificador
end
