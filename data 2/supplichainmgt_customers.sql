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
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `address` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `gender` varchar(255) DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `nid_number` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `police_station_id` bigint DEFAULT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKeuat1oase6eqv195jvb71a93s` (`user_id`),
  KEY `FK2jlyb2c45nw0h6a2qdhf6ckep` (`police_station_id`),
  CONSTRAINT `FK2jlyb2c45nw0h6a2qdhf6ckep` FOREIGN KEY (`police_station_id`) REFERENCES `policestations` (`id`),
  CONSTRAINT `FKrh1g1a20omjmn6kurd35o3eit` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES (1,'মিরপুর ১২, ঢাকা, বাংলাদেশ','2026-06-28 17:48:46.995003','1998-06-15','srabonhasan66270@gmail.com','MALE','uploads/customer/Md._Tanvir_Hasan_26e0d855-31fa-4522-9095-40946b0666d9.JPG','Md. Tanvir Hasan','1998269123456','017123456788','2026-06-28 18:12:51.581602',12,7),(4,'মিরপুর ১২, ঢাকা, বাংলাদেশ','2026-06-28 18:37:41.309085','1998-06-15','srabonhasan662702@gmail.com','MALE','uploads/customer/Md.Hasan_187d7c75-a72a-4d73-a428-e5b97f47d1b2.JPG','Md.Hasan','1998269123456','0171234567828','2026-06-28 18:37:41.309085',22,11),(5,'মিরপুর ১২, ঢাকা, বাংলাদেশ','2026-06-28 18:42:43.834993','1998-06-15','srabonhasan66272@gmail.com','MALE','uploads/customer/Md.Hasan_ad0e5ae2-b3a2-4f1d-aa0b-b901017db42b.JPG','Md.Hasan','1998269123456','01712345628','2026-06-28 18:42:43.834993',2,12),(6,'মিরপুর ১২, ঢাকা, বাংলাদেশ','2026-06-28 18:54:17.340192','1998-06-15','srabonhasan6622@gmail.com','MALE','uploads/customer/Md.Hasan_62927dd9-bb91-4905-b96a-ad7c733875cc.JPG','Md.Hasan','1998269123456','017123456228','2026-06-28 19:02:06.931824',11,13),(8,'House 12, Road 4, Dhanmondi, Dhaka','2026-06-30 22:52:25.285410','1997-12-05','tanvirhan66270@gmail.com','MALE','Rashed_Khan_0f8f0a34-c3b7-40c0-96d5-70eb13779f1a.jpg','Rashed Khan','1997567890123','+8801711223344','2026-07-30 15:27:54.814767',2,37),(9,'House 14, Road 2, Sector 3, Uttara','2026-07-01 15:49:27.765973','1996-10-24','tanvirhasan6270@gmail.com','MALE','uploads/customer/Tanvir_Hasan_16d34125-b1f0-4fe0-be13-fc7da0f0ecf0.JPG','Tanvir Hasan','1996123456789','+8801712345678','2026-07-01 15:49:27.765973',4,38),(10,'মিরপুর ১২, Mirpur, Dhaka, Dhaka, Bangladesh','2026-07-04 18:14:42.527066','2026-06-29','85625@gmail.com','male','MD__TANVIRsaasfa_fe9c3bbc-00e3-42a3-8597-d1fb9c2ca4de.jpg','MD: TANVIRsaasfa','1998269123456','1156','2026-07-28 18:54:22.613560',1,43),(11,'মিরপুর ১২, Mirpur, Dhaka, Dhaka, Bangladesh','2026-07-04 18:19:29.441159','2026-07-02','8565@gmail.com','Male','MD__TANVIR_4c474829-8dd3-44f3-b5f6-2311e0383361.jpg','MD: TANVIR','199826912345','017123456828','2026-07-28 18:54:00.117116',1,45),(12,'মিরপুর ১২, Mirpur, Dhaka, Dhaka, Bangladesh','2026-07-04 18:21:34.090805','2026-07-16','65@gmail.com','Male','MD__TANVIR_6b931aec-03e8-4b30-917d-eba89a10d840.jpg','MD: TANVIR','5324545+6545','3324+6355+985','2026-07-28 18:47:40.406682',1,48),(15,'মিরপুর ১২, Mirpur, Dhaka, Dhaka, Bangladesh','2026-07-11 15:37:41.736782','2026-07-16','johan52@gmail.com','male','johan_7411dc55-3c47-4656-ac7b-5fa00a860f82.jpg','johan','19982623456','0171255252','2026-07-28 18:47:25.372831',1,84),(16,'bhkjl, Bangladesh','2026-07-11 16:07:46.616606','2026-06-28','dgdfdfg@gmail.com','male','dghfgf_b06751b9-e70e-40e8-a8c6-75f5f6adf087.jpg','dghfgf','4544','0171234567828454','2026-07-27 18:50:19.792422',19,85),(17,'fdsbfsd, Mirpur, Dhaka, Dhaka, Bangladesh','2026-08-30 06:25:03.146138','2026-08-02','admidaxvn@gmail.com','MALE','xsv_8947e53c-da1a-44b2-bcfd-83df8d70dd25.png','xsv','vdsasdfbdf','admin@gmail.com','2026-08-30 06:25:03.146138',1,96);
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
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
