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
-- Table structure for table `delivery_trips`
--

DROP TABLE IF EXISTS `delivery_trips`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delivery_trips` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `completed_at` datetime(6) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `customer_address` text NOT NULL,
  `delivery_photo_url` varchar(255) DEFAULT NULL,
  `dispatcher_id` bigint NOT NULL,
  `recipient_signature` varchar(255) DEFAULT NULL,
  `remarks` text,
  `started_at` datetime(6) DEFAULT NULL,
  `status` enum('CANCELLED','DELIVERED','IN_TRANSIT','PENDING') NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `customer_id` bigint NOT NULL,
  `driver_id` bigint NOT NULL,
  `vehicle_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK2o3mj1p41rujvmfdplp1mj0nx` (`customer_id`),
  KEY `FKr449c60k54t53nlem00r869t3` (`driver_id`),
  KEY `FKmjs8olu2fy49vw2m6vbfveoey` (`vehicle_id`),
  CONSTRAINT `FK2o3mj1p41rujvmfdplp1mj0nx` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `FKmjs8olu2fy49vw2m6vbfveoey` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`id`),
  CONSTRAINT `FKr449c60k54t53nlem00r869t3` FOREIGN KEY (`driver_id`) REFERENCES `drivers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delivery_trips`
--

LOCK TABLES `delivery_trips` WRITE;
/*!40000 ALTER TABLE `delivery_trips` DISABLE KEYS */;
INSERT INTO `delivery_trips` VALUES (1,'2026-07-28 16:36:57.318174','2026-07-09 19:06:12.627115','saDF;kerl jefkerwnojhor','deliveries/DELIVERIES_48de0bc4-2e61-4e03-8a61-c823e65c2f43_Screenshot_8.png',1,'signatures/SIGNATURES_32019516-7d26-4d51-b96d-c589b3799896_Screenshot_7.png','esrgmlkjhnoijfrgvt jhok','2026-07-28 16:36:57.318174','DELIVERED','2026-07-28 17:12:38.532663',1,1,1),(2,NULL,'2026-07-09 19:06:16.102922','saDF;kerl jefkerwnojhor',NULL,1,NULL,'esrgmlkjhnoijfrgvt jhok','2026-08-18 21:33:38.080025','IN_TRANSIT','2026-08-18 21:33:38.079030',1,1,1),(3,'2026-08-16 19:05:12.842314','2026-08-16 19:03:02.282035','qawrfasfd','deliveries/DELIVERIES_4bdb0e63-11e2-42b3-b159-dcd77895ce45_quatation.jpg',66,'signatures/SIGNATURES_b8c1d0f6-1468-4b6d-8e37-c8108e6aced6_quatation.jpg','afsef','2026-08-16 19:04:54.296260','DELIVERED','2026-08-16 19:05:12.842314',15,5,5),(4,NULL,'2026-08-23 02:03:40.021886','adsgfvasd',NULL,66,NULL,'sdbvdsbds',NULL,'PENDING','2026-08-23 02:03:40.021886',15,2,2);
/*!40000 ALTER TABLE `delivery_trips` ENABLE KEYS */;
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
