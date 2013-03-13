/* MS SQL Server table creation */

/* Table that keeps one record for each email sent */
CREATE TABLE trackemail_emails(
	id int IDENTITY(1,1) NOT NULL,
	site varchar(50) NOT NULL,
	subject varchar(255) NULL,
	body text NOT NULL,
	createdAt datetime NOT NULL,
	CONSTRAINT "pk_trackemail_email-id" PRIMARY KEY (id)
)

/* Table that holds the individual clicked links */
CREATE TABLE trackemail_links(
	id int IDENTITY(1,1) NOT NULL,
	sentid char(35) NOT NULL,
	link varchar(255) NOT NULL,
	createdAt datetime NOT NULL,
	CONSTRAINT "pk_trackemail_links-id" PRIMARY KEY (id)
)

/* Table that holds every email sent and to how */
CREATE TABLE trackemail_sent(
	id char(35) NOT NULL,
	emailid int NOT NULL,
	recipient varchar(255) NOT NULL,
	createdAt datetime NOT NULL,
	CONSTRAINT "pk_trackemail_sent-id" PRIMARY KEY (id)
)

/* Table that holds every time an email is viewed */
CREATE TABLE trackemail_views(
	id int IDENTITY(1,1) NOT NULL,
	sentid char(35) NOT NULL,
	createdAt datetime NOT NULL,
	CONSTRAINT "pk_trackemail_views-id" PRIMARY KEY (id)
)