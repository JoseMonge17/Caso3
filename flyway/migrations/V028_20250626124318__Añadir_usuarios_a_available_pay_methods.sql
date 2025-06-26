-- Alternativa: Solo añadir la columna sin eliminar la tabla
ALTER TABLE vpv_available_pay_methods
ADD userid INT NOT NULL DEFAULT 1
CONSTRAINT FK_vpv_available_pay_methods_userid 
FOREIGN KEY (userid) REFERENCES vpv_users(userid);
