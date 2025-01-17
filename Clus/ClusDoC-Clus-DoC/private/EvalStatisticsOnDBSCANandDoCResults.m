function EvalStatisticsOnDBSCANandDoCResults(ClusterSmoothTableCh, Ch, outputFolder, background_density)

    % Tabulate stats and output excel file for Clus-DoC analysis
    %% Pull NbThresh from handles
    handles = guidata(findobj('Tag', 'PALM GUI'));
    
    
    %% Density Comparison
    
    [row, column]=size(ClusterSmoothTableCh);
    
    MeanDensityDofC=cell(row, column);
    MeanAreaDofC=cell(row, column);
    MeanCircularityDofC=cell(row, column);
    
    MeanDensity2=cell(row, column);
    MeanArea2=cell(row, column);
    MeanCircularity2=cell(row, column);
    
    MeanDensity3=cell(row, column);
    MeanArea3=cell(row, column);
    MeanCircularity3=cell(row, column);
    
    MeanNumMolsPerColocCluster = cell(row, column);
    NumColocClustersPerROI = cell(row, column);
    MeanNumMolsPerNonColocCluster = cell(row, column);
    NumNonColocClustersPerROI = cell(row, column);
           
    %外层循环i j为遍历每个roi
    for i=1:column
        
        for j=1:row
            A=ClusterSmoothTableCh{j,i};
    
            if ~isempty(A)
               
               % 第一次filter
               % Population of cluster with Nb > NbThresh
               AA=cellfun(@(x) x(x.Nb > handles.DoC.NbThresh), A,'UniformOUtput',0);
               A=A(~cellfun('isempty', AA));
               
               % 第二次filter
               % Cluster with Nb(Dof>0.4) > NbThresh      
               Cluster_DofC=cellfun(@(x) x(x.Nb_In > handles.DoC.NbThresh), A,'UniformOUtput',0);
               Cluster_DofC=Cluster_DofC(~cellfun('isempty', Cluster_DofC));
               
               
               % Area and realtive density for Nb(Dof>0.4) >10
               DensityDofC=cellfun(@(x) x.AvRelativeDensity20, Cluster_DofC);
               AreaDofC=cellfun(@(x) x.Area, Cluster_DofC);
               CircularityDofC=cellfun(@(x) x.Circularity, Cluster_DofC);
               % 计算mean
               MeanDensityDofC{j,i}=mean(DensityDofC);
               MeanAreaDofC{j,i}=mean(AreaDofC);
               MeanCircularityDofC{j,i}=mean(CircularityDofC);
               
               NumMoleculesPerColocCluster = cellfun(@(x) x.Nb, Cluster_DofC);
               
               MeanNumMolsPerColocCluster{j,i} = mean(NumMoleculesPerColocCluster);
               NumColocClustersPerROI{j,i} = numel(NumMoleculesPerColocCluster);
               
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               
               % Cluster with Nb(Dof>0.4) < NbThresh
               Cluster_Other=cellfun(@(x) x(x.Nb_In <= handles.DoC.NbThresh), A,'UniformOUtput',0);
               Cluster_Other=Cluster_Other(~cellfun('isempty', Cluster_Other));
                          
               Density2=cellfun(@(x) x.AvRelativeDensity20, Cluster_Other);
               Area2=cellfun(@(x) x.Area, Cluster_Other);
               Circularity2=cellfun(@(x) x.Circularity, Cluster_Other);
               MeanDensity2{j,i}=mean(Density2);
               MeanArea2{j,i}=mean(Area2);
               MeanCircularity2{j,i}=mean(Circularity2);
               
               NumMoleculesPerNonColocCluster = cellfun(@(x) x.Nb, Cluster_Other);
               
               MeanNumMolsPerNonColocCluster{j,i} = mean(NumMoleculesPerNonColocCluster);
               NumNonColocClustersPerROI{j,i} = numel(NumMoleculesPerNonColocCluster);
               
               %MeanDensity22{j,i}=mean(Density2.*WNb2);
               %MeanArea22{j,i}=mean(Area2.*WNb2);
               
               % Population of cluster with Nb<10  
               A=ClusterSmoothTableCh{j,i};
               AA=cellfun(@(x) x(x.Nb <= handles.DoC.NbThresh), A,'UniformOUtput',0);
               A=A(~cellfun('isempty', AA));
               
               Density3=cellfun(@(x) x.AvRelativeDensity20, A);
               Area3=cellfun(@(x) x.Area, A);
               Circularity3=cellfun(@(x) x.Circularity, A);
    
               MeanArea3{j,i}=mean(Area3);
               MeanDensity3{j,i}=mean(Density3);
               MeanCircularity3{j,i}=mean(Circularity3);
                          
            else
               MeanDensityDofC{j,i}=[];
               MeanAreaDofC{j,i}=[];
               MeanCircularityDofC{j,i}=[];
               
               MeanDensity2{j,i}=[];
               MeanArea2{j,i}=[];
               MeanCircularity2{j,i}=[];
                    
            end        
        end
        
    end

    Result2.DensityDofC=MeanDensityDofC;
    Result2.AreaDofC=MeanAreaDofC;
    Result2.CircularityDofC=MeanCircularityDofC;
    
    Result2.Density2=MeanDensity2;
    Result2.Area2=MeanArea2;
    Result2.Circularity2=MeanCircularity2;
    
    Result2.Density3=MeanDensity3;
    Result2.Area3=MeanArea3;
    Result2.Circularity3=MeanCircularity3;

    switch Ch
        case 1
            ResultCh1=Result2;    
            save(fullfile(outputFolder, 'ResultCh1.mat'),'ResultCh1')
        case 2
            ResultCh2=Result2;    
            save(fullfile(outputFolder, 'ResultCh2.mat'),'ResultCh2')
    end
    


    %% Convert to excel file
    
    % Density Area Circularity for cluster with DofC>0.4
    check_list = {MeanDensityDofC(:), MeanAreaDofC(:), MeanCircularityDofC(:),...
        MeanDensity2(:), MeanArea2(:), MeanCircularity2(:)};
    for i=1:numel(check_list)
        check_list{i} = cellfun(@(x) replace_empty(x), check_list{i});
    end

    DensityDofC = check_list{1};
    AreaDofC = check_list{2};
    CircularityDofC = check_list{3};
    
    % Density Area Circularity for cluster with DofC<0.4
    Density2 = check_list{4};
    Area2 = check_list{5};
    Circularity2 = check_list{6};
    
