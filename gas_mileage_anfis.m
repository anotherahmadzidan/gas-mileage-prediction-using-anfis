clear; close all; clc;
rng(0); % Pakai rng(0) biar hasilnya selalu sama setiap kali di-run

%% Load Data
fname = 'auto-mpg.data';
fid = fopen(fname, 'r');
if fid == -1
    error('File auto-mpg.data tidak ditemukan, coba cek lagi.');
end

% Baca filenya sekali jalan untuk hitung ada berapa baris data yang valid.
temp_data = textscan(fid, '%s', 'delimiter', '\n');
fclose(fid);
valid_lines = ~cellfun('isempty', strfind(temp_data{1}, '?'));
num_valid_lines = sum(~valid_lines);

% Buat matriks kosong (pre-allocation) dengan ukuran yang pas.
data_raw = zeros(num_valid_lines, 7); 
line_idx = 1;

% Loop untuk mengisi matriks yang sudah disiapkan tadi.
for i = 1:length(temp_data{1})
    if valid_lines(i)
        continue; % Saya lewati baris yang datanya ada '?'
    end
    
    line = temp_data{1}{i};
    if isempty(line), continue; end
    
    parts = textscan(line, '%f %f %f %f %f %f %f %f %q', ...
        'MultipleDelimsAsOne', true);
    
    % Ini untuk jaga-jaga kalau ada baris kosong di akhir file
    if any(cellfun('isempty', parts))
        continue;
    end
        
    mpg   = parts{1};
    cyl   = parts{2};
    disp  = parts{3};
    hp    = parts{4};
    wt    = parts{5};
    accel = parts{6};
    year  = parts{7};

    % Masukkan data ke matriks di baris yang sesuai
    data_raw(line_idx, :) = [cyl disp hp wt accel year mpg];
    line_idx = line_idx + 1;
end


% Urutan kolom: [Cyl Disp HP Weight Accel Year MPG]

%% Split Data (ganjil = training, genap = checking)
trn_data = data_raw(1:2:end,:);
chk_data = data_raw(2:2:end,:);

% Nama-nama input
input_name = {'Cylinder','Displacement','Horsepower','Weight','Acceleration','Year'};

%% 3. Pilih Input Sesuai Di Buku (Weight dan Year)
input_index = [4 6];
new_trn_data = trn_data(:, [input_index, size(trn_data,2)]);
new_chk_data = chk_data(:, [input_index, size(chk_data,2)]);

%% 4. Generate FIS Awal (Grid Partition)
fisOptions = genfisOptions('GridPartition'); % Pakai metode Grid Partition
fisOptions.NumMembershipFunctions = 2;       % Set 2 MF untuk tiap input
fisOptions.InputMembershipFunctionType = 'gbellmf'; % Pakai tipe MF gbellmf
in_fismat = genfis(new_trn_data(:,1:end-1), new_trn_data(:,end), fisOptions);


%% 5. ANFIS Training Setup
anfisOpt = anfisOptions('InitialFIS', in_fismat, ...
    'EpochNumber', 100, ...
    'StepSizeDecreaseRate', 0.5, ...
    'StepSizeIncreaseRate', 1.5, ...
    'ValidationData', new_chk_data, ...
    'DisplayANFISInformation', 0, ... % Matikan display biar command window bersih
    'DisplayErrorValues', 0, ...
    'DisplayStepSize', 0, ...
    'DisplayFinalResults', 0);

% Mulai proses training ANFIS
[trn_out_fismat, trn_error, ~, chk_out_fismat, chk_error] = ...
    anfis(new_trn_data, anfisOpt);

%% 6. Plotting Error Training vs Checking (Figure 1)
% Cari nilai error checking terkecil dan terjadi di epoch ke berapa
[min_chk_err, best_epoch] = min(chk_error);

figure;
plot(1:100, trn_error, 'g-', 'LineWidth', 1.5); hold on;
plot(1:100, chk_error, 'r-', 'LineWidth', 1.5);
plot(best_epoch, min_chk_err, 'ko', 'MarkerFaceColor', 'k'); % Tandai titik error terbaik
xlabel('Epoch numbers','FontSize',10);
ylabel('RMS errors','FontSize',10);
title('Kurva Error Training (hijau) dan Checking (merah)','FontSize',10);
legend('Training','Checking','Minimum Checking Error','Location','best');
grid on;

%% 7. Bandingkan Hasil ANFIS dengan Regresi Linear
% Di command windows
N = size(trn_data,1);
A = [trn_data(:,1:6) ones(N,1)];
B = trn_data(:,7);
coef = A\B;
Nc = size(chk_data,1);
A_ck = [chk_data(:,1:6) ones(Nc,1)];
B_ck = chk_data(:,7);
lr_rmse = norm(A_ck*coef - B_ck)/sqrt(Nc);

fprintf('\nPerbandingan RMSE dengan checking data:\nANFIS : %.3f\tRegresi Linear : %.3f\n', ...
    min_chk_err, lr_rmse);

%% 8. Tampilkan Surface Plot dari FIS (Figure 2)
chk_out_fismat.Inputs(1).Name = 'Weight';
chk_out_fismat.Inputs(2).Name = 'Year';
chk_out_fismat.Outputs(1).Name = 'MPG';

figure;
gensurf(chk_out_fismat);
title('Input-Output Surface dari FIS yang Sudah Dilatih','FontSize',10);

%% 9. Plot Distribusi Data (Figure 3)
figure;
plot(new_trn_data(:,1), new_trn_data(:,2), 'bo'); hold on;
plot(new_chk_data(:,1), new_chk_data(:,2), 'rx');
xlabel('Weight','FontSize',10);
ylabel('Year','FontSize',10);
title('Sebaran Data Training (o) dan Checking (x)','FontSize',10);
legend('Training','Checking');
grid on;

%% 10. Tampilkan Ringkasan Hasil Terbaik
% Di command window
fprintf('\nRMSE checking terbaik di epoch ke-%d: %.3f\n', best_epoch, min_chk_err);

% Simpan hasil model ANFIS ke file .fis
writeFIS(chk_out_fismat, 'gas_mileage_anfis.fis'); % <-- PERUBAHAN: Tanda % dihapus
