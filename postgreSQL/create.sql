create role skay with login;

create database postgres_db with owner skay;

\c postgres_db skay;

create table welcome(
    tag_name varchar(32),
    tag_value text
);


insert into welcome (tag_name, tag_value) values('Welcome', 'Postgresql');
