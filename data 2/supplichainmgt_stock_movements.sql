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
-- Table structure for table `stock_movements`
--

DROP TABLE IF EXISTS `stock_movements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stock_movements` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `moved_at` datetime(6) NOT NULL,
  `movement_type` enum('ADJUSTMENT','INWARD','OUTWARD','TRANSFER') DEFAULT NULL,
  `performed_by` bigint NOT NULL,
  `product_id` bigint NOT NULL,
  `quantity` int NOT NULL,
  `reference_id` varchar(255) NOT NULL,
  `remarks` text,
  `send_warehouse` varchar(255) DEFAULT NULL,
  `warehouse_id` bigint NOT NULL,
  `source_warehouse_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKlaob67k5ekyx7qnir6ekb99jy` (`performed_by`),
  KEY `FKjcaag8ogfjxpwmqypi1wfdaog` (`product_id`),
  KEY `FK2qkwlt85m1lck03wx1uv8v5y7` (`source_warehouse_id`),
  KEY `FKiparp4rp4rsfsxb9y02oyxauh` (`warehouse_id`),
  CONSTRAINT `FK2qkwlt85m1lck03wx1uv8v5y7` FOREIGN KEY (`source_warehouse_id`) REFERENCES `warehouses` (`id`),
  CONSTRAINT `FKiparp4rp4rsfsxb9y02oyxauh` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`id`),
  CONSTRAINT `FKjcaag8ogfjxpwmqypi1wfdaog` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  CONSTRAINT `FKlaob67k5ekyx7qnir6ekb99jy` FOREIGN KEY (`performed_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_movements`
--

LOCK TABLES `stock_movements` WRITE;
/*!40000 ALTER TABLE `stock_movements` DISABLE KEYS */;
INSERT INTO `stock_movements` VALUES (2,'2026-07-28 16:06:44.681040','INWARD',82,1,200,'bnv  fvghvbjh','xdfgdsfgf',NULL,1,NULL),(3,'2026-08-17 02:38:32.729430','OUTWARD',66,1,20,'dfggfd','dfghh',NULL,1,NULL),(6,'2026-08-22 00:36:04.721440','OUTWARD',66,1,5,'zxcvz','zxv zxv',NULL,1,NULL),(7,'2026-08-23 01:49:09.082895','OUTWARD',66,1,200,'sdgsd','sadbsdvv',NULL,1,NULL),(8,'2026-08-23 02:01:13.367782','OUTWARD',66,1,35,'czcdvzdxv','sdgdsvb',NULL,1,NULL),(9,'2026-08-23 03:02:00.730882','OUTWARD',66,1,20,'sdvsdd','xcvvffvvf',NULL,1,NULL);
/*!40000 ALTER TABLE `stock_movements` ENABLE KEYS */;
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
