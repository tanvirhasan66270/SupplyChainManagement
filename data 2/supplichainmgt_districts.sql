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
-- Table structure for table `districts`
--

DROP TABLE IF EXISTS `districts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `districts` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `active` bit(1) DEFAULT NULL,
  `district_code` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `name_bn` varchar(255) DEFAULT NULL,
  `division_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKl374uao5cplc8w347pn93svoc` (`division_id`),
  CONSTRAINT `FKl374uao5cplc8w347pn93svoc` FOREIGN KEY (`division_id`) REFERENCES `divisions` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `districts`
--

LOCK TABLES `districts` WRITE;
/*!40000 ALTER TABLE `districts` DISABLE KEYS */;
INSERT INTO `districts` VALUES (1,_binary '','DHA','Dhaka','ঢাকা',1),(2,_binary '','GAZ','Gazipur','গাজীপুর',1),(3,_binary '','NAR','Narayanganj','নারায়ণগঞ্জ',1),(4,_binary '','NSI','Narsingdi','নরসিংদী',1),(5,_binary '','TAN','Tangail','টাঙ্গাইল',1),(6,_binary '','MAN','Manikganj','মানিকগঞ্জ',1),(7,_binary '','FAR','Faridpur','ফরিদপুর',1),(8,_binary '','CTG','Chattogram','চট্টগ্রাম',2),(9,_binary '','COX','Coxs Bazar','কক্সবাজার',2),(10,_binary '','CUM','Cumilla','কুমিল্লা',2),(11,_binary '','FEN','Feni','ফেনী',2),(12,_binary '','BRA','Brahmanbaria','ব্রাহ্মণবাড়িয়া',2),(13,_binary '','NOA','Noakhali','নোয়াখালী',2),(14,_binary '','CHA','Chandpur','চাঁদপুর',2),(15,_binary '','RAJ','Rajshahi','রাজশাহী',3),(16,_binary '','BOG','Bogra','বগুড়া',3),(17,_binary '','PAB','Pabna','পাবনা',3),(18,_binary '','NAO','Naogaon','নওগাঁ',3),(19,_binary '','NAT','Natore','নাটোর',3),(20,_binary '','SIR','Sirajganj','সিরাজগঞ্জ',3),(21,_binary '','KHU','Khulna','খুলনা',4),(22,_binary '','JAS','Jashore','যশোর',4),(23,_binary '','KUS','Kushtia','কুষ্টিয়া',4),(24,_binary '','SAT','Satkhira','সাতক্ষীরা',4),(25,_binary '','BAG','Bagerhat','বাগেরহাট',4),(26,_binary '','BAR','Barishal','বরিশাল',5),(27,_binary '','BHO','Bhola','ভোলা',5),(28,_binary '','PAT','Patuakhali','পটুয়াখালী',5),(29,_binary '','PIR','Pirojpur','পিরোজপুর',5),(30,_binary '','SYL','Sylhet','সিলেট',6),(31,_binary '','MOU','Moulvibazar','মৌলভীবাজার',6),(32,_binary '','HAB','Habiganj','হবিগঞ্জ',6),(33,_binary '','SUN','Sunamganj','সুনামগঞ্জ',6),(34,_binary '','RAN','Rangpur','রংপুর',7),(35,_binary '','DIN','Dinajpur','দিনাজপুর',7),(36,_binary '','GAI','Gaibandha','গাইবান্ধা',7),(37,_binary '','KUR','Kurigram','কুড়িগ্রাম',7),(38,_binary '','MYM','Mymensingh','ময়মনসিংহ',8),(39,_binary '','JAM','Jamalpur','জামালপুর',8),(40,_binary '','NET','Netrokona','নেত্রকোণা',8);
/*!40000 ALTER TABLE `districts` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-08-31 23:43:10
