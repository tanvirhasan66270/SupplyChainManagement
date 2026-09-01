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
-- Table structure for table `qc_inspections`
--

DROP TABLE IF EXISTS `qc_inspections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `qc_inspections` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `certificate_ref` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `defect_description` text,
  `defects_found` int NOT NULL,
  `inspected_at` date NOT NULL,
  `inspection_type` varchar(255) NOT NULL,
  `lab_test_report` varchar(255) DEFAULT NULL,
  `result` enum('AVERAGE','BAD','GOOD','VERY_GOOD') DEFAULT NULL,
  `sample_size` int NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `grn_id` bigint NOT NULL,
  `inspected_by` bigint NOT NULL,
  `product_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FKafi89xlyrdm5pg6osalqtqxgp` (`grn_id`),
  KEY `FKqlcsx9i5pyvfu3c6bcculr9bx` (`inspected_by`),
  KEY `FK3bi2ccsw4pidh4f89qye72uig` (`product_id`),
  CONSTRAINT `FK3bi2ccsw4pidh4f89qye72uig` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  CONSTRAINT `FKafi89xlyrdm5pg6osalqtqxgp` FOREIGN KEY (`grn_id`) REFERENCES `goods_received_notes` (`id`),
  CONSTRAINT `FKqlcsx9i5pyvfu3c6bcculr9bx` FOREIGN KEY (`inspected_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `qc_inspections`
--

LOCK TABLES `qc_inspections` WRITE;
/*!40000 ALTER TABLE `qc_inspections` DISABLE KEYS */;
INSERT INTO `qc_inspections` VALUES (1,'215341654','2026-08-17 00:48:40.676143','fghnfn',2,'2026-08-17','FUNCTIONAL','QC_FUNCTIONAL_4b6fc452-8c52-400f-bb08-eb7a50dc64e3.png','VERY_GOOD',10,'2026-08-17 00:48:40.676143',2,68,1);
/*!40000 ALTER TABLE `qc_inspections` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-08-31 23:43:13
