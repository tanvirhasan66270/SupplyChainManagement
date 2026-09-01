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
-- Table structure for table `purchase_requisitions`
--

DROP TABLE IF EXISTS `purchase_requisitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `purchase_requisitions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `approval_status` enum('APPROVED','CANCELLED','PENDING','REJECTED') DEFAULT NULL,
  `approved_by` bigint DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `currency` varchar(255) NOT NULL,
  `quantity_required` int NOT NULL,
  `remarks` text,
  `requested_by` bigint NOT NULL,
  `required_by_date` date NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `urgency_level` enum('CRITICAL','HIGH','LOW','MEDIUM') DEFAULT NULL,
  `product_names` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `purchase_requisitions`
--

LOCK TABLES `purchase_requisitions` WRITE;
/*!40000 ALTER TABLE `purchase_requisitions` DISABLE KEYS */;
INSERT INTO `purchase_requisitions` VALUES (1,'APPROVED',82,'2026-07-01 15:58:14.783577','USD',500,'Urgent procurement needed for garments raw materials production line.',12,'2026-07-25','2026-07-19 14:39:34.525954','CRITICAL','Type-C Braided Nylon Fast Charging Cable, Pneumatic Air Pressure Regulator Node, Industrial Machine Degreaser Fluid'),(4,'APPROVED',82,'2026-07-19 14:47:23.785823','USD',210,'ssssssssssssssss sesesesesesesesesesesesesese',80,'2026-07-20','2026-07-19 14:48:57.279244','LOW','Industrial Garments Big Knitting Machine, Heavy Duty Double Needle Sewing Machine'),(5,'APPROVED',82,'2026-08-16 00:43:14.287766','USD',200,'mdsfnvfdevg askefgr dfgjnfsdo',80,'2026-09-30','2026-08-16 00:46:58.368875','MEDIUM','Super Fast Dual Port Charger 2.0, Premium Heavy Duty Silicone Protection Cover, Ergonomic Desktop Mobile Handle Stand'),(6,'PENDING',NULL,'2026-08-16 00:43:46.507634','USD',10,'sxfdvgsdfrgvsdf\n[Fulfilling Requirements: sgfsfdh]\n[Fulfilling Requirements: sgfsfdh, Havey Duty Machin]\n[Fulfilling Requirements: sgfsfdh]\n[Fulfilling Requirements: sgfsfdh]',80,'2026-09-03','2026-08-21 23:19:52.187311','LOW','High Speed Garments Stitching System'),(7,'PENDING',NULL,'2026-08-21 23:28:59.796510','USD',20,'advsdab\n[Fulfilling Requirements: sgfsfdh]',80,'2026-08-25','2026-08-21 23:28:59.796510','MEDIUM','Heavy Duty Double Needle Sewing Machine'),(8,'PENDING',NULL,'2026-08-22 22:41:16.363511','USD',1,'',80,'2026-09-01','2026-08-22 22:41:16.363511','LOW','Heavy Duty Double Needle Sewing Machine, High Speed Garments Stitching System'),(9,'APPROVED',82,'2026-08-22 22:45:07.044756','USD',1,'dagfdasgg',80,'2026-09-02','2026-08-23 00:21:03.637893','LOW','High Speed Garments Stitching System, Industrial Garments Big Knitting Machine'),(10,'PENDING',NULL,'2026-08-22 22:47:17.245780','USD',50,'dbfdzb',80,'2026-09-01','2026-08-22 22:47:17.245780','LOW','Industrial Garments Big Knitting Machine, Commercial Garments Washing Machine'),(11,'APPROVED',82,'2026-08-22 22:50:41.342759','USD',1,'sdgsdhsfhh',80,'2026-08-25','2026-08-23 00:39:42.278571','LOW','Heavy Duty Double Needle Sewing Machine, Industrial Garments Big Knitting Machine'),(12,'APPROVED',82,'2026-08-22 22:59:18.723346','USD',1,'asegadsvgvv',80,'2026-08-31','2026-08-23 00:29:32.102225','LOW','High Speed Garments Stitching System, Heavy Duty Double Needle Sewing Machine'),(13,'APPROVED',82,'2026-08-22 23:09:52.661412','USD',20,'adfsdgvdc asdfsdfd',80,'2026-08-31','2026-08-23 00:26:43.547140','LOW','Industrial Garments Big Knitting Machine, Heavy Duty Double Needle Sewing Machine'),(14,'APPROVED',82,'2026-08-22 23:14:54.093615','USD',50,'scbdf sdfgsd',80,'2026-09-02','2026-08-23 00:20:00.485790','LOW','Industrial Garments Big Knitting Machine, Heavy Duty Double Needle Sewing Machine'),(15,'APPROVED',82,'2026-08-22 23:54:14.819974','USD',50,'',80,'2026-08-27','2026-08-23 00:16:16.047116','LOW','High Speed Garments Stitching System, Heavy Duty Double Needle Sewing Machine');
/*!40000 ALTER TABLE `purchase_requisitions` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-08-31 23:43:09
