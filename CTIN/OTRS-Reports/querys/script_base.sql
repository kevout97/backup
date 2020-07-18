/*
* Sentencias para la creación de la base de datos a la cual
* Jasper hará las consultas para la creacion de cada grafica 
* en el reporte
*/

/*Creación de Base de Datos*/
DROP DATABASE IF EXISTS BaseJasper;
CREATE DATABASE BaseJasper;
USE BaseJasper;








DROP PROCEDURE IF EXISTS init_tablas;
DELIMITER $$
CREATE PROCEDURE init_tablas ()
BEGIN
/*Tabla de la grafica (Tickets abiertos vs Tickets cerrados)*/
DROP TABLE IF EXISTS BaseJasper.tickets_abiertos_cerrados;
CREATE TABLE BaseJasper.tickets_abiertos_cerrados (idGerencia INT, total_abiertos INT default 0, total_cerrados INT default 0);
/*Tabla de la grafica (Estado de los tickets vs Cantidad de tickets en ese estado)*/
DROP TABLE IF EXISTS BaseJasper.solicitudes_estado;
CREATE TABLE BaseJasper.solicitudes_estado (estado_nombre VARCHAR(200), idEstado INT,total_solicitudes INT default 0);
/*Tabla de la grafica Gerencias y cantidad de tikckets en cada estado*/
DROP TABLE IF EXISTS BaseJasper.gerencias_estados;
CREATE TABLE BaseJasper.gerencias_estados (idGerencia int,
                                estado_new int default 0,
                                estado_closed_successful int default 0,
                                estado_closed_unsuccessful int default 0,
                                estado_open int default 0,
                                estado_removed int default 0,
                                estado_pending_reminder int default 0,
                                estado_pending_auto_close_mas int default 0,
                                estado_pending_auto_close_menos int default 0,
                                estado_merged int default 0,
                                estado_closed_with_workaround int default 0,
                                estado_Awaiting_Scheduled_Time int default 0,
                                estado_Awaiting_Precedent_Requirement int default 0,
                                estado_open_L2 int default 0,
                                estado_open_L3 int default 0,
                                estado_L1_follow_up int default 0,
                                estado_L1_follow_up_pending_reminder int default 0,
                                estado_closed_without_validation int default 0,
                                estado_closed_invalid_request int default 0,
                                estado_Awaiting_for_missing_information  int default 0,
                                estado_impact_analysis int default 0,
                                estado_application_for_team_leader_approval int default 0,
                                estado_application_for_business_risk_approval int default 0,
                                estado_Queued_L2 int default 0);

DROP TABLE IF EXISTS BaseJasper.solicitudes_pendientes_semanal;
CREATE TABLE BaseJasper.solicitudes_pendientes_semanal (fecha DATETIME, porcentaje INT);
INSERT INTO BaseJasper.solicitudes_pendientes_semanal VALUES ("2018-08-20 18:00:00",70),
                                                        ("2018-08-27 18:00:00",64),
                                                        ("2018-09-03 18:00:00",61),
                                                        ("2018-09-10 18:00:00",67),
                                                        ("2018-09-17 18:00:00",63),
                                                        ("2018-09-24 18:00:00",61),
                                                        ("2018-10-01 18:00:00",49),
                                                        ("2018-10-08 18:00:00",66),
                                                        ("2018-10-15 18:00:00",60),
                                                        ("2018-10-22 18:00:00",59),
                                                        ("2018-10-29 18:00:00",87),
                                                        ("2018-11-05 18:00:00",67),
                                                        ("2018-11-12 18:00:00",68),
                                                        ("2018-11-19 18:00:00",69),
                                                        ("2018-11-26 18:00:00",64),
                                                        ("2018-12-03 18:00:00",60),
                                                        ("2018-12-10 18:00:00",57),
                                                        ("2018-12-17 18:00:00",52);