%     DensityDofC = cell2mat(MeanDensityDofC(:));
%     AreaDofC = cell2mat(MeanAreaDofC(:));
%     CircularityDofC = cell2mat(MeanCircularityDofC(:));
%     
%     % Density Area Circularity for cluster with DofC<0.4
%     Density2 = cell2mat(MeanDensity2(:));
%     Area2 = cell2mat(MeanArea2(:));
%     Circularity2 = cell2mat(MeanCircularity2(:));

    
    % Density Area Circularity for cluster with Nb<NbThresh 
    %     Density3 = cell2mat(MeanDensity3(:));
    %     Area3 = cell2mat(MeanArea3(:));
    %     Circularity3=cell2mat(MeanCircularity3(:));
    
    Array=[{'Rel density in colocalised clusters'}, ...
         {'Rel density in non-colocalised clusters'},...
         {'Average area of colicalised clusters (nm^2)'}, ...	
         {'Average area of non-colicalised clusters (nm^2)'}, ...
         {'Circularity of colocalised clusters'}, ...
         {'Circularity of non-colicalised clusters'}, ...
         {'Mean number of molecules per colocalised cluster'}, ... % per cluster, colocalized
         {'Mean number of colocalised clusters per ROI'}, ...	   % per ROI, colocalized
		 {'Mean number of molecules per non-colocalised cluster'}, ... % per cluster, non-colicalised
         {'Mean number of non-colocalised clusters per ROI'},...       % per ROI, colocalized
         {'Relative density 2 of colocalized cluster'},...
         {'Relative density 2 of non-colocalized cluster'}
         ];
    
    checklist = {MeanNumMolsPerColocCluster, NumColocClustersPerROI,...
        MeanNumMolsPerNonColocCluster, NumNonColocClustersPerROI};
    for i =1:numel(checklist)
        checklist{i} = cellfun(@(x) replace_empty(x), checklist{i});
    end

    MeanNumMolsPerColocCluster = checklist{1};
    NumColocClustersPerROI = checklist{2};
    MeanNumMolsPerNonColocCluster = checklist{3};
    NumNonColocClustersPerROI = checklist{4};
    

    Matrix_Result=[
        DensityDofC,...
        Density2,...
        AreaDofC,...
        Area2,...
        CircularityDofC,...
        Circularity2, ...
        MeanNumMolsPerColocCluster(:), ...
        NumColocClustersPerROI(:), ...
        MeanNumMolsPerNonColocCluster(:), ...
        NumNonColocClustersPerROI(:),...
        MeanNumMolsPerColocCluster(:) ./ AreaDofC ./ cell2mat(background_density),...
        MeanNumMolsPerNonColocCluster(:) ./ Area2 ./ cell2mat(background_density),...
        ];
    % replace NaN as O
    Matrix_Result(find(isnan(Matrix_Result)==1)) = 0;

    RegionName = strcat('Clus-DoC results');
    
    switch Ch
        case 1
            xlswrite(fullfile(outputFolder, 'Clus-DoC Ch1.xls'), Array, RegionName, 'A1');
            xlswrite(fullfile(outputFolder, 'Clus-DoC Ch1.xls'), Matrix_Result, RegionName, 'A2');
        case 2
            xlswrite(fullfile(outputFolder, 'Clus-DoC Ch2.xls'), Array, RegionName, 'A1');
            xlswrite(fullfile(outputFolder, 'Clus-DoC Ch2.xls'), Matrix_Result, RegionName, 'A2');
    end

 
end



    

    

   
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    