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
-- Table structure for table `goods_received_notes`
--

DROP TABLE IF EXISTS `goods_received_notes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `goods_received_notes` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `grn_number` varchar(255) NOT NULL,
  `inspection_date` date DEFAULT NULL,
  `quantity` int DEFAULT NULL,
  `received_at` date NOT NULL,
  `received_quantity` int NOT NULL,
  `remarks` text,
  `status` enum('APPROVED','INSPECTED','PARTIALLY_RECEIVED','PENDING','RECEIVED','REJECTED') DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `inspected_by` bigint DEFAULT NULL,
  `product_id` bigint DEFAULT NULL,
  `po_id` bigint NOT NULL,
  `received_by` bigint NOT NULL,
  `warehouse_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKi0rtwqa3l7l3wy0h07pbgaw6c` (`grn_number`),
  KEY `FK1gj1tw0j5s9q5kgit0hkgav37` (`inspected_by`),
  KEY `FKcxc99qktk1p0ixc7d3eqls40p` (`product_id`),
  KEY `FK53antf8c4mm88psu7fvmv52yb` (`po_id`),
  KEY `FKor7g7ihbvc9ewv4kxwk9w7ag6` (`received_by`),
  KEY `FKjtftlag5qb1ncrdqum2av3t6b` (`warehouse_id`),
  CONSTRAINT `FK1gj1tw0j5s9q5kgit0hkgav37` FOREIGN KEY (`inspected_by`) REFERENCES `users` (`id`),
  CONSTRAINT `FK53antf8c4mm88psu7fvmv52yb` FOREIGN KEY (`po_id`) REFERENCES `purchase_orders` (`id`),
  CONSTRAINT `FKcxc99qktk1p0ixc7d3eqls40p` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  CONSTRAINT `FKjtftlag5qb1ncrdqum2av3t6b` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`id`),
  CONSTRAINT `FKor7g7ihbvc9ewv4kxwk9w7ag6` FOREIGN KEY (`received_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `goods_received_notes`
--

LOCK TABLES `goods_received_notes` WRITE;
/*!40000 ALTER TABLE `goods_received_notes` DISABLE KEYS */;
INSERT INTO `goods_received_notes` VALUES (1,'2026-07-28 15:12:22.352913','GRN-D16D7310','2026-07-29',15,'2026-07-29',15,'asdcszd','RECEIVED','2026-07-28 15:27:52.138468',68,NULL,1,82,1),(2,'2026-08-16 22:35:46.738033','GRN-C739DBDC','2026-08-17',420,'2026-08-16',100,'szdgsdfgb','RECEIVED','2026-08-16 22:36:49.068136',68,NULL,15,66,1),(3,'2026-08-23 00:18:44.597150','GRN-CBF9BF72','2026-08-24',420,'2026-08-19',200,'zdga sadegsdgh','RECEIVED','2026-08-23 00:21:28.120081',26,NULL,24,66,1),(4,'2026-08-23 00:32:04.233220','GRN-195D8656','2026-08-24',420,'2026-08-19',200,'zdga sadegsdgh','RECEIVED','2026-08-23 00:41:13.531060',26,NULL,24,66,1),(5,'2026-08-23 02:03:03.181616','GRN-AEABB018','2026-08-24',420,'2026-08-22',420,'dasb SD','PENDING','2026-08-23 02:03:03.181101',26,NULL,25,66,1);
/*!40000 ALTER TABLE `goods_received_notes` ENABLE KEYS */;
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