DROP TABLE IF EXISTS BaseJasper.tabla;
CREATE TABLE BaseJasper.tabla (dato INT);
INSERT INTO BaseJasper.tabla VALUES (1);

DROP TABLE IF EXISTS BaseJasper.propuestas_queues;
CREATE TABLE BaseJasper.propuestas_queues (idGerencia INT, gerencia varchar(200));
INSERT INTO BaseJasper.propuestas_queues VALUES (1,'Postmaster'),
                                    (2,'Raw'),
                                    (3,'Junk'),
                                    (4,'Misc'),
                                    (5,'Portales Comerciales'),
                                    (6,'Desarrollo'),
                                    (7,'DesarrolloSPSMarti'),
                                    (8,'GI-AMX-Administración-Interna'),
                                    (9,'Capacitacion'),
                                    (10,'amx-solicitudes::amx-casos'),
                                    (11,'amx-solicitudes-ec'),
                                    (12,'Intermediación-Terceros'),
                                    (13,'amx-soporte-archived'),
                                    (14,'Claroshop'),
                                    (15,'SS-Colombia'),
                                    (16,'UNOTV'),
                                    (17,'Proyectos Generales-TyP'),
                                    (18,'Triara'),
                                    (19,'amx-ctin'),
                                    (20,'eCommerce'),
                                    (21,'Portales Cloud'),
                                    (22,'Self Service Chile'),
                                    (23,'Self Service CENAM'),
                                    (24,'amx-solicitudes::amx-pe'),
                                    (25,'amx-solicitudes::amx-clarochile'),
                                    (26,'amx-solicitudes::amx-ssgt'),
                                    (27,'Fintech'),
                                    (28,'SearsLegacy'),
                                    (29,'amx-dla'),
                                    (32,'amx-solicitudes::amx-usa'),
                                    (33,'Interacción-Salida');

DROP TABLE IF EXISTS BaseJasper.nombres_estados_detalle_solicitudes;
CREATE TABLE BaseJasper.nombres_estados_detalle_solicitudes (id_estado SMALLINT(6), nombre VARCHAR(200));
INSERT INTO BaseJasper.nombres_estados_detalle_solicitudes VALUES (2,"cerrado exitosamente"),
                                                (3, "abandonado por el usuario"),
                                                (6, "en espera de validacion por el usuario"),
                                                (16, "en espera de respuesta por el usuario"),
                                                (18, "en seguimiento de terceros"),
                                                (23, "abierto");

DROP TABLE IF EXISTS BaseJasper.reporte_actividades;
CREATE TABLE BaseJasper.reporte_actividades (proyecto VARCHAR(500),
                                             idGerencia INT,
                                             prioridad_herramienta SMALLINT(6), 
                                             prioridad_sugerida SMALLINT(6), 
                                             actividad VARCHAR(255),
                                             ticket_number VARCHAR(50),
                                             ticket_id BIGINT(20),
                                             tipo_actividad VARCHAR(200),
                                             fecha_inicio DATETIME);

DROP TABLE IF EXISTS BaseJasper.indicadores_rendimiento; 
CREATE TABLE BaseJasper.indicadores_rendimiento (name VARCHAR(500),
                                                        resumen_solicitudes INT,
                                                        cerrados_exitosamente INT,
                                                        abandonados_usuario INT,
                                                        validacion_usuario INT,
                                                        respuesta_usuario INT,
                                                        seguimiento_terceros INT,
                                                        atencion_L2 INT);

DROP TABLE IF EXISTS BaseJasper.detalle_solicitudes;
CREATE TABLE BaseJasper.detalle_solicitudes ( tn VARCHAR(50),
                                              prioridad_sugerida SMALLINT(6),
                                              status VARCHAR(200),
                                              fecha DATETIME);

END $$
DELIMITER ;








/* INSERTS para cada tabla*/
/*Tabla tickets_abiertos_cerrados*/

