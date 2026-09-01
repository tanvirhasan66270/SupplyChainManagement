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
-- Table structure for table `po_line_items`
--

DROP TABLE IF EXISTS `po_line_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `po_line_items` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `delivery_date` date DEFAULT NULL,
  `line_total` double NOT NULL,
  `notes` text,
  `po_number` varchar(255) DEFAULT NULL,
  `quantity` int NOT NULL,
  `quotation_ref` varchar(255) DEFAULT NULL,
  `shipment_method` varchar(255) DEFAULT NULL,
  `status` enum('APPROVED','CANCELLED','DELIVERED','PENDING','SHIPPED') DEFAULT NULL,
  `tracking_number` varchar(255) DEFAULT NULL,
  `unit_price` double NOT NULL,
  `product_id` bigint NOT NULL,
  `po_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FKhmm1b027r53yyytpuovxigg31` (`product_id`),
  KEY `FK110v33g1nivy9s5rhuqj5bs5x` (`po_id`),
  CONSTRAINT `FK110v33g1nivy9s5rhuqj5bs5x` FOREIGN KEY (`po_id`) REFERENCES `purchase_orders` (`id`),
  CONSTRAINT `FKhmm1b027r53yyytpuovxigg31` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `po_line_items`
--

LOCK TABLES `po_line_items` WRITE;
/*!40000 ALTER TABLE `po_line_items` DISABLE KEYS */;
INSERT INTO `po_line_items` VALUES (1,'2026-08-16 16:54:30.966088','2026-08-31',10000000,'asdfadsf','PO-1786872119070',100,'sbdjvhcfbwshaidb','3','SHIPPED','TRN-1787421384131',100000,1,15),(2,'2026-08-16 17:02:48.756254','2026-08-19',1000000,'sddgfd','PO-1786872119070',100,'sdfgsd','sdgsdfg','SHIPPED','TRN-1787417001906',10000,1,15),(3,'2026-08-22 13:19:18.343340','2026-08-24',400000,'rsfRHJH','PO-1786872119070',200,'QTN-A6ACA465','254+61','PENDING',NULL,2000,1,15);
/*!40000 ALTER TABLE `po_line_items` ENABLE KEYS */;
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
