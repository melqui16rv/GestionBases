# POLÍTICA DE SEGURIDAD - COMPONENTE 3
## RECURSOS HUMANOS Y CONTROL DE ACCESO

### TABLA DE CONTENIDO
1. [Objetivos del Componente](#objetivos)
2. [Alcance y Responsabilidades](#alcance)
3. [Políticas de Recursos Humanos](#politicas-recursos-humanos)
4. [Control de Acceso Físico](#control-acceso-fisico)
5. [Gestión de Usuarios del Sistema](#gestion-usuarios)
6. [Monitoreo y Auditoría](#monitoreo-auditoria)
7. [Procedimientos de Respuesta](#respuesta-incidentes)

## 1. OBJETIVOS DEL COMPONENTE {#objetivos}

Establecer controles de seguridad para personal, acceso físico y gestión de usuarios en el sistema logístico de seguridad, garantizando:
- Verificación y autorización adecuada del personal
- Control de acceso físico a instalaciones críticas
- Gestión centralizada de usuarios y privilegios
- Monitoreo continuo de actividades y accesos

## 2. ALCANCE Y RESPONSABILIDADES {#alcance}

### 2.1 Personal Afectado
- Administradores de base de datos
- Desarrolladores y personal técnico
- Operadores logísticos y supervisores
- Personal de seguridad física
- Contratistas y personal temporal

### 2.2 Responsabilidades por Rol
```sql
-- Tabla de responsabilidades de seguridad
CREATE TABLE ResponsabilidadesSeguridad (
    id_responsabilidad INT PRIMARY KEY IDENTITY(1,1),
    rol_empleado VARCHAR(50) NOT NULL,
    area_responsabilidad VARCHAR(100) NOT NULL,
    nivel_acceso VARCHAR(20) NOT NULL,
    descripcion_tareas TEXT,
    fecha_asignacion DATE DEFAULT GETDATE(),
    estado VARCHAR(10) DEFAULT 'ACTIVO'
);
```

## 3. POLÍTICAS DE RECURSOS HUMANOS {#politicas-recursos-humanos}

### 3.1 Proceso de Contratación y Verificación

```sql
-- Procedimiento para verificación de antecedentes
CREATE PROCEDURE sp_VerificarAntecedentesEmpleado
    @empleado_id INT,
    @tipo_verificacion VARCHAR(50),
    @resultado VARCHAR(20) OUTPUT
AS
BEGIN
    DECLARE @fecha_verificacion DATE = GETDATE();
    
    INSERT INTO VerificacionAntecedentes (
        empleado_id, 
        tipo_verificacion, 
        fecha_verificacion, 
        estado
    ) VALUES (
        @empleado_id, 
        @tipo_verificacion, 
        @fecha_verificacion, 
        'EN_PROCESO'
    );
    
    -- Lógica de verificación según tipo
    IF @tipo_verificacion = 'ANTECEDENTES_PENALES'
        SET @resultado = 'APROBADO';
    ELSE IF @tipo_verificacion = 'REFERENCIAS_LABORALES'
        SET @resultado = 'PENDIENTE';
    
    UPDATE VerificacionAntecedentes 
    SET estado = @resultado, fecha_completado = GETDATE()
    WHERE empleado_id = @empleado_id AND tipo_verificacion = @tipo_verificacion;
END;
```

### 3.2 Capacitación en Seguridad

```sql
-- Sistema de seguimiento de capacitaciones
CREATE TABLE CapacitacionSeguridad (
    id_capacitacion INT PRIMARY KEY IDENTITY(1,1),
    empleado_id INT FOREIGN KEY REFERENCES Empleado(id_empleado),
    tipo_capacitacion VARCHAR(100) NOT NULL,
    fecha_capacitacion DATE NOT NULL,
    fecha_vencimiento DATE,
    certificacion_obtenida BIT DEFAULT 0,
    puntuacion_obtenida DECIMAL(3,1),
    instructor VARCHAR(100),
    estado VARCHAR(20) DEFAULT 'COMPLETADO'
);

-- Función para verificar capacitaciones vigentes
CREATE FUNCTION fn_VerificarCapacitacionVigente(@empleado_id INT, @tipo_capacitacion VARCHAR(100))
RETURNS BIT
AS
BEGIN
    DECLARE @vigente BIT = 0;
    
    IF EXISTS (
        SELECT 1 FROM CapacitacionSeguridad 
        WHERE empleado_id = @empleado_id 
        AND tipo_capacitacion = @tipo_capacitacion
        AND (fecha_vencimiento IS NULL OR fecha_vencimiento > GETDATE())
        AND certificacion_obtenida = 1
    )
        SET @vigente = 1;
    
    RETURN @vigente;
END;
```

## 4. CONTROL DE ACCESO FÍSICO {#control-acceso-fisico}

### 4.1 Sistema de Tarjetas de Acceso

```sql
-- Gestión de tarjetas de acceso físico
CREATE TABLE TarjetasAcceso (
    id_tarjeta INT PRIMARY KEY IDENTITY(1,1),
    empleado_id INT FOREIGN KEY REFERENCES Empleado(id_empleado),
    numero_tarjeta VARCHAR(20) UNIQUE NOT NULL,
    tipo_tarjeta VARCHAR(30) NOT NULL, -- EMPLEADO, VISITANTE, TEMPORAL
    zonas_permitidas TEXT, -- JSON con zonas autorizadas
    fecha_emision DATE DEFAULT GETDATE(),
    fecha_vencimiento DATE,
    estado VARCHAR(15) DEFAULT 'ACTIVA' -- ACTIVA, SUSPENDIDA, BLOQUEADA
);

-- Registro de accesos físicos
CREATE TABLE RegistroAccesoFisico (
    id_registro INT PRIMARY KEY IDENTITY(1,1),
    tarjeta_id INT FOREIGN KEY REFERENCES TarjetasAcceso(id_tarjeta),
    zona_acceso VARCHAR(50) NOT NULL,
    tipo_evento VARCHAR(20) NOT NULL, -- ENTRADA, SALIDA, INTENTO_DENEGADO
    fecha_hora DATETIME DEFAULT GETDATE(),
    dispositivo_lectura VARCHAR(50),
    resultado VARCHAR(20) NOT NULL -- AUTORIZADO, DENEGADO
);
```

### 4.2 Monitoreo de Accesos en Tiempo Real

```sql
-- Trigger para alertas de acceso
CREATE TRIGGER tr_AlertaAccesoNoAutorizado
ON RegistroAccesoFisico
AFTER INSERT
AS
BEGIN
    DECLARE @zona_acceso VARCHAR(50), @empleado_id INT, @resultado VARCHAR(20);
    
    SELECT @zona_acceso = i.zona_acceso, @resultado = i.resultado,
           @empleado_id = ta.empleado_id
    FROM inserted i
    INNER JOIN TarjetasAcceso ta ON i.tarjeta_id = ta.id_tarjeta;
    
    -- Generar alerta para accesos denegados en zonas críticas
    IF @resultado = 'DENEGADO' AND @zona_acceso IN ('SERVIDOR_PRINCIPAL', 'CENTRO_CONTROL')
    BEGIN
        INSERT INTO Alerta (empleado_id, tipo_alerta, descripcion, nivel_gravedad)
        VALUES (@empleado_id, 'ACCESO_FISICO_DENEGADO', 
                'Intento de acceso denegado a zona crítica: ' + @zona_acceso, 
                'ALTO');
    END
END;
```

## 5. GESTIÓN DE USUARIOS DEL SISTEMA {#gestion-usuarios}

### 5.1 Ciclo de Vida de Usuarios

```sql
-- Procedimiento para activación de usuario
CREATE PROCEDURE sp_ActivarUsuarioSistema
    @empleado_id INT,
    @rol_solicitado VARCHAR(50)
AS
BEGIN
    DECLARE @usuario_db VARCHAR(50) = 'USR_' + CAST(@empleado_id AS VARCHAR(10));
    DECLARE @password_temp VARCHAR(50) = 'TempPass' + CAST(@empleado_id AS VARCHAR(10)) + '!';
    
    -- Verificar capacitación de seguridad
    IF dbo.fn_VerificarCapacitacionVigente(@empleado_id, 'SEGURIDAD_INFORMACION') = 0
    BEGIN
        RAISERROR('Empleado debe completar capacitación de seguridad antes de acceso al sistema', 16, 1);
        RETURN;
    END
    
    -- Crear usuario y asignar rol
    EXEC('CREATE LOGIN ' + @usuario_db + ' WITH PASSWORD = ''' + @password_temp + '''');
    EXEC('CREATE USER ' + @usuario_db + ' FOR LOGIN ' + @usuario_db);
    EXEC('ALTER ROLE ' + @rol_solicitado + ' ADD MEMBER ' + @usuario_db);
    
    -- Forzar cambio de contraseña en primer acceso
    EXEC('ALTER LOGIN ' + @usuario_db + ' WITH CHECK_POLICY = ON, MUST_CHANGE = ON');
    
    -- Registrar en auditoría
    INSERT INTO RegistroAuditoria (usuario, accion, tabla_afectada, descripcion)
    VALUES (SYSTEM_USER, 'CREAR_USUARIO', 'SISTEMA', 
            'Usuario creado para empleado ID: ' + CAST(@empleado_id AS VARCHAR(10)));
END;
```

### 5.2 Revisión Periódica de Accesos

```sql
-- Vista para revisión de privilegios
CREATE VIEW vw_RevisionPrivilegios AS
SELECT 
    e.id_empleado,
    e.nombre + ' ' + e.apellido AS nombre_completo,
    e.departamento,
    e.cargo,
    dp.name AS rol_db,
    dp.create_date AS fecha_asignacion,
    CASE 
        WHEN DATEDIFF(DAY, dp.create_date, GETDATE()) > 180 
        THEN 'REQUIERE_REVISION'
        ELSE 'VIGENTE'
    END AS estado_revision
FROM Empleado e
LEFT JOIN sys.database_principals dp ON dp.name = 'USR_' + CAST(e.id_empleado AS VARCHAR(10))
WHERE e.estado = 'ACTIVO' AND dp.type = 'S';
```

## 6. MONITOREO Y AUDITORÍA {#monitoreo-auditoria}

### 6.1 Alertas de Seguridad Automatizadas

```bash
#!/bin/bash
# Script de monitoreo de seguridad (ejecutar cada 5 minutos)

# Verificar intentos de acceso fallidos
sqlcmd -S localhost -d LogisticaSeguridad -Q "
SELECT COUNT(*) as intentos_fallidos
FROM RegistroAccesoSistema 
WHERE resultado = 'FALLIDO' 
AND fecha_hora > DATEADD(MINUTE, -5, GETDATE())
HAVING COUNT(*) > 3" -h -1 -W | while read intentos; do
    if [ "$intentos" -gt 0 ]; then
        echo "ALERTA: $intentos intentos de acceso fallidos en los últimos 5 minutos" | \
        mail -s "Alerta de Seguridad - Sistema Logístico" admin@empresa.com
    fi
done

# Verificar accesos fuera de horario
sqlcmd -S localhost -d LogisticaSeguridad -Q "
SELECT e.nombre, e.apellido, r.fecha_hora
FROM RegistroAccesoSistema r
JOIN Empleado e ON r.empleado_id = e.id_empleado
WHERE r.fecha_hora > DATEADD(HOUR, -1, GETDATE())
AND (DATEPART(HOUR, r.fecha_hora) < 7 OR DATEPART(HOUR, r.fecha_hora) > 20)
AND DATEPART(WEEKDAY, r.fecha_hora) BETWEEN 2 AND 6" -h -1 -s "," | \
while IFS=, read nombre apellido fecha_hora; do
    echo "Acceso fuera de horario: $nombre $apellido a las $fecha_hora"
done
```

### 6.2 Reportes de Cumplimiento

```sql
-- Función para generar reporte de cumplimiento
CREATE FUNCTION fn_ReporteCumplimientoSeguridad(@fecha_inicio DATE, @fecha_fin DATE)
RETURNS TABLE
AS
RETURN (
    SELECT 
        'Capacitaciones Vigentes' AS categoria,
        COUNT(*) AS total,
        SUM(CASE WHEN dbo.fn_VerificarCapacitacionVigente(e.id_empleado, 'SEGURIDAD_INFORMACION') = 1 
                 THEN 1 ELSE 0 END) AS cumple
    FROM Empleado e WHERE e.estado = 'ACTIVO'
    
    UNION ALL
    
    SELECT 
        'Contraseñas Actualizadas',
        COUNT(*),
        SUM(CASE WHEN DATEDIFF(DAY, p.fecha_cambio, GETDATE()) <= 90 
                 THEN 1 ELSE 0 END)
    FROM PoliticasPassword p
    JOIN Empleado e ON p.empleado_id = e.id_empleado
    WHERE e.estado = 'ACTIVO'
);
```

## 7. PROCEDIMIENTOS DE RESPUESTA {#respuesta-incidentes}

### 7.1 Respuesta a Incidentes de Seguridad

```sql
-- Procedimiento para manejo de incidentes
CREATE PROCEDURE sp_ManejarIncidenteSeguridad
    @tipo_incidente VARCHAR(50),
    @empleado_afectado INT,
    @descripcion TEXT,
    @nivel_gravedad VARCHAR(10)
AS
BEGIN
    DECLARE @id_incidente INT;
    
    -- Registrar incidente
    INSERT INTO IncidentesSeguridad (tipo_incidente, empleado_id, descripcion, nivel_gravedad, estado)
    VALUES (@tipo_incidente, @empleado_afectado, @descripcion, @nivel_gravedad, 'ABIERTO');
    
    SET @id_incidente = SCOPE_IDENTITY();
    
    -- Acciones automáticas según gravedad
    IF @nivel_gravedad = 'CRITICO'
    BEGIN
        -- Suspender acceso inmediatamente
        EXEC sp_SuspenderAccesoEmpleado @empleado_afectado;
        
        -- Notificar a administradores
        INSERT INTO NotificacionesSeguridad (destinatario, asunto, mensaje, prioridad)
        VALUES ('ADMIN_SEGURIDAD', 
                'INCIDENTE CRÍTICO - ID: ' + CAST(@id_incidente AS VARCHAR(10)),
                @descripcion, 'ALTA');
    END
    ELSE IF @nivel_gravedad = 'ALTO'
    BEGIN
        -- Requerir cambio de contraseña
        UPDATE PoliticasPassword 
        SET requiere_cambio = 1, 
            motivo_cambio = 'Incidente de seguridad ID: ' + CAST(@id_incidente AS VARCHAR(10))
        WHERE empleado_id = @empleado_afectado;
    END
END;
```

### 7.2 Plan de Continuidad de Accesos

```sql
-- Procedimientos de emergencia para accesos críticos
CREATE PROCEDURE sp_ActivarAccesoEmergencia
    @empleado_id INT,
    @justificacion TEXT,
    @aprobado_por INT
AS
BEGIN
    -- Verificar autorización del aprobador
    IF NOT EXISTS (
        SELECT 1 FROM Empleado 
        WHERE id_empleado = @aprobado_por 
        AND cargo IN ('DIRECTOR_TI', 'GERENTE_SEGURIDAD')
    )
    BEGIN
        RAISERROR('Solo directores pueden aprobar accesos de emergencia', 16, 1);
        RETURN;
    END
    
    -- Crear acceso temporal (24 horas)
    INSERT INTO AccesosEmergencia (
        empleado_id, 
        fecha_activacion, 
        fecha_vencimiento,
        justificacion,
        aprobado_por,
        estado
    ) VALUES (
        @empleado_id,
        GETDATE(),
        DATEADD(HOUR, 24, GETDATE()),
        @justificacion,
        @aprobado_por,
        'ACTIVO'
    );
    
    -- Otorgar permisos temporales
    EXEC sp_AsignarRolTemporal @empleado_id, 'OPERADOR_EMERGENCIA';
END;
```

---

**Implementación:** Este componente debe implementarse junto con los componentes anteriores y ser revisado trimestralmente por el comité de seguridad.

**Próximas Actualizaciones:** Integración con sistemas biométricos y mejoras en automatización de respuesta a incidentes.
3. [Políticas de Recursos Humanos](#politicas-rrhh)
4. [Control de Acceso Físico](#control-fisico)
5. [Gestión de Identidades](#gestion-identidades)
6. [Procedimientos Técnicos](#procedimientos)
7. [Monitoreo y Auditoría](#monitoreo)

---

### 1. OBJETIVOS DEL COMPONENTE {#objetivos}

#### 1.1 Objetivo General
Establecer controles de seguridad relacionados con el personal y el acceso físico/lógico a las instalaciones y sistemas del Sistema de Seguridad Logística.

#### 1.2 Objetivos Específicos
- Definir procesos de selección y verificación de antecedentes del personal
- Implementar controles de acceso físico a instalaciones críticas
- Gestionar ciclo de vida de identidades digitales
- Establecer procedimientos de revocación de accesos
- Monitorear actividades de acceso en tiempo real

---

### 2. ALCANCE Y RESPONSABILIDADES {#alcance}

#### 2.1 Personal Incluido
- **Personal Directo**: Empleados permanentes con acceso a sistemas críticos
- **Personal Contratista**: Terceros con acceso temporal
- **Personal de Limpieza**: Acceso limitado a áreas no críticas
- **Visitantes**: Acceso supervisado y temporal

#### 2.2 Matriz de Responsabilidades
| Rol | Responsabilidad | Nivel Acceso |
|-----|----------------|--------------|
| Jefe de Seguridad | Aprobación accesos críticos | CRITICO |
| Supervisor RRHH | Gestión personal, verificaciones | ALTO |
| Administrador Físico | Control acceso instalaciones | MEDIO |
| Operador Seguridad | Monitoreo tiempo real | BASICO |

---

### 3. POLÍTICAS DE RECURSOS HUMANOS {#politicas-rrhh}

#### 3.1 Verificación de Antecedentes

##### 3.1.1 Procedimiento de Verificación
```sql
-- Tabla para registro de verificaciones de antecedentes
CREATE TABLE verificacion_antecedentes (
    id_verificacion INT AUTO_INCREMENT PRIMARY KEY,
    id_empleado INT NOT NULL,
    tipo_verificacion ENUM('JUDICIAL', 'CREDITICIA', 'LABORAL', 'ACADEMICA') NOT NULL,
    fecha_solicitud DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_respuesta DATETIME,
    resultado ENUM('APROBADO', 'RECHAZADO', 'PENDIENTE') DEFAULT 'PENDIENTE',
    observaciones TEXT,
    documento_verificacion VARCHAR(255),
    verificado_por VARCHAR(100),
    FOREIGN KEY (id_empleado) REFERENCES Empleado(empleado_id)
);
```

##### 3.1.2 Niveles de Verificación
- **NIVEL 1 (BÁSICO)**: Verificación judicial
- **NIVEL 2 (MEDIO)**: Judicial + Crediticia + Laboral
- **NIVEL 3 (CRÍTICO)**: Todas las verificaciones + Entrevista especializada

#### 3.2 Capacitación en Seguridad
```sql
-- Tabla para control de capacitaciones
CREATE TABLE capacitaciones_seguridad (
    id_capacitacion INT AUTO_INCREMENT PRIMARY KEY,
    id_empleado INT NOT NULL,
    tipo_capacitacion ENUM('INICIAL', 'PERIODICA', 'ESPECIALIZADA') NOT NULL,
    tema VARCHAR(200) NOT NULL,
    fecha_capacitacion DATE NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    estado ENUM('VIGENTE', 'VENCIDA', 'PENDIENTE') DEFAULT 'PENDIENTE',
    calificacion DECIMAL(3,1),
    certificado_url VARCHAR(255),
    FOREIGN KEY (id_empleado) REFERENCES Empleado(empleado_id)
);
```