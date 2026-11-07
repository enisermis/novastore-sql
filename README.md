# NovaStore E-Ticaret Veri Yönetim Sistemi

Veri Tabanı ve SQL eğitiminin proje ödevi. NovaStore adlı bir e-ticaret sitesi için SQL Server'da ilişkisel bir veri tabanı tasarladım, örnek verilerle doldurdum ve yönetimin istediği raporları SQL sorgularıyla hazırladım.

## Dosyalar

| Dosya | İçerik |
|---|---|
| `MuhammedEnisErmis_NovaStore_Proje.sql` | Veri tabanı ve tablolar (DDL), örnek veriler (INSERT), 6 rapor sorgusu, `vw_SiparisOzet` view'ı ve yedekleme komutu. Her bölüm `--` yorum satırlarıyla işaretli. |
| `MuhammedEnisErmis_NovaStore_Proje.docx` | Kodlar, sorgu sonuçlarının ekran görüntüleri ve açıklamalar |
| `MuhammedEnisErmis_NovaStore_Proje.png` | Tabloların ilişki şeması |
| `ekran-goruntuleri/` | Sorgu sonuçlarının ekran görüntüleri |

## Çalıştırma

SQL Server Management Studio (veya DBeaver, Azure Data Studio) ile SQL Server'a bağlanıp `MuhammedEnisErmis_NovaStore_Proje.sql` dosyasını baştan sona çalıştırmak yeterli. Dosya `NovaStoreDB` veri tabanını sıfırdan oluşturur. Yedekleme komutu için `C:\Yedek\` klasörünün önceden açılmış olması gerekir.

Ben SQL Server 2022 kullandım.
