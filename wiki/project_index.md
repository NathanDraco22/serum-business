---
type: index
title: Serum Business — Mapa del Proyecto (Project Index)
description: Mapa maestro y exhaustivo de la arquitectura, repositorios de negocio, data sources, modelos y servicios del paquete Dart puro serum_business.
tags: [dart, business-logic, lis, index, map, repositories, client]
timestamp: 2026-10-21T15:45:00Z
---

# 🗺️ Project Index — Serum Business (`serum_business`)

Este documento es el **mapa central y rector** del paquete Dart puro `serum_business`. Cualquier agente o desarrollador que trabaje en esta librería debe consultar este índice para comprender la distribución de capas, la interacción con la API FastAPI de `serum_app_back`, el manejo de estado en memoria y la persistencia local segura.

---

## 🏛️ 1. Filosofía y Arquitectura del Paquete

`serum_business` es una **librería Dart pura (sin dependencia alguna del framework Flutter ni del motor de renderizado UI)**.

### Propósitos Fundamentales:
1. **Agnóstico de Interfaz:** Puede ejecutarse en aplicaciones Flutter (Web, Android, iOS, Windows, macOS, Linux), herramientas de línea de comandos (CLI Dart), scripts de automatización o microservicios Dart.
2. **Fuente Única de Verdad (Single Source of Truth):** Modela todas las reglas de negocio del sistema de laboratorio clínico (LIS), cálculos financieros en centavos (`int`), contratos de datos y comunicación de red.
3. **Contrato de Integración Unificado:** Provee a la interfaz de usuario una fachada única y centralizada (`SerumClient`) que expone los repositorios listos para ser inyectados vía `RepositoryProvider` o `GetIt`.
4. **Patrón de Repositorio Reactivo:** Soporta flujos de datos en tiempo real mediante `ReactiveRepository`, exponiendo `Stream<List<T>>` para actualizar interfaces reactivamente tras operaciones de mutación.

---

## 🏗️ 2. Flujo de Datos y Capas Internas

```
[ Frontend / Consumidor (Flutter / CLI) ]
                    ↓
[ Fachada Unificada: SerumClient ]
                    ↓
[ Capa de Repositorios (lib/src/domain/repositories/) ]
                    ↓
        ┌───────────┴───────────┐
        ▼                       ▼
[ DataSources HTTP ]     [ Repositorios Reactivos (Streams) ]
(lib/src/data/)          (lib/src/tools/reactive_repo/)
        ↓                       ↓
[ Servicio HTTP ]        [ Modelos Inmutables ]
(lib/src/services/       (lib/src/domain/models/)
 http_service.dart)
        ↓
[ Backend FastAPI / Red ]
```

### Convenciones Críticas de Datos:
- **Montos Monetarios:** Siempre enteros (`int`) en **centavos**. $100.00 MXN se representa como `10000`. Nunca números de punto flotante (`double`) en cálculos contables.
- **Marcas de Tiempo (Timestamps):** Milisegundos Unix (`int`) para fechas de creación/actualización en base de datos (`createdAt`, `updatedAt`). En tokens JWT se utilizan segundos Unix estándar (RFC 7519).
- **Formato JSON:** `camelCase` estricto en la serialización/deserialización, coincidiendo exactamente con los esquemas Pydantic del backend.

---

## 📂 3. Árbol de Directorios y Estructura de Archivos

