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
-- Table structure for table `daily_reports`
--

DROP TABLE IF EXISTS `daily_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `daily_reports` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `attachment_url` varchar(255) DEFAULT NULL,
  `generated_at` datetime(6) NOT NULL,
  `issues_logged` int NOT NULL,
  `report_date` date NOT NULL,
  `report_status` enum('APPROVED','DRAFT','SUBMITTED') DEFAULT NULL,
  `summary` text,
  `total_tasks_done` int NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `user_id` varchar(255) NOT NULL,
  `warehouse_id` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `daily_reports`
--

LOCK TABLES `daily_reports` WRITE;
/*!40000 ALTER TABLE `daily_reports` DISABLE KEYS */;
INSERT INTO `daily_reports` VALUES (8,'REPORTS_05c9d40e-9dc3-4523-9ff4-2584443d4aa9.png','2026-07-11 18:59:55.333144',20,'2026-07-15','SUBMITTED','SDMFKngbw sjrwef',500,'2026-08-16 01:04:17.025808','tanvirhasan66270@gmail.com','WH-DHAKA-01'),(9,'REPORTS_a2a7e6cb-194e-4ad6-a4f3-98b645e796f9.png','2026-07-11 18:59:56.213706',20,'2026-07-15','SUBMITTED','SDMFKngbw sjrwef',500,'2026-07-11 19:00:07.222288','tanvirhasan66270@gmail.com','WH-DHAKA-01'),(10,'REPORTS_0176f100-da4a-4c3c-b7d9-4adbff784a71.png','2026-07-11 18:59:56.461372',20,'2026-07-15','SUBMITTED','SDMFKngbw sjrwef',500,'2026-07-11 19:00:05.182431','tanvirhasan66270@gmail.com','WH-DHAKA-01'),(11,'REPORTS_5469c213-fb4d-46bd-b532-40aa23bc417f.png','2026-07-11 18:59:57.174253',20,'2026-07-15','SUBMITTED','SDMFKngbw sjrwef',500,'2026-07-11 19:00:08.064731','tanvirhasan66270@gmail.com','WH-DHAKA-01'),(13,'REPORTS_531d4d28-3132-42f2-b86c-d708392e7512.jpg','2026-07-26 15:46:30.191709',10,'2026-07-28','APPROVED','zdfgd',200,'2026-08-23 00:41:30.934321','tanvirhas@gmail.com','WH-CHITTAGONG-02'),(14,'REPORTS_5252bcdc-d319-4227-973a-d4fa974bbc8a.jpg','2026-07-26 15:46:31.666497',10,'2026-07-28','SUBMITTED','zdfgd',200,'2026-07-26 15:46:50.602613','tanvirhas@gmail.com','WH-CHITTAGONG-02');
/*!40000 ALTER TABLE `daily_reports` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-08-31 23:43:12
