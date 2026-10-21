---
type: reference
title: Repositorios de Gestión y Operación
description: Detalle de repositorios de sucursales, usuarios, roles, cotizaciones, importaciones y reportes.
tags: [repositories, management, users, roles, branches, quotations, reports]
timestamp: 2026-10-21T15:45:00Z
---

# Repositorios de Gestión y Operación

Esta sección documenta los repositorios de soporte administrativo, catálogo organizativo y análisis de rendimiento:

---

## 1. `BranchesRepository` (`branches_repository.dart`)
- Sedes o sucursales físicas del laboratorio.
- Datos de contacto, dirección y prefijo de folio de órdenes.

## 2. `UsersRepository` (`users_repository.dart`)
- Control de personal del laboratorio (recepcionistas, químicos, administradores).
- Asignación de sucursales autorizadas por usuario.

## 3. `RolesRepository` (`roles_repository.dart`)
- Catálogo de roles y permisos específicos por módulo (lectura, escritura, cancelación, auditoría).

## 4. `QuotationsRepository` (`quotations_repository.dart`)
- Cotizaciones preventivas para pacientes casuales o empresas.
- Capacidad de conversión automática a orden clínica sin recaptura de pruebas.

## 5. `ImportsRepository` (`imports_repository.dart`)
- Carga e importación masiva de catálogos de pruebas clínicas desde archivos externos estructurados.

## 6. `ReportsRepository` (`reports_repository.dart`)
- Extracción de métricas de desempeño, cortes financieros y volumen de estudios.
