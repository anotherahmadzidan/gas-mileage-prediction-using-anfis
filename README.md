## **Prediksi Konsumsi Bahan Bakar (Gas Mileage) Menggunakan ANFIS**

Proyek ini bertujuan untuk memprediksi efisiensi bahan bakar kendaraan (MPG - Miles Per Gallon) berdasarkan spesifikasi kendaraan menggunakan metode ANFIS (Adaptive Neuro-Fuzzy Inference System) di MATLAB.
Sistem ini melatih model fuzzy untuk mempelajari hubungan non-linear antara berat kendaraan dan tahun pembuatannya terhadap konsumsi bahan bakar.

### **📂 Struktur File**

**gas_mileage_anfis.m**: Skrip utama MATLAB. File ini memuat data, melakukan preprocessing, melatih sistem ANFIS, dan memvisualisasikan hasil (kurva error dan surface plot).

**auto-mpg.data**: Dataset yang digunakan. Berisi data spesifikasi teknis berbagai mobil (silinder, displacement, horsepower, berat, akselerasi, tahun, dll).

**gas_mileage_anfis.fis**: File model Fuzzy Inference System (FIS) yang telah selesai dilatih dan disimpan. Dapat dimuat kembali untuk penggunaan langsung tanpa pelatihan ulang.

**Figure_1.png, Figure_2.png, Figure_3.png**: Gambar hasil plot yang dihasilkan oleh program.


### **🛠️ Persyaratan Sistem**

MATLAB (Versi R2018a atau yang lebih baru disarankan).

Fuzzy Logic Toolbox (Wajib terinstal untuk fungsi genfis, anfis, dan evalfis).


### **🚀 Cara Menjalankan**

- Pastikan file gas_mileage_anfis.m dan auto-mpg.data berada dalam satu folder yang sama (Current Folder di MATLAB).

- Buka file gas_mileage_anfis.m di MATLAB Editor.

- Jalankan skrip dengan menekan tombol Run atau F5.

Program akan menampilkan:

Command Window: Nilai RMSE (Root Mean Square Error) terbaik pada data validasi dan perbandingannya dengan metode Regresi Linear sederhana.

Grafik: Tiga buah grafik yang menjelaskan performa model dan distribusi data.


### **📊 Metodologi**

Model ANFIS dikonfigurasi dengan parameter berikut berdasarkan studi kasus:

**Input: Menggunakan 2 fitur paling berpengaruh, yaitu:**

- Weight (Berat Kendaraan)

- Year (Tahun Pembuatan)

**Pembagian Data:**

- Data baris ganjil sebagai Training Data.

- Data baris genap sebagai Checking Data (Validasi).

**Struktur FIS:**

- Metode Grid Partition.

- 2 Fungsi Keanggotaan (Membership Functions) per input.

- Tipe MF: gbellmf (Generalized Bell-shaped).

- Tipe Output: Linear (Sugeno orde-1).

- Pelatihan: Dilakukan selama 100 epoch menggunakan algoritma hybrid.

### **📈 Hasil Visualisasi**

**Figure 1 (Error Curve)**: Menunjukkan penurunan error RMSE seiring bertambahnya epoch. Titik lingkaran hitam menandai epoch dimana error data checking paling rendah (model terbaik sebelum overfitting).

**Figure 2 (Surface Plot)**: Grafik 3D yang memvisualisasikan aturan fuzzy yang terbentuk. Terlihat kecenderungan bahwa mobil yang lebih ringan dengan tahun pembuatan lebih baru memiliki MPG yang lebih tinggi.

**Figure 3 (Data Distribution)**: Menampilkan sebaran data input (Training vs Checking) untuk memastikan representasi data yang seimbang.
