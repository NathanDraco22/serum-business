---
type: concept
title: Almacenamiento Seguro Multiplataforma
description: Implementación de almacenamiento cifrado de credenciales y tokens con Hive CE y AES-256.
tags: [storage, security, hive, aes-256]
timestamp: 2026-10-21T15:45:00Z
---

# Almacenamiento Seguro con Hive CE (`HiveTokenStorage`)

Para garantizar compatibilidad **100% multiplataforma** (Web vía IndexedDB, Windows, macOS, Linux, Android e iOS) sin depender de librerías nativas con problemas de enlace C++ (como ATL en Windows), `serum_business` utiliza **Hive Community Edition (`hive_ce`)**.

---

## 🔐 Cifrado AES-256

- Las cajas de Hive que almacenan tokens de acceso (`accessToken`) y de refresco (`refreshToken`) se inicializan con un cifrador `HiveAesCipher`.
- La clave criptográfica de 32 bytes (`Uint8List`) se suministra en tiempo de ejecución o se genera mediante `Hive.generateSecureKey()`.

```dart
final secureStorage = HiveTokenStorage(
  secureKey: encryptionKeyBytes,
);
```

---

## 🔄 Interfaz `TokenStorage`

`serum_business` desacopla la implementación concreta a través de la interfaz abstracta `TokenStorage`:
- `Future<void> saveTokens({required String accessToken, required String refreshToken})`
- `Future<String?> getAccessToken()`
- `Future<String?> getRefreshToken()`
- `Future<void> clearTokens()`

Esto permite reemplazar el almacenamiento en entornos de prueba con un `InMemoryTokenStorage` sin alterar el resto de la aplicación.
