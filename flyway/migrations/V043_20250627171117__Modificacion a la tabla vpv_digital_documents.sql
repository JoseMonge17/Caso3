ALTER TABLE vpv_digital_documents
DROP CONSTRAINT FK__vpv_digit__reque__208CD6FA;

ALTER TABLE vpv_digital_documents
ALTER COLUMN requestid INT NULL;

ALTER TABLE vpv_digital_documents
ADD CONSTRAINT FK__vpv_digit__reque__208CD6FA
FOREIGN KEY (requestid) REFERENCES vpv_validation_request(requestid);