---
type: convention
title: Guía de Agentes — Serum Business Wiki
description: Normas obligatorias para agentes de inteligencia artificial al consultar y actualizar la documentación de serum_business.
tags: [agents, okf, conventions, guidelines]
timestamp: 2026-10-21T15:45:00Z
---

# 🤖 Guía para Agentes de IA en `serum_business/wiki/`

## Regla Fundamental

**Antes de proponer o ejecutar cualquier cambio de código en `serum_business`, DEBES consultar obligatoriamente [`project_index.md`](project_index.md) y los documentos relevantes de la wiki (`arquitectura/`, `repositorios/`).**

## Protocolo Obligatorio

1. **Consulta Previa:**
   - Lee `project_index.md` para ubicar el repositorio o modelo correspondiente.
   - Si vas a modificar lógica clínica o de órdenes, revisa [`repositorios/clinica.md`](repositorios/clinica.md).
   - Si vas a modificar transacciones monetarias o recibos, revisa [`repositorios/pos_y_caja.md`](repositorios/pos_y_caja.md).
2. **Preservar Dart Puro:**
   - **NUNCA** importar paquetes de Flutter (`flutter/material.dart`, `flutter/widgets.dart`, etc.) dentro de `serum_business`. Este paquete debe mantenerse 100% puro.
3. **Convenciones de Datos:**
   - Todos los precios deben modelarse en centavos enteros (`int`).
   - Todos los timestamps en milisegundos Unix (`int`).
   - Todos los payloads JSON en `camelCase`.
4. **Verificación Estática:**
   - Ejecuta siempre `dart analyze` tras cualquier modificación. El resultado debe ser siempre `No issues found!`.
5. **Mantenimiento de la Wiki:**
   - Cualquier adición de un nuevo repositorio, método clave o modelo debe registrarse inmediatamente en `project_index.md` y en su documento de dominio correspondiente.
