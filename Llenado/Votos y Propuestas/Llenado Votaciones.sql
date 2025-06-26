use VotoPuraVida;

-- Visibilidades de los votos
INSERT INTO vote_result_visibilities (description)
VALUES
  ('After_Close'),         -- Se cierra el plazo de votación (AC)
  ('After_All_Votes'),     -- Todos los elegibles ya votaron (AV)


-- Tipos de votos
INSERT INTO vote_types (name, description, singleWeight)
VALUES
  ('Publico', 'Se puede ver quien voto en una sesión particular', 0),
  ('Privado', 'No se puede ver quien voto en una sesión particular', 0);


-- Status de sesiones
INSERT INTO vote_sessions_status (name)
VALUES ('Por Empezar', 'En Progreso', 'Terminado')


-- Inserción de 7 sesiones de votos
INSERT INTO vote_sessions (
  startDate,
  endDate,
  public_key,
  sessionStatusid,
  voteTypeid,
  visibilityid)
VALUES
  ('2024-05-15 09:00:00', '2024-05-15 17:00:00', 0xA1B2C3D4, 3, 1, 1), -- Terminado, PUBLICO, AC
  ('2024-11-10 08:00:00', '2024-11-10 12:00:00', 0xB2C3D4E5, 3, 2, 2), -- Terminado, Privado, AV
  ('2025-01-20 10:00:00', '2025-01-20 18:00:00', 0xC3D4E5F6, 3, 2, 1), -- Terminado, Privado, AC
  ('2025-03-05 13:00:00', '2025-03-05 19:00:00', 0xD4E5F607, 3, 2, 2), -- Terminado, Privado, AV
  ('2025-04-10 09:15:00', '2025-04-10 17:15:00', 0xE5F60718, 3, 2, 1), -- Terminado, Privado, AC
  ('2024-09-22 14:00:00', '2024-09-22 20:00:00', 0xF6071829, 3, 2, 2), -- Terminado, Privado, AV
  ('2025-05-01 10:30:00', '2025-05-01 16:30:00', 0x0718293A, 3, 2, 1); -- Terminado, PUBLICO, AC



