# Clean Architecture .NET Solution Generator

Bu proje, **.NET Clean Architecture mimarisine uygun bir solution yapısını tek komutla oluşturmak** için geliştirilmiş bir PowerShell scriptidir.

Script çalıştırıldığında aşağıdaki işlemler otomatik olarak gerçekleştirilir:

* Solution oluşturulur
* Clean Architecture katmanları oluşturulur
* Katmanlar arası referanslar kurulur
* CQRS klasör yapısı hazırlanır
* BaseEntity oluşturulur
* Örnek Entity oluşturulur
* DbContext oluşturulur
* Global Exception Middleware oluşturulur
* MediatR handler örneği oluşturulur
* Gerekli NuGet paketleri eklenir

Bu sayede yeni bir proje başlatırken **manuel kurulum işlemlerine gerek kalmaz**.

---

# 1. Projenin Amacı

Yeni bir .NET backend projesi başlatırken genellikle aşağıdaki işlemler tekrar tekrar yapılır:

* Solution oluşturma
* Katman projelerini oluşturma
* Katman bağımlılıklarını ayarlama
* Klasör mimarisini oluşturma
* NuGet paketlerini ekleme

Bu script bu işlemlerin tamamını **tek komutla otomatik hale getirir**.

Sonuç olarak geliştirici doğrudan **iş mantığını geliştirmeye başlayabilir**.

---

# 2. Script Nasıl Çalıştırılır

Script PowerShell üzerinden çalıştırılır.

```
powershell -ExecutionPolicy Bypass -File .\create-clean-arch.ps1 ProjectName
```

Örnek:

```
powershell -ExecutionPolicy Bypass -File .\create-clean-arch.ps1 OrderService
```

Script çalıştırıldığında **OrderService isimli bir solution oluşturulur**.

---

# 3. Oluşan Proje Yapısı

Script aşağıdaki klasör yapısını oluşturur:

```
OrderService
│
├─ OrderService.sln
│
├─ src
│   ├─ OrderService.Domain
│   ├─ OrderService.Application
│   ├─ OrderService.Infrastructure
│   └─ OrderService.API
│
└─ tests
    └─ OrderService.UnitTests
```

---

# 4. Clean Architecture

Bu proje **Clean Architecture prensiplerini** kullanır.

Clean Architecture uygulamayı katmanlara ayırarak bağımlılıkların doğru yönde akmasını sağlar.

---

# 5. Katman Bağımlılık Diyagramı

```
           ┌──────────────┐
           │     API      │
           └──────┬───────┘
                  │
           ┌──────▼───────┐
           │ Infrastructure│
           └──────┬───────┘
                  │
           ┌──────▼───────┐
           │  Application  │
           └──────┬───────┘
                  │
           ┌──────▼───────┐
           │    Domain     │
           └──────────────┘
```

Bağımlılık yönü:

```
Domain
↑
Application
↑
Infrastructure
↑
API
```

Domain katmanı **hiçbir katmana bağımlı değildir**.

---

# 6. Katmanların Görevleri

---

# 6.1 Domain Katmanı

Domain katmanı sistemin iş kurallarını içerir.

Bu katmanda:

* Entity sınıfları
* Value Objects
* Domain Events
* Interface tanımları

bulunur.

Domain katmanı **hiçbir dış bağımlılık içermez**.

Klasör yapısı:

```
Entities
Common
```

Örnek Entity:

```
Product
```

---

# 6.2 Application Katmanı

Application katmanı sistemin **use-case mantığını içerir**.

Bu katmanda:

* Commands
* Queries
* DTO sınıfları
* Validation kuralları
* Application servisleri

bulunur.

Klasör yapısı:

```
Features
Interfaces
Behaviors
```

---

# 6.3 Infrastructure Katmanı

Infrastructure katmanı dış sistemlerle iletişim kuran kodları içerir.

Örnek:

* Entity Framework
* Repository implementasyonları
* Harici servis entegrasyonları

Klasör yapısı:

```
Persistence
Repositories
```

---

# 6.4 API Katmanı

API katmanı uygulamanın giriş noktasıdır.

HTTP isteklerini karşılar.

Klasör yapısı:

```
Controllers
Middleware
```

---

# 7. CQRS Yapısı

Proje **CQRS (Command Query Responsibility Segregation)** pattern kullanacak şekilde hazırlanmıştır.

---

# 7.1 CQRS Diyagramı

```
Client
   │
   ▼
Controller
   │
   ▼
MediatR
   │
   ├── Command Handler
   │
   └── Query Handler
```

---

# 8. Script Tarafından Oluşturulan Kodlar

Script aşağıdaki örnek bileşenleri oluşturur:

---

# 8.1 BaseEntity

```
BaseEntity
```

Bu sınıf tüm entity sınıflarının temel sınıfıdır.

İçerdiği alanlar:

```
Id
CreatedDate
```

---

# 8.2 Example Entity

```
Product
```

Domain katmanında oluşturulur.

---

# 8.3 MediatR Query ve Handler

Script örnek bir CQRS handler oluşturur.

```
GetProductsQuery
GetProductsHandler
```

Bu sayede MediatR yapısının nasıl kullanılacağı görülebilir.

---

# 8.4 DbContext

Infrastructure katmanında aşağıdaki sınıf oluşturulur:

```
AppDbContext
```

Bu sınıf Entity Framework Core veritabanı erişimini sağlar.

---

# 8.5 Global Exception Middleware

API katmanında aşağıdaki middleware oluşturulur:

```
ExceptionMiddleware
```

Bu middleware uygulama içindeki hataları merkezi olarak yakalar.

---

# 9. Eklenen NuGet Paketleri

Script bazı yaygın kullanılan paketleri otomatik olarak ekler.

---

## 9.1 Application Katmanı

```
MediatR
FluentValidation
AutoMapper
```

---

## 9.2 Infrastructure Katmanı

```
Microsoft.EntityFrameworkCore
Microsoft.EntityFrameworkCore.SqlServer
```

---

## 9.3 API Katmanı

```
Serilog.AspNetCore
Swashbuckle.AspNetCore
```

---

# 10. Scriptin Otomatik Yaptığı İşlemler

Script çalıştırıldığında aşağıdaki işlemler gerçekleştirilir:

1. Solution oluşturulur
2. Clean Architecture katmanları oluşturulur
3. Katman referansları kurulur
4. Klasör mimarisi hazırlanır
5. CQRS klasör yapısı oluşturulur
6. BaseEntity oluşturulur
7. Example Entity oluşturulur
8. MediatR handler oluşturulur
9. DbContext oluşturulur
10. Global Exception Middleware oluşturulur
11. NuGet paketleri yüklenir

---

# 11. Kullanım Senaryosu

Yeni bir proje başlatmak için yalnızca aşağıdaki komutu çalıştırmanız yeterlidir.

```
powershell -ExecutionPolicy Bypass -File .\create-clean-arch.ps1 PaymentService
```

Script tamamlandığında proje **Clean Architecture mimarisi ile hazır hale gelir**.

---

# 12. Avantajlar

Bu script aşağıdaki avantajları sağlar:

* Proje başlangıç süresini azaltır
* Mimari standart oluşturur
* Tekrarlayan kurulum işlemlerini ortadan kaldırır
* Clean Architecture kullanımını kolaylaştırır

---

# 13. Sonuç

Bu araç sayesinde yeni bir .NET backend projesi **dakikalar yerine saniyeler içinde hazır hale gelir**.

Script özellikle aşağıdaki projeler için uygundur:

* Web API projeleri
* Microservice projeleri
* Kurumsal backend servisleri

---
