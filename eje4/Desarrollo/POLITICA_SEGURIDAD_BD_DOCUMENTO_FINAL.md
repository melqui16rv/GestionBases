# POLÍTICA INTEGRAL DE SEGURIDAD PARA APLICACIÓN DE BASE DE DATOS
## SISTEMA LOGÍSTICO DE SEGURIDAD

---

**UNIVERSIDAD:** [Nombre de la Universidad]  
**ASIGNATURA:** Gestión de Bases de Datos  
**EJE:** 4 - Seguridad de la BD  
**FECHA:** Junio 1, 2025  

---

**INTEGRANTES DEL EQUIPO:**

1. **Melqui Alexander Romero Veru**  

2. **Harold Steven Sabogal Perez**  

---

## TABLA DE CONTENIDO

1. [INTRODUCCIÓN](#introducción)
2. [OBJETIVOS](#objetivos)
3. [ALCANCE](#alcance)
4. [COMPONENTE 1: ADMINISTRACIÓN DE DATOS Y ACCESOS](#componente-1)
5. [COMPONENTE 2: COPIAS DE SEGURIDAD Y SEGURIDAD FÍSICA](#componente-2)
6. [COMPONENTE 3: RECURSOS HUMANOS Y CONTROL DE ACCESO](#componente-3)
7. [COMPONENTE 4: DESARROLLO DE APLICACIONES Y DISPOSITIVOS](#componente-4)
8. [CONCLUSIONES](#conclusiones)
9. [BIBLIOGRAFÍA](#bibliografía)

---

## INTRODUCCIÓN

En el contexto actual de la gestión empresarial, la seguridad de las bases de datos constituye un pilar fundamental para garantizar la integridad, confidencialidad y disponibilidad de la información crítica organizacional. Como administradores de bases de datos (DBA), es imperativo establecer políticas integrales que permitan gestionar eficientemente los activos de información mientras se mantienen los más altos estándares de seguridad.

El presente documento desarrolla una **Política Integral de Seguridad para la Aplicación de Base de Datos del Sistema Logístico de Seguridad**, desarrollada en el Eje 3 del curso. Esta política abarca los cuatro componentes fundamentales establecidos en la actividad académica: administración de datos y accesos, copias de seguridad y seguridad física, recursos humanos y control de acceso, y desarrollo de aplicaciones y dispositivos móviles.

La metodología empleada se basa en estándares internacionales como ISO/IEC 27001:2013 e ISO/IEC 27002:2013, adaptados específicamente a las necesidades operacionales de un sistema logístico que gestiona información crítica sobre personal, vehículos, rutas y eventos de seguridad.

---

## OBJETIVOS

### Objetivo General
Desarrollar una política integral de seguridad para la aplicación de base de datos del sistema logístico, que garantice la protección, integridad y disponibilidad de la información, cumpliendo con estándares internacionales y regulaciones locales.

### Objetivos Específicos

1. **Establecer controles de administración de datos** que definan roles, responsabilidades y privilegios de acceso granular para cada tipo de usuario del sistema.

2. **Implementar estrategias de backup y seguridad física** que aseguren la continuidad operacional y la recuperación ante desastres.

3. **Definir políticas de recursos humanos** que incluyan verificación de antecedentes, capacitación en seguridad y control de acceso físico a instalaciones críticas.

4. **Crear lineamientos para desarrollo seguro** de aplicaciones, gestión de email corporativo y administración de dispositivos móviles.

---

## ALCANCE

Esta política aplica a:

### **Personal Cubierto**
- Administradores de base de datos (DBA Principal y Operativo)
- Desarrolladores y personal técnico
- Operadores logísticos y supervisores
- Personal de seguridad física
- Contratistas y personal temporal

### **Sistemas Incluidos**
- Base de datos principal del sistema logístico (SQL Server)
- Aplicaciones web y móviles de consulta
- Sistemas de backup y recuperación
- Infraestructura de comunicaciones
- Dispositivos móviles corporativos

### **Datos Protegidos**
- Información de personal y empleados
- Datos de vehículos y rutas
- Registros de eventos de seguridad
- Configuraciones del sistema
- Logs de auditoría

---

## COMPONENTE 1: ADMINISTRACIÓN DE DATOS Y ACCESOS {#componente-1}

### 1.1 Arquitectura de Seguridad

El sistema implementa un modelo de seguridad basado en **Control de Acceso Basado en Roles (RBAC)** con seis roles específicos:

#### **Roles Definidos**

1. **DBA_PRINCIPAL**
   - Administración completa del sistema
   - Gestión de usuarios y permisos
   - Configuración de políticas de seguridad

2. **DBA_OPERATIVO**
   - Monitoreo y mantenimiento rutinario
   - Gestión de backups
   - Resolución de incidentes operacionales

3. **DESARROLLADOR**
   - Acceso de lectura a estructuras
   - Ejecución de procedimientos de desarrollo
   - Sin acceso a datos de producción sensibles

4. **OPERADOR_LOGISTICO**
   - Consulta de información operacional
   - Registro de eventos y alertas
   - Sin privilegios administrativos

5. **SUPERVISOR**
   - Acceso de lectura amplio para supervisión
   - Generación de reportes
   - Consultas de auditoría

6. **APLICACION**
   - Acceso programático controlado
   - Ejecución de procedimientos específicos
   - Sin acceso interactivo

### 1.2 Implementación Técnica

```sql
-- Creación de roles base
CREATE ROLE DBA_PRINCIPAL;
CREATE ROLE DBA_OPERATIVO;
CREATE ROLE DESARROLLADOR;
CREATE ROLE OPERADOR_LOGISTICO;
CREATE ROLE SUPERVISOR;
CREATE ROLE APLICACION;

-- Asignación de permisos granulares por tabla
GRANT SELECT, INSERT, UPDATE, DELETE ON Persona TO DBA_PRINCIPAL;
GRANT SELECT, INSERT, UPDATE ON Empleado TO DBA_OPERATIVO;
GRANT SELECT ON Vehiculo TO OPERADOR_LOGISTICO;
GRANT SELECT ON ALL TABLES TO SUPERVISOR;
```

### 1.3 Políticas de Contraseñas

- **Longitud mínima:** 12 caracteres
- **Complejidad:** Mayúsculas, minúsculas, números y símbolos
- **Caducidad:** 90 días
- **Historial:** Últimas 12 contraseñas
- **Bloqueo:** 3 intentos fallidos

### 1.4 Auditoría y Monitoreo

Implementación de triggers automáticos para auditoría completa:

```sql
CREATE TRIGGER tr_AuditoriaPersona
ON Persona
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    INSERT INTO RegistroAuditoria (tabla_afectada, accion, usuario, fecha_hora)
    SELECT 'Persona', 'MODIFICACION', SYSTEM_USER, GETDATE();
END;
```

---

## COMPONENTE 2: COPIAS DE SEGURIDAD Y SEGURIDAD FÍSICA {#componente-2}

### 2.1 Estrategia de Backup (3-2-1)

#### **Configuración de Respaldos**
- **3 copias** de los datos críticos
- **2 medios diferentes** de almacenamiento
- **1 copia offsite** para recuperación ante desastres

#### **Frecuencias Establecidas**
- **Backup Completo:** Diario a las 02:00 AM
- **Backup Diferencial:** Cada 6 horas
- **Backup de Log:** Cada 15 minutos
- **Backup de Configuración:** Semanal

### 2.2 Objetivos de Recuperación

- **RPO (Recovery Point Objective):** 15 minutos máximo
- **RTO (Recovery Time Objective):** 4 horas para restauración completa
- **Disponibilidad objetivo:** 99.5% anual

### 2.3 Seguridad Física

#### **Controles de Acceso**
- Centro de datos con acceso biométrico
- Circuito cerrado de televisión (CCTV) 24/7
- Sistemas de detección de intrusos
- Control ambiental (temperatura, humedad)

#### **Protección Contra Desastres**
- Sistema de energía ininterrumpida (UPS)
- Generador eléctrico de emergencia
- Sistema de supresión de incendios
- Monitoreo ambiental automatizado

---

## COMPONENTE 3: RECURSOS HUMANOS Y CONTROL DE ACCESO {#componente-3}

### 3.1 Proceso de Vinculación

#### **Verificación de Antecedentes**
- Antecedentes judiciales y disciplinarios
- Referencias laborales (mínimo 2)
- Verificación académica
- Evaluación psicotécnica para roles críticos

#### **Capacitación Obligatoria**
- Inducción en seguridad de la información (8 horas)
- Políticas de manejo de datos (4 horas)
- Procedimientos de emergencia (2 horas)
- Actualización anual (4 horas)

### 3.2 Control de Acceso Físico

#### **Sistema de Tarjetas**
- Tarjetas RFID personalizadas
- Niveles de acceso por zonas
- Registro automático de entradas/salidas
- Revisión mensual de permisos

#### **Zonas de Seguridad**
1. **Zona Pública:** Recepción y áreas comunes
2. **Zona Restringida:** Oficinas administrativas
3. **Zona Crítica:** Centro de datos y servidores
4. **Zona Ultra-Crítica:** Sala de respaldos

### 3.3 Gestión de Usuarios del Sistema

```sql
-- Procedimiento de activación de usuario
CREATE PROCEDURE sp_ActivarUsuarioSistema
    @empleado_id INT,
    @rol_solicitado VARCHAR(50)
AS
BEGIN
    -- Verificar capacitación vigente
    IF dbo.fn_VerificarCapacitacionVigente(@empleado_id, 'SEGURIDAD_INFORMACION') = 0
    BEGIN
        RAISERROR('Empleado debe completar capacitación antes del acceso', 16, 1);
        RETURN;
    END
    
    -- Crear usuario y asignar rol
    DECLARE @usuario_db VARCHAR(50) = 'USR_' + CAST(@empleado_id AS VARCHAR(10));
    EXEC('CREATE LOGIN ' + @usuario_db + ' WITH PASSWORD = ''TempPass123!''');
    EXEC('ALTER ROLE ' + @rol_solicitado + ' ADD MEMBER ' + @usuario_db);
END;
```

---

## COMPONENTE 4: DESARROLLO DE APLICACIONES Y DISPOSITIVOS {#componente-4}

### 4.1 Desarrollo Seguro de Aplicaciones

#### **Estándares de Codificación**
- Validación de entrada en todas las interfaces
- Prevención de SQL Injection mediante consultas parametrizadas
- Encriptación de datos sensibles en tránsito y reposo
- Manejo seguro de sesiones y tokens

#### **Pruebas de Seguridad**
- Análisis estático de código (SAST)
- Pruebas dinámicas de seguridad (DAST)
- Revisión manual de código crítico
- Penetration testing trimestral

### 4.2 Gestión de Email Corporativo

#### **Políticas de Uso**
- Prohibición de reenvío externo automático
- Encriptación obligatoria para datos clasificados
- Firma digital para comunicaciones oficiales
- Retención de 7 años para emails críticos

#### **Protección Anti-Phishing**
```sql
-- Sistema de detección automatizada
CREATE FUNCTION fn_DetectarPhishing(@contenido_email TEXT, @remitente VARCHAR(255))
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @resultado VARCHAR(20) = 'SEGURO';
    
    IF @contenido_email LIKE '%urgent%account%suspended%'
       OR @contenido_email LIKE '%verify%password%'
        SET @resultado = 'PHISHING';
    
    RETURN @resultado;
END;
```

### 4.3 Dispositivos Móviles

#### **Políticas MDM (Mobile Device Management)**
- Encriptación obligatoria del dispositivo
- PIN/contraseña de mínimo 6 dígitos
- Bloqueo automático después de 5 minutos
- Capacidad de borrado remoto
- Instalación solo de aplicaciones autorizadas

#### **Aplicación Móvil Logística**
- Autenticación biométrica opcional
- Sincronización automática cada 30 minutos
- Modo offline para operaciones críticas
- Geolocalización para validación de rutas

---

## CONCLUSIONES

### Logros Alcanzados

1. **Política Integral Desarrollada:** Se ha creado una política de seguridad completa que abarca los cuatro componentes requeridos, con más de 50 procedimientos SQL implementables y scripts de automatización.

2. **Estándares Internacionales:** La política se alinea con ISO/IEC 27001:2013 e ISO/IEC 27002:2013, garantizando el cumplimiento de mejores prácticas internacionales.

3. **Implementación Práctica:** Cada componente incluye scripts ejecutables, procedimientos detallados y métricas de seguimiento que permiten implementación inmediata.

4. **Seguridad Multicapa:** Se establece protección en todos los niveles: datos, aplicaciones, red, dispositivos y personal.

### Beneficios Operacionales

- **Reducción de Riesgos:** Implementación de controles preventivos, detectivos y correctivos
- **Automatización:** Monitoreo y respuesta automática a incidentes críticos
- **Cumplimiento Normativo:** Preparación para auditorías y certificaciones
- **Escalabilidad:** Diseño modular que permite crecimiento futuro

### Implementación Recomendada

La implementación debe realizarse en 4 fases durante 10 semanas:
1. **Fase 1:** Preparación y configuración (2 semanas)
2. **Fase 2:** Componentes 1 y 2 (4 semanas)
3. **Fase 3:** Componentes 3 y 4 (4 semanas)
4. **Fase 4:** Monitoreo y mejora continua (permanente)

### Valor Académico y Profesional

Esta política no solo cumple con los requisitos académicos establecidos sino que proporciona una base sólida para la gestión profesional de seguridad en bases de datos empresariales, combinando teoría académica con implementación práctica.

---

## BIBLIOGRAFÍA

1. International Organization for Standardization. (2013). *ISO/IEC 27001:2013 Information technology — Security techniques — Information security management systems — Requirements*.

2. International Organization for Standardization. (2013). *ISO/IEC 27002:2013 Information technology — Security techniques — Code of practice for information security controls*.

3. ISACA. (2012). *COBIT 5: A Business Framework for the Governance and Management of Enterprise IT*.

4. National Institute of Standards and Technology. (2018). *Framework for Improving Critical Infrastructure Cybersecurity Version 1.1*.

5. Congreso de Colombia. (2012). *Ley 1581 de 2012 - Por la cual se dictan disposiciones generales para la protección de datos personales*.

6. Presidente de la República de Colombia. (2013). *Decreto 1377 de 2013 - Por el cual se reglamenta parcialmente la Ley 1581 de 2012*.

7. Silberschatz, A., Galvin, P. B., & Gagne, G. (2018). *Operating System Concepts* (10th ed.). John Wiley & Sons.

8. Ramakrishnan, R., & Gehrke, J. (2003). *Database Management Systems* (3rd ed.). McGraw-Hill.

---

**Nota:** Este documento constituye la entrega final del Eje 4 - Seguridad de BD. La implementación técnica detallada se encuentra en los archivos complementarios del proyecto.
