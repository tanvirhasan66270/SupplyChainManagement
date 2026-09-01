-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: supplichainmgt
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `logistics_officers`
--

DROP TABLE IF EXISTS `logistics_officers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `logistics_officers` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `address` text,
  `contact_person` varchar(255) NOT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `designation` varchar(255) DEFAULT NULL,
  `dob` date NOT NULL,
  `gender` enum('FEMALE','MALE','OTHERS') DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `is_active` bit(1) NOT NULL,
  `joining_date` date DEFAULT NULL,
  `language` enum('BANGLA','ENGLISH','OTHERS') DEFAULT NULL,
  `nid_number` varchar(255) NOT NULL,
  `passport_number` varchar(255) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `police_station_id` bigint DEFAULT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKcy05ijhk7kjrhfvdajftp9jlm` (`nid_number`),
  UNIQUE KEY `UK3evy0tmt052kgxl30e1btaeln` (`user_id`),
  UNIQUE KEY `UKeyc1ews9maiej04o5xnqws9ft` (`passport_number`),
  KEY `FKda83q98bup14mycuf3hl13c6u` (`police_station_id`),
  CONSTRAINT `FKda83q98bup14mycuf3hl13c6u` FOREIGN KEY (`police_station_id`) REFERENCES `policestations` (`id`),
  CONSTRAINT `FKmigcgicdln6unhoavd4b46hj` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `logistics_officers`
--

LOCK TABLES `logistics_officers` WRITE;
/*!40000 ALTER TABLE `logistics_officers` DISABLE KEYS */;
INSERT INTO `logistics_officers` VALUES (1,'House 12, Mirpur, Dhaka, Dhaka, Bangladesh','MD. Tanvir','2026-06-30 16:42:38.414605','Logistics Operations Officer','1999-10-10','MALE','MD_Tanvir_d8a7693e-322e-4a03-aabd-18e9ed96e27a.jpg',_binary '','2026-06-30','BANGLA','1999261025478','A01234567','2026-07-28 18:50:57.409178',1,19),(2,'uploads/logistics_officer/Emon_d2a4e755-cc24-4499-922a-0124a57b9aea.jpg, Mirpur, Dhaka, Dhaka, Bangladesh','Emon','2026-07-05 16:17:57.428392','Logistics Officer','2026-06-28','MALE','Emon_33380ab7-e4fb-4864-a108-eae1b40b51e1.jpg',_binary '\0','2026-07-08','ENGLISH','19982693456','2123013242','2026-07-28 18:51:18.675482',1,66);
/*!40000 ALTER TABLE `logistics_officers` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-08-31 23:43:11
