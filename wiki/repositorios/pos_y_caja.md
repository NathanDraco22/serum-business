---
type: reference
title: Repositorios de POS, Caja y Finanzas
description: Detalle de repositorios y modelos de cajas físicas, turnos, kardex inmutable y recibos.
tags: [repositories, pos, cash-register, receipts, finance]
timestamp: 2026-10-21T15:45:00Z
---

# Repositorios de Punto de Venta (POS) y Caja

Esta sección documenta los repositorios encargados del cobro, control de flujo de efectivo y auditoría financiera:

---

## 1. `CashRegistersRepository` (`cash_registers_repository.dart`)

Administra las cajas registradoras físicas dentro de cada sucursal.
- Controla el estado operativo (abierta / cerrada).
- Vincula cada terminal física a su sucursal (`branchId`).

---

## 2. `CashShiftsRepository` (`cash_shifts_repository.dart`)

Controla los turnos o sesiones de cobro:
- `openShift(...)`: Apertura de turno registrando el fondo inicial de caja (en centavos `int`).
- `closeShift(...)`: Cierre de turno, corte Z/X y balance de diferencias entre efectivo esperado y contado.

---

## 3. `CashTransactionsRepository` (`cash_transactions_repository.dart`)

**Kardex Financiero Inmutable:**
- Registra cada evento económico asociado a un cobro, abono, cancelación o devolución.
- Nunca se eliminan ni modifican registros existentes (auditoría forense estricta).
- Segmentación por método de pago (`cash`, `card`, `transfer`).

---

## 4. `CashMovementsRepository` (`cash_movements_repository.dart`)

Gestiona entradas y salidas de efectivo independientes de ventas (gastos menores, pago de suministros, ingresos extraordinarios).

---

## 5. `ReceiptsRepository` (`receipts_repository.dart`)

Emisión y control de recibos de pago:
- Soporta pagos completos o parciales (abonos) para órdenes pendientes de saldo.
- Control de devoluciones financieras (`DevolutionModel`).
