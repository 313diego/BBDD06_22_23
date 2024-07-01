create or replace PROCEDURE CambiarAgentesFamilia (id_FamiliaOrigen familias.identificador%TYPE,
                                            id_FamiliaDestino familias.identificador%TYPE) AS

famOrigenExiste familias.identificador%TYPE; -- Identificador para coprobar familia de origen
famDestinoExiste familias.identificador%TYPE; -- Identificador para comprobar familia de destino
numAgentes NUMBER (4); -- Identificado para almacenar el número de agentes de la familia de origen

BEGIN
    
    famOrigenExiste := id_FamiliaOrigen;
    famDestinoExiste := id_familiaDestino;
    
    SELECT COUNT (f.identificador) INTO famOrigenExiste FROM familias f 
        WHERE f.identificador = id_FamiliaOrigen;
    SELECT COUNT (f.identificador) INTO famDestinoExiste FROM familias f
        WHERE f.identificador = id_FamiliaDestino;
    SELECT COUNT (*) INTO numAgentes FROM agentes a
        WHERE a.familia = id_FamiliaOrigen;

    IF (id_FamiliaOrigen = id_FamiliaDestino) THEN
        RAISE_APPLICATION_ERROR (-20001, 'Las familias de origen y destino son iguales');
    ELSIF (famOrigenExiste = 0) THEN
        RAISE_APPLICATION_ERROR (-20002, 'La familia de origen no existe');
    ELSIF (famDestinoExiste = 0) THEN
        RAISE_APPLICATION_ERROR (-20003, 'La familia de destino no existe');
    ELSE 
        UPDATE agentes SET familia = id_FamiliaDestino
            WHERE familia = id_FamiliaOrigen;

        DBMS_OUTPUT.PUT_LINE ('Se han cambiado '|| numAgentes || ' de la familia '
            || id_FamiliaOrigen || ' a la familia ' || id_FamiliaDestino);
    END IF;

END;
/

create or replace TRIGGER control_Agentes 
BEFORE INSERT OR UPDATE ON agentes 
FOR EACH ROW

BEGIN

    IF LENGTH (:new.clave) < 6 THEN
        RAISE_APPLICATION_ERROR (-20001, 'La clave no puede contener menos de 6
            digitos');
    END IF;

    IF (:new.habilidad < 0 OR :new.habilidad > 9) THEN
        RAISE_APPLICATION_ERROR (-20002, 'La habilidad de un agente debe estar
            coprendida entre 0 y 9 (ambos inclusive)');
    END IF;

    IF (:new.categoria NOT IN (0,1,2)) THEN
        RAISE_APPLICATION_ERROR (-20003, 'La categoría del agente debe ser 0, 1 o
            2');
    END IF;

    IF (:new.categoria = 2 AND :new.familia IS NOT NULL AND :new.oficina IS NULL)
        THEN
        RAISE_APPLICATION_ERROR (-20004, 'Un agente de categoria 2 no puede
            pertenecer a ninguna familia y debe pertenecer a una oficina');
    END IF;

    IF (:new.categoria = 1 AND :new.oficina IS NOT NULL AND :new.familia IS NULL)
        THEN
        RAISE_APPLICATION_ERROR (-20005, 'Un agente de categoria 1 no puede
            pertenecer a ninguna oficina y debe pertenecer a una familia');
    END IF;

    IF (:new.oficina IS NOT NULL AND :new.familia IS NOT NULL) THEN
        RAISE_APPLICATION_ERROR (-20006, 'Un agente no puede pertenecer a una 
            oficina y a una familia a la vez');
    ELSIF (:new.oficina IS NULL AND :new.familia IS NULL) THEN
        RAISE_APPLICATION_ERROR (-20007, 'Un agente debe pertenecer a una oficina 
            o a una familia, pero no a ambas a la vez');
    END IF;

END;
/

create or replace TRIGGER control_Agentes 
BEFORE INSERT OR UPDATE ON agentes 
FOR EACH ROW

BEGIN

-- La longitud de la clave de un agente no puede ser inferior a 6.
    IF LENGTH (:new.clave) < 6 THEN
        RAISE_APPLICATION_ERROR (-20001, 'La clave no puede contener menos de 6
            digitos');
    END IF;

-- La habilidad de un agente debe estar comprendida entre 0 y 9 (ambos inclusive).
    IF (:new.habilidad < 0 OR :new.habilidad > 9) THEN
        RAISE_APPLICATION_ERROR (-20002, 'La habilidad de un agente debe estar
            coprendida entre 0 y 9 (ambos inclusive)');
    END IF;

-- La categoría de un agente sólo puede ser igual a 0, 1 o 2.
    IF (:new.categoria NOT IN (0,1,2)) THEN
        RAISE_APPLICATION_ERROR (-20003, 'La categoría del agente debe ser 0, 1 o
            2');
    END IF;

-- Si un agente tiene categoría 2 no puede pertenecer a ninguna familia y debe pertenecer a una oficina.
    IF (:new.categoria = 2 AND :new.familia IS NOT NULL AND :new.oficina IS NULL)
        THEN
        RAISE_APPLICATION_ERROR (-20004, 'Un agente de categoria 2 no puede
            pertenecer a ninguna familia y debe pertenecer a una oficina');
    END IF;

-- Si un agente tiene categoría 1 no puede pertenecer a ninguna oficina y debe pertenecer a una familia.
    IF (:new.categoria = 1 AND :new.oficina IS NOT NULL AND :new.familia IS NULL)
        THEN
        RAISE_APPLICATION_ERROR (-20005, 'Un agente de categoria 1 no puede
            pertenecer a ninguna oficina y debe pertenecer a una familia');
    END IF;

-- Todos los agentes deben pertenecer a una oficina o a una familia pero nunca a ambas a la vez.
    IF (:new.oficina IS NOT NULL AND :new.familia IS NOT NULL) THEN
        RAISE_APPLICATION_ERROR (-20006, 'Un agente no puede pertenecer a una 
            oficina y a una familia a la vez');
    ELSIF (:new.oficina IS NULL AND :new.familia IS NULL) THEN
        RAISE_APPLICATION_ERROR (-20007, 'Un agente debe pertenecer a una oficina 
            o a una familia, pero no a ambas a la vez');
    END IF;

/*
Algunas de las restricciones implementadas con el disparador se pueden incorporar a la definición del esquema de la tabla
utilizando el Lenguaje de Definición de Datos (Check,Unique,..). Identifica cuáles son y con qué tipo de restricciones las
implementarías.
Las retricciones la categoria del agente y de la habiliad se pueden hacer con un check en ambos casos. La prira sería check in 0,1,2
y la segunda sería check between 0 and 9
*/
END;