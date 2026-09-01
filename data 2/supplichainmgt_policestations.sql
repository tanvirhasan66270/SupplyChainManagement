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
-- Table structure for table `policestations`
--

DROP TABLE IF EXISTS `policestations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `policestations` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `active` bit(1) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `name_bn` varchar(255) DEFAULT NULL,
  `postal_code` varchar(255) DEFAULT NULL,
  `district_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKa8qg39gnjde9t8dc8m9a4qbsb` (`district_id`),
  CONSTRAINT `FKa8qg39gnjde9t8dc8m9a4qbsb` FOREIGN KEY (`district_id`) REFERENCES `districts` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=97 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `policestations`
--

LOCK TABLES `policestations` WRITE;
/*!40000 ALTER TABLE `policestations` DISABLE KEYS */;
INSERT INTO `policestations` VALUES (1,_binary '','Mirpur','মিরপুর','1216',1),(2,_binary '','Uttara','উত্তরা','1230',1),(3,_binary '','Gulshan','গুলশান','1212',1),(4,_binary '','Dhanmondi','ধানমন্ডি','1209',1),(5,_binary '','Mohammadpur','মোহাম্মদপুর','1207',1),(6,_binary '','Tejgaon','তেজগাঁও','1215',1),(7,_binary '','Paltan','পল্টন','1000',1),(8,_binary '','Shahbagh','শাহবাগ','1000',1),(9,_binary '','Ramna','রমনা','1217',1),(10,_binary '','Khilgaon','খিলগাঁও','1219',1),(11,_binary '','Badda','বাড্ডা','1212',1),(12,_binary '','Motijheel','মতিঝিল','1000',1),(13,_binary '','Savar','সাভার','1340',1),(14,_binary '','Dhamrai','ধামরাই','1350',1),(15,_binary '','Keraniganj','কেরানীগঞ্জ','1310',1),(16,_binary '','Gazipur Sadar','গাজীপুর সদর','1700',2),(17,_binary '','Kaliakair','কালিয়াকৈর','1750',2),(18,_binary '','Sreepur','শ্রীপুর','1740',2),(19,_binary '','Tongi','টঙ্গী','1710',2),(20,_binary '','Kapasia','কপাসিয়া','1730',2),(21,_binary '','Kaliganj','কালীগঞ্জ','1720',2),(22,_binary '','Narayanganj Sadar','নারায়ণগঞ্জ সদর','1400',3),(23,_binary '','Siddhirganj','সিদ্ধিরগঞ্জ','1430',3),(24,_binary '','Rupganj','রূপগঞ্জ','1460',3),(25,_binary '','Araihazar','আড়াইহাজার','1450',3),(26,_binary '','Sonargaon','সোনারগাঁও','1440',3),(27,_binary '','Bandar','বন্দর','1410',3),(28,_binary '','Narsingdi Sadar','নরসিংদী সদর','1600',4),(29,_binary '','Madhabdi','মাধবদী','1604',4),(30,_binary '','Raipura','রায়পুরা','1630',4),(31,_binary '','Belabo','বেলাবো','1640',4),(32,_binary '','Tangail Sadar','টাঙ্গাইল সদর','1900',5),(33,_binary '','Mirzapur','মির্জাপুর','1940',5),(34,_binary '','Kalihati','কালীহাতী','1970',5),(35,_binary '','Gopalpur','গোপালপুর','1990',5),(36,_binary '','Madhupur','মধুপুর','1996',5),(37,_binary '','Manikganj Sadar','মানিকগঞ্জ সদর','1800',6),(38,_binary '','Singair','সিংগাইর','1820',6),(39,_binary '','Saturia','সাটুরিয়া','1810',6),(40,_binary '','Faridpur Sadar','ফরিদপুর সদর','7800',7),(41,_binary '','Bhanga','ভাঙ্গা','7830',7),(42,_binary '','Madhukhali','মধুখালী','7850',7),(43,_binary '','Kotwali','কোতোয়ালী','4000',8),(44,_binary '','Double Mooring','ডবলমুরিং','4100',8),(45,_binary '','Halishahar','হালিশহর','4216',8),(46,_binary '','Panchlaish','পাচলাইশ','4203',8),(47,_binary '','Hathazari','হাটহাজারী','4330',8),(48,_binary '','Sitakunda','সীতাকুণ্ড','4310',8),(49,_binary '','Mirsarai','মীরসরাই','4320',8),(50,_binary '','Patiya','পটিয়া','4370',8),(51,_binary '','Anwara','আনোয়ারা','4376',8),(52,_binary '','Raozan','রাউজান','4340',8),(53,_binary '','Coxs Bazar Sadar','কক্সবাজার সদর','4700',9),(54,_binary '','Ukhiya','উখিয়া','4750',9),(55,_binary '','Teknaf','টেকনাফ','4760',9),(56,_binary '','Ramu','রামু','4730',9),(57,_binary '','Chakaria','চকোরিয়া','4740',9),(58,_binary '','Cumilla Sadar','কুমিল্লা সদর','3500',10),(59,_binary '','Chaddagram','চৌদ্দগ্রাম','3550',10),(60,_binary '','Laksam','লাকসাম','3570',10),(61,_binary '','Daudkandi','দাউদকান্দি','3516',10),(62,_binary '','Feni Sadar','ফেনী সদর','3900',11),(63,_binary '','Chhagalnaiya','ছাগলনাইয়া','3910',11),(64,_binary '','Brahmanbaria Sadar','ব্রাহ্মণবাড়িয়া সদর','3400',12),(65,_binary '','Ashuganj','আশুগঞ্জ','3402',12),(66,_binary '','Kasba','কসবা','3460',12),(67,_binary '','Noakhali Sadar','নোয়াখালী সদর','3800',13),(68,_binary '','Begumganj','বেগমগঞ্জ','3820',13),(69,_binary '','Hatiya','হাতিয়া','3890',13),(70,_binary '','Chandpur Sadar','চাঁদপুর সদর','3600',14),(71,_binary '','Hajiganj','হাজীগঞ্জ','3610',14),(72,_binary '','Boalia','বোয়ালিয়া','6000',15),(73,_binary '','Rajshahi Sadar','রাজশাহী সদর','6100',15),(74,_binary '','Puthia','পুঠিয়া','6240',15),(75,_binary '','Godagari','গোদাগাড়ী','6280',15),(76,_binary '','Bogra Sadar','বগুড়া সদর','5800',16),(77,_binary '','Sherpur','শেরপুর','5840',16),(78,_binary '','Shajahanpur','শাজাহানপুর','5801',16),(79,_binary '','Pabna Sadar','পাবনা সদর','6600',17),(80,_binary '','Ishwardi','ঈশ্বরদী','6620',17),(81,_binary '','Khulna Sadar','খুলনা সদর','9100',21),(82,_binary '','Daulatpur','দৌলতপুর','9202',21),(83,_binary '','Khalishpur','খালিশপুর','9201',21),(84,_binary '','Rupsha','রূপসা','9240',21),(85,_binary '','Jashore Sadar','যশোর সদর','7400',22),(86,_binary '','Benapole','বেনাপোল','7432',22),(87,_binary '','Barishal Sadar','বরিশাল সদর','8200',26),(88,_binary '','Bakerganj','বাকেরগঞ্জ','8280',26),(89,_binary '','Kotwali Sylhet','কোতোয়ালী সিলেট','3100',30),(90,_binary '','Shahparan','শাহপরান','3104',30),(91,_binary '','Beanibazar','বিয়ানিবাজার','3170',30),(92,_binary '','Rangpur Sadar','রংপুর সদর','5400',34),(93,_binary '','Mithapukur','মিঠাপুকুর','5460',34),(94,_binary '','Mymensingh Sadar','ময়মনসিংহ সদর','2200',38),(95,_binary '','Trishal','ত্রিশাল','2220',38),(96,_binary '','Bhaluka','ভালুকা','2240',38);
/*!40000 ALTER TABLE `policestations` ENABLE KEYS */;
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