DROP PROCEDURE IF EXISTS insert_abiertos_cerrados;
DELIMITER $$
CREATE PROCEDURE insert_abiertos_cerrados ()
BEGIN
INSERT INTO BaseJasper.tickets_abiertos_cerrados 
        SELECT otrsdb.ticket.queue_id, 
                NULL,
                (CASE WHEN otrsdb.ticket.ticket_state_id  IN (2,3,9,10,17,18) THEN count(DISTINCT otrsdb.ticket.id) END) AS Cerrados
        FROM otrsdb.ticket
        WHERE otrsdb.ticket.queue_id IN (1,2,3,5,8,9,11,12,13,14,15,16,17,18,20,21,22,23,24,25,27,28,29,32,33) AND 
                  otrsdb.ticket.change_time >= DATE_SUB("2018-08-13 18:00:00", INTERVAL 7 DAY) AND 
                  otrsdb.ticket.change_time <= "2018-08-13 18:00:00" /*Validacion para obtener solo los tickets de la semana*/
        GROUP BY otrsdb.ticket.queue_id,otrsdb.ticket.ticket_state_id;

INSERT INTO BaseJasper.tickets_abiertos_cerrados 
        SELECT otrsdb.ticket.queue_id, 
                (CASE WHEN otrsdb.ticket.ticket_state_id IN (1,4,6,11,12,16,23) THEN count(DISTINCT otrsdb.ticket.id) END) AS Abiertos,
                NULL
        FROM otrsdb.ticket
        WHERE otrsdb.ticket.queue_id IN (1,2,3,5,8,9,11,12,13,14,15,16,17,18,20,21,22,23,24,25,27,28,29,32,33)
        GROUP BY otrsdb.ticket.queue_id,otrsdb.ticket.ticket_state_id;


END $$
DELIMITER ;

/*Tabla solicitudes_estado*/
DROP PROCEDURE IF EXISTS insert_solicitudes_estado;
DELIMITER $$
CREATE PROCEDURE insert_solicitudes_estado ()
BEGIN
INSERT INTO BaseJasper.solicitudes_estado SELECT
                                        otrsdb.ticket_state.name ,
                                        otrsdb.ticket_state.id,
                                        count(DISTINCT otrsdb.ticket.id)
                                FROM otrsdb.ticket_state,otrsdb.ticket
                                WHERE
                                        otrsdb.ticket_state.id = otrsdb.ticket.ticket_state_id AND
                                        otrsdb.ticket.ticket_state_id IN (1,4,6,11,12,16,23) AND
                                        otrsdb.ticket.queue_id IN (1,2,3,5,8,9,11,12,13,14,15,16,17,18,20,21,22,23,24,25,27,28,29,32,33) 
                                GROUP BY otrsdb.ticket_state.name,otrsdb.ticket_state.id;
END $$
DELIMITER ;

/*Tabla gerencias_estados*/
DROP PROCEDURE IF EXISTS insert_gerencias_estados;
DELIMITER $$
CREATE PROCEDURE insert_gerencias_estados ()
BEGIN
INSERT INTO BaseJasper.gerencias_estados SELECT otrsdb.ticket.queue_id,
                (CASE WHEN otrsdb.ticket.ticket_state_id IN (1) THEN count(otrsdb.ticket.id) END),
                NULL,
                NULL,
                (CASE WHEN otrsdb.ticket.ticket_state_id IN (4) THEN count(otrsdb.ticket.id) END),
                NULL,
                (CASE WHEN otrsdb.ticket.ticket_state_id IN (6) THEN count(otrsdb.ticket.id) END),
                NULL,
                NULL,
                NULL,
                NULL,
                (CASE WHEN otrsdb.ticket.ticket_state_id IN (11) THEN count(otrsdb.ticket.id) END),
                (CASE WHEN otrsdb.ticket.ticket_state_id IN (12) THEN count(otrsdb.ticket.id) END),
                NULL,
                NULL,
                NULL,
                (CASE WHEN otrsdb.ticket.ticket_state_id IN (16) THEN count(otrsdb.ticket.id) END),
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                (CASE WHEN otrsdb.ticket.ticket_state_id IN (23) THEN count(otrsdb.ticket.id) END)
        FROM    otrsdb.ticket
        WHERE
                otrsdb.ticket.queue_id IN (1,2,3,5,8,9,11,12,13,14,15,16,17,18,20,21,22,23,24,25,27,28,29,32,33)
        GROUP BY otrsdb.ticket.queue_id,otrsdb.ticket.ticket_state_id;

