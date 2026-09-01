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
-- Table structure for table `qc_inspectors`
--

DROP TABLE IF EXISTS `qc_inspectors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `qc_inspectors` (
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
  `nid_number` varchar(50) NOT NULL,
  `passport_number` varchar(50) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `police_station_id` bigint DEFAULT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKh8xco197fsa5d1re74tie23de` (`nid_number`),
  UNIQUE KEY `UK51hgx2pfkrn715f2816ed61cu` (`user_id`),
  UNIQUE KEY `UKaa0qgby06fe3v5mi2ipje4m2f` (`passport_number`),
  KEY `FKirh38dvp71qcrfvbc643whlht` (`police_station_id`),
  CONSTRAINT `FKirh38dvp71qcrfvbc643whlht` FOREIGN KEY (`police_station_id`) REFERENCES `policestations` (`id`),
  CONSTRAINT `FKn2c84886a4hpo67hoo2a46382` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `qc_inspectors`
--

LOCK TABLES `qc_inspectors` WRITE;
/*!40000 ALTER TABLE `qc_inspectors` DISABLE KEYS */;
INSERT INTO `qc_inspectors` VALUES (3,'House 56, Uttara, Dhaka, Dhaka, Bangladesh','MD. Tanvir','2026-06-30 18:06:42.210591','Senior QC Auditor','1999-10-10','MALE','Robin_fff91530-dba4-4d7b-b84c-46b67bbe8529.jpg',_binary '','2026-07-01','BANGLA','1999261025777','Q07778889','2026-07-28 18:50:19.718300',2,26),(4,'মিরপুর ১২, Mirpur, Dhaka, Dhaka, Bangladesh','mitu','2026-07-05 17:14:00.361313','Senior QC IUnspactor','2026-06-28','MALE','Miskat_89d23106-a7c9-478a-bb45-7b5d4bf1af57.jpg',_binary '\0','2026-07-21','BANGLA','65432154115','2332352325','2026-07-28 18:50:34.021187',1,68);
/*!40000 ALTER TABLE `qc_inspectors` ENABLE KEYS */;
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
