CREATE DATABASE IF NOT EXISTS [database];
CREATE USER '[user]'@'[server]' IDENTIFIED BY '[password]';
GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER,INDEX ON [database].* TO '[user]'@'[server]';
GRANT usage ON *.* to '[user]'@'[server]' WITH max_user_connections [workers];