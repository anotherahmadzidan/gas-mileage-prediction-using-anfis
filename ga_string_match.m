% ga_string_match.m
% Genetic Algorithm untuk mencari string target (MATLAB)
% Versi: fungsi bantu menerima argumen untuk menghindari scope error

clear; close all; clc;
rng('shuffle');

%% --- Parameter GA ---
target = 'Achmad Zidan Al-ashar'; % <-- ubah sesuai nama kalian
popSize = 100;            % ukuran populasi
maxGenerations = 1000;    % batas maksimal generasi
mutationRate = 0.03;      % peluang mutasi per gen
elitismCount = 1;         % jumlah individu terbaik yang dipertahankan tiap generasi
verbose = true;           % tampilkan log tiap generasi

%% --- Set karakter yang diizinkan ---
allowedChars = [ 'A':'Z' 'a':'z' ' ' '-' ]; % sesuai contoh nama
nChars = numel(allowedChars);

%% --- Persiapan ---
L = length(target); % panjang kromosom

% Check: apakah semua karakter target ada di allowedChars
for i = 1:L
    if ~any(target(i) == allowedChars)
        warning('Target berisi karakter yang tidak ada di allowedChars: "%s" (pos %d).', target(i), i);
    end
end

% Inisialisasi populasi: popSize x L
population = char( zeros(popSize, L) );
for i = 1:popSize
    idx = randi(nChars, 1, L);
    population(i, :) = allowedChars(idx);
end

% Logging
history.bestFitness = zeros(maxGenerations,1);
history.bestString  = strings(maxGenerations,1);
history.meanFitness = zeros(maxGenerations,1);

found = false;
generation = 0;

%% --- Loop Generasi ---
while generation < maxGenerations && ~found
    generation = generation + 1;
    
    % 1) Evaluasi fitness
    fitness = computeFitness(population, target); % popSize x 1
    
    % Statistik
    [bestFit, bestIdx] = max(fitness);
    bestStr = population(bestIdx, :);
    meanFit = mean(fitness);
    history.bestFitness(generation) = bestFit;
    history.bestString(generation)  = string(bestStr);
    history.meanFitness(generation) = meanFit;
    
    % Log output
    if verbose
        fprintf('Gen %4d | Best fitness: %2d/%d | Mean: %.2f | Best: %s\n', ...
            generation, bestFit, L, meanFit, bestStr);
    end
    
    % 2) Terminasi
    if bestFit == L
        fprintf('Target ditemukan pada generasi %d: %s\n', generation, bestStr);
        found = true;
        break;
    end
    
    % 3) Buat populasi baru (elitism + offspring)
    newPop = char( zeros(popSize, L) );
    
    % 3a) Elitism
    if elitismCount > 0
        [~, sortIdx] = sort(fitness, 'descend');
        elites = population(sortIdx(1:elitismCount), :);
        newPop(1:elitismCount, :) = elites;
        insertPos = elitismCount + 1;
    else
        insertPos = 1;
    end
    
    % 3b) Generate offspring
    for k = insertPos:popSize
        % Seleksi (roulette based on fitness)
        p1idx = rouletteSelect(fitness);
        p2idx = rouletteSelect(fitness);
        parent1 = population(p1idx, :);
        parent2 = population(p2idx, :);
        
        % Crossover (single point) - berikan L sebagai argumen
        child = crossoverSingle(parent1, parent2, L);
        
        % Mutasi - beri mutationRate dan allowedChars
        child = mutateGenewise(child, mutationRate, allowedChars);
        
        newPop(k, :) = child;
    end
    
    % 4) Replace population
    population = newPop;
end

% Truncate history
history.bestFitness = history.bestFitness(1:generation);
history.bestString  = history.bestString(1:generation);
history.meanFitness = history.meanFitness(1:generation);

%% --- Hasil akhir & visualisasi ---
if ~found
    fprintf('Belum menemukan target setelah %d generasi. Best: %s (fitness %d/%d)\n', ...
        generation, history.bestString(end), history.bestFitness(end), L);
end

figure('Name','GA Progress - Fitness','NumberTitle','off');
plot(1:generation, history.bestFitness, '-o', 'LineWidth', 1.5);
hold on;
plot(1:generation, history.meanFitness, '-x', 'LineWidth', 1.2);
xlabel('Generasi');
ylabel('Fitness (cocok karakter)');
legend('Best fitness','Mean fitness','Location','southeast');
title(sprintf('GA String Matching — target length = %d', L));
grid on;

% Simpan log ke workspace
assignin('base', 'GA_history', history);
assignin('base', 'GA_params', struct('popSize',popSize,'mutationRate',mutationRate,...
    'maxGenerations',maxGenerations,'elitism',elitismCount,'target',target));

fprintf('Selesai. Generasi dijalankan: %d. Best pada akhir: %s (fitness %d/%d)\n', ...
    generation, history.bestString(end), history.bestFitness(end), L);


%% ---------------------------
%% Local functions (menerima argumen yang diperlukan)
%% ---------------------------
function fit = computeFitness(pop, target)
    % fitness = jumlah karakter yang cocok dengan target (0..L)
    % pop: N x L char matrix
    if isempty(pop)
        fit = [];
        return;
    end
    matches = (pop == repmat(target, size(pop,1), 1));
    fit = sum(matches, 2);
end

function parentIdx = rouletteSelect(fit)
    % Roulette-wheel selection (return index)
    % Jika semua fitness nol, pilih acak
    N = numel(fit);
    if all(fit == 0)
        parentIdx = randi(N);
        return;
    end
    epsVal = 1e-9;
    total = sum(fit) + epsVal;
    probs = fit / total;
    cum = cumsum(probs);
    r = rand();
    parentIdx = find(cum >= r, 1, 'first');
    if isempty(parentIdx)
        parentIdx = randi(N);
    end
end

function child = crossoverSingle(p1, p2, L)
    % Single point crossover antara dua char vectors (1 x L)
    if L <= 1
        child = p1;
        return;
    end
    point = randi([1, L-1]);
    child = [p1(1:point) p2(point+1:end)];
end

function mutated = mutateGenewise(ind, mutationRate, allowedChars)
    mutated = ind;
    L = length(ind);
    nChars = numel(allowedChars);
    for ii = 1:L
        if rand() < mutationRate
            mutated(ii) = allowedChars(randi(nChars));
        end
    end
end
