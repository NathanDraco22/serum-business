---
type: index
title: Serum Business — Wiki del Paquete
description: Índice general de la documentación del paquete de lógica de negocio y repositorios de Serum LIS (Dart puro).
tags: [serum_business, dart, lis, index, wiki]
timestamp: 2026-10-21T15:45:00Z
---

# Serum Business — Wiki

Wiki del paquete **`serum_business`**, la librería de lógica de negocio pura, modelos, repositorios y comunicación con el backend para el ecosistema **Serum LIS**.

---

## 🗺️ Mapa Maestro del Paquete

| Documento | Descripción |
|---|---|
| [**Project Index (`project_index.md`)**](project_index.md) | **Mapa central y rector del paquete:** estructura completa, 20 repositorios, modelos, servicios y flujo de datos |
| [**Guía para Agentes (`AGENTS.md`)**](AGENTS.md) | Reglas obligatorias para interacción y mantenimiento de este paquete |

---

## 🏛️ Arquitectura del Sistema

| Sección | Descripción |
|---|---|
| [Capas Dart Puro](arquitectura/capas_dart_puro.md) | Aislamiento de dependencias de Flutter, portabilidad y ejecutable en cualquier entorno |
| [Cliente Serum (`SerumClient`)](arquitectura/cliente_serum.md) | Fachada central de inicialización, ciclo de vida e inyección de dependencias |
| [Almacenamiento Seguro](arquitectura/almacenamiento_seguro.md) | Almacenamiento con Hive CE cifrado AES-256 multiplataforma |
| [Repositorios Reactivos](arquitectura/reactividad.md) | Patrón `ReactiveRepository` con Streams y `BehaviorSubject` para reactividad UI |

---

## 📦 Detalle de Repositorios

| Dominio | Repositorios Incluidos | Descripción |
|---|---|---|
| [**Clínica**](repositorios/clinica.md) | `OrdersRepository`, `LabTestsRepository`, `PatientsRepository`, `DoctorsRepository`, `LabTestAccountsRepository` | Órdenes clínicas, snapshots inmutables, catálogo de análisis/packs, pacientes y médicos |
| [**POS y Caja**](repositorios/pos_y_caja.md) | `CashRegistersRepository`, `CashShiftsRepository`, `CashTransactionsRepository`, `CashMovementsRepository`, `ReceiptsRepository` | Cajas físicas, turnos, kardex financiero inmutable, movimientos de efectivo y recibos |
| [**Gestión y Operación**](repositorios/gestion.md) | `BranchesRepository`, `UsersRepository`, `RolesRepository`, `QuotationsRepository`, `ReportsRepository`, `ImportsRepository` | Sucursales, usuarios, permisos, cotizaciones, importación masiva y reportes |
| [**Configuración y Seguridad**](repositorios/configuracion_y_seguridad.md) | `AuthRepository`, `AppSettingsRepository`, `ApiKeysRepository`, `ServinRepository` | Doble token JWT, ajustes del laboratorio, API keys e integración Servin |
