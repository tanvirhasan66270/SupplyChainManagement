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
-- Table structure for table `commercial_officers`
--

DROP TABLE IF EXISTS `commercial_officers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `commercial_officers` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `address` text,
  `created_at` datetime(6) DEFAULT NULL,
  `designation` varchar(255) DEFAULT NULL,
  `dob` date NOT NULL,
  `gender` enum('FEMALE','MALE','OTHERS') DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `is_active` bit(1) NOT NULL,
  `joining_date` date DEFAULT NULL,
  `language` enum('BANGLA','ENGLISH','OTHERS') DEFAULT NULL,
  `nid_number` varchar(255) NOT NULL,
  `passport_number` varchar(255) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `police_station_id` bigint DEFAULT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKn77kqifc8exw470e788b5b7hx` (`nid_number`),
  UNIQUE KEY `UK2ikjbv2vvushwb84ensg4tjct` (`user_id`),
  UNIQUE KEY `UKhk13ybbhpgene2w5qhu89mxu9` (`passport_number`),
  KEY `FKnqdyr0o4yfy6rg9gcy3scvtti` (`police_station_id`),
  CONSTRAINT `FK4davvtn2jxnbicn37xbkvw5hm` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `FKnqdyr0o4yfy6rg9gcy3scvtti` FOREIGN KEY (`police_station_id`) REFERENCES `policestations` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `commercial_officers`
--

LOCK TABLES `commercial_officers` WRITE;
/*!40000 ALTER TABLE `commercial_officers` DISABLE KEYS */;
INSERT INTO `commercial_officers` VALUES (1,'House 88, Mirpur, Dhaka, Dhaka, Bangladesh','2026-06-30 16:19:26.306162','Commercial Officer','1999-10-10','MALE','Tanvir_Rahman_bca6b793-752e-4004-80f7-b18683c784ce.jpg',_binary '','2026-07-01','BANGLA','1999261025111','C01112223','2026-07-28 18:51:55.360637',1,16),(2,'10, Mirpur, Dhaka, Dhaka, Bangladesh','2026-07-05 15:22:17.431013','Commercial Officer','2026-06-29','MALE','MD_TANVIR_d8138af1-e932-45e6-b6d7-f9ad02f481ed.jpg',_binary '\0','2026-07-14','BANGLA','199826912456','324321567451','2026-07-28 18:52:06.285039',1,59),(3,'মিরপুর ১২, Mirpur, Dhaka, Dhaka, Bangladesh','2026-07-05 15:25:35.225171','Commercial Officer','2026-07-08','MALE','hasan_b2b41a23-e96f-43e0-bb85-e6a336be0a87.jpg',_binary '\0','2026-07-22','BANGLA','1998269456','45157852415678','2026-07-28 18:52:19.570413',1,62),(4,'Hasan_ec604525-e9dc-423d-adb8-cb50c7c5dacd.jpg, Mirpur, Dhaka, Dhaka, Bangladesh','2026-07-12 16:23:50.141382','Commercial Officer','2026-06-28','MALE','Hasan_ced546d7-0603-4601-b3c3-7409ae598854.jpg',_binary '\0','2026-07-15','BANGLA','635453213546','324210353','2026-07-28 18:52:38.926101',1,88);
/*!40000 ALTER TABLE `commercial_officers` ENABLE KEYS */;
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
