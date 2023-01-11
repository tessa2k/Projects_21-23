-- -----------------------------------------------------
-- Create Database VintageFun
-- -----------------------------------------------------
DROP DATABASE IF EXISTS VintageFun;

CREATE SCHEMA IF NOT EXISTS `VintageFun` DEFAULT CHARACTER SET utf8 ;
USE `VintageFun` ;

SET FOREIGN_KEY_CHECKS = 0;
drop table if exists retail_stores;
drop table if exists employees;
drop table if exists jobs;
drop table if exists punch_clock;
drop table if exists workdays;
drop table if exists employee_workdyas;
drop table if exists games;
drop table if exists developer_companies;
drop table if exists formats;
drop table if exists products;
drop table if exists sell_methods;
drop table if exists product_games;
drop table if exists game_comments;
SET FOREIGN_KEY_CHECKS = 1;

-- -----------------------------------------------------
-- Create Table `VintageFun`.`retail_stores`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `VintageFun`.`retail_stores` (
  `store_id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  `telephone_number` VARCHAR(50) NOT NULL,
  `postcode` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`store_id`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Create Table `VintageFun`.`jobs`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `VintageFun`.`jobs` (
  `job_role` VARCHAR(50) NOT NULL,
  `description` VARCHAR(500) NULL DEFAULT NULL,
  PRIMARY KEY (`job_role`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Create Table `VintageFun`.`workdays`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `VintageFun`.`workdays` (
  `name` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`name`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Create Table `VintageFun`.`employees`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `VintageFun`.`employees` (
  `id_number` CHAR(12) NOT NULL,
  `first_name` VARCHAR(50) NOT NULL,
  `last_name` VARCHAR(50) NOT NULL,
  `store_id` INT NOT NULL,
  `job_role` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id_number`),
  CONSTRAINT `fk_employees_retail_stores`
    FOREIGN KEY (`store_id`)
    REFERENCES `VintageFun`.`retail_stores` (`store_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_employees_job_roles`
    FOREIGN KEY (`job_role`)
    REFERENCES `VintageFun`.`jobs` (`job_role`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Create Table `VintageFun`.`employee_workdays`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `VintageFun`.`employee_workdays` (
  `id_number` CHAR(12) NOT NULL,
  `workday` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id_number`, `workday`),
  CONSTRAINT `fk_employee_workdays_employees`
    FOREIGN KEY (`id_number`)
    REFERENCES `VintageFun`.`employees` (`id_number`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
CONSTRAINT `fk_employee_workdays_workdays`
    FOREIGN KEY (`workday`)
    REFERENCES `VintageFun`.`workdays` (`name`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Create Table `VintageFun`.`punch_clock`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `VintageFun`.`punch_clock` (
  `punch_clock_id` INT NOT NULL AUTO_INCREMENT,
  `id_number` CHAR(12) NOT NULL,
  `arrive_time` DATETIME NULL DEFAULT NULL,
  `leave_time` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`punch_clock_id`),
  CONSTRAINT `fk_punch_clock_employees`
    FOREIGN KEY (`id_number`)
    REFERENCES `VintageFun`.`employees` (`id_number`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Create Table `VintageFun`.`developer_companies`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `VintageFun`.`developer_companies` (
  `developer_company_id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(500) NULL DEFAULT NULL,
  PRIMARY KEY (`developer_company_id`))
ENGINE = InnoDB;
USE `vintagefun`;

-- -----------------------------------------------------
-- Create Table `VintageFun`.`games`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `VintageFun`.`games` (
  `game_id` INT NOT NULL,
  `title` VARCHAR(500) NOT NULL,
  `genre` VARCHAR(50) NULL DEFAULT NULL,
  `release_date` DATE NULL DEFAULT NULL,
  `age_rating` TINYINT UNSIGNED NULL DEFAULT NULL,
  `developer_company_id` INT NOT NULL,
  PRIMARY KEY (`game_id`),
  CONSTRAINT `fk_games_developer_companies`
    FOREIGN KEY (`developer_company_id`)
    REFERENCES `VintageFun`.`developer_companies` (`developer_company_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Create Table `VintageFun`.`game_comments`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `VintageFun`.`game_comments` (
  `game_id` INT NOT NULL,
  `comment` VARCHAR(1000) NOT NULL,
  PRIMARY KEY (`game_id`, `comment`),
  CONSTRAINT `fk_game_comments_games`
    FOREIGN KEY (`game_id`)
    REFERENCES `VintageFun`.`games` (`game_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Create Table `VintageFun`.`sell_methods`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `VintageFun`.`sell_methods` (
  `name` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`name`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Create Table `VintageFun`.`formats`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `VintageFun`.`formats` (
  `name` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`name`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Create Table `VintageFun`.`products`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `VintageFun`.`products` (
  `serial_number` VARCHAR(5) NOT NULL,
  `title` VARCHAR(500) NULL DEFAULT NULL,
  `format_name` VARCHAR(50) NOT NULL,
  `sell_method_name` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`serial_number`),
  CONSTRAINT `fk_products_formats`
    FOREIGN KEY (`format_name`)
    REFERENCES `VintageFun`.`formats` (`name`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_products_sell_methods`
    FOREIGN KEY (`sell_method_name`)
    REFERENCES `VintageFun`.`sell_methods` (`name`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Create Table `VintageFun`.`product_games`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `VintageFun`.`product_games` (
  `serial_number` CHAR(5) NOT NULL,
  `game_id` INT NOT NULL,
  PRIMARY KEY (`game_id`, `serial_number`),
  CONSTRAINT `fk_product_games_games`
    FOREIGN KEY (`game_id`)
    REFERENCES `VintageFun`.`games` (`game_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_product_games_products`
    FOREIGN KEY (`serial_number`)
    REFERENCES `VintageFun`.`products` (`serial_number`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Insert data into Table `VintageFun`.`retail_stores`
-- -----------------------------------------------------
INSERT INTO `retail_stores`
VALUES
(1, 'VintageFun1', '12345', 'LN1x'),
(2, 'VintageFun2', '23456', 'LS2xx'),
(3, 'VintageFun3', '34567','LW3xx'),
(4, 'VintageFun4', '45678', 'LE4hjkx'),
(5, 'VintageFun5', '56789', 'LE468xx'),
(6, 'VintageFun6', '67890', 'LE8hb7x'),
(7, 'VintageFun7', '45668', 'LC800'),
(8, 'VintageFun8', '79867', 'LC066hx'),
(9, 'VintageFun9', '84448', 'LW77xx'),
(10, 'VintageFun10', '40078', 'LC00a');

-- -----------------------------------------------------
-- Insert data into Table `VintageFun`.`workdays`
-- -----------------------------------------------------
INSERT INTO `workdays`
VALUES
('Monday'),
('Tuesday'),
('Wednesday'),
('Thursday'),
('Friday');

-- -----------------------------------------------------
-- Insert data into Table `VintageFun`.`jobs`
-- -----------------------------------------------------
INSERT INTO `jobs`
VALUES
('shopkeeper','The manager who in charges of the whole store.Need to be in the store everyday.'),
('sales staff','The main duty is to serve and sell products to the customers.'),
('shop cleaner','The main duty is to keep the environment in the store clean.');

-- -----------------------------------------------------
-- Insert data into Table `VintageFun`.`employees`
-- -----------------------------------------------------
INSERT INTO `employees` 
VALUES 
('123456789000','Yusu','Li',2,'shopkeeper'),
('123456789001','Yile','Feng',1,'shopkeeper'),
('123456789002','Xiaosuo','Wang',8,'shop cleaner'),
('123456789003','Yuxin','Jin',4,'shopkeeper'),
('123456789004','Zeyu','Liu',5,'shopkeeper'),
('123456789005','Yihuan','Li',6,'shopkeeper'),
('123456789006','Yibo','Wang',8,'shopkeeper'),
('123456789007','Zhan','Xiao',8,'sales staff'),
('123456789008','Jiacheng','Gu',7,'sales staff'),
('123456789009','Gang','Wang',4,'sales staff'),
('123456789010','Tiange','Jia',6,'shop cleaner'),
('123456789011','Akang','Liu',3,'shop cleaner'),
('123456789012','Si','Zhao',1,'shop cleaner'),
('123456789013','Wangji','Lan',10,'shop cleaner'),
('123456789014','Wuxian','Wei',10,'sales staff'),
('123456789015','Wenqing','Zhao',5,'shop cleaner'),
('123456789016','Liying','Liu',3,'sales staff'),
('123456789017','Jialin','Zheng',9,'sales staff'),
('123456789018','Yilin','Tang',5,'sales staff'),
('123456789019','Jie','Xiao',2,'sales staff'),
('123456789020','Lu','Xu',7,'shopkeeper'),
('123456789021','Bohan','Su',6,'sales staff'),
('123456789022','Ruyu','Jia',3,'shopkeeper'),
('123456789023','Qingyuan','Deng',7,'shop cleaner'),
('123456789024','Meiqi','He',9,'shopkeeper'),
('123456789025','Junyi','Li',1,'sales staff'),
('123456789026','Jing','Lu',9,'shop cleaner'),
('123456789027','Chen','Liang',10,'shopkeeper'),
('123456789028','Luge','Hao',4,'shop cleaner'),
('123456789029','Zheng','Gao',2,'shop cleaner');

-- -----------------------------------------------------
-- Insert data into Table `VintageFun`.`employee_workdays`
-- -----------------------------------------------------
INSERT INTO `employee_workdays`
VALUES
('123456789000','Monday'),
('123456789000','Tuesday'),
('123456789000','Wednesday'),
('123456789000','Thursday'),
('123456789000','Friday'),
('123456789001','Monday'),
('123456789001','Tuesday'),
('123456789001','Wednesday'),
('123456789001','Thursday'),
('123456789001','Friday'),
('123456789002','Monday'),
('123456789002','Tuesday'),
('123456789003','Monday'),
('123456789003','Tuesday'),
('123456789003','Wednesday'),
('123456789003','Thursday'),
('123456789003','Friday'),
('123456789004','Monday'),
('123456789004','Tuesday'),
('123456789004','Wednesday'),
('123456789004','Thursday'),
('123456789004','Friday'),
('123456789005','Monday'),
('123456789005','Tuesday'),
('123456789005','Wednesday'),
('123456789005','Thursday'),
('123456789005','Friday'),
('123456789006','Monday'),
('123456789006','Tuesday'),
('123456789006','Wednesday'),
('123456789006','Thursday'),
('123456789006','Friday'),
('123456789007','Wednesday'),
('123456789007','Thursday'),
('123456789007','Friday'),
('123456789008','Wednesday'),
('123456789008','Thursday'),
('123456789009','Tuesday'),
('123456789009','Friday'),
('123456789010','Thursday'),
('123456789010','Friday'),
('123456789011','Monday'),
('123456789011','Wednesday'),
('123456789011','Thursday'),
('123456789012','Wednesday'),
('123456789012','Thursday'),
('123456789012','Friday'),
('123456789013','Wednesday'),
('123456789013','Friday'),
('123456789014','Monday'),
('123456789014','Tuesday'),
('123456789014','Thursday'),
('123456789015','Tuesday'),
('123456789016','Tuesday'),
('123456789016','Friday'),
('123456789017','Wednesday'),
('123456789017','Thursday'),
('123456789018','Monday'),
('123456789018','Wednesday'),
('123456789018','Thursday'),
('123456789018','Friday'),
('123456789019','Monday'),
('123456789019','Tuesday'),
('123456789020','Monday'),
('123456789020','Tuesday'),
('123456789020','Wednesday'),
('123456789020','Thursday'),
('123456789020','Friday'),
('123456789021','Monday'),
('123456789021','Tuesday'),
('123456789021','Wednesday'),
('123456789022','Monday'),
('123456789022','Tuesday'),
('123456789022','Wednesday'),
('123456789022','Thursday'),
('123456789022','Friday'),
('123456789023','Monday'),
('123456789023','Tuesday'),
('123456789023','Friday'),
('123456789024','Monday'),
('123456789024','Tuesday'),
('123456789024','Wednesday'),
('123456789024','Thursday'),
('123456789024','Friday'),
('123456789025','Monday'),
('123456789025','Tuesday'),
('123456789026','Monday'),
('123456789026','Tuesday'),
('123456789026','Friday'),
('123456789027','Monday'),
('123456789027','Tuesday'),
('123456789027','Wednesday'),
('123456789027','Thursday'),
('123456789027','Friday'),
('123456789028','Monday'),
('123456789028','Wednesday'),
('123456789028','Thursday'),
('123456789029','Wednesday'),
('123456789029','Thursday'),
('123456789029','Friday');

-- -----------------------------------------------------
-- Insert data into Table `VintageFun`.`punch_clock`
-- -----------------------------------------------------
INSERT INTO `punch_clock`
VALUES
-- Monday
(1,'123456789000','2021-05-03 08:50:23','2021-05-03 20:03:25'),
(2,'123456789001','2021-05-03 08:52:38','2021-05-03 20:04:37'),
(3,'123456789002','2021-05-03 09:03:43','2021-05-03 20:09:28'),
(4,'123456789003','2021-05-03 08:45:31','2021-05-03 20:10:47'),
(5,'123456789004','2021-05-03 08:58:13','2021-05-03 20:15:35'), 
(6,'123456789005','2021-05-03 09:01:53','2021-05-03 20:01:30'),
(7,'123456789006','2021-05-03 08:53:23','2021-05-03 20:12:28'),
(8,'123456789011','2021-05-03 08:51:34','2021-05-03 20:12:32'),
(9,'123456789014','2021-05-03 08:52:33','2021-05-03 20:11:29'),
(10,'123456789018','2021-05-03 08:52:43','2021-05-03 20:10:23'), 
(11,'123456789019','2021-05-03 08:59:33','2021-05-03 20:20:38'),
(12,'123456789020','2021-05-03 08:50:43','2021-05-03 20:06:36'),
(13,'123456789021','2021-05-03 08:58:25','2021-05-03 20:09:29'),
(14,'123456789022','2021-05-03 09:05:21','2021-05-03 20:23:25'),
(15,'123456789023','2021-05-03 09:20:27','2021-05-03 20:06:29'),
(16,'123456789024','2021-05-03 08:50:12','2021-05-03 20:09:12'),
(17,'123456789025','2021-05-03 08:48:14','2021-05-03 19:27:12'),
(18,'123456789026','2021-05-03 08:49:12','2021-05-03 19:45:23'),
(19,'123456789027','2021-05-03 08:50:29',NULL),
(20,'123456789028','2021-05-03 08:54:09','2021-05-03 20:12:12'),
-- Tuesday
(21,'123456789000','2021-05-04 08:58:10','2021-05-04 20:18:12'),
(22,'123456789001','2021-05-04 08:52:40','2021-05-04 20:12:45'),
(23,'123456789002','2021-05-04 09:09:22','2021-05-04 20:13:17'),
(24,'123456789003','2021-05-04 08:50:23','2021-05-04 19:58:20'),
(25,'123456789004','2021-05-04 08:52:43','2021-05-04 20:03:23'),
(26,'123456789005','2021-05-04 08:49:23','2021-05-04 20:03:20'),
(27,'123456789006','2021-05-04 09:10:23','2021-05-04 20:02:12'),
(28,'123456789009','2021-05-04 08:52:25','2021-05-04 20:06:36'), 
(29,'123456789014','2021-05-04 08:53:34','2021-05-04 20:04:25'), 
(30,'123456789015','2021-05-04 08:23:35','2021-05-04 20:03:25'),
(31,'123456789016','2021-05-04 08:34:59','2021-05-04 20:34:22'),
(32,'123456789019','2021-05-04 09:23:34','2021-05-04 20:10:47'),
(33,'123456789020','2021-05-04 08:45:23','2021-05-04 20:12:25'),
(34,'123456789021','2021-05-04 08:47:53','2021-05-04 20:11:25'),
(35,'123456789022','2021-05-04 08:23:21','2021-05-04 20:39:25'),
(36,'123456789023','2021-05-04 08:36:26','2021-05-04 19:20:12'),
(37,'123456789024','2021-05-04 08:35:29','2021-05-04 19:58:20'),
(38,'123456789025',NULL,'2021-05-04 20:05:15'),
(39,'123456789026','2021-05-04 08:35:22','2021-05-04 20:15:45'),
(40,'123456789027','2021-05-04 08:50:23','2021-05-04 20:03:25'),
-- Wednesday
(41,'123456789000','2021-05-05 09:12:23','2021-05-05 20:09:15'),
(42,'123456789001','2021-05-05 09:02:13','2021-05-05 20:00:25'),
(43,'123456789003','2021-05-05 09:10:53','2021-05-05 20:18:12'), 
(44,'123456789004','2021-05-05 08:51:34','2021-05-05 20:03:29'),
(45,'123456789005','2021-05-05 09:00:23','2021-05-05 20:03:56'),
(46,'123456789006','2021-05-05 08:52:47','2021-05-05 20:05:25'),
(47,'123456789007','2021-05-05 08:53:34','2021-05-05 20:08:49'), 
(48,'123456789008','2021-05-05 08:49:45','2021-05-05 20:13:17'),
(49,'123456789011',NULL,'2021-05-05 20:02:25'), 
(50,'123456789012','2021-05-05 08:54:56','2021-05-05 20:09:12'),
(51,'123456789013','2021-05-05 08:52:43','2021-05-05 20:16:25'),
(52,'123456789017','2021-05-05 08:57:16','2021-05-05 20:09:25'),
(53,'123456789018','2021-05-05 08:54:20','2021-05-05 20:02:27'),
(54,'123456789020','2021-05-05 08:59:23','2021-05-05 20:23:25'),
(55,'123456789021','2021-05-05 08:58:21','2021-05-05 20:12:23'),
(56,'123456789022','2021-05-05 08:57:39','2021-05-05 20:03:25'),
(57,'123456789024','2021-05-05 08:53:40','2021-05-05 20:04:25'),
(58,'123456789027','2021-05-05 08:54:30','2021-05-05 20:03:25'),
(59,'123456789028','2021-05-05 08:46:22','2021-05-05 20:09:25'),
(60,'123456789029','2021-05-05 08:48:10','2021-05-05 20:12:25'),
-- Thursday
(61,'123456789000','2021-05-06 08:54:23','2021-05-06 20:13:25'),
(62,'123456789001','2021-05-06 08:55:23','2021-05-06 20:23:25'),
(63,'123456789003','2021-05-06 09:12:23','2021-05-06 20:09:21'),
(64,'123456789004','2021-05-06 08:57:23','2021-05-06 20:03:21'),
(65,'123456789005','2021-05-06 08:54:23','2021-05-06 20:12:22'),
(66,'123456789006','2021-05-06 08:56:23','2021-05-06 20:03:25'),
(67,'123456789007','2021-05-06 08:57:23','2021-05-06 20:10:47'),
(68,'123456789008','2021-05-06 08:58:23','2021-05-06 20:23:25'),
(69,'123456789010','2021-05-06 08:59:23','2021-05-06 20:09:21'),
(70,'123456789011','2021-05-06 09:02:33','2021-05-06 20:03:25'),
(71,'123456789012','2021-05-06 08:46:37','2021-05-06 20:03:27'),
(72,'123456789014','2021-05-06 08:49:49','2021-05-06 20:09:12'),
(73,'123456789017','2021-05-06 08:47:40','2021-05-06 20:04:25'),
(74,'123456789018','2021-05-06 09:20:29','2021-05-06 20:09:25'),
(75,'123456789020','2021-05-06 08:59:59',NULL),
(76,'123456789022','2021-05-06 08:43:38','2021-05-06 20:03:25'),
(77,'123456789024','2021-05-06 08:56:45','2021-05-06 20:23:23'),
(78,'123456789027','2021-05-06 08:38:23','2021-05-06 20:03:12'),
(79,'123456789028','2021-05-06 08:49:43','2021-05-06 20:06:28'), 
(80,'123456789029','2021-05-06 08:58:43','2021-05-06 20:09:12'),
-- Friday
(81,'123456789000','2021-05-07 08:53:23','2021-05-07 20:16:22'),
(82,'123456789001','2021-05-07 08:52:38','2021-05-07 20:29:25'), 
(83,'123456789003','2021-05-07 08:53:29','2021-05-07 20:23:25'),
(84,'123456789004','2021-05-07 08:59:23','2021-05-07 20:06:32'),
(85,'123456789005','2021-05-07 08:53:23','2021-05-07 20:09:25'),
(86,'123456789006','2021-05-07 08:52:23','2021-05-07 20:03:12'),
(87,'123456789007','2021-05-07 08:51:48','2021-05-07 20:23:09'),
(88,'123456789009','2021-05-07 08:57:35',NULL), 
(89,'123456789010','2021-05-07 09:04:19','2021-05-07 20:13:45'),
(90,'123456789012','2021-05-07 09:03:38','2021-05-07 20:23:25'),
(91,'123456789013','2021-05-07 08:47:23','2021-05-07 20:09:13'),
(92,'123456789016','2021-05-07 08:50:48','2021-05-07 20:13:23'),
(93,'123456789018','2021-05-07 08:49:29','2021-05-07 20:23:25'),
(94,'123456789020','2021-05-07 08:09:12','2021-05-07 20:02:25'),
(95,'123456789022','2021-05-07 09:04:24','2021-05-07 20:03:25'),
(96,'123456789023','2021-05-07 08:54:42','2021-05-07 20:09:25'),
(97,'123456789024','2021-05-07 08:32:23','2021-05-07 20:10:27'),
(98,'123456789026','2021-05-07 08:43:23',NULL),
(99,'123456789027','2021-05-07 08:56:23','2021-05-07 20:06:32'), 
(100,'123456789029','2021-05-07 08:45:25','2021-05-07 19:45:23');

-- -----------------------------------------------------
-- Insert data into Table `VintageFun`.`developer_companies`
-- -----------------------------------------------------
INSERT INTO `developer_companies`
VALUES  (1, 'Capcom'), 
		(2, 'Nintendo'), 
		(3, 'Tose Co.'),
		(4, 'THQ'), 
		(5, 'Rockstar Games'), 
		(6, 'Valve Corporation'),
		(7, 'Riot Games');

-- -----------------------------------------------------
-- Insert data into Table `VintageFun`.`formats`
-- -----------------------------------------------------
INSERT INTO `formats`
VALUES  ( 'CD'),
	( 'cartridge');

-- -----------------------------------------------------
-- Insert data into Table `VintageFun`.`sell_methods`
-- -----------------------------------------------------
INSERT INTO `sell_methods`
VALUES  ('game'),
	('game pack');

-- -----------------------------------------------------
-- Insert data into Table `VintageFun`.`products`
-- -----------------------------------------------------
INSERT INTO `products`
VALUES  ('shwj1', 'VintageFun 19 in 1 2021',  'CD', 'game pack'),
		('mario', 'VintageFun 15 in 1 2019',  'CD', 'game pack'),
		('sh22t', 'VintageFun 10 in 1 2019',  'cartridge', 'game pack'),
		('a2021', 'VintageFun 44 in 1 2021',  'cartridge', 'game pack'),
		('shwj2', 'VintageFun 19 in 1 2021',  'cartridge', 'game pack'),
		('28900', 'Dota 2',  'CD', 'game'),
		('r2009', 'New Super Mario Bros. Wii',  'CD', 'game'),
		('fjgyb', 'Couter-Strike: Condition Zero',  'CD', 'game'),
		('f8vea', 'Resident Evil: The Umbrella Chronicles',  'CD', 'game'),
		('f00n6', 'Couter-Strike: Global Offensive',  'cartridge', 'game'),
		('wx095', 'Resident Evil: The Darkside Chronicles', 'cartridge', 'game');

-- -----------------------------------------------------
-- Insert data into Table `VintageFun`.`games`
-- -----------------------------------------------------
INSERT INTO `games`
VALUES  (1, 'Resident Evil 1', 'survival horror', '1996-03-22', 17, 1),
	    (2, 'Resident Evil 2', 'survival horror', '1998-01-21', 17, 1),
	    (3, 'Resident Evil 3: Nemesis', 'survival horror', '1999-09-22', 17, 1),
	    (4, 'Resident Evil 4', 'survival horror', '2005-01-11', 17, 1),
		(5, 'Resident Evil 5', 'survival horror', '2009-03-05', 17, 1),
		(6, 'Resident Evil 6', 'survival horror', '2012-10-02', 17, 1),
		(7, 'Resident Evil 7: Biohazard', 'survival horror', '2017-01-24', 17, 1),
		(8, 'Resident Evil Village', 'survival horror', '2021-05-07', 17, 1),
		(9, 'Resident Evil zero', 'survival horror', '2002-11-12', 17, 1),
		(10, 'Resident Evil: Revelations', 'survival horror', '2012-01-26', 17, 2),
		(11, 'Resident Evil: The Umbrella Chronicles', 'survival horror', '2007-11-13', 17, 4),
		(12, 'Resident Evil Outbreak', 'survival horror', '2003-12-11', 17, 1),
		(13, 'Resident Evil: Dead Aim', 'survival horror', '2003-02-13', 17, 1),
		(14, 'Resident evil Survivor', 'survival horror', '2000-01-27', 17, 1),
		(15, 'Resident Evil Garden', 'survival horror', '2001-12-14', 17, 1),
		(16, 'Resident Evil: The Darkside Chronicles', 'survival horror', '2009-11-17', 17, 1),
		(17, 'Resident Evil: Revelation 2', 'survival horror', '2015-02-24', 17, 1),
		(18, 'Resident Evil: Operation Raccoon City', 'survival horror', '2012-03-20', 17, 1),
		(19, 'Resident Evil: The Mercenaries 3D', 'survival horror', '2011-06-02', 17, 3),
		(20, 'Super Mario Bros.', 'adventure', '1985-09-13', 14, 2),
		(21, 'Super Mario Bros. 2', 'adventure', '1988-10-09', 14, 2),
		(22, 'Super Mario Bros. 3', 'adventure', '1988-09-23', 14, 2),
		(23, 'Super Mario World', 'adventure', '1900-11-21', 14, 2),
		(24, 'Super Mario 64', 'adventure', '1996-06-23', 14, 2),
		(25, 'Super Mario Sunshine', 'adventure', '2001-08-26', 14, 2),
		(26, 'Super Mario Galaxy', 'adventure', '2007-11-01', 14, 2),
		(27, 'Super Mario Galaxy 2', 'adventure', '2010-05-23', 14, 2),
		(28, 'Super Mario Odyssey', 'adventure', '2017-10-27', 14, 2),
		(29, 'New Super Mario Bros. U', 'adventure', '2012-11-18', 14, 2),
		(30, 'Super Mario Maker 2', 'adventure', '2019-06-28', 14, 2),
		(31, 'Super Mario 3D World', 'adventure', '2013-11-21', 14, 2),
		(32, 'Super Mario 3D Land', 'adventure', '2011-11-03', 14, 2),
		(33, 'New Super Mario Bros.', 'adventure', '2006-05-15', 14, 2),
		(34, 'New Super Mario Bros. Wii', 'adventure', '2009-11-11', 14, 2),
		(35, 'Red Dead', 'action-adventure', '2004-05-04', 17, 5),
		(36, 'Red Dead Redemption', 'action-adventure', '2010-05-18', 17, 5),
		(37, 'Red Dead Redemption 2', 'action-adventure', '2018-10-26', 17, 5),
		(38, 'Red Dead Revolver', 'action-adventure', '2004-05-03', 17, 5),
		(39, 'League of Legends', 'battle arena', '2009-10-27', 14, 7),
		(40, 'Dota 2', 'battle arena', '2013-07-09', 14, 6),
		(41, 'Couter-Strike', 'First-person Shooter', '2000-11-09', 18, 6),
		(42, 'Couter-Strike: Global Offensive', 'First-person Shooter', '2012-08-21', 18, 6),
		(43, 'Couter-Strike: Source', 'First-person Shooter', '2004-08-11', 18, 6),
		(44, 'Couter-Strike: Condition Zero', 'First-person Shooter', '2004-03-23', 18, 6);

-- -----------------------------------------------------
-- Insert data into Table `VintageFun`.`product_games`
-- -----------------------------------------------------
INSERT INTO `product_games`
VALUES  ('shwj1', 1),
		('shwj1', 2),
		('shwj1', 3),
		('shwj1', 4),
		('shwj1', 5),
		('shwj1', 6),
		('shwj1', 7),
		('shwj1', 8),
		('shwj1', 9),
		('shwj1', 10),
		('shwj1', 11),
		('shwj1', 12),
		('shwj1', 13),
		('shwj1', 14),
		('shwj1', 15),
		('shwj1', 16),
		('shwj1', 17),
		('shwj1', 18),
		('shwj1', 19),
		-- games for product1
		('mario', 20),
		('mario', 21),
		('mario', 22),
		('mario', 23),
		('mario', 24),
		('mario', 25),
		('mario', 26),
		('mario', 27),
		('mario', 28),
		('mario', 29),
		('mario', 30),
		('mario', 31),
		('mario', 32),
		('mario', 33),
		('mario', 34),
		-- games for product2
		('sh22t', 35),
		('sh22t', 36),
		('sh22t', 37),
		('sh22t', 38),
		('sh22t', 39),
		('sh22t', 40),
		('sh22t', 41),
		('sh22t', 42),
		('sh22t', 43),
		('sh22t', 44),
		-- games for product3
		('a2021', 1),
		('a2021', 2),
		('a2021', 3),
		('a2021', 4),
		('a2021', 5),
		('a2021', 6),
		('a2021', 7),
		('a2021', 8),
		('a2021', 9),
		('a2021', 10),
		('a2021', 11),
		('a2021', 12),
		('a2021', 13),
		('a2021', 14),
		('a2021', 15),
		('a2021', 16),
		('a2021', 17),
		('a2021', 18),
		('a2021', 19),
		('a2021', 20),
		('a2021', 21),
		('a2021', 22),
		('a2021', 23),
		('a2021', 24),
		('a2021', 25),
		('a2021', 26),
		('a2021', 27),
		('a2021', 28),
		('a2021', 29),
		('a2021', 30),
		('a2021', 31),
		('a2021', 32),
		('a2021', 33),
		('a2021', 34),
		('a2021', 35),
		('a2021', 36),
		('a2021', 37),
		('a2021', 38),
		('a2021', 39),
		('a2021', 40),
		('a2021', 41),
		('a2021', 42),
		('a2021', 43),
		('a2021', 44),
		-- games for product4
		('shwj2', 1),
		('shwj2', 2),
		('shwj2', 3),
		('shwj2', 4),
		('shwj2', 5),
		('shwj2', 6),
		('shwj2', 7),
		('shwj2', 8),
		('shwj2', 9),
		('shwj2', 10),
		('shwj2', 11),
		('shwj2', 12),
		('shwj2', 13),
		('shwj2', 14),
		('shwj2', 15),
		('shwj2', 16),
		('shwj2', 17),
		('shwj2', 18),
		('shwj2', 19),
		-- games for product5
		('28900', 40),
		('r2009', 34),
		('fjgyb', 44),
		('f8vea', 11),
		('f00n6', 42),
		('wx095', 16);

-- -----------------------------------------------------
-- Insert data into Table `VintageFun`.`game_comments`
-- -----------------------------------------------------
INSERT INTO `game_comments`
VALUES (1, 'Good Games.'), 
(2, 'Scary enough!'), 
(3, 'Like it!!!'), 
(4, 'Not scary at all, but then again, the previous game didnt exactly put out a standart to meet.'), 
(5, 'I do think the boss fights also end up being stronger than usual for the series, it does feel there is a bit room for improvement, 
	but the series has a rocky, uneven history with boss fights, 
	& I can say Village has more consistently good boss fights than other entries, helped they are all pretty varied to each other.'), 
(6, 'big booba the end'), 
(6, 'RE fan here!!'),
(7, 'perfect!!'), 
(7, 'It is not that scary yes, it can be at sometimes. '), 
(8, 'Compared to, say, RE7, which nailed its hillbilly found footage horror aesthetic 
	& focus on the Baker Family, RE8 is a bit more all over the place. 
	This leads to greater variety, & I think RE8 nails what it is going for, but 
	it is very different, & actually makes them hard to compare for me. I think RE8 virtually 
	solves all of RE7 is problems, IE it has a good final boss fight, Chris is really interesting in RE8, 
	new much more interesting enemies, with new enemy types introduced through the whole game, with a better back-half, 
	but it is such a different game than RE7 in so many ways I still find it hard to compare the two.'), 
(8, 'A perfect mix of Resident Evil 7 and Resident Evil 4. 
	Loved all the lore it had and loved every single thing about it. 
	Incredible game and truly a masterpiece. 10/10. Thank you, Capcom'), 
(8, ' I will save you, no matter what. -- Ethan Winters'), 
(8, 'Great horror game'), 
(9, '10/10 would recommend!'),
(10, 'Is no one realizing this is the first resident evil with actually evil residents.'), 
(11, 'great'), 
(12, 'just so so.....'), 
(12, 'not bad.'), 
(13, 'very fun game, and love the series.'), 
(14, 'fun and horror!'), 
(15, '10/10'), 
(15, 'LEON YOU HAVE TO CONTINUE THE REDFIELD BLOODLINE!'),
(16, 'This is by far my most favourite Resident Evil game ever'),  
(18, 'pog'), 
(18, 'Jesus!!!'), 
(19, 'good'), 
(20, 'lovin it'), 
(20, 'seriously, bro?'), 
(21, 'i love mario for 8 ys, it is my favourite god!!!!'), 
(22, 'what?'),
(23, 'hi like it!'), 
(23, 'comment here if u love it too!!!!'), 
(23, 'fun games, respect!'), 
(24, 'not bad...'), 
(25, 'waste money......'), 
(26, 'ok.'), 
(27, 'my happy chlid '), 
(28, 'my friend recommended this to me, and now i play better than her lol!'), 
(29, 'good game!'),
(30, 'very good'), 
(30, 'sucks......'), 
(31, '10/10 recommend'), 
(32, 'loving it!'), 
(33, 'gooooooooooooood!'), 
(34, 'not bad, man'), 
(35, 'alright.'), 
(36, 'do not buy it, sucks!!!!'), 
(37, 'great!!!!'),
(39, 'It is like roulette; fun until it turns into Russian'), 
(40, 'is a game'), 
(41, 'sucks'), 
(42, 'not bad, kkkkk'), 
(43, 'The only game where you can shoot someone 3 times in the head and they kill you.'), 
(43, '>see a guy
		>shoot him
		>miss every shot
		>he turns around
		>kills me in one shot'), 
(43, 'After 8 years playing it, I didnt improve my skills in-game.
		However, I learned new language skills: now I can curse in Russian and Brazilian Portuguese.'), 
(44, 'love it forever!');

-- ----------------------------------------------------------------------------------------------------
-- Section3: Query
-- ----------------------------------------------------------------------------------------------------

-- 1.search the staff group whose shopkeeper is known 
SELECT *
FROM employees
WHERE store_id=
(SELECT store_id
FROM employees WHERE first_name='Yibo'
	AND last_name='Wang')
ORDER BY id_number;

-- -----------------------------------------------------------------------------------
-- 2.return the information of the shopkeeper
SELECT first_name,
	last_name,
	name AS store,
	telephone_number,
	postcode	
FROM employees
JOIN retail_stores
USING (store_id)
WHERE job_role = 'shopkeeper';

-- -----------------------------------------------------------------------------------
-- 3.retrieve the infromation of stores in a central region as well as the staff information
-- The results should be in the following format:
-- || store id |  store telephone  | store postcode |  employee id |  full name| job role  ||

SELECT *
FROM employees 
JOIN retail_stores
USING (store_id)
WHERE store_id IN (
	SELECT store_id FROM retail_stores  WHERE postcode REGEXP '^LC'
)
ORDER BY store_id;

-- -----------------------------------------------------------------------------------
-- 4.return the information of the most recently built store
-- The results should be in the following format:
-- || store id | employee id | full name | job role | arrive time | leave time ||

SELECT store_id,
	id_number AS employee_id,
	CONCAT(first_name,' ', last_name) AS full_name,
	job_role,
	arrive_time,
	leave_time
FROM employees 
lEFT JOIN punch_clock 
USING (id_number)
WHERE store_id =(
SELECT store_id
FROM retail_stores  
WHERE store_id >= ALL (SELECT store_id FROM retail_stores)
)
ORDER BY id_number;

-- -----------------------------------------------------------------------------------
-- 5.return the information of employees who are late at morning or leave early in the evening in the stores located in centre.
-- The results should be in the following format:
-- || store id | employee id | full name | date | arrive time | leave time ||

SELECT 
	store_id,
	id_number AS employee_id,
	CONCAT(first_name,' ', last_name) AS full_name,
	cast(arrive_time AS DATE) AS date,
	cast(arrive_time AS TIME) arrive_time,
	cast(leave_time AS TIME) leave_time
FROM punch_clock
JOIN employees USING (id_number)
WHERE (
	cast(arrive_time AS TIME) > '09:00:00' 
	OR cast(leave_time AS TIME) < '20:00:00'
	)
	AND store_id IN (SELECT store_id FROM retail_stores WHERE postcode LIKE 'LC%')
ORDER BY store_id, date;

-- -----------------------------------------------------------------------------------
-- 6.return the list of employees who came to work without punching the clock in the morning or in the evening
-- The results should be in the following format:
-- || store id | employee id | full name | arrive time | leave time ||

SELECT store_id,
  id_number AS employee_id,
  CONCAT(first_name,' ', last_name) AS full_name,
  arrive_time,
  leave_time
FROM employees 
JOIN punch_clock 
USING (id_number)
WHERE arrive_time IS NULL 
  OR leave_time IS NULL
ORDER BY store_id;

-- -----------------------------------------------------------------------------------
-- 7. return the records of who is late more than 20 minutes or leaves early more than 30 minutes
-- The results should be in the following format: 
-- || store id | employee id | full name | date | arrive time | leave time ||

SELECT 
	store_id,
	id_number AS employee_id,
	CONCAT(first_name,' ', last_name) AS full_name,
	cast(arrive_time AS DATE) AS date,  -- cast arrive_time as DATE type
	cast(arrive_time AS TIME) arrive_time, 
	cast(leave_time AS TIME) leave_time     -- cast arrive_time and leave_time as TIME type
FROM punch_clock
JOIN employees USING (id_number)
WHERE time_to_sec(arrive_time)-time_to_sec('09:00:00') > 1200 
	OR time_to_sec('20:00:00')-time_to_sec(leave_time) > 1800
ORDER BY store_id, date;

-- -----------------------------------------------------------------------------------
-- 8.return how long each employee works everyday
-- The results should be in the following format: 
-- || store id | employee id | full name | date | working time ||
 
SELECT store_id,
  id_number AS employee_id,
  CONCAT(first_name,' ', last_name) AS full_name,
  COALESCE(DATE_FORMAT(arrive_time,'%Y-%m-%d'),DATE_FORMAT(leave_time,'%Y-%m-%d')) AS date, -- use the coalesce function since in the table punch_clock, the arrive_time or leave_time could be NULL
  COALESCE(TIMEDIFF(leave_time, arrive_time), 'arrive_time or leave_time is missing' ) AS working_time
FROM employees 
JOIN punch_clock 
USING (id_number)
ORDER BY store_id, id_number;

-- -----------------------------------------------------------------------------------
-- 9. retrieve the employees excluding shopkeepers who actually come to work for 3 days consecutively
SELECT DISTINCT p1.id_number,
  CONCAT(first_name,' ', last_name) AS full_name
FROM punch_clock p1, punch_clock p2, punch_clock p3
JOIN employees e USING (id_number)
WHERE (p1.id_number=p2.id_number AND p2.id_number=p3.id_number)
  AND
  DAYOFWEEK(p1.arrive_time)+1=DAYOFWEEK(p2.arrive_time)
  AND
  DAYOFWEEK(p2.arrive_time)+1=DAYOFWEEK(p3.arrive_time)
  AND
  e.job_role <> 'shopkeeper';

-- -----------------------------------------------------------------------------------
-- 10. return the the list of all developer companies and the number of their released games
-- The results should be in the following format: 
-- || developer company id | company name | number of games ||

SELECT 
	developer_company_id,
    name AS company_name,
	COUNT(*) AS number_of_games
FROM developer_companies
JOIN games 
USING (developer_company_id)
GROUP BY developer_company_id
ORDER BY number_of_games DESC;

-- -----------------------------------------------------------------------------------
-- 11.return the developer companies and when they released the newest games
SELECT 
	developer_company_id,
    name AS company_name,
    MAX(YEAR(release_date)) AS newest_game_release_in
FROM developer_companies
JOIN games 
USING (developer_company_id)
GROUP BY developer_company_id
ORDER BY developer_company_id ASC;

-- -----------------------------------------------------------------------------------
-- 12.return the products that contain the games released in the current year, in this case, it's 2021 
SELECT serial_number,
	title,
	format_name AS format,
	sell_method_name AS sell_method
FROM products 
JOIN product_games USING (serial_number)
WHERE game_id IN (
	SELECT game_id FROM games 
	WHERE YEAR(release_date) = YEAR(NOW()) -- get the current year
)
ORDER BY serial_number ASC;

-- -----------------------------------------------------------------------------------
-- 13.return the number of comments of all Resident Evil games
-- The results should be in the following format: 
-- || game id  | game title  | release date  | number of comments  || 

SELECT game_id,
	title,
	release_date,
	count(*) AS number_of_comments
FROM game_comments 
JOIN games 
USING (game_id)
WHERE title LIKE 'Resident Evil%'
GROUP BY game_id
ORDER BY release_date;

-- -----------------------------------------------------------------------------------
-- 14.return the games that have no comment
SELECT title,
	genre,
	release_date,
	age_rating,
	dc.name,
  0 AS comment
FROM games g
JOIN developer_companies dc
USING (developer_company_id)
WHERE NOT EXISTS (
	SELECT game_id FROM game_comments
	WHERE  game_id = g.game_id
		)  -- rerun true if a game has comments
ORDER BY release_date;

-- -----------------------------------------------------------------------------------
-- 15.  return the number of comments and the average length of comments of each game
-- The results should be in the following format: 
-- || game id  |game title  | game genre  | release date | number of comments | average length of comments ||

SELECT game_id,
	title,
	genre,
  release_date,
	count(comment) AS number_of_comments, -- count the number of comments
	ROUND(AVG(LENGTH(comment)), 2) AS average_comment_length -- compute the average length of comments and round the result
FROM games 
LEFT JOIN game_comments
USING (game_id)
GROUP BY game_id
ORDER BY release_date;

-- -----------------------------------------------------------------------------------
-- 16. retrieve all games from 'Resident Evil' series and label them. if it is released before 2010, then return 'classic', otherwise, 'new'

SELECT g.title,
  IF(YEAR(release_date)<='2010',
  'classic',
  'new') AS label
FROM games g
WHERE g.title LIKE 'Resident Evil%';

-- -----------------------------------------------------------------------------------
-- 17. return for each game, there are how many products contains it.
-- The results should be in the following format: 
-- || game id  | game title  | number of products  ||

SELECT 
	game_id,
  title AS game_name,
	COUNT(serial_number) AS number_of_products
FROM product_games
JOIN games 
USING (game_id)
GROUP BY game_id
ORDER BY number_of_products DESC;

-- -----------------------------------------------------------------------------------
-- 18. return the games whose age rating is the smallest
SELECT *
FROM games
WHERE age_rating <= ALL(SELECT age_rating FROM games);

-- -----------------------------------------------------------------------------------
-- 19. return the number of games for different game genres
-- The results should be in the following format:
-- || game genre | number of games ||

SELECT 
	genre,
	COUNT(*) AS number_of_games
FROM games
GROUP BY genre
ORDER BY number_of_games DESC;

-- -----------------------------------------------------------------------------------
-- 20. return the average working time of each store
-- The results should be in the following format:
-- || store id | average working time||

SELECT store_id,
  AVG(working_time) AS average_working_time_hours
FROM(
  SELECT store_id,
  id_number AS employee_id,
  COALESCE(TIMEDIFF(leave_time, arrive_time), 'arrive_time or leave_time is missing' ) AS working_time -- get (leave_time - arrive_time)
FROM employees 
JOIN punch_clock 
USING (id_number)
) AS working_time_summary   -- create a new table for query
GROUP BY store_id
ORDER BY average_working_time_hours DESC;


