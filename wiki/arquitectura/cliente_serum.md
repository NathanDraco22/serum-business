---
type: concept
title: Cliente Serum (SerumClient)
description: Fachada unificada y contenedor de inicialización para repositorios y servicios.
tags: [serum_client, facade, dependency-injection]
timestamp: 2026-10-21T15:45:00Z
---

# `SerumClient` y `SerumClientConfig`

`SerumClient` actúa como el **punto de entrada principal y contenedor de dependencias** de `serum_business`.

---

## ⚙️ `SerumClientConfig`

Encapsula los parámetros necesarios para conectar y autenticar al cliente contra el servidor:

```dart
class SerumClientConfig {
  final String baseUrl;              // URL base de la API (ej. https://api.laboratorioserum.com)
  final String? businessNickname;    // Identificador multi-tenant de la clínica/laboratorio
  final String? branchId;            // Sucursal activa seleccionada
  final TokenStorage tokenStorage;   // Proveedor de persistencia segura de tokens
  final http.Client? customClient;   // Cliente HTTP subyacente opcional (para tests)
}
```

---

## 🏛️ Fachada `SerumClient`

Al instanciar `SerumClient`, este se encarga de:
1. Configurar el `HttpService` inyectando los headers obligatorios (`x-business-nickname`, tokens JWT).
2. Instanciar los DataSources correspondientes.
3. Instanciar y exponer públicamente los **20 repositorios** listos para ser consumidos:
   - `authRepository`
   - `ordersRepository`
   - `labTestsRepository`
   - `patientsRepository`
   - `cashRegistersRepository`
   - *(y los 15 repositorios restantes)*.

```dart
final client = SerumClient(config: myConfig);
final patients = await client.patientsRepository.getAll();
```