INSERT INTO BaseJasper.gerencias_estados SELECT otrsdb.ticket.queue_id,
                NULL,
                (CASE WHEN otrsdb.ticket.ticket_state_id IN (2) THEN count(otrsdb.ticket.id) END),
                (CASE WHEN otrsdb.ticket.ticket_state_id IN (3) THEN count(otrsdb.ticket.id) END),
                NULL,
                (CASE WHEN otrsdb.ticket.ticket_state_id IN (5) THEN count(otrsdb.ticket.id) END),
                NULL,
                (CASE WHEN otrsdb.ticket.ticket_state_id IN (7) THEN count(otrsdb.ticket.id) END),
                (CASE WHEN otrsdb.ticket.ticket_state_id IN (8) THEN count(otrsdb.ticket.id) END),
                (CASE WHEN otrsdb.ticket.ticket_state_id IN (9) THEN count(otrsdb.ticket.id) END),
                (CASE WHEN otrsdb.ticket.ticket_state_id IN (10) THEN count(otrsdb.ticket.id) END),
                NULL,
                NULL,
                (CASE WHEN otrsdb.ticket.ticket_state_id IN (13) THEN count(otrsdb.ticket.id) END),
                (CASE WHEN otrsdb.ticket.ticket_state_id IN (14) THEN count(otrsdb.ticket.id) END),
                (CASE WHEN otrsdb.ticket.ticket_state_id IN (15) THEN count(otrsdb.ticket.id) END),
                NULL,
                (CASE WHEN otrsdb.ticket.ticket_state_id IN (17) THEN count(otrsdb.ticket.id) END),
                (CASE WHEN otrsdb.ticket.ticket_state_id IN (18) THEN count(otrsdb.ticket.id) END),
                (CASE WHEN otrsdb.ticket.ticket_state_id IN (19) THEN count(otrsdb.ticket.id) END),
                (CASE WHEN otrsdb.ticket.ticket_state_id IN (20) THEN count(otrsdb.ticket.id) END),
                (CASE WHEN otrsdb.ticket.ticket_state_id IN (21) THEN count(otrsdb.ticket.id) END),
                (CASE WHEN otrsdb.ticket.ticket_state_id IN (22) THEN count(otrsdb.ticket.id) END),
                NULL
        FROM    otrsdb.ticket
        WHERE
                otrsdb.ticket.queue_id IN (1,2,3,5,8,9,11,12,13,14,15,16,17,18,20,21,22,23,24,25,27,28,29,32,33) AND 
                  otrsdb.ticket.change_time >= DATE_SUB("2018-08-13 18:00:00", INTERVAL 7 DAY) AND 
                  otrsdb.ticket.change_time <= "2018-08-13 18:00:00" /*Validacion para obtener solo los tickets de la semana*/
        GROUP BY otrsdb.ticket.queue_id,otrsdb.ticket.ticket_state_id;


END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS insert_solicitudes_pendientes_semanal;
DELIMITER $$
CREATE PROCEDURE insert_solicitudes_pendientes_semanal ()
BEGIN
SET @total_abiertos := (SELECT SUM(BaseJasper.tickets_abiertos_cerrados.total_abiertos) FROM BaseJasper.tickets_abiertos_cerrados);
SET @total_pendientes := (SELECT SUM(BaseJasper.solicitudes_estado.total_solicitudes) FROM BaseJasper.solicitudes_estado WHERE BaseJasper.solicitudes_estado.idEstado IN (6,16));
INSERT INTO BaseJasper.solicitudes_pendientes_semanal SELECT DATE_FORMAT("2018-08-13 18:00:00","%Y-%m-%d"), (@total_pendientes*100)/@total_abiertos;
END $$
DELIMITER ;




