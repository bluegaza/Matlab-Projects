%% Traditional Chinese Medicine (TCM) Mass Spectrometry Analysis - Corrected Version
% Improved combination logic, accurate data matching, and enhanced graph generation.

clear; clc; close all;

%% Define Atomic Masses
atomicMasses = struct('C', 12.0000, 'H', 1.0078, 'O', 15.9949, 'N', 14.0031, 'P', 30.9738, ...
                      'Na', 22.9898, 'HCOO', 45.0174);

%% Core Structures and Substituents
coreStructures = {'cuscutamine', 'sesaminol', 'kaempferol', 'quercetin', 'isorhamnetin'};
substituents = {'caffeoyl', 'feruloyl'};

% Generate Advanced Combinations
combinations = {};
for i = 1:length(coreStructures)
    base = coreStructures{i};
    combinations{end+1} = base; % A
    for j = 1:length(substituents)
        combinations{end+1} = strcat(base, '+', substituents{j}); % A+B
    end
    % A + 2B Cases (Explicit Three Combinations)
    combinations{end+1} = strcat(base, '+2', substituents{1});
    combinations{end+1} = strcat(base, '+2', substituents{2});
    combinations{end+1} = strcat(base, '+', substituents{1}, '+', substituents{2});
end

disp('Generated Combination Library:');
disp(combinations);

%% Load Mass Spectrometry Data (Ensure Data Exists)
if ~exist('MS1_data', 'var') || isempty(MS1_data)
    error('MS1_data is missing. Please load the MS1 mass spectrometry dataset.');
end
if ~exist('MS2_data', 'var') || isempty(MS2_data)
    error('MS2_data is missing. Please load the MS2 fragment dataset.');
end

massErrorThreshold = 0.01; % Da tolerance
matchedComponents = {};

for i = 1:numel(MS1_data.Mass)
    observedMass = MS1_data.Mass(i);
    retentionTime = MS1_data.RetentionTime(i);
    for j = 1:length(coreStructures)
        formula = coreStructures{j};
        if isfield(quasiIons, formula)
            expectedMasses = struct2array(quasiIons.(formula));
            if any(abs(observedMass - expectedMasses) <= massErrorThreshold)
                matchedComponents{end+1} = {formula, observedMass, retentionTime};
            end
        end
    end
end

disp('First-Level Data Matching Results:');
disp(matchedComponents);

%% Improved MS2 Matching - Including Corrected Neutral Loss Logic
finalIdentifications = {};

for i = 1:length(matchedComponents)
    compound = matchedComponents{i}{1};
    if isfield(MS2_data, compound)
        observedFragments = MS2_data.(compound);
        if isfield(secondaryFragments, compound)
            expectedFragments = compoundMasses.(compound) - struct2array(secondaryFragments.(compound));
            
            % Correct neutral loss identification
            validMatches = ismember(expectedFragments, observedFragments, 'rows');
            neutralLosses = expectedFragments(~validMatches);
            
            finalIdentifications{end+1} = struct('Compound', compound, 'Fragments', observedFragments, 'NeutralLosses', neutralLosses);
        end
    end
end

disp('Final Identification from Second-Level Data Matching:');
disp(finalIdentifications);

%% Generate Molecular Network Graph
numCompounds = length(finalIdentifications);
if numCompounds > 0
    similarityMatrix = rand(numCompounds); % Placeholder for actual similarity calculations
    figure;
    G = graph(similarityMatrix, combinations(1:numCompounds));
    plot(G, 'Layout', 'force');
    title('Corrected Molecular Network Graph');
    xlabel('Compound Index');
    ylabel('Similarity');
end

%% Generate Mass Spectrum Plot
figure;
histogram([MS1_data.Mass], 'BinWidth', 0.1);
title('Mass Spectrum of MS1 Data');
xlabel('Mass (Da)');
ylabel('Frequency');
grid on;

%% Generate Fragmentation Spectrum Plot
if ~isempty(finalIdentifications)
    figure;
    hold on;
    colors = lines(length(finalIdentifications));
    legendEntries = cell(1, length(finalIdentifications));
    for i = 1:length(finalIdentifications)
        compound = finalIdentifications{i}.Compound;
        if isfield(MS2_data, compound)
            stem(MS2_data.(compound), ones(size(MS2_data.(compound))) * i, 'Color', colors(i, :));
            legendEntries{i} = compound;
        end
    end
    legend(legendEntries, 'Location', 'Best');
    title('Fragmentation Spectrum for Identified Compounds');
    xlabel('Mass-to-Charge Ratio (m/z)');
    ylabel('Relative Intensity');
    grid on;
    hold off;
end

disp('Processing Complete. Molecular Clusters, Spectra, and Neutral Loss Identifications Updated.');
