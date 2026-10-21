---
type: reference
title: Repositorios del Módulo Clínico
description: Detalle de repositorios y modelos encargados de la operación médica, órdenes, catálogo de análisis y pacientes.
tags: [repositories, clinical, orders, lab-tests, patients, doctors]
timestamp: 2026-10-21T15:45:00Z
---

# Repositorios Clínicos

Esta sección documenta los repositorios que manejan el flujo medular del laboratorio de análisis clínicos:

---

## 1. `OrdersRepository` (`orders_repository.dart`)

Orquesta el ciclo de vida de las órdenes de análisis clínicos.

### Métodos Principales:
- `create(CreateOrder order)`: Genera una nueva orden capturando el snapshot inmutable de los análisis seleccionados.
- `update(String id, UpdateOrder order)`: Actualiza datos generales o notas de la orden.
- `updateResults(String id, List<OrderTestResult> results)`: Registra valores numéricos, cualitativos o descriptivos de los análisis.
- `approve(String id, OrderApproval approval)`: Firma y valida médicamente los resultados.
- `block(String id)` / `unblock(String id)`: Bloquea una orden para impedir modificaciones o entregas hasta resolución de adeudos o incidencias.
- `getById(String id)`: Recupera la orden completa con resultados y estados.

---

## 2. `LabTestsRepository` (`lab_tests_repository.dart`)

Catálogo unificado de análisis clínicos y paquetes comerciales (Packs).

### Características:
- Distingue análisis individuales de paquetes (`isPack: true`).
- Almacena rangos de referencia por edad y género (`ReferenceValue`).
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
