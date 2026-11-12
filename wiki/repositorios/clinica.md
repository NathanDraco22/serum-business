---
type: reference
title: Repositorios del Módulo Clínico
description: Detalle de repositorios y modelos encargados de la operación médica, órdenes, catálogo de análisis y pacientes.
tags: [repositories, clinical, orders, lab-tests, patients, doctors]
timestamp: 2026-11-12T12:00:00Z
---

# Repositorios Clínicos

Esta sección documenta los repositorios que manejan el flujo medular del laboratorio de análisis clínicos:

---

## 1. `OrdersRepository` (`orders_repository.dart`)

Orquesta el ciclo de vida de las órdenes de análisis clínicos.

### Métodos Principales:
- `createOrder(CreateOrder order)`: Genera una nueva orden capturando el snapshot inmutable de los análisis seleccionados.
- `updateOrderById(String id, UpdateOrder order)`: Actualiza datos generales, notas o resultados de la orden.
- `finalizeOrder(String id)`: `POST /orders/{id}/finalize`. Cierra clínicamente una orden en `in_review`; valida que todos los resultados estén completos y registra `finalizedAt` / `finalizedBy`.
- `reopenOrder(String id, OrderReopenRequest request)`: `POST /orders/{id}/reopen`. Devuelve una orden `completed` a `in_review` con motivo obligatorio, auditoría y `revisionCount`.
- `approveOrder(String id, OrderApproveRequest request)`: Autoriza órdenes bloqueadas por precio.
- `deleteOrderById(String id)`: Cancela lógicamente una orden sin pagos ni resultados.
- `getOrderById(String id)` / `getAllOrders(...)`: Recupera la orden completa con resultados, historial de estados y datos financieros.

### Estado clínico y auditoría:
- `status`: `pending` → `in_review` → `completed`; `cancelled` como estado terminal.
- `in_review` se activa al completar todos los `results`, sin depender de `paidAmount`.
- `OrderInDb` incorpora `statusHistory`, `finalizedAt`, `finalizedBy`, `reopenedAt`, `reopenedBy`, `reopenReason` y `revisionCount`.
- `paid` / `partiallyPaid` se mantienen temporalmente como estados legacy de respuesta; no representan el estado clínico persistido.

---

## 2. `LabTestsRepository` (`lab_tests_repository.dart`)

Catálogo unificado de análisis clínicos y paquetes comerciales (Packs).

### Características:
- Distingue análisis individuales de paquetes (`isPack: true`).
- **Subclasificación Clínica (`subclassification`)**: Permite categorizar subseries analíticas (ej. *Serie Roja*, *Serie Blanca*, *Físico-Químico*, etc.) complementando la especialidad médica (`commercialCategory`).
- **Parámetros Internos de Perfiles (`isProfileParameter: bool`)**: Identifica parámetros creados directamente dentro de un perfil clínico para evitar ruido visual en el catálogo de venta comercial.
- **Propagación Clínica**: La `subclassification` se propaga hacia `IncludedTest` y `OrderTestResult`, posibilitando la agrupación por subseries en los informes de resultados (PDF y visor en pantalla).
- Almacena rangos de referencia por edad y género (`ReferenceValue`), con flags `useAge` / `useGender` (por defecto `false`) que indican si cada rango debe evaluar esas dimensiones.
- `ReferenceValueResolver` (en `lib/src/core/`) centraliza la resolución demográfica: edad exacta en días, normalización de género, prioridad del rango más específico y formateo de edades (`formatAgeDays`, `formatReferenceAge`, `formatAgeRange`). La edad se calcula con `referenceDateMs` obligatorio (normalmente `order.createdAt`); el resolvedor no usa `DateTime.now()` internamente, por lo que el cálculo es determinista y apto para auditoría histórica.
- `ClinicalAlertEvaluator` (en `lib/src/core/`) centraliza la evaluación de flags clínicos a partir del valor capturado y del rango resuelto: normaliza alias (`HIGH`/`ALTO` → `H`, `LOW`/`BAJO` → `L`, `ABNORMAL`/`ANORMAL` → `ABNORMAL`), trata `NORMAL` como ausencia de alerta y recalcula en lugar de confiar en el `alertFlag` persistido. `OrderTestResult.fromJson` usa `normalizeFlag` para que un `NORMAL` persistido se lea como `null`. La comparación cualitativa ignora mayúsculas y espacios periféricos.
- Soporta tipos de resultado: `numeric`, `qualitative`, `boolean`, `text`.
- Búsqueda en vivo: `searchLabTestsByText(String query)` (con retorno inmediato de `[]` ante cadenas vacías para evitar cargas innecesarias).

---

## 3. `PatientsRepository` (`patients_repository.dart`)

Gestión y expediente demográfico de pacientes.

### Métodos:
- `create(CreatePatient patient)`
- `update(String id, UpdatePatient patient)`
- `searchPatientsByText(String text)`: Búsqueda rápida por nombre, teléfono o identificación.

---

## 4. `DoctorsRepository` (`doctors_repository.dart`)

Directorio de médicos remitentes e instituciones solicitantes.

### Métodos:
- `create(CreateDoctor doctor)`
- `searchDoctorsByText(String text)`
- Asignación de porcentajes de comisión por referencia médica.

---

## 5. `LabTestAccountsRepository` (`lab_test_accounts_repository.dart`)

Convenios comerciales con empresas, aseguradoras o médicos VIP para aplicar listas de precios personalizadas a órdenes y cotizaciones.