DROP PROCEDURE IF EXISTS insert_reporte_actividades;
DELIMITER $$
CREATE PROCEDURE insert_reporte_actividades()
BEGIN

INSERT INTO BaseJasper.reporte_actividades 
                        SELECT BaseJasper.propuestas_queues.gerencia,
                                otrsdb.ticket.queue_id,
                                otrsdb.ticket.ticket_priority_id,
                                otrsdb.ticket.ticket_priority_id,
                                otrsdb.ticket.title,
                                otrsdb.ticket.tn,
                                otrsdb.ticket.id,
                                otrsdb.service.name,
                                otrsdb.ticket.create_time
                        FROM    otrsdb.ticket, otrsdb.users,otrsdb.service, BaseJasper.propuestas_queues
                        WHERE   otrsdb.ticket.queue_id = BaseJasper.propuestas_queues.idGerencia AND
                                otrsdb.ticket.user_id = otrsdb.users.id AND
                                otrsdb.ticket.service_id = otrsdb.service.id AND
                                otrsdb.ticket.ticket_state_id = 23;
END $$
DELIMITER ;




DROP PROCEDURE IF EXISTS insert_reporte_indicadores_rendimiento;
DELIMITER $$
CREATE PROCEDURE insert_reporte_indicadores_rendimiento()
BEGIN

SET @v_planeados := (SELECT COUNT(otrsdb.ticket.id) 
                        FROM otrsdb.ticket 
                        WHERE otrsdb.ticket.ticket_priority_id IN (4,5,6) AND 
                              otrsdb.ticket.ticket_state_id IN (6,16,23));

SET @v_planeados := @v_planeados + (SELECT COUNT(otrsdb.ticket.id) 
                        FROM otrsdb.ticket 
                        WHERE otrsdb.ticket.ticket_priority_id IN (4,5,6) AND 
                              otrsdb.ticket.ticket_state_id IN (2,3)AND 
                              otrsdb.ticket.change_time >= DATE_SUB("2018-08-13 18:00:00", INTERVAL 7 DAY) AND 
                              otrsdb.ticket.change_time <= "2018-08-13 18:00:00");

SET @v_cerrados := (SELECT COUNT(otrsdb.ticket.id) 
                        FROM otrsdb.ticket 
                        WHERE otrsdb.ticket.ticket_priority_id IN (4,5,6) AND 
                              otrsdb.ticket.ticket_state_id = 2 AND 
                              otrsdb.ticket.change_time >= DATE_SUB("2018-08-13 18:00:00", INTERVAL 7 DAY) AND 
                              otrsdb.ticket.change_time <= "2018-08-13 18:00:00");

SET @v_abandonados_usuario := (SELECT COUNT(otrsdb.ticket.id) 
                                FROM otrsdb.ticket 
                                WHERE otrsdb.ticket.ticket_priority_id IN (4,5,6) AND 
                                      otrsdb.ticket.ticket_state_id = 3 AND 
                                      otrsdb.ticket.change_time >= DATE_SUB("2018-08-13 18:00:00", INTERVAL 7 DAY) AND 
                                      otrsdb.ticket.change_time <= "2018-08-13 18:00:00");

SET @v_seguimiento_terceros := (SELECT COUNT(otrsdb.ticket.id) 
                        FROM otrsdb.ticket 
                        WHERE otrsdb.ticket.ticket_priority_id IN (4,5,6) AND 
                              otrsdb.ticket.ticket_state_id IN (6,16,23) AND
                              otrsdb.ticket.queue_id = 18);

