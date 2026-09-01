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
-- Table structure for table `product_requirements`
--

DROP TABLE IF EXISTS `product_requirements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_requirements` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `customer_order_number` varchar(255) DEFAULT NULL,
  `description` text,
  `procurement_remarks` text,
  `product_name` varchar(255) NOT NULL,
  `request_reference_no` varchar(255) NOT NULL,
  `requested_by_officer_id` bigint DEFAULT NULL,
  `requested_by_officer_name` varchar(255) DEFAULT NULL,
  `requested_quantity` int NOT NULL,
  `status` enum('APPROVED','PENDING','PROCESSING','REJECTED') NOT NULL,
  `target_price_range` varchar(255) DEFAULT NULL,
  `unit` varchar(255) NOT NULL,
  `urgency_level` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK5fwjr6191airjq8i5ogqynr60` (`request_reference_no`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_requirements`
--

LOCK TABLES `product_requirements` WRITE;
/*!40000 ALTER TABLE `product_requirements` DISABLE KEYS */;
INSERT INTO `product_requirements` VALUES (1,'2026-08-18 14:39:20.936762','ORD-1782838721455','Good Productivity , Genarel color,A gread Product','for havey working duty\n','Havey Duty Machin','PRQ-11CD59F0',66,'Mst Rehana',50,'APPROVED','101000','Kg','MEDIUM'),(2,'2026-08-18 16:54:00.866583','ssssss','sdgsfd','shs','sgfsfdh','PRQ-0345D226',66,'Mst Rehana',15,'PROCESSING','5876','Box','LOW'),(3,'2026-08-18 16:54:00.866583','ssssss','sdgsfd','shs','sgfsfdh','PRQ-E2675BA0',66,'Mst Rehana',15,'PENDING','5876','Box','LOW');
/*!40000 ALTER TABLE `product_requirements` ENABLE KEYS */;
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