```
serum_business/
├── pubspec.yaml                        # Definición de dependencias puras (http, intl, hive_ce, meta)
├── pubspec.lock                        # Bloqueo de versiones
├── devtools_options.yaml               # Opciones de DevTools
├── README.md                           # Documentación en inglés
├── README_ES.md                        # Documentación en español
├── AGENTS.md                           # Directrices operativas para agentes de IA
├── wiki/                               # Wiki Open Knowledge Format (OKF)
│   ├── INDEX.md                        # Índice general OKF
│   ├── AGENTS.md                       # Convenciones de navegación y modificación
│   ├── project_index.md                # 🗺️ Este archivo maestro
│   ├── arquitectura/                   # Arquitectura técnica y patrones
│   │   ├── capas_dart_puro.md
│   │   ├── cliente_serum.md
│   │   ├── almacenamiento_seguro.md
│   │   └── reactividad.md
│   └── repositorios/                   # Detalle técnico de los repositorios
│       ├── clinica.md
│       ├── pos_y_caja.md
│       ├── gestion.md
│       └── configuracion_y_seguridad.md
└── lib/
    ├── serum_business.dart             # Barrel file principal (export público completo)
    └── src/
        ├── serum_client.dart           # Fachada orquestadora y contenedor de repositorios
        ├── serum_client_config.dart    # Configuración de inicialización del cliente
        ├── local_storage.dart          # Interfaz abstracta para persistencia local
        ├── constants/
        │   └── default_values.dart     # Valores y constantes por defecto
        ├── services/                   # Servicios transversales de infraestructura
        │   ├── http_service.dart       # Cliente HTTP con interceptor multi-tenant y Auth
        │   ├── token_storage.dart      # Abstracción para persistencia de tokens de sesión
        │   ├── hive_token_storage.dart # Implementación de token storage con Hive CE cifrado AES-256
        │   ├── hive_service.dart       # Inicialización y manejo de cajas de Hive CE
        │   ├── services.dart           # Barrel file de servicios
        │   └── exceptions/
        │       └── http_exceptions.dart# Jerarquía de excepciones tipadas (Unauthorized, NotFound, etc.)
        ├── domain/
        │   ├── models/                 # Modelos de datos inmutables con soporte JSON
        │   ├── repositories/           # Repositorios de negocio
        │   ├── query_params/           # Clases para filtros y parámetros de consulta URL
        │   └── responses/              # Wrappers de respuestas (ListResponse, ServinStatus)
        ├── data/                       # Data Sources HTTP que se comunican con los endpoints REST
        └── tools/                      # Utilidades de negocio, tokens y repos reactivos
```

---

## 📦 4. Detalle de los 20 Repositorios de Negocio

El paquete organiza la lógica de interacción en **20 repositorios especializados**:

| # | Repositorio | Archivo | Responsabilidad Principal |
|---|---|---|---|
| 1 | **`AuthRepository`** | `auth_repository.dart` | Autenticación, login con email/password, refresh automático de JWT y verificación `/check-user`. |
| 2 | **`OrdersRepository`** | `orders_repository.dart` | Gestión de órdenes de laboratorio, snapshots inmutables de pruebas, registro de resultados médicos y aprobación facultativa. |
| 3 | **`LabTestsRepository`** | `lab_tests_repository.dart` | Catálogo de análisis individuales y paquetes (Packs) comerciales, parámetros clínicos y valores de referencia. |
| 4 | **`PatientsRepository`** | `patients_repository.dart` | Catálogo de pacientes, datos biológicos (edad, género), historial y búsqueda de texto optimizada. |
| 5 | **`DoctorsRepository`** | `doctors_repository.dart` | Directorio de médicos remitentes y cálculo de comisiones. |
| 6 | **`QuotationsRepository`** | `quotations_repository.dart` | Cotizaciones comerciales para clientes o pacientes casuales y conversión directa a órdenes clínicas. |
| 7 | **`ReceiptsRepository`** | `receipts_repository.dart` | Recibos de pago asociados a órdenes clínicas, soporte de abonos y control de devoluciones financieras. |
| 8 | **`CashRegistersRepository`** | `cash_registers_repository.dart` | Control de cajas físicas de cobro y asignación a sucursales. |
| 9 | **`CashShiftsRepository`** | `cash_shifts_repository.dart` | Ciclo de vida de turnos de caja (apertura con balance inicial, arqueo y corte de cierre). |
| 10 | **`CashTransactionsRepository`**| `cash_transactions_repository.dart`| Kardex inmutable de transacciones financieras POS (ventas, abonos, cancelaciones y devoluciones). |
| 11 | **`CashMovementsRepository`** | `cash_movements_repository.dart` | Movimientos manuales de efectivo (ingresos adicionales o retiros de caja chica). |
| 12 | **`BranchesRepository`** | `branches_repository.dart` | Sucursales o sedes operativas del laboratorio. |
| 13 | **`UsersRepository`** | `users_repository.dart` | Gestión de usuarios, asignación de sucursales permitidas y desactivación. |
| 14 | **`RolesRepository`** | `roles_repository.dart` | Definición de roles de seguridad y matriz de permisos por módulo. |
| 15 | **`LabTestAccountsRepository`**| `lab_test_accounts_repository.dart`| Listas de precios corporativas, convenios empresariales y tarifas preferenciales. |
| 16 | **`AppSettingsRepository`** | `app_settings_repository.dart` | Parámetros globales de configuración del laboratorio y personalización. |
| 17 | **`ApiKeysRepository`** | `api_keys_repository.dart` | Generación y revocación de API keys para integración con sistemas externos (analizadores, HL7/REST). |
| 18 | **`ImportsRepository`** | `imports_repository.dart` | Procesamiento e importación masiva de catálogos clínicos vía archivos JSON o CSV. |
| 19 | **`ReportsRepository`** | `reports_repository.dart` | Extracción de reportes de rentabilidad, volumen de órdenes y desempeño médico. |
| 20 | **`ServinRepository`** | `servin_repository.dart` | Monitoreo y sincronización con el servicio de integración fiscal / analítico Servin. |

