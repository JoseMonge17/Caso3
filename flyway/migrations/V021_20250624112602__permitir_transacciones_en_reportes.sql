ALTER TABLE cf_financial_reports
ADD transactionid INT NULL,
CONSTRAINT FK_cf_financial_reports_vpv_transactions
FOREIGN KEY (transactionid) REFERENCES vpv_transactions(transactionid);