<div align="center">
  <img src="assets/icon/schedule.png" alt="Puantajım Logo" width="120" />
  <h1>Puantajım</h1>
  <p>Minimalist, hızlı ve tamamıyla internetsiz çalışan kişisel iş takip ve puantaj uygulaması.</p>
  
  <a href="https://github.com/KULLANICI_ADIN/puantajim/releases/latest">
    <img src="https://img.shields.io/badge/APK_İNDİR-Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Download APK" />
  </a>
</div>

<br>

Puantajım, kullanıcıların günlük çalıştıkları işleri karmaşıklıktan uzak bir şekilde takip etmelerini sağlayan **Flutter** tabanlı yerel (offline) bir mobil uygulamadır. Geleneksel karmaşık "aylık filtreli" takvimlerin aksine, sadece çalışılan günleri ardışık olarak sunar ve tek tıkla işaretleme imkanı sunar.

## ✨ Öne Çıkan Özellikler

- **Tek Tıkla Takip:** Takvim üzerindeki güne tek tıklayarak Çalıştı/Çalışmadı olarak işaretleme.
- **Detaylı Notlar:** Günlere uzun basarak o güne özel detaylı notlar ekleme/düzenleme/silme.
- **Aktif ve Biten İşler:** Karmaşayı önlemek için aktif işlerle tamamlanmış işleri sekmeli (Tab) bir yapıda ayırma.
- **Akıllı İstatistikler:** Seçilen işin ne zaman başladığını, toplam kaç gün çalışıldığını ve kaç gün boş geçildiğini anında görebilme.
- **Koyu/Açık Mod:** Sistemden bağımsız çalışan, tercihi hatırlayan kalıcı karanlık mod desteği.
- **Yerel ve Hızlı:** Hiçbir veri buluta gitmez. SQLite sayesinde saniyeler içinde çalışır ve verilerin sadece senin telefonunda güvende kalır.

---

## 📱 Ekran Görüntüleri

*(Buraya uygulamanın 2-3 adet ekran görüntüsünü sürükleyip bırakabilirsin)*
| Ana Ekran (Aktif) | Takvim & İşaretleme | Not Ekleme |
| :---: | :---: | :---: |
| <img width="200" alt="image" src="https://github.com/user-attachments/assets/9a6ceb73-3bfb-4582-9c0e-8fc58cf030bd" /> | <img width="200"  alt="image" src="https://github.com/user-attachments/assets/f879d4c5-0d71-4bb5-8b79-74524f7bc333" /> | <img width="200"  alt="image" src="https://github.com/user-attachments/assets/b0486732-dca1-43af-823c-50d6447f57f0" />



---


## 🛠 Kullanılan Teknolojiler

- **[Flutter](https://flutter.dev/):** UI ve temel altyapı
- **Provider:** State Management (Durum yönetimi)
- **sqflite:** Lokal veritabanı işlemleri
- **shared_preferences:** Kullanıcı tercihleri (Tema yönetimi vb.)
- **flutter_launcher_icons:** Android/iOS uygulama ikon oluşturucu

## 🚀 Kurulum & Çalıştırma

Eğer bu projeyi kendi bilgisayarınızda derlemek isterseniz aşağıdaki adımları takip edebilirsiniz:

1. Repoyu bilgisayarınıza klonlayın:
   ```bash
   git clone https://github.com/KULLANICI_ADIN/puantajim.git
   ```
2. Proje dizinine girin:
   ```bash
   cd puantajim
   ```
3. Gerekli kütüphaneleri indirin:
   ```bash
   flutter pub get
   ```
4. Uygulamayı bağlı bir cihaza veya emülatöre kurun:
   ```bash
   flutter run
   ```

## 📦 Çıktı Alma (Release Build)

Uygulamanın optimize edilmiş Android paketini (APK) almak için:
```bash
flutter build apk --split-per-abi
```
Bu işlem sonunda `build/app/outputs/flutter-apk/` klasörünün içerisinde işlemcilere özel parçalanmış düşük boyutlu APK'ları bulabilirsiniz.