---

## 🌐 5. Capa de DataSources (`lib/src/data/`)

Cada repositorio delega sus llamadas HTTP a un `DataSource` especializado que utiliza `HttpService`:
- Construye las URL relativas correspondientes a la API (`/api/v1/<entity>/`).
- Serializa los parámetros de filtro usando las clases `QueryParams` (`order_query_params.dart`, etc.).
- Deserializa respuestas en entidades fuertemente tipadas o en `ListResponse<T>`.
- Mapea códigos de error del servidor a excepciones tipadas de Dart (`HttpException`).

---

## 🔒 6. Seguridad, Autenticación y Persistencia Local

### Doble Token JWT y Token Rotation
- **Access Token:** Corta duración (15-30 minutos). Se inyecta en el header `Authorization: Bearer <token>`.
- **Refresh Token:** Larga duración (días/meses). Se almacena localmente de forma cifrada.
- **Detección Preventiva (`TokenManager`):** Se decodifica el token en local y si restan menos de 10 minutos para caducar, se renueva preventivamente antes de enviar una petición.
- **Verificación de Usuario (`/check-user`):** Comprueba que el usuario siga activo y no haya sido deshabilitado en el backend.

### Cifrado Seguro con Hive CE (`HiveTokenStorage`)
- Almacenamiento seguro 100% multiplataforma utilizando `hive_ce` y `HiveAesCipher` con claves de 32 bytes generadas criptográficamente.
- Funciona uniformemente en Web (IndexedDB cifrado), Windows, Linux, macOS, Android e iOS sin dependencias nativas complejas.

---

## ⚙️ 7. Inicialización y Uso con `SerumClient`

```dart
import 'package:serum_business/serum_business.dart';

// 1. Configurar cliente
final config = SerumClientConfig(
  baseUrl: 'https://api.laboratorioserum.com',
  businessNickname: 'central_lab',
  tokenStorage: HiveTokenStorage(secureKey: mySecureKey),
);

// 2. Instanciar cliente unificado
final serumClient = SerumClient(config: config);

// 3. Inicializar sesión previa
await serumClient.authRepository.init();

// 4. Consumir repositorios
final patients = await serumClient.patientsRepository.getAll();
final order = await serumClient.ordersRepository.getById('ord_123');
```