SET @v_validacion_usuario := (SELECT COUNT(otrsdb.ticket.id) 
                                FROM otrsdb.ticket 
                                WHERE otrsdb.ticket.ticket_priority_id IN (4,5,6) AND 
                                      otrsdb.ticket.ticket_state_id = 6) - @v_seguimiento_terceros;

SET @v_respuesta_usuario := (SELECT COUNT(otrsdb.ticket.id) 
                                FROM otrsdb.ticket 
                                WHERE otrsdb.ticket.ticket_priority_id IN (4,5,6) AND 
                                      otrsdb.ticket.ticket_state_id = 16) - @v_seguimiento_terceros;

SET @v_espera_L2 := (SELECT COUNT(otrsdb.ticket.id) 
                        FROM otrsdb.ticket 
                        WHERE otrsdb.ticket.ticket_priority_id IN (4,5,6) AND 
                              otrsdb.ticket.ticket_state_id = 23) - @v_seguimiento_terceros;


INSERT INTO BaseJasper.indicadores_rendimiento SELECT 
                                                        "++ Solicitudes priorizadas con planeacion",
                                                        @v_planeados,
                                                        @v_cerrados,
                                                        @v_abandonados_usuario,
                                                        @v_validacion_usuario,
                                                        @v_respuesta_usuario,
                                                        @v_seguimiento_terceros,
                                                        @v_espera_L2;

INSERT INTO BaseJasper.indicadores_rendimiento VALUES
                                ("++ Solicitudes priorizadas sin planeacion",0,0,0,0,0,0,0),
                                ("Subtotal solicitudes priorizadas",0,0,0,0,0,0,0);

SET @v_planeados_qL2 := (SELECT COUNT(otrsdb.ticket.id) 
                        FROM otrsdb.ticket 
                        WHERE otrsdb.ticket.ticket_priority_id IN (4,5,6) AND 
                              otrsdb.ticket.ticket_state_id IN (6,16,23));

SET @v_planeados_qL2 := @v_planeados_qL2 + (SELECT COUNT(otrsdb.ticket.id) 
                        FROM otrsdb.ticket 
                        WHERE otrsdb.ticket.ticket_priority_id IN (4,5,6) AND 
                              otrsdb.ticket.ticket_state_id IN (2,3)AND 
                              otrsdb.ticket.change_time >= DATE_SUB("2018-08-13 18:00:00", INTERVAL 7 DAY) AND 
                              otrsdb.ticket.change_time <= "2018-08-13 18:00:00");

SET @v_cerrados_qL2 := (SELECT COUNT(otrsdb.ticket.id) 
                        FROM otrsdb.ticket 
                        WHERE otrsdb.ticket.ticket_priority_id IN (4,5,6) AND 
                              otrsdb.ticket.ticket_state_id = 2 AND 
                              otrsdb.ticket.change_time >= DATE_SUB("2018-08-13 18:00:00", INTERVAL 7 DAY) AND 
                              otrsdb.ticket.change_time <= "2018-08-13 18:00:00");

SET @v_abandonados_usuario_qL2 := (SELECT COUNT(otrsdb.ticket.id) 
                                FROM otrsdb.ticket 
                                WHERE otrsdb.ticket.ticket_priority_id IN (4,5,6) AND 
                                      otrsdb.ticket.ticket_state_id = 3 AND 
                                      otrsdb.ticket.change_time >= DATE_SUB("2018-08-13 18:00:00", INTERVAL 7 DAY) AND 
                                      otrsdb.ticket.change_time <= "2018-08-13 18:00:00");

SET @v_seguimiento_terceros_qL2 := (SELECT COUNT(otrsdb.ticket.id) 
                        FROM otrsdb.ticket 
                        WHERE otrsdb.ticket.ticket_priority_id IN (4,5,6) AND 
                              otrsdb.ticket.ticket_state_id IN (6,16,23) AND
                              otrsdb.ticket.queue_id = 18);

