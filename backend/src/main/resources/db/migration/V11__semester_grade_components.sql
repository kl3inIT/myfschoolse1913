ALTER TABLE semester_subject_grades
    ADD COLUMN formative_score NUMERIC(4, 1) CHECK (formative_score >= 0 AND formative_score <= 10),
    ADD COLUMN midterm_score NUMERIC(4, 1) CHECK (midterm_score >= 0 AND midterm_score <= 10),
    ADD COLUMN final_score NUMERIC(4, 1) CHECK (final_score >= 0 AND final_score <= 10),
    ADD COLUMN teacher_comment VARCHAR(255);

