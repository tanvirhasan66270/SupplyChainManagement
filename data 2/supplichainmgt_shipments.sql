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
-- Table structure for table `shipments`
--

DROP TABLE IF EXISTS `shipments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shipments` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `assigned_by_email` varchar(255) NOT NULL,
  `captain_registration_number` varchar(255) NOT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `estimated_delivery` date NOT NULL,
  `origin` varchar(255) NOT NULL,
  `pod_file_url` varchar(255) DEFAULT NULL,
  `send_by_address` varchar(255) NOT NULL,
  `shipment_number` varchar(50) NOT NULL,
  `transport_cost` double NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `vehicle_number` varchar(255) NOT NULL,
  `po_id` bigint NOT NULL,
  `supplier_id` bigint NOT NULL,
  `shipment_quantity` double NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKil6gfafk66ly6rpmjugdmd1ne` (`shipment_number`),
  KEY `FKa4f6mkumdlqftqtlcr3e8p8jw` (`po_id`),
  KEY `FKtgwmjvgiiiws922molg0jnn8o` (`supplier_id`),
  CONSTRAINT `FKa4f6mkumdlqftqtlcr3e8p8jw` FOREIGN KEY (`po_id`) REFERENCES `purchase_orders` (`id`),
  CONSTRAINT `FKtgwmjvgiiiws922molg0jnn8o` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shipments`
--

LOCK TABLES `shipments` WRITE;
/*!40000 ALTER TABLE `shipments` DISABLE KEYS */;
INSERT INTO `shipments` VALUES (1,'logistics@enterprise.com','1541451','2026-07-08 18:19:13.642062','2026-07-14','US port','POD_57114ae2-6c77-47cb-8361-da10c6405d13.jpg','nsbd  jsgv kwsvdjh','SH-92D06FDC',1000,'2026-07-08 18:19:13.642062','ch-f-645-25',2,2,0),(2,'srabonhasn66270@gmail.com','1541451','2026-07-29 15:18:25.663171','2026-07-30','dfgdfgdf','POD_1e4d5275-2390-4b34-ab62-aaf957062b4c.jpg','xfgvf','SH-766075FA',0,'2026-07-29 15:18:25.663171','DHAKA-METRO-TA-11-2233',2,1,0),(3,'srabonhasn66270@gmail.com','1541451','2026-07-29 15:21:54.433832','2026-08-05','US port','POD_9b72a084-95df-40e8-803c-4b6163c6878b.jpg','sdfsf','SH-2092C35C',50000,'2026-07-29 15:21:54.433832','DHAKA-METRO-TA-11-2233',4,1,0),(4,'srabonhasn66270@gmail.com','1541452','2026-08-16 17:10:55.657597','2026-08-19','US port','POD_3b1b61f6-993e-414e-b2b5-447c9da3da12.jpg','bjvjnb bvjhbv jnv','SH-7E8BA7EF',1000,'2026-08-16 17:10:55.657597','DHAKA-METRO-TA-11-2233',15,1,0),(5,'srabonhasn66270@gmail.com','1541451','2026-08-16 17:23:42.919452','2026-09-03','US port','POD_1bf4e34f-3440-4e7d-b31c-e0d24155da82.jpg','szdfvdsafd','SH-44DEEBE9',2000,'2026-08-16 17:23:42.919452','DHAKA-METRO-TA-11-2233',15,1,0),(6,'srabonhasn66270@gmail.com','1541451','2026-08-16 17:30:00.186660','2026-08-28','US port','POD_96a7edd1-6ab5-4cb2-8013-bf7b27acbcbf.jpg','asdfdafa','SH-302BEAF2',15000,'2026-08-16 17:30:00.186660','DHAKA-METRO-TA-11-2233',15,1,200);
/*!40000 ALTER TABLE `shipments` ENABLE KEYS */;
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