SET @v_validacion_usuario_qL2 := (SELECT COUNT(otrsdb.ticket.id) 
                                FROM otrsdb.ticket 
                                WHERE otrsdb.ticket.ticket_priority_id IN (4,5,6) AND 
                                      otrsdb.ticket.ticket_state_id = 6) - @v_seguimiento_terceros_qL2;

SET @v_respuesta_usuario_qL2 := (SELECT COUNT(otrsdb.ticket.id) 
                                FROM otrsdb.ticket 
                                WHERE otrsdb.ticket.ticket_priority_id IN (4,5,6) AND 
                                      otrsdb.ticket.ticket_state_id = 16) - @v_seguimiento_terceros_qL2;

SET @v_espera_L2_qL2 := (SELECT COUNT(otrsdb.ticket.id) 
                        FROM otrsdb.ticket 
                        WHERE otrsdb.ticket.ticket_priority_id IN (4,5,6) AND 
                              otrsdb.ticket.ticket_state_id = 23) - @v_seguimiento_terceros_qL2;

INSERT INTO BaseJasper.indicadores_rendimiento SELECT 
                                                        "Solicitudes no priorizados",
                                                        @v_planeados_qL2,
                                                        @v_cerrados_qL2,
                                                        @v_abandonados_usuario_qL2,
                                                        @v_validacion_usuario_qL2,
                                                        @v_respuesta_usuario_qL2,
                                                        @v_seguimiento_terceros_qL2,
                                                        @v_espera_L2_qL2;

INSERT INTO BaseJasper.indicadores_rendimiento VALUES ("Total",0,0,0,0,0,0,0);

INSERT INTO BaseJasper.detalle_solicitudes SELECT otrsdb.ticket.tn,
                                                  otrsdb.ticket.ticket_priority_id,
                                                  BaseJasper.nombres_estados_detalle_solicitudes.nombre,
                                                  otrsdb.ticket.change_time
                                           FROM otrsdb.ticket,
                                                BaseJasper.nombres_estados_detalle_solicitudes
                                           WHERE otrsdb.ticket.ticket_priority_id IN (4,5,6) AND 
                                                 otrsdb.ticket.ticket_state_id IN (6,16,23) AND
                                                 BaseJasper.nombres_estados_detalle_solicitudes.id_estado = otrsdb.ticket.ticket_state_id AND
                                                 otrsdb.ticket.queue_id <> 18;

INSERT INTO BaseJasper.detalle_solicitudes SELECT otrsdb.ticket.tn,
                                                  otrsdb.ticket.ticket_priority_id,
                                                  BaseJasper.nombres_estados_detalle_solicitudes.nombre,
                                                  otrsdb.ticket.change_time
                                           FROM otrsdb.ticket,
                                                BaseJasper.nombres_estados_detalle_solicitudes
                                           WHERE otrsdb.ticket.ticket_priority_id IN (4,5,6) AND 
                                                 otrsdb.ticket.ticket_state_id IN (6,16,23) AND
                                                 BaseJasper.nombres_estados_detalle_solicitudes.id_estado = otrsdb.ticket.queue_id AND
                                                 otrsdb.ticket.queue_id = 18;

INSERT INTO BaseJasper.detalle_solicitudes SELECT otrsdb.ticket.tn,
                                                  otrsdb.ticket.ticket_priority_id,
                                                  BaseJasper.nombres_estados_detalle_solicitudes.nombre,
                                                  otrsdb.ticket.change_time
                                           FROM otrsdb.ticket,
                                                BaseJasper.nombres_estados_detalle_solicitudes
                                           WHERE otrsdb.ticket.ticket_priority_id IN (4,5,6) AND 
                                                 otrsdb.ticket.ticket_state_id IN (2,3)AND 
                                                 otrsdb.ticket.change_time >= DATE_SUB("2018-08-13 18:00:00", INTERVAL 7 DAY) AND 
                                                 otrsdb.ticket.change_time <= "2018-08-13 18:00:00" AND
                                                 BaseJasper.nombres_estados_detalle_solicitudes.id_estado = otrsdb.ticket.ticket_state_id;

