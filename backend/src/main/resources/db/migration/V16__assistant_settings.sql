-- Runtime-tunable settings for the student assistant, managed from the admin
-- web's AI page. Single row enforced by the fixed-id check. Nullable model
-- options fall back to the provider's defaults when unset (gpt-5.5 rejects
-- any temperature but its default, so null is the safe out-of-the-box state).
CREATE TABLE assistant_settings (
	id INT PRIMARY KEY CHECK (id = 1),
	chat_model VARCHAR(80) NOT NULL,
	temperature DOUBLE PRECISION CHECK (temperature BETWEEN 0 AND 2),
	top_p DOUBLE PRECISION CHECK (top_p BETWEEN 0 AND 1),
	max_tokens INT CHECK (max_tokens BETWEEN 1 AND 32768),
	frequency_penalty DOUBLE PRECISION CHECK (frequency_penalty BETWEEN -2 AND 2),
	presence_penalty DOUBLE PRECISION CHECK (presence_penalty BETWEEN -2 AND 2),
	top_k INT NOT NULL CHECK (top_k BETWEEN 1 AND 20),
	similarity_threshold DOUBLE PRECISION CHECK (similarity_threshold BETWEEN 0 AND 1),
	memory_window_messages INT NOT NULL CHECK (memory_window_messages BETWEEN 2 AND 100),
	extra_instructions VARCHAR(2000),
	updated_at TIMESTAMP WITH TIME ZONE NOT NULL
);
