# AGENTS.md — Convenciones y Estándares de `serum_business`

Este proyecto es el paquete central de lógica de negocio y repositorios del sistema **Serum LIS**, desarrollado como paquete **Dart Puro** (sin dependencias del framework Flutter).

---

## 📌 Regla de Oro

**Cualquier agente que trabaje en `serum_business` DEBE consultar primero [`wiki/project_index.md`](wiki/project_index.md) y [`wiki/INDEX.md`](wiki/INDEX.md) antes de analizar, responder o alterar cualquier archivo de código.**

---

## 📐 Convenciones Obligatorias

### 1. Pureza de Dart (Sin Flutter)
- Está estrictamente prohibido añadir dependencias del SDK de Flutter o paquetes que dependan de `flutter` en `pubspec.yaml`.
- Toda la lógica debe ser portable a CLI, backend o frontend.

### 2. Estructura de Capas
- **`lib/src/core/`**: Reglas y servicios de dominio puros y compartidos. Incluye `reference_value_resolver.dart` (resolución demográfica y de rangos), `clinical_alert_evaluator.dart` (flags `H`/`L`/`ABNORMAL`) y `evaluation/`, el pipeline estándar de evaluación clínica (`ClinicalEvaluationService` → `DemographicsStep` → `ReferenceResolutionStep` → `ResultEvaluationStep`). Es lógica de dominio pura: no debe depender de Flutter, HTTP ni persistencia.
- **`lib/src/domain/models/`**: Clases inmutables con constructores `const`, métodos `fromJson` y `toJson`.
- **`lib/src/data/`**: DataSources que interactúan vía HTTP con el servidor utilizando `HttpService`.
- **`lib/src/domain/repositories/`**: Repositorios de negocio que exponen métodos de alto nivel y pueden heredar de `ReactiveRepository` para soporte de streams.
- **`lib/src/services/`**: Servicios de infraestructura (HTTP, persistencia local segura).
- **`lib/src/tools/`**: Utilidades (formateo monetario, cálculo de fechas, gestión de JWT).

### 3. Manejo de Montos y Fechas
- **Dinero:** Siempre en enteros (`int`) representando **centavos**.
- **Formato monetario:** Usar `NumberFormatter`; la moneda global se registra con `configureCurrencyResolver` desde la app. Nunca concatenar símbolos ni duplicar setters de moneda.
- **Fechas de Base de Datos:** Milisegundos Unix (`int`).
- **Nombres de Campos:** `camelCase` estricto en JSON para empatar con los esquemas del backend FastAPI.

### 4. Verificación Obligatoria
- Después de cualquier modificación:
  ```bash
  dart analyze
  ```
  Debe resultar en **0 errores y 0 advertencias**.
