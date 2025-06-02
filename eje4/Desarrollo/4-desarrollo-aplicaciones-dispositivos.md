# POLÍTICA DE SEGURIDAD - COMPONENTE 4
## DESARROLLO DE APLICACIONES, EMAIL Y DISPOSITIVOS MÓVILES

### TABLA DE CONTENIDO
1. [Objetivos del Componente](#objetivos)
2. [Alcance y Arquitectura](#alcance)
3. [Seguridad en Desarrollo de Aplicaciones](#desarrollo-aplicaciones)
4. [Gestión de Email Corporativo](#email-corporativo)
5. [Seguridad en Dispositivos Móviles](#dispositivos-moviles)
6. [APIs y Servicios Web](#apis-servicios)
7. [Monitoreo y Auditoría](#monitoreo-auditoria)

## 1. OBJETIVOS DEL COMPONENTE {#objetivos}

Establecer controles de seguridad para:
- Desarrollo seguro de aplicaciones del sistema logístico
- Gestión segura de comunicaciones por email
- Control y protección de dispositivos móviles
- Implementación de APIs seguras para integración

## 2. ALCANCE Y ARQUITECTURA {#alcance}

### 2.1 Arquitectura del Sistema Logístico

```sql
-- Configuración de aplicaciones registradas
CREATE TABLE AplicacionesRegistradas (
    id_aplicacion INT PRIMARY KEY IDENTITY(1,1),
    nombre_aplicacion VARCHAR(100) NOT NULL,
    tipo_aplicacion VARCHAR(50) NOT NULL, -- WEB, MOBILE, API, DESKTOP
    version VARCHAR(20) NOT NULL,
    ambiente VARCHAR(20) NOT NULL, -- DESARROLLO, PRUEBAS, PRODUCCION
    url_aplicacion VARCHAR(255),
    estado VARCHAR(15) DEFAULT 'ACTIVA',
    fecha_registro DATE DEFAULT GETDATE(),
    responsable_desarrollo INT FOREIGN KEY REFERENCES Empleado(id_empleado)
);

-- Tokens de autenticación para APIs
CREATE TABLE TokensAutenticacion (
    id_token INT PRIMARY KEY IDENTITY(1,1),
    aplicacion_id INT FOREIGN KEY REFERENCES AplicacionesRegistradas(id_aplicacion),
    token_hash VARCHAR(255) NOT NULL,
    fecha_creacion DATETIME DEFAULT GETDATE(),
    fecha_vencimiento DATETIME NOT NULL,
    permisos_json TEXT, -- JSON con permisos específicos
    estado VARCHAR(15) DEFAULT 'ACTIVO'
);
```

## 3. SEGURIDAD EN DESARROLLO DE APLICACIONES {#desarrollo-aplicaciones}

### 3.1 Estándares de Codificación Segura

```sql
-- Validación de entrada para prevenir SQL Injection
CREATE FUNCTION fn_ValidarEntradaSegura(@input NVARCHAR(MAX), @tipo_validacion VARCHAR(50))
RETURNS BIT
AS
BEGIN
    DECLARE @es_valido BIT = 1;
    
    -- Detectar patrones de SQL Injection
    IF @tipo_validacion = 'SQL_SAFE'
    BEGIN
        IF @input LIKE '%''%' OR @input LIKE '%;%' OR @input LIKE '%---%'
            OR @input LIKE '%UNION%' OR @input LIKE '%DROP%' OR @input LIKE '%DELETE%'
            SET @es_valido = 0;
    END
    
    -- Validar entrada de ID numérico
    ELSE IF @tipo_validacion = 'NUMERIC_ID'
    BEGIN
        IF @input NOT LIKE '[0-9]%' OR LEN(@input) > 10
            SET @es_valido = 0;
    END
    
    -- Validar formato de email
    ELSE IF @tipo_validacion = 'EMAIL'
    BEGIN
        IF @input NOT LIKE '%@%.%' OR LEN(@input) > 255
            SET @es_valido = 0;
    END
    
    RETURN @es_valido;
END;

-- Procedimiento seguro para consulta de vehículos
CREATE PROCEDURE sp_ConsultarVehiculosSeguro
    @filtro_placa NVARCHAR(10) = NULL,
    @filtro_tipo NVARCHAR(50) = NULL,
    @usuario_solicitante VARCHAR(50)
AS
BEGIN
    -- Validar entradas
    IF @filtro_placa IS NOT NULL AND dbo.fn_ValidarEntradaSegura(@filtro_placa, 'SQL_SAFE') = 0
    BEGIN
        RAISERROR('Entrada no válida en filtro de placa', 16, 1);
        RETURN;
    END
    
    -- Registrar consulta para auditoría
    INSERT INTO RegistroConsultas (usuario, tabla_consultada, filtros_aplicados, fecha_consulta)
    VALUES (@usuario_solicitante, 'Vehiculo', 
            'placa=' + ISNULL(@filtro_placa, 'NULL') + ',tipo=' + ISNULL(@filtro_tipo, 'NULL'),
            GETDATE());
    
    -- Ejecutar consulta segura
    SELECT v.id_vehiculo, v.placa, v.tipo, v.modelo, v.estado
    FROM Vehiculo v
    WHERE (@filtro_placa IS NULL OR v.placa = @filtro_placa)
      AND (@filtro_tipo IS NULL OR v.tipo = @filtro_tipo)
      AND v.estado = 'ACTIVO';
END;
```

### 3.2 Gestión de Vulnerabilidades

```sql
-- Registro de vulnerabilidades detectadas
CREATE TABLE VulnerabilidadesDetectadas (
    id_vulnerabilidad INT PRIMARY KEY IDENTITY(1,1),
    aplicacion_id INT FOREIGN KEY REFERENCES AplicacionesRegistradas(id_aplicacion),
    tipo_vulnerabilidad VARCHAR(100) NOT NULL,
    severidad VARCHAR(20) NOT NULL, -- CRITICA, ALTA, MEDIA, BAJA
    descripcion TEXT NOT NULL,
    estado VARCHAR(20) DEFAULT 'DETECTADA', -- DETECTADA, EN_REVISION, CORREGIDA
    fecha_deteccion DATE DEFAULT GETDATE(),
    fecha_correccion DATE NULL,
    responsable_correccion INT FOREIGN KEY REFERENCES Empleado(id_empleado)
);

-- Trigger para alertas automáticas de vulnerabilidades críticas
CREATE TRIGGER tr_AlertaVulnerabilidadCritica
ON VulnerabilidadesDetectadas
AFTER INSERT
AS
BEGIN
    DECLARE @severidad VARCHAR(20), @aplicacion VARCHAR(100);
    
    SELECT @severidad = i.severidad, @aplicacion = ar.nombre_aplicacion
    FROM inserted i
    JOIN AplicacionesRegistradas ar ON i.aplicacion_id = ar.id_aplicacion;
    
    IF @severidad = 'CRITICA'
    BEGIN
        INSERT INTO Alerta (empleado_id, tipo_alerta, descripcion, nivel_gravedad)
        SELECT 1, 'VULNERABILIDAD_CRITICA', 
               'Vulnerabilidad crítica detectada en aplicación: ' + @aplicacion,
               'ALTO';
    END
END;
```

## 4. GESTIÓN DE EMAIL CORPORATIVO {#email-corporativo}

### 4.1 Políticas de Email Seguro

```sql
-- Configuración de seguridad de email
CREATE TABLE ConfiguracionEmailSeguridad (
    id_config INT PRIMARY KEY IDENTITY(1,1),
    empleado_id INT FOREIGN KEY REFERENCES Empleado(id_empleado),
    encriptacion_habilitada BIT DEFAULT 1,
    firma_digital_requerida BIT DEFAULT 1,
    filtro_spam_nivel VARCHAR(10) DEFAULT 'ALTO', -- ALTO, MEDIO, BAJO
    notificacion_lectura BIT DEFAULT 0,
    reenvio_externo_permitido BIT DEFAULT 0,
    fecha_configuracion DATE DEFAULT GETDATE()
);

-- Registro de emails con datos sensibles
CREATE TABLE EmailsDataSensible (
    id_email INT PRIMARY KEY IDENTITY(1,1),
    remitente_empleado_id INT FOREIGN KEY REFERENCES Empleado(id_empleado),
    destinatarios TEXT NOT NULL, -- JSON con lista de destinatarios
    asunto_hash VARCHAR(255), -- Hash del asunto para privacidad
    contiene_datos_criticos BIT DEFAULT 0,
    clasificacion_datos VARCHAR(20), -- PUBLICO, INTERNO, CONFIDENCIAL, RESTRINGIDO
    fecha_envio DATETIME DEFAULT GETDATE(),
    metodo_encriptacion VARCHAR(50),
    estado_entrega VARCHAR(20) DEFAULT 'ENVIADO'
);
```

### 4.2 Filtrado y Prevención de Phishing

```sql
-- Sistema de detección de phishing
CREATE FUNCTION fn_DetectarPhishing(@contenido_email TEXT, @remitente_email VARCHAR(255))
RETURNS VARCHAR(20) -- SEGURO, SOSPECHOSO, PHISHING
AS
BEGIN
    DECLARE @resultado VARCHAR(20) = 'SEGURO';
    
    -- Verificar dominios sospechosos
    IF @remitente_email LIKE '%@suspicious-domain.%' 
       OR @remitente_email LIKE '%@phishing-site.%'
        SET @resultado = 'PHISHING';
    
    -- Detectar patrones de phishing en contenido
    ELSE IF @contenido_email LIKE '%urgent%account%suspended%'
            OR @contenido_email LIKE '%click%here%immediately%'
            OR @contenido_email LIKE '%verify%password%'
        SET @resultado = 'SOSPECHOSO';
    
    -- Verificar enlaces maliciosos
    ELSE IF @contenido_email LIKE '%http://%' -- Prefiere HTTPS
            AND @contenido_email NOT LIKE '%https://%'
        SET @resultado = 'SOSPECHOSO';
    
    RETURN @resultado;
END;

-- Procedimiento para procesar emails entrantes
CREATE PROCEDURE sp_ProcesarEmailEntrante
    @remitente VARCHAR(255),
    @destinatario_empleado_id INT,
    @asunto VARCHAR(500),
    @contenido TEXT
AS
BEGIN
    DECLARE @nivel_riesgo VARCHAR(20);
    SET @nivel_riesgo = dbo.fn_DetectarPhishing(@contenido, @remitente);
    
    -- Registrar email
    INSERT INTO EmailsRecibidos (
        destinatario_empleado_id, 
        remitente_email, 
        asunto_hash, 
        nivel_riesgo,
        fecha_recepcion
    ) VALUES (
        @destinatario_empleado_id,
        @remitente,
        HASHBYTES('SHA256', @asunto),
        @nivel_riesgo,
        GETDATE()
    );
    
    -- Crear alerta si es phishing detectado
    IF @nivel_riesgo = 'PHISHING'
    BEGIN
        INSERT INTO Alerta (empleado_id, tipo_alerta, descripcion, nivel_gravedad)
        VALUES (@destinatario_empleado_id, 'PHISHING_DETECTADO',
                'Email de phishing detectado de: ' + @remitente, 'ALTO');
    END
END;
```

## 5. SEGURIDAD EN DISPOSITIVOS MÓVILES {#dispositivos-moviles}

### 5.1 Gestión de Dispositivos (MDM)

```sql
-- Registro de dispositivos móviles
CREATE TABLE DispositivosMoviles (
    id_dispositivo INT PRIMARY KEY IDENTITY(1,1),
    empleado_id INT FOREIGN KEY REFERENCES Empleado(id_empleado),
    imei VARCHAR(20) UNIQUE NOT NULL,
    modelo_dispositivo VARCHAR(100) NOT NULL,
    sistema_operativo VARCHAR(50) NOT NULL,
    version_os VARCHAR(20) NOT NULL,
    politicas_aplicadas TEXT, -- JSON con políticas de seguridad
    estado_dispositivo VARCHAR(20) DEFAULT 'ACTIVO', -- ACTIVO, PERDIDO, BLOQUEADO
    ubicacion_ultima TEXT, -- JSON con lat/lon de última ubicación
    fecha_registro DATE DEFAULT GETDATE(),
    fecha_ultima_sincronizacion DATETIME
);

-- Políticas de seguridad móvil
CREATE TABLE PoliticasDispositivoMovil (
    id_politica INT PRIMARY KEY IDENTITY(1,1),
    dispositivo_id INT FOREIGN KEY REFERENCES DispositivosMoviles(id_dispositivo),
    pin_requerido BIT DEFAULT 1,
    longitud_pin_minima INT DEFAULT 6,
    encriptacion_requerida BIT DEFAULT 1,
    apps_permitidas TEXT, -- JSON con lista de apps autorizadas
    bloqueo_automatico_minutos INT DEFAULT 5,
    borrado_remoto_habilitado BIT DEFAULT 1,
    acceso_camara_restringido BIT DEFAULT 1,
    fecha_aplicacion DATE DEFAULT GETDATE()
);
```

### 5.2 Aplicación Móvil del Sistema Logístico

```sql
-- Sesiones de aplicación móvil
CREATE TABLE SesionesAppMovil (
    id_sesion INT PRIMARY KEY IDENTITY(1,1),
    dispositivo_id INT FOREIGN KEY REFERENCES DispositivosMoviles(id_dispositivo),
    empleado_id INT FOREIGN KEY REFERENCES Empleado(id_empleado),
    token_sesion VARCHAR(255) UNIQUE NOT NULL,
    fecha_inicio DATETIME DEFAULT GETDATE(),
    fecha_expiracion DATETIME NOT NULL,
    ip_origen VARCHAR(45), -- IPv4 o IPv6
    ubicacion_gps VARCHAR(100), -- lat,lon
    estado_sesion VARCHAR(15) DEFAULT 'ACTIVA' -- ACTIVA, EXPIRADA, CERRADA
);

-- Procedimiento para autenticación móvil
CREATE PROCEDURE sp_AutenticarAppMovil
    @imei VARCHAR(20),
    @empleado_id INT,
    @pin_hash VARCHAR(255),
    @ubicacion_gps VARCHAR(100),
    @token_salida VARCHAR(255) OUTPUT
AS
BEGIN
    DECLARE @dispositivo_id INT, @pin_valido BIT = 0;
    
    -- Verificar dispositivo registrado
    SELECT @dispositivo_id = id_dispositivo 
    FROM DispositivosMoviles 
    WHERE imei = @imei AND empleado_id = @empleado_id AND estado_dispositivo = 'ACTIVO';
    
    IF @dispositivo_id IS NULL
    BEGIN
        RAISERROR('Dispositivo no autorizado', 16, 1);
        RETURN;
    END
    
    -- Verificar PIN (simulado - en producción usar bcrypt)
    IF EXISTS (SELECT 1 FROM Empleado WHERE id_empleado = @empleado_id AND password_hash = @pin_hash)
        SET @pin_valido = 1;
    
    IF @pin_valido = 1
    BEGIN
        -- Generar token de sesión
        SET @token_salida = 'MOB_' + CAST(NEWID() AS VARCHAR(36));
        
        -- Crear sesión
        INSERT INTO SesionesAppMovil (
            dispositivo_id, 
            empleado_id, 
            token_sesion, 
            fecha_expiracion,
            ubicacion_gps
        ) VALUES (
            @dispositivo_id,
            @empleado_id,
            @token_salida,
            DATEADD(HOUR, 8, GETDATE()), -- Sesión válida por 8 horas
            @ubicacion_gps
        );
        
        -- Actualizar última sincronización
        UPDATE DispositivosMoviles 
        SET fecha_ultima_sincronizacion = GETDATE(),
            ubicacion_ultima = @ubicacion_gps
        WHERE id_dispositivo = @dispositivo_id;
    END
    ELSE
    BEGIN
        RAISERROR('Credenciales inválidas', 16, 1);
    END
END;
```

## 6. APIs Y SERVICIOS WEB {#apis-servicios}

### 6.1 Autenticación y Autorización de APIs

```sql
-- Rate limiting para APIs
CREATE TABLE RateLimitingAPI (
    id_limite INT PRIMARY KEY IDENTITY(1,1),
    token_id INT FOREIGN KEY REFERENCES TokensAutenticacion(id_token),
    endpoint VARCHAR(255) NOT NULL,
    solicitudes_permitidas INT NOT NULL, -- Por ventana de tiempo
    ventana_tiempo_minutos INT DEFAULT 60,
    solicitudes_actuales INT DEFAULT 0,
    ventana_inicio DATETIME DEFAULT GETDATE(),
    estado VARCHAR(15) DEFAULT 'ACTIVO'
);

-- Procedimiento para validar solicitud API
CREATE PROCEDURE sp_ValidarSolicitudAPI
    @token VARCHAR(255),
    @endpoint VARCHAR(255),
    @ip_origen VARCHAR(45),
    @autorizado BIT OUTPUT
AS
BEGIN
    DECLARE @token_id INT, @solicitudes_actuales INT, @limite_solicitudes INT;
    SET @autorizado = 0;
    
    -- Verificar token válido
    SELECT @token_id = id_token 
    FROM TokensAutenticacion 
    WHERE token_hash = HASHBYTES('SHA256', @token)
      AND estado = 'ACTIVO' 
      AND fecha_vencimiento > GETDATE();
    
    IF @token_id IS NULL
    BEGIN
        INSERT INTO LogsAPI (endpoint, ip_origen, resultado, descripcion)
        VALUES (@endpoint, @ip_origen, 'TOKEN_INVALIDO', 'Token no válido o expirado');
        RETURN;
    END
    
    -- Verificar rate limiting
    SELECT @solicitudes_actuales = solicitudes_actuales,
           @limite_solicitudes = solicitudes_permitidas
    FROM RateLimitingAPI 
    WHERE token_id = @token_id AND endpoint = @endpoint;
    
    IF @solicitudes_actuales >= @limite_solicitudes
    BEGIN
        INSERT INTO LogsAPI (endpoint, ip_origen, resultado, descripcion)
        VALUES (@endpoint, @ip_origen, 'LIMITE_EXCEDIDO', 'Rate limit excedido');
        RETURN;
    END
    
    -- Autorizar solicitud
    SET @autorizado = 1;
    
    -- Incrementar contador
    UPDATE RateLimitingAPI 
    SET solicitudes_actuales = solicitudes_actuales + 1
    WHERE token_id = @token_id AND endpoint = @endpoint;
    
    -- Registrar solicitud autorizada
    INSERT INTO LogsAPI (endpoint, ip_origen, token_usado, resultado)
    VALUES (@endpoint, @ip_origen, @token, 'AUTORIZADO');
END;
```

### 6.2 API de Consulta de Rutas Segura

```sql
-- Endpoint seguro para consultar rutas
CREATE PROCEDURE sp_API_ConsultarRutas
    @token VARCHAR(255),
    @filtro_estado VARCHAR(20) = NULL,
    @fecha_desde DATE = NULL,
    @fecha_hasta DATE = NULL
AS
BEGIN
    DECLARE @autorizado BIT, @empleado_id INT;
    
    -- Validar autorización
    EXEC sp_ValidarSolicitudAPI @token, '/api/rutas', '0.0.0.0', @autorizado OUTPUT;
    
    IF @autorizado = 0
    BEGIN
        SELECT 'ERROR' AS status, 'No autorizado' AS mensaje;
        RETURN;
    END
    
    -- Obtener empleado asociado al token
    SELECT @empleado_id = ar.responsable_desarrollo
    FROM TokensAutenticacion ta
    JOIN AplicacionesRegistradas ar ON ta.aplicacion_id = ar.id_aplicacion
    WHERE ta.token_hash = HASHBYTES('SHA256', @token);
    
    -- Validar parámetros de entrada
    IF @filtro_estado IS NOT NULL AND dbo.fn_ValidarEntradaSegura(@filtro_estado, 'SQL_SAFE') = 0
    BEGIN
        SELECT 'ERROR' AS status, 'Parámetros inválidos' AS mensaje;
        RETURN;
    END
    
    -- Ejecutar consulta segura
    SELECT 
        r.id_ruta,
        r.nombre_ruta,
        r.origen,
        r.destino,
        r.estado,
        r.fecha_creacion,
        COUNT(e.id_evento) AS total_eventos
    FROM Ruta r
    LEFT JOIN Evento e ON r.id_ruta = e.ruta_id
    WHERE (@filtro_estado IS NULL OR r.estado = @filtro_estado)
      AND (@fecha_desde IS NULL OR r.fecha_creacion >= @fecha_desde)
      AND (@fecha_hasta IS NULL OR r.fecha_creacion <= @fecha_hasta)
    GROUP BY r.id_ruta, r.nombre_ruta, r.origen, r.destino, r.estado, r.fecha_creacion
    ORDER BY r.fecha_creacion DESC;
    
    -- Registrar consulta realizada
    INSERT INTO RegistroConsultas (usuario, tabla_consultada, fecha_consulta)
    VALUES ('API_USER_' + CAST(@empleado_id AS VARCHAR), 'Ruta', GETDATE());
END;
```

## 7. MONITOREO Y AUDITORÍA {#monitoreo-auditoria}

### 7.1 Dashboard de Seguridad

```sql
-- Vista para dashboard de seguridad de aplicaciones
CREATE VIEW vw_DashboardSeguridadApps AS
SELECT 
    'Aplicaciones Activas' AS metrica,
    COUNT(*) AS valor,
    NULL AS porcentaje
FROM AplicacionesRegistradas WHERE estado = 'ACTIVA'

UNION ALL

SELECT 
    'Vulnerabilidades Abiertas',
    COUNT(*),
    NULL
FROM VulnerabilidadesDetectadas WHERE estado IN ('DETECTADA', 'EN_REVISION')

UNION ALL

SELECT 
    'Dispositivos Móviles Activos',
    COUNT(*),
    NULL
FROM DispositivosMoviles WHERE estado_dispositivo = 'ACTIVO'

UNION ALL

SELECT 
    'Emails Phishing Bloqueados (Últimos 7 días)',
    COUNT(*),
    NULL
FROM EmailsRecibidos 
WHERE nivel_riesgo = 'PHISHING' 
  AND fecha_recepcion > DATEADD(DAY, -7, GETDATE())

UNION ALL

SELECT 
    'APIs con Rate Limit Excedido (Última hora)',
    COUNT(*),
    NULL
FROM LogsAPI 
WHERE resultado = 'LIMITE_EXCEDIDO' 
  AND fecha_log > DATEADD(HOUR, -1, GETDATE());
```

### 7.2 Automatización de Respuestas

```bash
#!/bin/bash
# Script de monitoreo automatizado para aplicaciones
# Ejecutar cada hora via cron

LOG_FILE="/var/log/security_monitor.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$DATE] Iniciando monitoreo de seguridad de aplicaciones" >> $LOG_FILE

# Verificar vulnerabilidades críticas
CRITICAL_VULNS=$(sqlcmd -S localhost -d LogisticaSeguridad -Q \
"SELECT COUNT(*) FROM VulnerabilidadesDetectadas WHERE severidad='CRITICA' AND estado='DETECTADA'" -h -1 -W)

if [ "$CRITICAL_VULNS" -gt 0 ]; then
    echo "[$DATE] ALERTA: $CRITICAL_VULNS vulnerabilidades críticas detectadas" >> $LOG_FILE
    # Enviar notificación inmediata
    curl -X POST "https://alerts.empresa.com/webhook" \
         -H "Content-Type: application/json" \
         -d "{\"alert\": \"critical_vulnerability\", \"count\": $CRITICAL_VULNS}"
fi

# Verificar intentos de API no autorizados
UNAUTH_ATTEMPTS=$(sqlcmd -S localhost -d LogisticaSeguridad -Q \
"SELECT COUNT(*) FROM LogsAPI WHERE resultado='TOKEN_INVALIDO' AND fecha_log > DATEADD(HOUR, -1, GETDATE())" -h -1 -W)

if [ "$UNAUTH_ATTEMPTS" -gt 10 ]; then
    echo "[$DATE] ALERTA: $UNAUTH_ATTEMPTS intentos de API no autorizados en la última hora" >> $LOG_FILE
fi

# Verificar dispositivos móviles no sincronizados
OLD_SYNC=$(sqlcmd -S localhost -d LogisticaSeguridad -Q \
"SELECT COUNT(*) FROM DispositivosMoviles WHERE fecha_ultima_sincronizacion < DATEADD(DAY, -7, GETDATE()) AND estado_dispositivo='ACTIVO'" -h -1 -W)

if [ "$OLD_SYNC" -gt 0 ]; then
    echo "[$DATE] ADVERTENCIA: $OLD_SYNC dispositivos sin sincronizar por más de 7 días" >> $LOG_FILE
fi

echo "[$DATE] Monitoreo completado" >> $LOG_FILE
```

### 7.3 Reportes Ejecutivos

```sql
-- Función para reporte ejecutivo mensual
CREATE FUNCTION fn_ReporteEjecutivoSeguridad(@mes INT, @año INT)
RETURNS TABLE
AS
RETURN (
    SELECT 
        'Incidentes de Seguridad' AS categoria,
        COUNT(*) AS total_mes,
        COUNT(*) - LAG(COUNT(*)) OVER (ORDER BY MONTH(fecha_deteccion)) AS variacion_mes_anterior
    FROM VulnerabilidadesDetectadas
    WHERE MONTH(fecha_deteccion) = @mes AND YEAR(fecha_deteccion) = @año
    
    UNION ALL
    
    SELECT 
        'Dispositivos Comprometidos',
        COUNT(*),
        0
    FROM DispositivosMoviles 
    WHERE estado_dispositivo = 'BLOQUEADO' 
      AND MONTH(fecha_registro) = @mes AND YEAR(fecha_registro) = @año
    
    UNION ALL
    
    SELECT 
        'Emails Maliciosos Bloqueados',
        COUNT(*),
        0
    FROM EmailsRecibidos 
    WHERE nivel_riesgo IN ('PHISHING', 'MALWARE')
      AND MONTH(fecha_recepcion) = @mes AND YEAR(fecha_recepcion) = @año
);
```

---

**Implementación Completa:** Este componente finaliza la política integral de seguridad para el sistema logístico, cubriendo todos los aspectos técnicos y operativos requeridos.

**Siguiente Fase:** Implementación gradual en ambiente de desarrollo, pruebas de seguridad, y despliegue en producción con monitoreo continuo.