END $$
DELIMITER ;









/*Procedimiento principal*/
DROP PROCEDURE IF EXISTS ingresar_registros;
DELIMITER $$
CREATE PROCEDURE ingresar_registros ()
BEGIN
CALL init_tablas();
CALL insert_abiertos_cerrados();
CALL insert_solicitudes_estado();
CALL insert_gerencias_estados();
CALL insert_solicitudes_pendientes_semanal();
CALL insert_reporte_actividades ();
CALL insert_reporte_indicadores_rendimiento();
END $$
DELIMITER ;
/*Llamada a procedimiento principal ingresar_registros*/
CALL ingresar_registros();






/*SELECTS para el reporte*/
/*Grafica Total Solicitudes cerradas vs Solicitudes Abiertas*/
SELECT gerencia, sum(total_abiertos) as total_abiertos, sum(total_cerrados) as total_cerrados FROM tickets_abiertos_cerrados, propuestas_queues 
        WHERE tickets_abiertos_cerrados.idGerencia = propuestas_queues.idGerencia
        GROUP BY gerencia;

/*Grafica Total Solicitudes VS Estatus*/
SELECT estado_nombre, total_solicitudes FROM solicitudes_estado;

SELECT DATE_FORMAT(fecha,"%Y-%M-%d"), porcentaje FROM solicitudes_pendientes_semanal ORDER BY fecha ASC;


/*Los unicos estados que se consideran abiertos son:
* *new
* open
* pending reminder
* Awaiting Scheduled Time
* Awaiting Precedent Requirement
* L1_follow up pending reminder
* Queued L2
*/

/*Los unicos estados que se consideran cerrados son todos los close y merge*/

/*Grafica Gerencia de Desarrollo de Claro Pagos*/
SELECT gerencia, 
       sum(estado_new) as new,
       sum(estado_closed_successful) as closed_successful,
       sum(estado_closed_unsuccessful) as closed_unsuccessful, 
       sum(estado_open) as "open",
       sum(estado_removed) as removed,
       sum(estado_pending_reminder) as pending_reminder,
       sum(estado_pending_auto_close_mas) as pending_auto_close_mas,
       sum(estado_pending_auto_close_menos) as pending_auto_close_menos,
       sum(estado_merged) as merged,
       sum(estado_closed_with_workaround) as closed_with_workaround,
       sum(estado_Awaiting_Scheduled_Time) as Awaiting_Scheduled_Time,
       sum(estado_Awaiting_Precedent_Requirement) as Awaiting_Precedent_Requirement,
       sum(estado_open_L2) as open_L2,
       sum(estado_open_L3) as open_L3,
       sum(estado_L1_follow_up) as L1_follow_up,
       sum(estado_L1_follow_up_pending_reminder) as L1_follow_up_pending_reminder,
       sum(estado_closed_without_validation) as closed_without_validation,
       sum(estado_closed_invalid_request) as closed_invalid_request,
       sum(estado_Awaiting_for_missing_information) as Awaiting_for_missing_information,
       sum(estado_impact_analysis) as impact_analysis,
       sum(estado_application_for_team_leader_approval) as application_for_team_leader_approval,
       sum(estado_application_for_business_risk_approval) as application_for_business_risk_approval,
       sum(estado_Queued_L2) as Queued_L2
       FROM gerencias_estados , propuestas_queues WHERE gerencias_estados.idGerencia = propuestas_queues.idGerencia AND gerencias_estados.idGerencia = 27 
       GROUP BY 1;

SELECT 
        proyecto, 
        prioridad_herramienta, 
        prioridad_sugerida,
        actividad,ticket_number, 
        ticket_id, 
        responsable_first_name,
        responsable_last_name, 
        tipo_actividad, 
        DATE_FORMAT(fecha_inicio, "%Y-%m-%d") as  fecha_inicio
FROM reporte_actividades;