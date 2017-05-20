SET FOREIGN_KEY_CHECKS=0;
/*
	This table is only to get started off with
*/
/*
Recreate each table 
*/
create table if not exists appuser
(
	id tinyint unsigned NOT NULL AUTO_INCREMENT,
	name varchar (50),
	username varchar (50),
	password varchar (50),
	primary key(id)
);

insert into appuser (name, username, password) values ('Poker John', 'pokerj', 'Pokerj#'), ('Floop McMan', 'fmcman', 'Floopm#');
SET FOREIGN_KEY_CHECKS=1;

