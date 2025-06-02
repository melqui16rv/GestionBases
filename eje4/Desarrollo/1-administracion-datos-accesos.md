# POLÍTICA DE ADMINISTRACIÓN DE DATOS, ACCESOS Y PRIVILEGIOS
## Sistema de Seguridad Logística

---

## TABLA DE CONTENIDO

1. [Objetivos](#objetivos)
2. [Alcance](#alcance)
3. [Definiciones](#definiciones)
4. [Administración de Datos](#administración-de-datos)
5. [Gestión de Usuarios y Roles](#gestión-de-usuarios-y-roles)
6. [Control de Accesos y Privilegios](#control-de-accesos-y-privilegios)
7. [Roles y Responsabilidades](#roles-y-responsabilidades)
8. [Procedimientos de Auditoría](#procedimientos-de-auditoría)
9. [Políticas de Contraseñas](#políticas-de-contraseñas)
10. [Monitoreo y Logging](#monitoreo-y-logging)
11. [Gestión de Excepciones](#gestión-de-excepciones)
12. [Procedimientos Operativos](#procedimientos-operativos)

---

## OBJETIVOS

### Objetivo General
Establecer los lineamientos para la administración segura de datos, gestión de accesos, asignación de privilegios y definición clara de roles y responsabilidades en el Sistema de Seguridad Logística.

### Objetivos Específicos
1. Definir la estructura de roles y permisos para el acceso a la base de datos `seguridad_logistica`
2. Establecer procedimientos para la creación, modificación y eliminación de usuarios
3. Implementar controles de acceso basados en el principio de menor privilegio
4. Definir responsabilidades específicas para cada rol dentro del sistema
5. Establecer mecanismos de auditoría y monitoreo de accesos

## ALCANCE

Esta política aplica a:
- Todos los usuarios que interactúan con la base de datos `seguridad_logistica`
- Administradores de base de datos (DBA)
- Desarrolladores de aplicaciones
- Personal operativo del sistema logístico
- Sistemas automatizados que acceden a la base de datos

## DEFINICIONES

| Término | Definición |
|---------|------------|
| **DBA** | Administrador de Base de Datos responsable de la gestión técnica del sistema |
| **Usuario Final** | Personal operativo que utiliza las aplicaciones del sistema |
| **Cuenta de Servicio** | Cuenta técnica utilizada por aplicaciones para conectarse a la BD |
| **Privilegio Mínimo** | Principio de otorgar únicamente los permisos necesarios para realizar una función |
| **Segregación de Funciones** | Separación de responsabilidades para prevenir conflictos de interés |

## ADMINISTRACIÓN DE DATOS

### 4.1 Clasificación de Datos

Los datos del sistema se clasifican según su nivel de sensibilidad:

#### **DATOS CRÍTICOS**
- Contraseñas encriptadas (tabla `Persona.Contrseña`)
- Información de rutas de alto riesgo (tabla `Ruta` con `nivelRiesgo = 'Alto'`)
- Eventos de seguridad clasificados (tabla `Evento`)
- Historial de accesos (tabla `HistorialAcceso`)

#### **DATOS SENSIBLES**
- Información personal de empleados (tabla `Persona`)
- Datos de vehículos y placas (tabla `Vehiculo`)
- Información de rutas estándar (tabla `Ruta`)
- Registros de alertas (tabla `Alerta`)

#### **DATOS INTERNOS**
- Catálogos de cargos (tabla `Cargo`)
- Estados del sistema (tabla `Estado`)
- Tipos de acceso (tabla `TipoAcceso`)
- Configuraciones de roles (tabla `Rol`)

### 4.2 Integridad de Datos

#### **Controles de Integridad Referencial**
```sql
-- Ejemplo de verificación de integridad
-- Validar que todos los empleados tengan una persona asociada
SELECT e.id_empleado, e.id_persona 
FROM Empleado e 
LEFT JOIN Persona p ON e.id_persona = p.Cedula 
WHERE p.Cedula IS NULL;
```

#### **Validaciones de Negocio**
- Las placas de vehículos deben seguir el formato estándar colombiano
- Los niveles de riesgo deben ser: 'Bajo', 'Medio', 'Alto'
- Las fechas de eventos no pueden ser futuras
- Los empleados deben tener un cargo asignado

### 4.3 Gestión de Versiones y Cambios

#### **Control de Cambios en Estructura**
- Todos los cambios DDL requieren aprobación del DBA principal
- Implementación de versionado para scripts de migración
- Documentación obligatoria de todos los cambios estructurales

#### **Gestión de Datos Maestros**
- Los catálogos (`Cargo`, `Estado`, `TipoAcceso`) requieren aprobación especial
- Implementación de procedimientos para actualización masiva de datos
- Control de sincronización entre ambientes

## GESTIÓN DE USUARIOS Y ROLES

### 5.1 Estructura de Roles del Sistema

#### **ROL: DBA_PRINCIPAL**
```sql
-- Privilegios completos sobre la base de datos
GRANT ALL PRIVILEGES ON seguridad_logistica.* TO 'dba_principal'@'%';
GRANT CREATE USER ON *.* TO 'dba_principal'@'%';
GRANT RELOAD, PROCESS, SHOW DATABASES ON *.* TO 'dba_principal'@'%';
```

**Responsabilidades:**
- Administración completa del servidor de base de datos
- Creación y gestión de usuarios
- Implementación de políticas de seguridad
- Supervisión del rendimiento del sistema

#### **ROL: DBA_OPERATIVO**
```sql
-- Privilegios operativos sin gestión de usuarios
GRANT SELECT, INSERT, UPDATE, DELETE ON seguridad_logistica.* TO 'dba_operativo'@'%';
GRANT CREATE, ALTER, DROP ON seguridad_logistica.* TO 'dba_operativo'@'%';
GRANT LOCK TABLES ON seguridad_logistica.* TO 'dba_operativo'@'%';
```

**Responsabilidades:**
- Mantenimiento rutinario de la base de datos
- Optimización de consultas
- Generación de reportes operativos
- Soporte técnico a desarrolladores

#### **ROL: DESARROLLADOR**
```sql
-- Acceso de desarrollo y testing
GRANT SELECT, INSERT, UPDATE, DELETE ON seguridad_logistica.* TO 'desarrollador'@'localhost';
GRANT CREATE, ALTER, DROP ON seguridad_logistica.* TO 'desarrollador'@'localhost';
-- Restricción: No acceso a datos de producción sensibles
REVOKE SELECT ON seguridad_logistica.Persona TO 'desarrollador'@'localhost';
REVOKE SELECT ON seguridad_logistica.HistorialAcceso TO 'desarrollador'@'localhost';
```

**Responsabilidades:**
- Desarrollo de aplicaciones que consumen la BD
- Creación de procedimientos almacenados
- Testing y validación de funcionalidades
- Documentación técnica

#### **ROL: OPERADOR_LOGISTICO**
```sql
-- Vista específica para operaciones logísticas
CREATE VIEW vista_operaciones AS
SELECT 
    r.id_ruta, r.Origen, r.Destino, r.nivelRiesgo,
    v.tipo, v.placa, v.color,
    p.Nombre, p.Apellido, p.Telefono,
    e.Tipo as TipoEvento, e.Nombre as NombreEvento
FROM Ruta r
JOIN Vehiculo v ON r.id_vehiculo = v.id_vehiculo
JOIN Empleado em ON r.id_empleado = em.id_empleado
JOIN Persona p ON em.id_persona = p.Cedula
LEFT JOIN Evento e ON e.id_ruta = r.id_ruta;

GRANT SELECT ON seguridad_logistica.vista_operaciones TO 'operador_logistico'@'%';
GRANT INSERT, UPDATE ON seguridad_logistica.Evento TO 'operador_logistico'@'%';
GRANT SELECT ON seguridad_logistica.Alerta TO 'operador_logistico'@'%';
```

**Responsabilidades:**
- Registro de eventos operativos
- Consulta de información de rutas y vehículos
- Generación de alertas manuales
- Seguimiento de incidentes

#### **ROL: SUPERVISOR**
```sql
-- Acceso amplio de supervisión sin modificación de estructura
GRANT SELECT ON seguridad_logistica.* TO 'supervisor'@'%';
GRANT INSERT, UPDATE ON seguridad_logistica.Evento TO 'supervisor'@'%';
GRANT INSERT, UPDATE ON seguridad_logistica.Alerta TO 'supervisor'@'%';
-- Acceso restringido a información personal sensible
CREATE VIEW vista_supervisor_empleados AS
SELECT id_empleado, Nombre, Apellido, id_cargo, id_estado
FROM Empleado e
JOIN Persona p ON e.id_persona = p.Cedula;

GRANT SELECT ON seguridad_logistica.vista_supervisor_empleados TO 'supervisor'@'%';
```

**Responsabilidades:**
- Supervisión de operaciones logísticas
- Generación de reportes gerenciales
- Análisis de eventos y alertas
- Coordinación de respuestas a incidentes

#### **ROL: APLICACION**
```sql
-- Cuenta de servicio para aplicaciones
GRANT SELECT, INSERT, UPDATE ON seguridad_logistica.* TO 'app_service'@'app_server_ip';
-- Restricciones específicas
REVOKE DELETE ON seguridad_logistica.* FROM 'app_service'@'app_server_ip';
REVOKE ALTER, DROP, CREATE ON seguridad_logistica.* FROM 'app_service'@'app_server_ip';
```

**Responsabilidades:**
- Conexión automatizada de aplicaciones
- Procesamiento de transacciones de negocio
- Ejecución de procedimientos almacenados
- Generación automática de alertas

### 5.2 Gestión del Ciclo de Vida de Usuarios

#### **Proceso de Creación de Usuarios**

1. **Solicitud Formal**
   - Formulario de solicitud completado
   - Aprobación del supervisor directo
   - Validación por parte del área de seguridad

2. **Implementación Técnica**
```sql
-- Plantilla para creación de usuarios
DELIMITER //
CREATE PROCEDURE sp_crear_usuario(
    IN p_username VARCHAR(50),
    IN p_host VARCHAR(255),
    IN p_password VARCHAR(255),
    IN p_rol ENUM('DBA_PRINCIPAL','DBA_OPERATIVO','DESARROLLADOR','OPERADOR_LOGISTICO','SUPERVISOR','APLICACION')
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Crear usuario
    SET @sql = CONCAT('CREATE USER ''', p_username, '''@''', p_host, ''' IDENTIFIED BY ''', p_password, '''');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    -- Asignar rol según el tipo
    CASE p_rol
        WHEN 'DBA_PRINCIPAL' THEN
            SET @sql = CONCAT('GRANT ALL PRIVILEGES ON seguridad_logistica.* TO ''', p_username, '''@''', p_host, '''');
        WHEN 'OPERADOR_LOGISTICO' THEN
            SET @sql = CONCAT('GRANT SELECT ON seguridad_logistica.vista_operaciones TO ''', p_username, '''@''', p_host, '''');
        -- Otros casos...
    END CASE;
    
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    -- Registrar en tabla de auditoría
    INSERT INTO HistorialAcceso (fecha, ip, id_tipoAcceso, id_persona, id_estado, id_tipoAccion)
    VALUES (NOW(), CONNECTION_ID(), 1, 'SYSTEM', 1, 1);
    
    COMMIT;
END //
DELIMITER ;
```

3. **Validación y Activación**
   - Prueba de conectividad
   - Verificación de permisos asignados
   - Documentación en registro de usuarios
   - Notificación al usuario

#### **Proceso de Modificación de Usuarios**

1. **Identificación de Cambios Necesarios**
   - Cambio de rol o responsabilidades
   - Transferencia de área
   - Necesidades adicionales de acceso

2. **Implementación de Cambios**
```sql
-- Procedure para modificar permisos
DELIMITER //
CREATE PROCEDURE sp_modificar_permisos_usuario(
    IN p_username VARCHAR(50),
    IN p_host VARCHAR(255),
    IN p_nuevo_rol ENUM('DBA_PRINCIPAL','DBA_OPERATIVO','DESARROLLADOR','OPERADOR_LOGISTICO','SUPERVISOR','APLICACION'),
    IN p_accion ENUM('AGREGAR','REMOVER','REEMPLAZAR')
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Registrar cambio en auditoría
    INSERT INTO HistorialAcceso (fecha, ip, id_tipoAcceso, id_persona, id_estado, id_tipoAccion)
    VALUES (NOW(), CONNECTION_ID(), 2, p_username, 1, 2);
    
    -- Aplicar cambios según la acción
    IF p_accion = 'REEMPLAZAR' THEN
        SET @sql = CONCAT('REVOKE ALL PRIVILEGES ON seguridad_logistica.* FROM ''', p_username, '''@''', p_host, '''');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
    
    -- Asignar nuevos permisos según el rol...
    
    COMMIT;
END //
DELIMITER ;
```

#### **Proceso de Desactivación de Usuarios**

1. **Desactivación Inmediata**
```sql
-- Procedure para desactivar usuario
DELIMITER //
CREATE PROCEDURE sp_desactivar_usuario(
    IN p_username VARCHAR(50),
    IN p_host VARCHAR(255),
    IN p_motivo VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Bloquear cuenta
    SET @sql = CONCAT('ALTER USER ''', p_username, '''@''', p_host, ''' ACCOUNT LOCK');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    -- Registrar desactivación
    INSERT INTO HistorialAcceso (fecha, ip, id_tipoAcceso, id_persona, id_estado, id_tipoAccion)
    VALUES (NOW(), CONNECTION_ID(), 3, p_username, 2, 3);
    
    COMMIT;
END //
DELIMITER ;
```

2. **Proceso de Eliminación (después de 90 días)**
```sql
-- Eliminar usuario después del período de retención
DROP USER 'username'@'host';
```

## CONTROL DE ACCESOS Y PRIVILEGIOS

### 6.1 Principio de Menor Privilegio

#### **Implementación por Niveles**

**Nivel 1: Acceso de Solo Lectura**
- Personal de consulta y reportes
- Usuarios en período de entrenamiento
- Cuentas de auditoría externa

**Nivel 2: Acceso Operativo**
- Personal operativo del sistema logístico
- Supervisores de área
- Usuarios de aplicaciones de negocio

**Nivel 3: Acceso Administrativo**
- Desarrolladores con acceso a testing
- DBA operativos
- Personal de soporte técnico

**Nivel 4: Acceso Completo**
- DBA principales
- Administradores de sistema
- Personal de seguridad informática

### 6.2 Control de Acceso Basado en Tiempo

#### **Restricciones Horarias**
```sql
-- Función para validar horario de acceso
DELIMITER //
CREATE FUNCTION f_validar_horario_acceso(p_rol VARCHAR(50))
RETURNS BOOLEAN
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE v_hora_actual TIME;
    DECLARE v_dia_semana INT;
    DECLARE v_permitido BOOLEAN DEFAULT FALSE;
    
    SET v_hora_actual = TIME(NOW());
    SET v_dia_semana = DAYOFWEEK(NOW());
    
    CASE p_rol
        WHEN 'OPERADOR_LOGISTICO' THEN
            -- Acceso 24/7 para operadores
            SET v_permitido = TRUE;
        WHEN 'SUPERVISOR' THEN
            -- Lunes a Viernes 6:00 - 22:00
            IF v_dia_semana BETWEEN 2 AND 6 AND v_hora_actual BETWEEN '06:00:00' AND '22:00:00' THEN
                SET v_permitido = TRUE;
            END IF;
        WHEN 'DESARROLLADOR' THEN
            -- Lunes a Viernes 8:00 - 18:00
            IF v_dia_semana BETWEEN 2 AND 6 AND v_hora_actual BETWEEN '08:00:00' AND '18:00:00' THEN
                SET v_permitido = TRUE;
            END IF;
        ELSE
            -- DBA y otros roles administrativos: acceso 24/7
            SET v_permitido = TRUE;
    END CASE;
    
    RETURN v_permitido;
END //
DELIMITER ;
```

### 6.3 Control de Acceso por Ubicación

#### **Restricciones Geográficas**
```sql
-- Tabla para IPs autorizadas por rol
CREATE TABLE ips_autorizadas (
    id_ip INT AUTO_INCREMENT PRIMARY KEY,
    direccion_ip VARCHAR(45) NOT NULL,
    mascara_red VARCHAR(45),
    id_rol INT NOT NULL,
    descripcion VARCHAR(255),
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_rol) REFERENCES Rol(id_rol)
);

-- Trigger para validar IP en conexión
DELIMITER //
CREATE TRIGGER tr_validar_ip_conexion
BEFORE INSERT ON HistorialAcceso
FOR EACH ROW
BEGIN
    DECLARE v_ip_autorizada INT DEFAULT 0;
    
    SELECT COUNT(*) INTO v_ip_autorizada
    FROM ips_autorizadas ia
    JOIN Rol r ON ia.id_rol = r.id_rol
    WHERE ia.direccion_ip = NEW.ip 
    AND r.id_persona = NEW.id_persona
    AND ia.activo = TRUE;
    
    IF v_ip_autorizada = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Acceso denegado: IP no autorizada';
    END IF;
END //
DELIMITER ;
```

## ROLES Y RESPONSABILIDADES

### 7.1 Matriz de Responsabilidades

| Rol | Administración Usuarios | Gestión Datos | Monitoreo | Auditoría | Backup |
|-----|------------------------|---------------|-----------|-----------|---------|
| **DBA Principal** | Responsable | Responsable | Supervisa | Responsable | Responsable |
| **DBA Operativo** | Ejecuta | Responsable | Ejecuta | Asiste | Ejecuta |
| **Desarrollador** | - | Consulta | - | - | - |
| **Supervisor** | Solicita | Consulta | Supervisa | Consulta | - |
| **Operador** | - | Actualiza | Reporta | - | - |

### 7.2 Responsabilidades Específicas por Rol

#### **DBA PRINCIPAL**

**Responsabilidades Diarias:**
- Monitoreo del estado del servidor de base de datos
- Revisión de logs de seguridad y acceso
- Validación de backups automáticos
- Respuesta a alertas críticas del sistema

**Responsabilidades Semanales:**
- Análisis de rendimiento del sistema
- Revisión de usuarios activos y permisos
- Validación de integridad de datos
- Generación de reportes de seguridad

**Responsabilidades Mensuales:**
- Auditoría completa de accesos
- Revisión y actualización de políticas
- Análisis de tendencias de uso
- Planificación de mantenimientos

#### **DBA OPERATIVO**

**Responsabilidades Diarias:**
- Ejecución de procedimientos de mantenimiento
- Monitoreo de rendimiento de consultas
- Soporte a desarrolladores y usuarios
- Gestión de incidentes operativos

**Responsabilidades Semanales:**
- Optimización de consultas problemáticas
- Actualización de estadísticas de tablas
- Validación de espacio en disco
- Coordinación con equipo de infraestructura

#### **SUPERVISOR**

**Responsabilidades Diarias:**
- Supervisión de operaciones logísticas
- Validación de eventos registrados
- Coordinación de respuestas a alertas
- Generación de reportes operativos

**Responsabilidades Semanales:**
- Análisis de patrones de eventos
- Revisión de eficiencia operativa
- Coordinación con equipos de campo
- Planificación de rutas optimizadas

## PROCEDIMIENTOS DE AUDITORÍA

### 8.1 Auditoría de Accesos

#### **Registro Automático de Accesos**
```sql
-- Trigger para registrar todos los accesos
DELIMITER //
CREATE TRIGGER tr_registrar_acceso
AFTER INSERT ON HistorialAcceso
FOR EACH ROW
BEGIN
    -- Logging adicional para accesos sensibles
    IF NEW.id_tipoAcceso IN (1, 2) THEN -- Accesos administrativos
        INSERT INTO log_accesos_criticos 
        (fecha, usuario, ip, accion, tabla_afectada, descripcion)
        VALUES 
        (NEW.fecha, NEW.id_persona, NEW.ip, NEW.id_tipoAccion, 
         'ACCESO_ADMINISTRATIVO', 'Acceso con privilegios elevados');
    END IF;
END //
DELIMITER ;
```

#### **Consultas de Auditoría Regulares**
```sql
-- Reporte de accesos por usuario en las últimas 24 horas
SELECT 
    ha.id_persona,
    p.Nombre,
    p.Apellido,
    COUNT(*) as total_accesos,
    MIN(ha.fecha) as primer_acceso,
    MAX(ha.fecha) as ultimo_acceso,
    GROUP_CONCAT(DISTINCT ha.ip) as ips_utilizadas
FROM HistorialAcceso ha
JOIN Persona p ON ha.id_persona = p.Cedula
WHERE ha.fecha >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
GROUP BY ha.id_persona, p.Nombre, p.Apellido
ORDER BY total_accesos DESC;

-- Reporte de accesos fuera de horario
SELECT 
    ha.id_persona,
    p.Nombre,
    ha.fecha,
    ha.ip,
    ta.Nombre as tipo_acceso
FROM HistorialAcceso ha
JOIN Persona p ON ha.id_persona = p.Cedula
JOIN TipoAcceso ta ON ha.id_tipoAcceso = ta.id_tipoAcceso
WHERE (TIME(ha.fecha) < '06:00:00' OR TIME(ha.fecha) > '22:00:00')
AND DAYOFWEEK(ha.fecha) BETWEEN 2 AND 6
ORDER BY ha.fecha DESC;
```

### 8.2 Auditoría de Datos

#### **Implementación de Triggers de Auditoría**
```sql
-- Tabla de auditoría para cambios en datos sensibles
CREATE TABLE auditoria_cambios (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    tabla_afectada VARCHAR(50) NOT NULL,
    operacion ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    id_registro VARCHAR(50) NOT NULL,
    usuario VARCHAR(50) NOT NULL,
    fecha_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valores_anteriores JSON,
    valores_nuevos JSON,
    ip_origen VARCHAR(45)
);

-- Trigger de auditoría para tabla Persona
DELIMITER //
CREATE TRIGGER tr_auditoria_persona_update
AFTER UPDATE ON Persona
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_cambios 
    (tabla_afectada, operacion, id_registro, usuario, valores_anteriores, valores_nuevos, ip_origen)
    VALUES 
    ('Persona', 'UPDATE', NEW.Cedula, USER(),
     JSON_OBJECT('Nombre', OLD.Nombre, 'Apellido', OLD.Apellido, 'Telefono', OLD.Telefono, 'Correo', OLD.Correo),
     JSON_OBJECT('Nombre', NEW.Nombre, 'Apellido', NEW.Apellido, 'Telefono', NEW.Telefono, 'Correo', NEW.Correo),
     CONNECTION_ID());
END //
DELIMITER ;
```

## POLÍTICAS DE CONTRASEÑAS

### 9.1 Requisitos de Complejidad

#### **Políticas para Usuarios del Sistema**
- **Longitud mínima:** 12 caracteres
- **Composición:** Al menos 3 de los siguientes tipos:
  - Letras mayúsculas (A-Z)
  - Letras minúsculas (a-z)
  - Números (0-9)
  - Caracteres especiales (!@#$%^&*()_+-=[]{}|;:,.<>?)
- **Restricciones:**
  - No debe contener el nombre de usuario
  - No debe contener información personal
  - No debe ser una contraseña utilizada en los últimos 12 cambios

#### **Implementación de Validación**
```sql
-- Función para validar complejidad de contraseña
DELIMITER //
CREATE FUNCTION f_validar_contraseña(p_password VARCHAR(255), p_username VARCHAR(50))
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_valida BOOLEAN DEFAULT FALSE;
    DECLARE v_longitud INT;
    DECLARE v_tiene_mayuscula BOOLEAN DEFAULT FALSE;
    DECLARE v_tiene_minuscula BOOLEAN DEFAULT FALSE;
    DECLARE v_tiene_numero BOOLEAN DEFAULT FALSE;
    DECLARE v_tiene_especial BOOLEAN DEFAULT FALSE;
    DECLARE v_tipos_cumplidos INT DEFAULT 0;
    
    SET v_longitud = LENGTH(p_password);
    
    -- Validar longitud mínima
    IF v_longitud < 12 THEN
        RETURN FALSE;
    END IF;
    
    -- Validar que no contenga el username
    IF LOCATE(LOWER(p_username), LOWER(p_password)) > 0 THEN
        RETURN FALSE;
    END IF;
    
    -- Validar tipos de caracteres
    IF p_password REGEXP '[A-Z]' THEN 
        SET v_tiene_mayuscula = TRUE;
        SET v_tipos_cumplidos = v_tipos_cumplidos + 1;
    END IF;
    
    IF p_password REGEXP '[a-z]' THEN 
        SET v_tiene_minuscula = TRUE;
        SET v_tipos_cumplidos = v_tipos_cumplidos + 1;
    END IF;
    
    IF p_password REGEXP '[0-9]' THEN 
        SET v_tiene_numero = TRUE;
        SET v_tipos_cumplidos = v_tipos_cumplidos + 1;
    END IF;
    
    IF p_password REGEXP '[^A-Za-z0-9]' THEN 
        SET v_tiene_especial = TRUE;
        SET v_tipos_cumplidos = v_tipos_cumplidos + 1;
    END IF;
    
    -- Requiere al menos 3 tipos diferentes
    IF v_tipos_cumplidos >= 3 THEN
        SET v_valida = TRUE;
    END IF;
    
    RETURN v_valida;
END //
DELIMITER ;
```

### 9.2 Gestión de Contraseñas

#### **Frecuencia de Cambio**
- **Usuarios regulares:** Cada 90 días
- **Usuarios administrativos:** Cada 60 días
- **Cuentas de servicio:** Cada 180 días
- **Usuarios con acceso crítico:** Cada 45 días

#### **Proceso de Cambio de Contraseñas**
```sql
-- Procedure para cambio de contraseña con validaciones
DELIMITER //
CREATE PROCEDURE sp_cambiar_contraseña(
    IN p_username VARCHAR(50),
    IN p_host VARCHAR(255),
    IN p_contraseña_actual VARCHAR(255),
    IN p_contraseña_nueva VARCHAR(255)
)
BEGIN
    DECLARE v_contraseña_valida BOOLEAN;
    DECLARE v_usuario_existe INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Validar que el usuario existe
    SELECT COUNT(*) INTO v_usuario_existe
    FROM mysql.user 
    WHERE User = p_username AND Host = p_host;
    
    IF v_usuario_existe = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Usuario no existe';
    END IF;
    
    -- Validar complejidad de nueva contraseña
    SET v_contraseña_valida = f_validar_contraseña(p_contraseña_nueva, p_username);
    
    IF NOT v_contraseña_valida THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Contraseña no cumple con políticas de seguridad';
    END IF;
    
    -- Cambiar contraseña
    SET @sql = CONCAT('ALTER USER ''', p_username, '''@''', p_host, ''' IDENTIFIED BY ''', p_contraseña_nueva, '''');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    -- Registrar cambio en auditoría
    INSERT INTO HistorialAcceso (fecha, ip, id_tipoAcceso, id_persona, id_estado, id_tipoAccion)
    VALUES (NOW(), CONNECTION_ID(), 4, p_username, 1, 4);
    
    COMMIT;
END //
DELIMITER ;
```

## MONITOREO Y LOGGING

### 10.1 Eventos a Monitorear

#### **Eventos Críticos (Alerta Inmediata)**
- Intentos fallidos de acceso repetidos (>5 en 15 minutos)
- Accesos fuera del horario laboral para roles restringidos
- Modificaciones en tablas de configuración de seguridad
- Operaciones DDL no programadas
- Accesos desde IPs no autorizadas

#### **Eventos de Interés (Revisión Diaria)**
- Accesos exitosos de usuarios administrativos
- Cambios en datos sensibles
- Ejecución de procedimientos almacenados críticos
- Consultas que afectan grandes volúmenes de datos

#### **Implementación de Monitoreo Automático**
```sql
-- Vista para monitoreo en tiempo real
CREATE VIEW v_monitoreo_accesos AS
SELECT 
    ha.fecha,
    p.Nombre,
    p.Apellido,
    ta.Nombre as tipo_acceso,
    ha.ip,
    e.nombre as estado,
    tac.nombre as accion,
    CASE 
        WHEN TIME(ha.fecha) BETWEEN '22:00:00' AND '06:00:00' THEN 'FUERA_HORARIO'
        WHEN ha.ip NOT IN (SELECT direccion_ip FROM ips_autorizadas WHERE activo = TRUE) THEN 'IP_NO_AUTORIZADA'
        WHEN ha.id_estado = 2 THEN 'ACCESO_FALLIDO'
        ELSE 'NORMAL'
    END as clasificacion_riesgo
FROM HistorialAcceso ha
JOIN Persona p ON ha.id_persona = p.Cedula
JOIN TipoAcceso ta ON ha.id_tipoAcceso = ta.id_tipoAcceso
JOIN Estado e ON ha.id_estado = e.id_estado
JOIN tipoAccion tac ON ha.id_tipoAccion = tac.id_tipoAccion
WHERE ha.fecha >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
ORDER BY ha.fecha DESC;

-- Procedure para generar alertas automáticas
DELIMITER //
CREATE PROCEDURE sp_generar_alertas_seguridad()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_persona VARCHAR(10);
    DECLARE v_ip VARCHAR(45);
    DECLARE v_intentos INT;
    
    DECLARE cur_accesos_sospechosos CURSOR FOR
        SELECT id_persona, ip, COUNT(*) as intentos
        FROM HistorialAcceso 
        WHERE fecha >= DATE_SUB(NOW(), INTERVAL 15 MINUTE)
        AND id_estado = 2  -- Accesos fallidos
        GROUP BY id_persona, ip
        HAVING COUNT(*) >= 5;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur_accesos_sospechosos;
    
    read_loop: LOOP
        FETCH cur_accesos_sospechosos INTO v_persona, v_ip, v_intentos;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Generar alerta en el sistema
        INSERT INTO Alerta (id_empleado, id_evento, Fecha)
        SELECT em.id_empleado, 999, NOW()  -- 999 = Evento de seguridad
        FROM Empleado em 
        WHERE em.id_persona = v_persona;
        
        -- Opcional: Bloquear IP temporalmente
        -- Se podría implementar una tabla de IPs bloqueadas
        
    END LOOP;
    
    CLOSE cur_accesos_sospechosos;
END //
DELIMITER ;

-- Evento programado para ejecutar monitoreo cada 15 minutos
CREATE EVENT evt_monitoreo_seguridad
ON SCHEDULE EVERY 15 MINUTE
DO
    CALL sp_generar_alertas_seguridad();
```

### 10.2 Retención de Logs

#### **Políticas de Retención**
- **Logs de acceso:** 2 años
- **Logs de auditoría:** 5 años
- **Logs de transacciones:** 1 año
- **Logs de errores:** 6 meses

#### **Proceso de Archivado**
```sql
-- Procedure para archivar logs antiguos
DELIMITER //
CREATE PROCEDURE sp_archivar_logs()
BEGIN
    DECLARE v_fecha_corte_acceso DATE;
    DECLARE v_fecha_corte_auditoria DATE;
    
    SET v_fecha_corte_acceso = DATE_SUB(CURDATE(), INTERVAL 2 YEAR);
    SET v_fecha_corte_auditoria = DATE_SUB(CURDATE(), INTERVAL 5 YEAR);
    
    -- Crear tabla de archivo si no existe
    CREATE TABLE IF NOT EXISTS archivo_historial_acceso LIKE HistorialAcceso;
    
    -- Mover registros antiguos a archivo
    INSERT INTO archivo_historial_acceso 
    SELECT * FROM HistorialAcceso 
    WHERE DATE(fecha) < v_fecha_corte_acceso;
    
    -- Eliminar registros antiguos de tabla principal
    DELETE FROM HistorialAcceso 
    WHERE DATE(fecha) < v_fecha_corte_acceso;
    
    -- Repetir proceso para otras tablas de auditoría
    -- Similar para auditoria_cambios...
    
END //
DELIMITER ;
```

## GESTIÓN DE EXCEPCIONES

### 11.1 Accesos de Emergencia

#### **Procedimiento de Acceso de Emergencia**
```sql
-- Cuenta de emergencia con privilegios temporales
CREATE USER 'emergencia'@'%' IDENTIFIED BY 'password_complejo_temporal';

-- Procedure para activar acceso de emergencia
DELIMITER //
CREATE PROCEDURE sp_activar_acceso_emergencia(
    IN p_justificacion TEXT,
    IN p_duracion_horas INT DEFAULT 4
)
BEGIN
    DECLARE v_expiracion TIMESTAMP;
    
    SET v_expiracion = DATE_ADD(NOW(), INTERVAL p_duracion_horas HOUR);
    
    -- Otorgar privilegios temporales
    GRANT SELECT, INSERT, UPDATE ON seguridad_logistica.* TO 'emergencia'@'%';
    
    -- Registrar activación
    INSERT INTO log_accesos_emergencia 
    (fecha_activacion, justificacion, usuario_autorizador, expiracion)
    VALUES (NOW(), p_justificacion, USER(), v_expiracion);
    
    -- Programar desactivación automática
    SET @sql = CONCAT('CREATE EVENT evt_desactivar_emergencia_', UNIX_TIMESTAMP(),
                     ' ON SCHEDULE AT ''', v_expiracion, '''',
                     ' DO REVOKE ALL PRIVILEGES ON seguridad_logistica.* FROM ''emergencia''@''%''');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
END //
DELIMITER ;
```

### 11.2 Gestión de Incidentes de Seguridad

#### **Clasificación de Incidentes**
- **Crítico:** Compromiso de datos sensibles, acceso no autorizado a información crítica
- **Alto:** Múltiples intentos fallidos de acceso, acceso desde ubicaciones no autorizadas
- **Medio:** Uso inadecuado de privilegios, acceso fuera de horario sin justificación
- **Bajo:** Violaciones menores de políticas, intentos aislados de acceso

#### **Procedimiento de Respuesta**
```sql
-- Tabla para gestión de incidentes
CREATE TABLE incidentes_seguridad (
    id_incidente INT AUTO_INCREMENT PRIMARY KEY,
    fecha_deteccion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tipo_incidente ENUM('CRITICO','ALTO','MEDIO','BAJO') NOT NULL,
    descripcion TEXT NOT NULL,
    usuario_afectado VARCHAR(50),
    ip_origen VARCHAR(45),
    estado ENUM('ABIERTO','EN_INVESTIGACION','RESUELTO','CERRADO') DEFAULT 'ABIERTO',
    acciones_tomadas TEXT,
    fecha_resolucion TIMESTAMP NULL,
    investigador VARCHAR(50)
);

-- Trigger para crear incidente automáticamente
DELIMITER //
CREATE TRIGGER tr_crear_incidente_acceso_sospechoso
AFTER INSERT ON HistorialAcceso
FOR EACH ROW
BEGIN
    DECLARE v_intentos_fallidos INT DEFAULT 0;
    
    -- Contar intentos fallidos recientes
    SELECT COUNT(*) INTO v_intentos_fallidos
    FROM HistorialAcceso 
    WHERE id_persona = NEW.id_persona
    AND id_estado = 2  -- Estado fallido
    AND fecha >= DATE_SUB(NOW(), INTERVAL 30 MINUTE);
    
    -- Si hay más de 10 intentos fallidos, crear incidente
    IF v_intentos_fallidos >= 10 THEN
        INSERT INTO incidentes_seguridad 
        (tipo_incidente, descripcion, usuario_afectado, ip_origen)
        VALUES 
        ('ALTO', 
         CONCAT('Múltiples intentos fallidos de acceso: ', v_intentos_fallidos, ' intentos'),
         NEW.id_persona, 
         NEW.ip);
    END IF;
END //
DELIMITER ;
```

## PROCEDIMIENTOS OPERATIVOS

### 12.1 Procedimientos Diarios

#### **Lista de Verificación Diaria del DBA**
```sql
-- Script de verificación diaria
DELIMITER //
CREATE PROCEDURE sp_verificacion_diaria()
BEGIN
    -- 1. Verificar estado del servidor
    SELECT 
        'Estado del Servidor' as verificacion,
        CONNECTION_ID() as conexion_actual,
        NOW() as fecha_verificacion;
    
    -- 2. Verificar usuarios activos
    SELECT 
        'Usuarios Conectados' as verificacion,
        COUNT(*) as total_conexiones
    FROM information_schema.processlist 
    WHERE db = 'seguridad_logistica';
    
    -- 3. Verificar espacio en disco
    SELECT 
        table_schema as base_datos,
        ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) as tamaño_mb
    FROM information_schema.tables 
    WHERE table_schema = 'seguridad_logistica'
    GROUP BY table_schema;
    
    -- 4. Verificar integridad referencial
    SELECT 
        'Integridad Referencial' as verificacion,
        'VERIFICAR MANUALMENTE' as estado;
    
    -- 5. Verificar backups recientes
    SELECT 
        'Ultimo Backup' as verificacion,
        MAX(fecha) as ultimo_backup
    FROM log_backups;
    
END //
DELIMITER ;
```

### 12.2 Procedimientos Semanales

#### **Mantenimiento Semanal**
```sql
-- Script de mantenimiento semanal
DELIMITER //
CREATE PROCEDURE sp_mantenimiento_semanal()
BEGIN
    -- 1. Actualizar estadísticas de tablas
    ANALYZE TABLE Persona, Empleado, Vehiculo, Ruta, Evento, Alerta;
    
    -- 2. Optimizar tablas fragmentadas
    OPTIMIZE TABLE HistorialAcceso, auditoria_cambios;
    
    -- 3. Limpiar logs antiguos
    CALL sp_archivar_logs();
    
    -- 4. Verificar usuarios inactivos
    SELECT 
        p.Cedula,
        p.Nombre,
        p.Apellido,
        MAX(ha.fecha) as ultimo_acceso,
        DATEDIFF(NOW(), MAX(ha.fecha)) as dias_inactivo
    FROM Persona p
    LEFT JOIN HistorialAcceso ha ON p.Cedula = ha.id_persona
    GROUP BY p.Cedula, p.Nombre, p.Apellido
    HAVING dias_inactivo > 30 OR ultimo_acceso IS NULL;
    
    -- 5. Reporte de rendimiento
    SELECT 
        'Reporte Semanal Completado' as estado,
        NOW() as fecha_ejecucion;
        
END //
DELIMITER ;
```

### 12.3 Procedimientos de Emergencia

#### **Procedimiento de Bloqueo de Usuario**
```sql
-- Procedure para bloqueo inmediato de usuario comprometido
DELIMITER //
CREATE PROCEDURE sp_bloqueo_emergencia_usuario(
    IN p_cedula VARCHAR(10),
    IN p_motivo TEXT
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_username VARCHAR(50);
    DECLARE v_host VARCHAR(255);
    
    DECLARE cur_usuarios CURSOR FOR
        SELECT User, Host 
        FROM mysql.user 
        WHERE User LIKE CONCAT('%', p_cedula, '%');
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    START TRANSACTION;
    
    -- Bloquear acceso a aplicaciones
    UPDATE Persona 
    SET id_estado = 2  -- Estado inactivo
    WHERE Cedula = p_cedula;
    
    -- Bloquear usuarios de BD relacionados
    OPEN cur_usuarios;
    
    read_loop: LOOP
        FETCH cur_usuarios INTO v_username, v_host;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        SET @sql = CONCAT('ALTER USER ''', v_username, '''@''', v_host, ''' ACCOUNT LOCK');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        
    END LOOP;
    
    CLOSE cur_usuarios;
    
    -- Registrar acción de emergencia
    INSERT INTO incidentes_seguridad 
    (tipo_incidente, descripcion, usuario_afectado)
    VALUES 
    ('CRITICO', CONCAT('Bloqueo de emergencia: ', p_motivo), p_cedula);
    
    COMMIT;
    
    SELECT 'Usuario bloqueado exitosamente' as resultado;
    
END //
DELIMITER ;
```

---

**Este documento establece las bases técnicas para la administración segura de datos y accesos en el Sistema de Seguridad Logística. Debe ser complementado con los demás componentes de la política general de seguridad.**
