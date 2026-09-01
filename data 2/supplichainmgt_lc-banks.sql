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
-- Table structure for table `lc-banks`
--

DROP TABLE IF EXISTS `lc-banks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lc-banks` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `address` varchar(255) DEFAULT NULL,
  `branch_name` varchar(255) DEFAULT NULL,
  `contact_email` varchar(255) DEFAULT NULL,
  `contact_phone` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `swift_code` varchar(255) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKlwkwcei6fg7n8ym6chf90al5` (`swift_code`)
) ENGINE=InnoDB AUTO_INCREMENT=62 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lc-banks`
--

LOCK TABLES `lc-banks` WRITE;
/*!40000 ALTER TABLE `lc-banks` DISABLE KEYS */;
INSERT INTO `lc-banks` VALUES (1,'35-42, Motijheel Commercial Area, Dhaka-1000','Motijheel Corporate Branch','motijheel.corp@sonalibank.com.bd','+8802223381421','2026-07-01 18:21:54.000000','Sonali Bank PLC','SBLDBDHA022','2026-07-01 18:21:54.000000'),(2,'Agrabad Commercial Area, Chittagong-4100','Agrabad Corporate Branch','agrabad.corp@sonalibank.com.bd','+88031716321','2026-07-01 18:21:54.000000','Sonali Bank PLC','SBLDBDHA023','2026-07-01 18:21:54.000000'),(3,'24, Dilkusha Commercial Area, Dhaka-1000','Local Office Branch','localoffice@sonalibank.com.bd','+8802223354621','2026-07-01 18:21:54.000000','Sonali Bank PLC','SBLDBDHA106','2026-07-01 18:21:54.000000'),(4,'1, Dilkusha Commercial Area, Dhaka-1000','Local Office Foreign Exchange','localoffice.fox@janatabank-bd.com','+8802223386121','2026-07-01 18:21:54.000000','Janata Bank PLC','JABALDHA011','2026-07-01 18:21:54.000000'),(5,'Janata Bank Bhaban, Agrabad C/A, Chittagong','Agrabad Corporate Branch','agrabad.ctg@janatabank-bd.com','+880312518101','2026-07-01 18:21:54.000000','Janata Bank PLC','JABALDHACTG','2026-07-01 18:21:54.000000'),(6,'9D, Dilkusha Commercial Area, Dhaka-1000','Principal Branch','principal.br@agranibank.org','+8802223383025','2026-07-01 18:21:54.000000','Agrani Bank PLC','AGRBDHA002','2026-07-01 18:21:54.000000'),(7,'71, Dilkusha Commercial Area, Dhaka-1000','Foreign Exchange Branch','fox.motijheel@islamibankbd.com','+8802223382101','2026-07-01 18:21:54.000000','Islami Bank Bangladesh PLC','IBBLBDHA011','2026-07-01 18:21:54.000000'),(8,'3, Agrabad Commercial Area, Chittagong','Agrabad Corporate Branch','agrabad.br@islamibankbd.com','+88031724561','2026-07-01 18:21:54.000000','Islami Bank Bangladesh PLC','IBBLBDHACTG','2026-07-01 18:21:54.000000'),(9,'Anik Tower, 220/B, Tejgaon Industrial Area, Dhaka-1208','Gulshan Corporate Branch','trade.operations@bracbank.com','+88028801201','2026-07-01 18:21:54.000000','BRAC Bank PLC','BKBKBDHA002','2026-07-01 18:21:54.000000'),(10,'S.S. Tower, 69 Agrabad C/A, Chittagong','Agrabad Branch','trade.ctg@bracbank.com','+880312513951','2026-07-01 18:21:54.000000','BRAC Bank PLC','BKBKBDHA024','2026-07-01 18:21:54.000000'),(11,'City Bank Center, 136, Gulshan Avenue, Dhaka-1212','Principal Branch','trade.services@thecitybank.com','+880258813485','2026-07-01 18:21:54.000000','The City Bank PLC','CIYBDHA001','2026-07-01 18:21:54.000000'),(12,'Khatungonj Commercial Area, Chittagong','Khatungonj Trade Branch','khatungonj.trade@thecitybank.com','+88031614521','2026-07-01 18:21:54.000000','The City Bank PLC','CIYBDHA002','2026-07-01 18:21:54.000000'),(13,'100, Gulshan Avenue, Dhaka-1212','Corporate Banking Branch','trade.support@ebl.com.bd','+88029556360','2026-07-01 18:21:54.000000','Eastern Bank PLC','EBLBDHA004','2026-07-01 18:21:54.000000'),(14,'33, Agrabad Commercial Area, Chittagong','Agrabad Trade Branch','trade.ctg@ebl.com.bd','+88031711291','2026-07-01 18:21:54.000000','Eastern Bank PLC','EBLBDHA032','2026-07-01 18:21:54.000000'),(15,'68, Gulshan Avenue, Gulshan-1, Dhaka-1212','Gulshan Trade Service Center','gulshan.lc@mtb.com.bd','+88029842451','2026-07-01 18:21:54.000000','Mutual Trust Bank PLC','MTBLBDHA007','2026-07-01 18:21:54.000000'),(16,'MTB Square, 21 Dilkusha C/A, Dhaka-1000','Dilkusha Commercial Branch','dilkusha.lc@mtb.com.bd','+8802223385214','2026-07-01 18:21:54.000000','Mutual Trust Bank PLC','MTBLBDHA015','2026-07-01 18:21:54.000000'),(17,'119-120, Motijheel C/A, Dhaka-1000','Motijheel Foreign Exchange Branch','motijheel.trade@primebank.com.bd','+8802223385621','2026-07-01 18:21:54.000000','Prime Bank PLC','PRMBDHA002','2026-07-01 18:21:54.000000'),(18,'47, Motijheel Commercial Area, Dhaka-1000','Local Office (Motijheel)','local.motijheel@dbbl.com.bd','+8802223384214','2026-07-01 18:21:54.000000','Dutch-Bangla Bank PLC','DBBLBDHA015','2026-07-01 18:21:54.000000'),(19,'67, Gulshan Avenue, Gulshan-1, Dhaka-1212','Gulshan Trade Service Center','bangladesh.trade@sc.com','+88028833003','2026-07-01 18:21:54.000000','Standard Chartered Bank','SCBLBDHAXXX','2026-07-01 18:21:54.000000'),(20,'Level 4, Shanta Western Tower, Tejgaon, Dhaka','Corporate Head Office Trade Dept','corporate.trade@hsbc.com.bd','+88028878831','2026-07-01 18:21:54.000000','HSBC Bangladesh','HSBCBDHAXXX','2026-07-01 18:21:54.000000');
/*!40000 ALTER TABLE `lc-banks` ENABLE KEYS */;
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
