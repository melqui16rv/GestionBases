# POLÍTICA DE COPIAS DE SEGURIDAD, SEGURIDAD FÍSICA Y DEL ENTORNO
## Sistema de Seguridad Logística

---

## TABLA DE CONTENIDO

1. [Objetivos](#objetivos)
2. [Alcance](#alcance)
3. [Definiciones](#definiciones)
4. [Estrategia de Respaldo](#estrategia-de-respaldo)
5. [Seguridad Física](#seguridad-física)
6. [Seguridad del Entorno](#seguridad-del-entorno)
7. [Plan de Contingencia](#plan-de-contingencia)
8. [Monitoreo de Infraestructura](#monitoreo-de-infraestructura)
9. [Procedimientos de Recuperación](#procedimientos-de-recuperación)
10. [Mantenimiento Preventivo](#mantenimiento-preventivo)
11. [Gestión de Incidentes](#gestión-de-incidentes)
12. [Controles Ambientales](#controles-ambientales)

---

## OBJETIVOS

### Objetivo General
Establecer un marco integral para la protección física de la infraestructura del Sistema de Seguridad Logística, garantizando la disponibilidad, integridad y recuperabilidad de los datos mediante estrategias robustas de respaldo y continuidad operacional.

### Objetivos Específicos
1. Definir estrategias de backup que garanticen la disponibilidad de datos críticos
2. Establecer controles de seguridad física para proteger la infraestructura
3. Implementar procedimientos de recuperación ante desastres
4. Crear protocolos de monitoreo continuo de la infraestructura
5. Establecer planes de contingencia para diversos escenarios de falla

## ALCANCE

Esta política aplica a:

### **Infraestructura Física**
- Servidores de base de datos principales y secundarios
- Equipos de red y comunicaciones
- Sistemas de almacenamiento y backup
- Infraestructura de energía y climatización
- Instalaciones del centro de datos

### **Infraestructura Lógica**
- Sistemas operativos y software de base
- Base de datos `seguridad_logistica`
- Aplicaciones del sistema logístico
- Configuraciones de red y seguridad
- Scripts y procedimientos automatizados

### **Procesos Operativos**
- Procedimientos de backup y restore
- Planes de recuperación ante desastres
- Protocolos de mantenimiento
- Gestión de incidentes de infraestructura
- Pruebas de continuidad

## DEFINICIONES

| Término | Definición |
|---------|------------|
| **RTO** | Recovery Time Objective - Tiempo máximo aceptable para restaurar servicios |
| **RPO** | Recovery Point Objective - Pérdida máxima aceptable de datos |
| **MTBF** | Mean Time Between Failures - Tiempo promedio entre fallas |
| **MTTR** | Mean Time To Repair - Tiempo promedio de reparación |
| **Hot Site** | Sitio alterno con infraestructura completamente operativa |
| **Cold Site** | Sitio alterno con infraestructura básica sin datos |
| **Warm Site** | Sitio alterno con infraestructura parcialmente configurada |

## ESTRATEGIA DE RESPALDO

### 4.1 Clasificación de Datos por Criticidad

#### **DATOS CRÍTICOS (Nivel 1)**
- **Contenido:** Tablas `Persona`, `Empleado`, `Ruta`, `Evento`, `Alerta`
- **RPO:** 15 minutos
- **RTO:** 30 minutos
- **Frecuencia de Backup:** Continuo (log shipping) + Full diario
- **Retención:** 90 días online, 7 años offline

#### **DATOS IMPORTANTES (Nivel 2)**
- **Contenido:** Tablas `Vehiculo`, `Cargo`, `HistorialAcceso`
- **RPO:** 1 hora
- **RTO:** 2 horas
- **Frecuencia de Backup:** Incremental cada hora + Full diario
- **Retención:** 30 días online, 3 años offline

#### **DATOS AUXILIARES (Nivel 3)**
- **Contenido:** Tablas de configuración `Estado`, `TipoAcceso`, `Rol`
- **RPO:** 4 horas
- **RTO:** 4 horas
- **Frecuencia de Backup:** Full diario
- **Retención:** 15 días online, 1 año offline

### 4.2 Arquitectura de Backup

#### **Esquema de Backup 3-2-1**
- **3 copias** de datos críticos
- **2 medios** diferentes de almacenamiento
- **1 copia offsite** (fuera del sitio principal)

#### **Implementación Técnica**

```sql
-- Configuración de backup automático para datos críticos
DELIMITER //
CREATE PROCEDURE sp_backup_criticos()
BEGIN
    DECLARE v_fecha VARCHAR(20);
    DECLARE v_ruta_backup VARCHAR(500);
    DECLARE v_comando_backup TEXT;
    
    SET v_fecha = DATE_FORMAT(NOW(), '%Y%m%d_%H%i%s');
    SET v_ruta_backup = CONCAT('/backup/criticos/seguridad_logistica_', v_fecha, '.sql');
    
    -- Backup de tablas críticas
    SET v_comando_backup = CONCAT(
        'mysqldump -u backup_user -p[PASSWORD] ',
        '--single-transaction ',
        '--routines ',
        '--triggers ',
        '--events ',
        'seguridad_logistica ',
        'Persona Empleado Ruta Evento Alerta ',
        '> ', v_ruta_backup
    );
    
    -- Registrar inicio de backup
    INSERT INTO log_backups (tipo_backup, fecha_inicio, estado, ruta_archivo)
    VALUES ('CRITICO', NOW(), 'INICIADO', v_ruta_backup);
    
    -- El comando se ejecutaría externamente vía cron/scheduled task
    -- SET @backup_id = LAST_INSERT_ID();
    
END //
DELIMITER ;

-- Tabla para registro de backups
CREATE TABLE log_backups (
    id_backup INT AUTO_INCREMENT PRIMARY KEY,
    tipo_backup ENUM('FULL','INCREMENTAL','DIFERENCIAL','CRITICO','LOG') NOT NULL,
    fecha_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_fin TIMESTAMP NULL,
    estado ENUM('INICIADO','COMPLETADO','ERROR','CANCELADO') DEFAULT 'INICIADO',
    ruta_archivo VARCHAR(500),
    tamaño_mb DECIMAL(10,2),
    checksum_md5 VARCHAR(32),
    observaciones TEXT
);
```

#### **Script de Backup Automatizado (Bash)**
```bash
#!/bin/bash
# Archivo: /scripts/backup_seguridad_logistica.sh

# Configuración
DB_NAME="seguridad_logistica"
DB_USER="backup_user"
DB_PASS="backup_password"
BACKUP_DIR="/backup"
LOG_FILE="/var/log/backup_seguridad_logistica.log"
RETENTION_DAYS=90
OFFSITE_SERVER="backup-remoto.empresa.com"

# Función de logging
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> $LOG_FILE
}

# Función para backup completo
backup_full() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$BACKUP_DIR/full/seguridad_logistica_full_$timestamp.sql"
    local compressed_file="$backup_file.gz"
    
    log_message "Iniciando backup completo"
    
    # Crear backup
    mysqldump -u$DB_USER -p$DB_PASS \
        --single-transaction \
        --routines \
        --triggers \
        --events \
        --all-databases \
        $DB_NAME > $backup_file
    
    if [ $? -eq 0 ]; then
        # Comprimir backup
        gzip $backup_file
        
        # Calcular checksum
        local checksum=$(md5sum $compressed_file | cut -d' ' -f1)
        local size_mb=$(du -m $compressed_file | cut -f1)
        
        # Registrar en base de datos
        mysql -u$DB_USER -p$DB_PASS $DB_NAME << EOF
UPDATE log_backups 
SET fecha_fin = NOW(), 
    estado = 'COMPLETADO',
    tamaño_mb = $size_mb,
    checksum_md5 = '$checksum'
WHERE ruta_archivo = '$backup_file' 
AND estado = 'INICIADO'
AND tipo_backup = 'FULL';
EOF
        
        # Enviar a sitio remoto
        scp $compressed_file backup@$OFFSITE_SERVER:/backup/remote/
        
        log_message "Backup completo exitoso: $compressed_file"
        
        # Limpiar backups antiguos
        find $BACKUP_DIR/full -name "*.gz" -mtime +$RETENTION_DAYS -delete
        
    else
        log_message "ERROR: Fallo en backup completo"
        mysql -u$DB_USER -p$DB_PASS $DB_NAME << EOF
UPDATE log_backups 
SET fecha_fin = NOW(), 
    estado = 'ERROR',
    observaciones = 'Error en mysqldump'
WHERE ruta_archivo = '$backup_file' 
AND estado = 'INICIADO';
EOF
    fi
}

# Función para backup incremental
backup_incremental() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$BACKUP_DIR/incremental/seguridad_logistica_inc_$timestamp.sql"
    
    log_message "Iniciando backup incremental"
    
    # Backup solo de datos modificados en las últimas 4 horas
    mysqldump -u$DB_USER -p$DB_PASS \
        --single-transaction \
        --where="fecha >= DATE_SUB(NOW(), INTERVAL 4 HOUR)" \
        $DB_NAME \
        HistorialAcceso auditoria_cambios Evento Alerta > $backup_file
    
    if [ $? -eq 0 ]; then
        gzip $backup_file
        log_message "Backup incremental exitoso: $backup_file.gz"
    else
        log_message "ERROR: Fallo en backup incremental"
    fi
}

# Función para backup de logs de transacciones
backup_transaction_logs() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local log_backup_dir="$BACKUP_DIR/logs"
    
    log_message "Iniciando backup de logs de transacciones"
    
    # Flush logs para forzar rotación
    mysql -u$DB_USER -p$DB_PASS -e "FLUSH LOGS;"
    
    # Copiar logs binarios
    cp /var/lib/mysql/mysql-bin.* $log_backup_dir/
    
    log_message "Backup de logs completado"
}

# Ejecución según parámetro
case "$1" in
    "full")
        backup_full
        ;;
    "incremental")
        backup_incremental
        ;;
    "logs")
        backup_transaction_logs
        ;;
    *)
        echo "Uso: $0 {full|incremental|logs}"
        exit 1
        ;;
esac
```

#### **Configuración de Crontab**
```bash
# Crontab para backups automatizados
# Backup completo diario a las 2:00 AM
0 2 * * * /scripts/backup_seguridad_logistica.sh full

# Backup incremental cada 4 horas
0 */4 * * * /scripts/backup_seguridad_logistica.sh incremental

# Backup de logs cada hora
0 * * * * /scripts/backup_seguridad_logistica.sh logs

# Verificación de integridad de backups diaria a las 3:00 AM
0 3 * * * /scripts/verificar_backups.sh

# Sincronización con sitio remoto cada 6 horas
0 */6 * * * /scripts/sync_offsite.sh
```

### 4.3 Validación de Backups

#### **Verificación Automática de Integridad**
```bash
#!/bin/bash
# Archivo: /scripts/verificar_backups.sh

BACKUP_DIR="/backup"
LOG_FILE="/var/log/verificacion_backups.log"
TEST_DB="test_restore"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> $LOG_FILE
}

verificar_backup() {
    local backup_file=$1
    local checksum_original=$2
    
    log_message "Verificando backup: $backup_file"
    
    # Verificar integridad del archivo
    if [ -f "$backup_file" ]; then
        local checksum_actual=$(md5sum $backup_file | cut -d' ' -f1)
        
        if [ "$checksum_actual" = "$checksum_original" ]; then
            log_message "Checksum OK para $backup_file"
            
            # Prueba de restauración en base de datos de prueba
            gunzip -c $backup_file | mysql -u root -p[PASSWORD] $TEST_DB
            
            if [ $? -eq 0 ]; then
                # Verificar que las tablas principales existen
                local tabla_count=$(mysql -u root -p[PASSWORD] $TEST_DB -e "SHOW TABLES;" | wc -l)
                
                if [ $tabla_count -gt 10 ]; then
                    log_message "Restauración de prueba exitosa para $backup_file"
                    mysql -u root -p[PASSWORD] -e "DROP DATABASE $TEST_DB; CREATE DATABASE $TEST_DB;"
                    return 0
                else
                    log_message "ERROR: Restauración incompleta para $backup_file"
                    return 1
                fi
            else
                log_message "ERROR: Fallo en restauración de prueba para $backup_file"
                return 1
            fi
        else
            log_message "ERROR: Checksum no coincide para $backup_file"
            return 1
        fi
    else
        log_message "ERROR: Archivo no encontrado $backup_file"
        return 1
    fi
}

# Verificar backups de los últimos 7 días
mysql -u backup_user -p[PASSWORD] seguridad_logistica << 'EOF'
SELECT ruta_archivo, checksum_md5 
FROM log_backups 
WHERE fecha_inicio >= DATE_SUB(NOW(), INTERVAL 7 DAY)
AND estado = 'COMPLETADO'
AND tipo_backup = 'FULL';
EOF
```

## SEGURIDAD FÍSICA

### 5.1 Seguridad del Centro de Datos

#### **Control de Acceso Físico**

**Niveles de Seguridad:**
- **Perímetro Externo:** Cercas, cámaras, guardias de seguridad
- **Edificio:** Tarjetas de acceso, control biométrico
- **Sala de Servidores:** Doble autenticación, registro de accesos
- **Racks Críticos:** Cerraduras adicionales, sensores de apertura

**Implementación de Control de Acceso:**
```sql
-- Tabla para registro de accesos físicos
CREATE TABLE accesos_fisicos (
    id_acceso INT AUTO_INCREMENT PRIMARY KEY,
    cedula_persona VARCHAR(10) NOT NULL,
    zona_acceso ENUM('PERIMETRO','EDIFICIO','SALA_SERVIDORES','RACK_CRITICO') NOT NULL,
    tipo_acceso ENUM('ENTRADA','SALIDA') NOT NULL,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metodo_autenticacion ENUM('TARJETA','BIOMETRICO','CLAVE','ACOMPAÑADO') NOT NULL,
    autorizado_por VARCHAR(10) NULL,
    observaciones TEXT,
    FOREIGN KEY (cedula_persona) REFERENCES Persona(Cedula),
    FOREIGN KEY (autorizado_por) REFERENCES Persona(Cedula)
);

-- Vista para monitoreo de accesos físicos sospechosos
CREATE VIEW v_accesos_fisicos_sospechosos AS
SELECT 
    af.cedula_persona,
    p.Nombre,
    p.Apellido,
    af.zona_acceso,
    af.fecha_hora,
    af.metodo_autenticacion,
    COUNT(*) OVER (
        PARTITION BY af.cedula_persona, DATE(af.fecha_hora) 
        ORDER BY af.fecha_hora 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) as accesos_dia
FROM accesos_fisicos af
JOIN Persona p ON af.cedula_persona = p.Cedula
WHERE af.fecha_hora >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
AND (
    TIME(af.fecha_hora) BETWEEN '22:00:00' AND '06:00:00' OR -- Fuera de horario
    af.zona_acceso = 'RACK_CRITICO' OR -- Acceso a área crítica
    af.metodo_autenticacion = 'ACOMPAÑADO' -- Requiere supervisión
)
ORDER BY af.fecha_hora DESC;

-- Trigger para alertas de acceso físico
DELIMITER //
CREATE TRIGGER tr_alerta_acceso_fisico
AFTER INSERT ON accesos_fisicos
FOR EACH ROW
BEGIN
    DECLARE v_accesos_recientes INT DEFAULT 0;
    DECLARE v_es_horario_critico BOOLEAN DEFAULT FALSE;
    
    -- Contar accesos recientes del mismo usuario
    SELECT COUNT(*) INTO v_accesos_recientes
    FROM accesos_fisicos
    WHERE cedula_persona = NEW.cedula_persona
    AND fecha_hora >= DATE_SUB(NOW(), INTERVAL 1 HOUR);
    
    -- Verificar si es horario crítico
    IF TIME(NEW.fecha_hora) BETWEEN '22:00:00' AND '06:00:00' THEN
        SET v_es_horario_critico = TRUE;
    END IF;
    
    -- Generar alerta si hay condiciones sospechosas
    IF v_accesos_recientes > 10 OR 
       (v_es_horario_critico AND NEW.zona_acceso IN ('SALA_SERVIDORES', 'RACK_CRITICO')) THEN
        
        INSERT INTO Alerta (id_empleado, id_evento, Fecha)
        SELECT em.id_empleado, 998, NOW()  -- 998 = Evento de seguridad física
        FROM Empleado em 
        WHERE em.id_persona = NEW.cedula_persona;
    END IF;
END //
DELIMITER ;
```

#### **Sistema de Videovigilancia**

**Configuración de Cámaras:**
- **Cobertura 360°** en sala de servidores
- **Grabación continua** con retención de 90 días
- **Detección de movimiento** con alertas automáticas
- **Redundancia** en sistemas de grabación

**Integración con Sistema de Alertas:**
```sql
-- Tabla para eventos de videovigilancia
CREATE TABLE eventos_videovigilancia (
    id_evento_video INT AUTO_INCREMENT PRIMARY KEY,
    camara_id VARCHAR(20) NOT NULL,
    tipo_evento ENUM('MOVIMIENTO','ACCESO_NO_AUTORIZADO','MANIPULACION_EQUIPO','ANOMALIA') NOT NULL,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ubicacion VARCHAR(100) NOT NULL,
    nivel_confianza DECIMAL(3,2), -- 0.00 a 1.00
    archivo_video VARCHAR(255),
    estado_revision ENUM('PENDIENTE','REVISADO','FALSA_ALARMA','INCIDENTE_CONFIRMADO') DEFAULT 'PENDIENTE',
    revisado_por VARCHAR(10) NULL,
    observaciones TEXT,
    FOREIGN KEY (revisado_por) REFERENCES Persona(Cedula)
);

-- Procedure para procesar eventos de video
DELIMITER //
CREATE PROCEDURE sp_procesar_evento_video(
    IN p_camara_id VARCHAR(20),
    IN p_tipo_evento VARCHAR(50),
    IN p_ubicacion VARCHAR(100),
    IN p_nivel_confianza DECIMAL(3,2)
)
BEGIN
    DECLARE v_es_critico BOOLEAN DEFAULT FALSE;
    
    -- Insertar evento de video
    INSERT INTO eventos_videovigilancia 
    (camara_id, tipo_evento, ubicacion, nivel_confianza)
    VALUES 
    (p_camara_id, p_tipo_evento, p_ubicacion, p_nivel_confianza);
    
    -- Determinar si es evento crítico
    IF p_tipo_evento IN ('ACCESO_NO_AUTORIZADO', 'MANIPULACION_EQUIPO') 
       AND p_nivel_confianza > 0.8 THEN
        SET v_es_critico = TRUE;
    END IF;
    
    -- Generar alerta automática para eventos críticos
    IF v_es_critico THEN
        INSERT INTO Alerta (id_empleado, id_evento, Fecha)
        VALUES (1, 997, NOW()); -- 997 = Evento de videovigilancia crítico
    END IF;
    
END //
DELIMITER ;
```

### 5.2 Protección de Equipos

#### **Inventario de Hardware Crítico**
```sql
-- Tabla para inventario de equipos
CREATE TABLE inventario_hardware (
    id_equipo INT AUTO_INCREMENT PRIMARY KEY,
    numero_serie VARCHAR(50) UNIQUE NOT NULL,
    tipo_equipo ENUM('SERVIDOR','SWITCH','ROUTER','FIREWALL','UPS','STORAGE') NOT NULL,
    marca VARCHAR(50) NOT NULL,
    modelo VARCHAR(100) NOT NULL,
    ubicacion_fisica VARCHAR(100) NOT NULL,
    ip_gestion VARCHAR(45),
    estado ENUM('ACTIVO','MANTENIMIENTO','FALLA','RETIRADO') DEFAULT 'ACTIVO',
    fecha_instalacion DATE NOT NULL,
    fecha_ultimo_mantenimiento DATE,
    responsable_tecnico VARCHAR(10),
    criticidad ENUM('CRITICA','ALTA','MEDIA','BAJA') NOT NULL,
    observaciones TEXT,
    FOREIGN KEY (responsable_tecnico) REFERENCES Persona(Cedula)
);

-- Vista para equipos críticos que requieren atención
CREATE VIEW v_equipos_atencion AS
SELECT 
    ih.numero_serie,
    ih.tipo_equipo,
    ih.marca,
    ih.modelo,
    ih.ubicacion_fisica,
    ih.estado,
    ih.fecha_ultimo_mantenimiento,
    DATEDIFF(NOW(), ih.fecha_ultimo_mantenimiento) as dias_sin_mantenimiento,
    p.Nombre as responsable_nombre,
    CASE 
        WHEN ih.estado = 'FALLA' THEN 'URGENTE'
        WHEN ih.criticidad = 'CRITICA' AND DATEDIFF(NOW(), ih.fecha_ultimo_mantenimiento) > 30 THEN 'ALTA'
        WHEN ih.criticidad = 'ALTA' AND DATEDIFF(NOW(), ih.fecha_ultimo_mantenimiento) > 60 THEN 'MEDIA'
        WHEN DATEDIFF(NOW(), ih.fecha_ultimo_mantenimiento) > 90 THEN 'BAJA'
        ELSE 'NORMAL'
    END as prioridad_atencion
FROM inventario_hardware ih
LEFT JOIN Persona p ON ih.responsable_tecnico = p.Cedula
WHERE ih.estado != 'RETIRADO'
AND (
    ih.estado = 'FALLA' 
    OR DATEDIFF(NOW(), ih.fecha_ultimo_mantenimiento) > 30
)
ORDER BY 
    FIELD(prioridad_atencion, 'URGENTE', 'ALTA', 'MEDIA', 'BAJA'),
    dias_sin_mantenimiento DESC;
```

#### **Registro de Mantenimiento Preventivo**
```sql
-- Tabla para registro de mantenimiento
CREATE TABLE mantenimiento_preventivo (
    id_mantenimiento INT AUTO_INCREMENT PRIMARY KEY,
    id_equipo INT NOT NULL,
    tipo_mantenimiento ENUM('PREVENTIVO','CORRECTIVO','ACTUALIZACION') NOT NULL,
    fecha_programada DATE NOT NULL,
    fecha_realizada DATE,
    tecnico_responsable VARCHAR(10),
    tiempo_inactividad_minutos INT DEFAULT 0,
    descripcion_trabajo TEXT NOT NULL,
    estado ENUM('PROGRAMADO','EN_PROCESO','COMPLETADO','CANCELADO') DEFAULT 'PROGRAMADO',
    observaciones TEXT,
    costo_mantenimiento DECIMAL(10,2),
    proveedor_servicio VARCHAR(100),
    FOREIGN KEY (id_equipo) REFERENCES inventario_hardware(id_equipo),
    FOREIGN KEY (tecnico_responsable) REFERENCES Persona(Cedula)
);

-- Procedimiento para programar mantenimiento automático
DELIMITER //
CREATE PROCEDURE programar_mantenimiento_automatico()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_id_equipo INT;
    DECLARE v_tipo_equipo VARCHAR(20);
    DECLARE v_dias_mantenimiento INT;
    DECLARE v_fecha_proximo DATE;
    
    DECLARE cursor_equipos CURSOR FOR
        SELECT id_equipo, tipo_equipo FROM inventario_hardware WHERE estado = 'ACTIVO';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cursor_equipos;
    
    equipo_loop: LOOP
        FETCH cursor_equipos INTO v_id_equipo, v_tipo_equipo;
        IF done THEN
            LEAVE equipo_loop;
        END IF;
        
        -- Definir intervalos según tipo de equipo
        CASE v_tipo_equipo
            WHEN 'SERVIDOR' THEN SET v_dias_mantenimiento = 30;
            WHEN 'SWITCH' THEN SET v_dias_mantenimiento = 60;
            WHEN 'ROUTER' THEN SET v_dias_mantenimiento = 60;
            WHEN 'FIREWALL' THEN SET v_dias_mantenimiento = 30;
            WHEN 'UPS' THEN SET v_dias_mantenimiento = 90;
            WHEN 'STORAGE' THEN SET v_dias_mantenimiento = 30;
            ELSE SET v_dias_mantenimiento = 60;
        END CASE;
        
        SET v_fecha_proximo = DATE_ADD(CURDATE(), INTERVAL v_dias_mantenimiento DAY);
        
        -- Verificar si ya existe mantenimiento programado
        IF NOT EXISTS (
            SELECT 1 FROM mantenimiento_preventivo 
            WHERE id_equipo = v_id_equipo 
            AND fecha_programada >= CURDATE()
            AND estado IN ('PROGRAMADO', 'EN_PROCESO')
        ) THEN
            INSERT INTO mantenimiento_preventivo (
                id_equipo, 
                tipo_mantenimiento, 
                fecha_programada, 
                descripcion_trabajo
            ) VALUES (
                v_id_equipo, 
                'PREVENTIVO', 
                v_fecha_proximo,
                CONCAT('Mantenimiento preventivo programado automáticamente para ', v_tipo_equipo)
            );
        END IF;
        
    END LOOP;
    
    CLOSE cursor_equipos;
END //
DELIMITER ;
```

## 6. Protocolos de Seguridad Física

### 6.1 Control de Acceso al Centro de Datos

#### **Procedimientos de Acceso**
```sql
-- Tabla para registro de accesos al centro de datos
CREATE TABLE acceso_centro_datos (
    id_acceso INT AUTO_INCREMENT PRIMARY KEY,
    cedula_persona VARCHAR(10) NOT NULL,
    tipo_acceso ENUM('ENTRADA','SALIDA') NOT NULL,
    timestamp_acceso TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    puerta_acceso ENUM('PRINCIPAL','EMERGENCIA','MANTENIMIENTO') NOT NULL,
    motivo_acceso VARCHAR(200),
    autorizado_por VARCHAR(10),
    tiempo_permanencia_minutos INT,
    dispositivos_introducidos TEXT,
    observaciones TEXT,
    FOREIGN KEY (cedula_persona) REFERENCES Persona(Cedula),
    FOREIGN KEY (autorizado_por) REFERENCES Persona(Cedula)
);

-- Trigger para validar accesos autorizados
DELIMITER //
CREATE TRIGGER validar_acceso_centro_datos
BEFORE INSERT ON acceso_centro_datos
FOR EACH ROW
BEGIN
    DECLARE v_tipo_empleado VARCHAR(50);
    DECLARE v_horario_permitido BOOLEAN DEFAULT FALSE;
    DECLARE v_hora_actual TIME;
    
    SELECT TipoEmpleado INTO v_tipo_empleado 
    FROM Empleado e 
    JOIN Persona p ON e.Cedula = p.Cedula 
    WHERE p.Cedula = NEW.cedula_persona;
    
    SET v_hora_actual = TIME(NOW());
    
    -- Verificar horarios permitidos según tipo de empleado
    IF v_tipo_empleado = 'DBA' OR v_tipo_empleado = 'ADMINISTRADOR_SISTEMA' THEN
        SET v_horario_permitido = TRUE; -- Acceso 24/7
    ELSEIF v_tipo_empleado = 'TECNICO' AND v_hora_actual BETWEEN '06:00:00' AND '22:00:00' THEN
        SET v_horario_permitido = TRUE;
    ELSEIF v_tipo_empleado = 'OPERADOR' AND v_hora_actual BETWEEN '08:00:00' AND '18:00:00' THEN
        SET v_horario_permitido = TRUE;
    END IF;
    
    -- Si no está autorizado y no es emergencia, rechazar
    IF NOT v_horario_permitido AND NEW.puerta_acceso != 'EMERGENCIA' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Acceso denegado: Fuera del horario permitido para su rol';
    END IF;
    
    -- Verificar autorización para acceso fuera de horario
    IF NOT v_horario_permitido AND NEW.autorizado_por IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Acceso fuera de horario requiere autorización';
    END IF;
END //
DELIMITER ;
```

### 6.2 Protección Contra Amenazas Ambientales

#### **Monitoreo de Condiciones Críticas**
```bash
#!/bin/bash
# Script: monitor_ambiental_critico.sh
# Descripción: Monitoreo crítico de condiciones ambientales

LOG_DIR="/var/log/seguridad/ambiental"
TEMP_THRESHOLD_HIGH=25
TEMP_THRESHOLD_LOW=18
HUMIDITY_THRESHOLD_HIGH=60
HUMIDITY_THRESHOLD_LOW=40

# Función para enviar alertas críticas
send_critical_alert() {
    local message=$1
    local severity=$2
    
    echo "$(date '+%Y-%m-%d %H:%M:%S') [CRITICAL] $message" >> $LOG_DIR/alertas_criticas.log
    
    # Envío de notificación al equipo
    mysql -u monitor_user -p$MONITOR_PASS seguridad_logistica -e "
    INSERT INTO Alerta (id_empleado, id_evento, Fecha, descripcion) 
    VALUES (1, 998, NOW(), '$message');
    "
    
    # Activar sistemas de respuesta automática
    if [[ $severity == "FIRE" ]]; then
        activate_fire_suppression
    elif [[ $severity == "FLOOD" ]]; then
        activate_flood_protection
    fi
}

# Monitoreo de temperatura
check_temperature() {
    local temp=$(sensors | grep 'Core 0' | awk '{print $3}' | sed 's/[^0-9.]//g')
    
    if (( $(echo "$temp > $TEMP_THRESHOLD_HIGH" | bc -l) )); then
        send_critical_alert "Temperatura crítica detectada: ${temp}°C" "OVERHEAT"
    elif (( $(echo "$temp < $TEMP_THRESHOLD_LOW" | bc -l) )); then
        send_critical_alert "Temperatura baja crítica: ${temp}°C" "COLD"
    fi
}

# Monitoreo de humedad
check_humidity() {
    local humidity=$(cat /sys/class/humidity/humidity0/humidity_input 2>/dev/null || echo "50")
    
    if [ $humidity -gt $HUMIDITY_THRESHOLD_HIGH ]; then
        send_critical_alert "Humedad excesiva: ${humidity}%" "HUMIDITY_HIGH"
    elif [ $humidity -lt $HUMIDITY_THRESHOLD_LOW ]; then
        send_critical_alert "Humedad baja: ${humidity}%" "HUMIDITY_LOW"
    fi
}

# Detección de humo
check_smoke_detection() {
    local smoke_level=$(cat /sys/class/smoke_detector/smoke0/level 2>/dev/null || echo "0")
    
    if [ $smoke_level -gt 5 ]; then
        send_critical_alert "DETECCIÓN DE HUMO - Nivel: $smoke_level" "FIRE"
    fi
}

# Detección de agua
check_water_detection() {
    local water_level=$(cat /sys/class/water_sensor/water0/level 2>/dev/null || echo "0")
    
    if [ $water_level -gt 2 ]; then
        send_critical_alert "DETECCIÓN DE AGUA - Nivel: $water_level" "FLOOD"
    fi
}

# Sistemas de respuesta automática
activate_fire_suppression() {
    echo "$(date) ACTIVANDO SISTEMA DE SUPRESIÓN DE INCENDIOS" >> $LOG_DIR/emergency_actions.log
    # Comandos para activar sistema de supresión
    # systemctl start fire_suppression_system
}

activate_flood_protection() {
    echo "$(date) ACTIVANDO PROTECCIÓN CONTRA INUNDACIONES" >> $LOG_DIR/emergency_actions.log
    # Comandos para protección contra agua
    # systemctl start water_pumps
}

# Ejecución principal
main() {
    mkdir -p $LOG_DIR
    
    while true; do
        check_temperature
        check_humidity
        check_smoke_detection
        check_water_detection
        
        sleep 30 # Verificación cada 30 segundos
    done
}

# Ejecución como daemon
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

## 7. Plan de Continuidad del Negocio

### 7.1 Análisis de Impacto al Negocio (BIA)

#### **Clasificación de Procesos Críticos**
```sql
-- Tabla para análisis de impacto al negocio
CREATE TABLE proceso_negocio (
    id_proceso INT AUTO_INCREMENT PRIMARY KEY,
    nombre_proceso VARCHAR(100) NOT NULL,
    descripcion TEXT,
    nivel_criticidad ENUM('CRITICO','ALTO','MEDIO','BAJO') NOT NULL,
    rto_minutos INT NOT NULL, -- Recovery Time Objective
    rpo_minutos INT NOT NULL, -- Recovery Point Objective
    impacto_financiero_hora DECIMAL(15,2),
    dependencias_tecnologicas TEXT,
    responsable_proceso VARCHAR(10),
    fecha_ultima_evaluacion DATE,
    FOREIGN KEY (responsable_proceso) REFERENCES Persona(Cedula)
);

-- Insertar procesos críticos del sistema logístico
INSERT INTO proceso_negocio VALUES
(1, 'Gestión de Vehículos', 'Control y seguimiento de flota vehicular', 'CRITICO', 15, 5, 5000.00, 'Base de datos principal, sistema GPS', '1001', CURDATE()),
(2, 'Control de Empleados', 'Gestión de personal y accesos', 'ALTO', 30, 15, 3000.00, 'Base de datos, sistema de autenticación', '1002', CURDATE()),
(3, 'Seguimiento GPS', 'Monitoreo en tiempo real de ubicaciones', 'CRITICO', 5, 2, 8000.00, 'Servidores GPS, base de datos, conectividad', '1003', CURDATE()),
(4, 'Gestión de Eventos', 'Registro y seguimiento de incidentes', 'ALTO', 20, 10, 2000.00, 'Base de datos, sistema de alertas', '1004', CURDATE()),
(5, 'Generación de Reportes', 'Informes operacionales y gerenciales', 'MEDIO', 60, 30, 1000.00, 'Base de datos, herramientas de BI', '1005', CURDATE());
```

### 7.2 Procedimientos de Activación del Plan

#### **Script de Activación de Emergencia**
```bash
#!/bin/bash
# Script: activar_plan_continuidad.sh
# Descripción: Activación del plan de continuidad de negocio

INCIDENT_TYPE=$1
SEVERITY_LEVEL=$2
LOG_FILE="/var/log/seguridad/continuidad_negocio.log"

# Validar parámetros
if [ -z "$INCIDENT_TYPE" ] || [ -z "$SEVERITY_LEVEL" ]; then
    echo "Uso: $0 <TIPO_INCIDENTE> <NIVEL_SEVERIDAD>"
    echo "Tipos: FALLA_HARDWARE, FALLA_SOFTWARE, DESASTRE_NATURAL, CIBERATAQUE"
    echo "Niveles: 1-BAJO, 2-MEDIO, 3-ALTO, 4-CRITICO"
    exit 1
fi

# Función de logging
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$SEVERITY_LEVEL] $1" >> $LOG_FILE
}

# Notificación al equipo de emergencia
notify_emergency_team() {
    log_action "Notificando al equipo de emergencia - Incidente: $INCIDENT_TYPE"
    
    # Insertar notificación en base de datos
    mysql -u emergency_user -p$EMERGENCY_PASS seguridad_logistica -e "
    INSERT INTO Alerta (id_empleado, id_evento, Fecha, descripcion) 
    VALUES (1, 999, NOW(), 'PLAN DE CONTINUIDAD ACTIVADO: $INCIDENT_TYPE - Nivel $SEVERITY_LEVEL');
    "
    
    # Enviar SMS/Email al equipo (simulación)
    echo "ALERTA CRÍTICA: Plan de continuidad activado" | mail -s "EMERGENCIA SISTEMA" emergency@empresa.com
}

# Activación del sitio de respaldo
activate_backup_site() {
    log_action "Iniciando activación del sitio de respaldo"
    
    case $SEVERITY_LEVEL in
        4) # CRITICO - Activación completa
            log_action "Activación completa del sitio de respaldo"
            # Redirigir tráfico al sitio de respaldo
            sudo iptables -t nat -A OUTPUT -p tcp --dport 3306 -j DNAT --to-destination 192.168.2.100:3306
            # Iniciar servicios críticos
            systemctl start mysql-backup
            systemctl start web-backup
            ;;
        3) # ALTO - Activación parcial
            log_action "Activación parcial del sitio de respaldo"
            # Solo servicios críticos
            systemctl start mysql-backup
            ;;
        2) # MEDIO - Preparación
            log_action "Preparando sitio de respaldo"
            # Sincronización adicional
            /opt/scripts/sync_to_backup.sh
            ;;
        1) # BAJO - Monitoreo
            log_action "Incrementando monitoreo"
            ;;
    esac
}

# Procedimientos específicos por tipo de incidente
handle_hardware_failure() {
    log_action "Manejando falla de hardware"
    
    # Verificar servicios afectados
    systemctl is-active mysql || {
        log_action "Servicio MySQL caído - Iniciando recuperación"
        systemctl start mysql
        sleep 30
        systemctl is_active mysql || activate_backup_site
    }
    
    # Verificar integridad de datos
    mysqlcheck -u dba_principal -p$DBA_PASS --all-databases --check
}

handle_cyber_attack() {
    log_action "Respondiendo a ciberataque"
    
    # Aislar sistemas comprometidos
    iptables -A INPUT -j DROP
    iptables -A OUTPUT -j DROP
    
    # Activar modo de solo lectura
    mysql -u dba_principal -p$DBA_PASS -e "FLUSH TABLES WITH READ LOCK;"
    
    # Crear snapshot de emergencia
    /opt/scripts/emergency_backup.sh
    
    log_action "Sistemas aislados - Investigación forense iniciada"
}

handle_natural_disaster() {
    log_action "Respondiendo a desastre natural"
    
    # Activación inmediata de sitio alterno
    activate_backup_site
    
    # Comunicación con personal remoto
    log_action "Activando protocolos de trabajo remoto"
}

# Función principal
main() {
    log_action "=== ACTIVACIÓN PLAN DE CONTINUIDAD ==="
    log_action "Tipo de incidente: $INCIDENT_TYPE"
    log_action "Nivel de severidad: $SEVERITY_LEVEL"
    
    notify_emergency_team
    
    case $INCIDENT_TYPE in
        "FALLA_HARDWARE")
            handle_hardware_failure
            ;;
        "CIBERATAQUE")
            handle_cyber_attack
            ;;
        "DESASTRE_NATURAL")
            handle_natural_disaster
            ;;
        "FALLA_SOFTWARE")
            log_action "Iniciando procedimientos de recuperación de software"
            /opt/scripts/software_recovery.sh
            ;;
        *)
            log_action "Tipo de incidente no reconocido - Aplicando procedimientos generales"
            activate_backup_site
            ;;
    esac
    
    log_action "Activación del plan completada"
    log_action "============================================"
}

# Verificar permisos de ejecución
if [ "$EUID" -ne 0 ]; then
    echo "Este script debe ejecutarse como root"
    exit 1
fi

# Ejecutar función principal
main
```

### 7.3 Pruebas de Recuperación

#### **Procedimiento de Pruebas Programadas**
```sql
-- Tabla para registro de pruebas de continuidad
CREATE TABLE prueba_continuidad (
    id_prueba INT AUTO_INCREMENT PRIMARY KEY,
    tipo_prueba ENUM('BACKUP_RESTORE','FAILOVER','DISASTER_RECOVERY','SECURITY_BREACH') NOT NULL,
    fecha_programada DATE NOT NULL,
    fecha_ejecutada DATETIME,
    resultado ENUM('EXITOSO','PARCIAL','FALLIDO','PENDIENTE') DEFAULT 'PENDIENTE',
    tiempo_recuperacion_minutos INT,
    rto_objetivo_minutos INT,
    rpo_logrado_minutos INT,
    rpo_objetivo_minutos INT,
    responsable_prueba VARCHAR(10),
    observaciones TEXT,
    acciones_correctivas TEXT,
    proxima_prueba DATE,
    FOREIGN KEY (responsable_prueba) REFERENCES Persona(Cedula)
);

-- Procedimiento para programar pruebas automáticas
DELIMITER //
CREATE PROCEDURE programar_pruebas_continuidad()
BEGIN
    DECLARE v_fecha_base DATE DEFAULT CURDATE();
    
    -- Pruebas mensuales de backup/restore
    INSERT INTO prueba_continuidad (
        tipo_prueba, 
        fecha_programada, 
        rto_objetivo_minutos, 
        rpo_objetivo_minutos,
        responsable_prueba
    ) VALUES 
    ('BACKUP_RESTORE', DATE_ADD(v_fecha_base, INTERVAL 1 MONTH), 30, 15, '1001'),
    ('FAILOVER', DATE_ADD(v_fecha_base, INTERVAL 2 MONTH), 15, 5, '1002'),
    ('DISASTER_RECOVERY', DATE_ADD(v_fecha_base, INTERVAL 3 MONTH), 60, 30, '1001'),
    ('SECURITY_BREACH', DATE_ADD(v_fecha_base, INTERVAL 1 MONTH), 45, 20, '1003');
    
END //
DELIMITER ;
```

## 8. Conclusiones y Recomendaciones

### 8.1 Resumen de Implementación

El Sistema de Seguridad Logística requiere una estrategia integral que abarca desde la protección física de la infraestructura hasta la continuidad operacional del negocio. Las medidas implementadas en este documento incluyen:

- **Respaldo automatizado con verificación de integridad** cada 4 horas
- **Monitoreo ambiental continuo** con respuesta automática a emergencias
- **Control de acceso físico** con registro completo de auditoría
- **Plan de continuidad** con RTO/RPO definidos para cada proceso crítico

### 8.2 Métricas de Cumplimiento

```sql
-- Vista para métricas de cumplimiento de seguridad
CREATE VIEW v_metricas_cumplimiento AS
SELECT 
    'Disponibilidad Sistema' as metrica,
    CONCAT(ROUND((COUNT(*) - SUM(CASE WHEN estado = 'FALLA' THEN 1 ELSE 0 END)) * 100.0 / COUNT(*), 2), '%') as valor_actual,
    '99.9%' as objetivo
FROM inventario_hardware
UNION ALL
SELECT 
    'Backups Exitosos (30 días)',
    CONCAT(ROUND(AVG(CASE WHEN resultado = 'EXITOSO' THEN 100 ELSE 0 END), 2), '%'),
    '100%'
FROM log_backup 
WHERE fecha_backup >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
UNION ALL
SELECT 
    'Tiempo Promedio RTO',
    CONCAT(ROUND(AVG(tiempo_recuperacion_minutos), 0), ' min'),
    '30 min'
FROM prueba_continuidad 
WHERE resultado = 'EXITOSO' AND fecha_ejecutada >= DATE_SUB(CURDATE(), INTERVAL 90 DAY);
```

### 8.3 Próximos Pasos

1. **Implementación gradual** de los procedimientos automatizados
2. **Capacitación del personal** en los nuevos protocolos de seguridad
3. **Pruebas de stress** del plan de continuidad
4. **Revisión trimestral** de todas las métricas de seguridad
5. **Actualización de hardware** según cronograma de mantenimiento

### 8.4 Responsabilidades

- **DBA Principal**: Supervisión general de backups y recuperación
- **Administrador de Sistemas**: Monitoreo de infraestructura física
- **Jefe de Seguridad**: Coordinación de respuesta a incidentes
- **Gerente de TI**: Aprobación de cambios y presupuesto

---

**Documento:** Política de Seguridad - Componente 2  
**Versión:** 1.0  
**Fecha:** $(date '+%B %Y')  
**Estado:** Implementación
