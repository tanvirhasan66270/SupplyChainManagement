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
-- Table structure for table `purchase_requisition_tokens`
--

DROP TABLE IF EXISTS `purchase_requisition_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `purchase_requisition_tokens` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `active` bit(1) NOT NULL,
  `approval_status` enum('APPROVED','CANCELLED','PENDING','REJECTED') DEFAULT NULL,
  `approved_by` bigint DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `currency` varchar(255) DEFAULT NULL,
  `deleted_at` datetime(6) DEFAULT NULL,
  `product_names` text,
  `purchase_created_at` datetime(6) DEFAULT NULL,
  `purchase_requisition_id` bigint DEFAULT NULL,
  `purchase_updated_at` datetime(6) DEFAULT NULL,
  `quantity_required` int DEFAULT NULL,
  `remarks` text,
  `requested_by` bigint DEFAULT NULL,
  `required_by_date` date DEFAULT NULL,
  `supplier_names` text,
  `token` varchar(200) NOT NULL,
  `total_products` int DEFAULT NULL,
  `urgency_level` enum('CRITICAL','HIGH','LOW','MEDIUM') DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK45befj545kup7rqov1gwrgnli` (`token`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `purchase_requisition_tokens`
--

LOCK TABLES `purchase_requisition_tokens` WRITE;
/*!40000 ALTER TABLE `purchase_requisition_tokens` DISABLE KEYS */;
INSERT INTO `purchase_requisition_tokens` VALUES (1,_binary '','PENDING',NULL,'2026-07-19 14:47:23.824720','USD',NULL,'Heavy Duty Double Needle Sewing Machine, Industrial Garments Big Knitting Machine','2026-07-19 14:47:23.785823',4,'2026-07-19 14:47:23.785823',210,'ssssssssssssssss sesesesesesesesesesesesesese',80,'2026-07-20','Apex Logistics Group, Badrul','9dd63720-3ae5-4d34-b4b1-e4f51f028374',2,'LOW'),(2,_binary '','PENDING',NULL,'2026-08-16 00:43:14.376217','USD',NULL,'Ergonomic Desktop Mobile Handle Stand, Premium Heavy Duty Silicone Protection Cover, Super Fast Dual Port Charger 2.0','2026-08-16 00:43:14.287766',5,'2026-08-16 00:43:14.287766',200,'mdsfnvfdevg askefgr dfgjnfsdo',80,'2026-09-30','Apex Logistics Group, Badrul','f5ea6d27-7ec4-4105-916e-d2368d933f7f',3,'MEDIUM'),(3,_binary '','PENDING',NULL,'2026-08-16 00:43:46.514238','USD',NULL,'High Speed Garments Stitching System','2026-08-16 00:43:46.507634',6,'2026-08-21 23:19:52.179653',10,'sxfdvgsdfrgvsdf\n[Fulfilling Requirements: sgfsfdh]\n[Fulfilling Requirements: sgfsfdh, Havey Duty Machin]\n[Fulfilling Requirements: sgfsfdh]\n[Fulfilling Requirements: sgfsfdh]',80,'2026-09-03','Apex Logistics Group, Badrul','ffbf5d97-2a18-4fd2-89c2-ac842d2b5f29',1,'LOW'),(4,_binary '','PENDING',NULL,'2026-08-21 23:28:59.813453','USD',NULL,'Heavy Duty Double Needle Sewing Machine','2026-08-21 23:28:59.796510',7,'2026-08-21 23:28:59.796510',20,'advsdab\n[Fulfilling Requirements: sgfsfdh]',80,'2026-08-25','Apex Logistics Group, Badrul','5878c788-2297-4aac-ae98-ed1fd8ee185c',1,'MEDIUM'),(5,_binary '','PENDING',NULL,'2026-08-22 22:41:16.427546','USD',NULL,'Heavy Duty Double Needle Sewing Machine, High Speed Garments Stitching System','2026-08-22 22:41:16.363511',8,'2026-08-22 22:41:16.363511',1,'',80,'2026-09-01','Apex Logistics Group, Badrul','05f807b6-b566-475c-902a-73277d292a49',2,'LOW'),(6,_binary '','PENDING',NULL,'2026-08-22 22:45:07.060789','USD',NULL,'Industrial Garments Big Knitting Machine, High Speed Garments Stitching System','2026-08-22 22:45:07.044756',9,'2026-08-22 22:45:07.044756',1,'dagfdasgg',80,'2026-09-02','Apex Logistics Group, Badrul','283948f0-7b04-4781-86ab-1c550c7899af',2,'LOW'),(7,_binary '','PENDING',NULL,'2026-08-22 22:47:17.258226','USD',NULL,'Industrial Garments Big Knitting Machine, Commercial Garments Washing Machine','2026-08-22 22:47:17.245780',10,'2026-08-22 22:47:17.245780',50,'dbfdzb',80,'2026-09-01','Apex Logistics Group, Badrul','b496a9dd-f327-49de-80dd-ade301fc0627',2,'LOW'),(8,_binary '','PENDING',NULL,'2026-08-22 22:50:41.345782','USD',NULL,'Heavy Duty Double Needle Sewing Machine, Industrial Garments Big Knitting Machine','2026-08-22 22:50:41.342759',11,'2026-08-22 22:50:41.342759',1,'sdgsdhsfhh',80,'2026-08-25','Apex Logistics Group, Badrul','abac7135-3cc7-4baa-8c33-d2d504171907',2,'LOW'),(9,_binary '','PENDING',NULL,'2026-08-22 22:59:18.728475','USD',NULL,'Heavy Duty Double Needle Sewing Machine, High Speed Garments Stitching System','2026-08-22 22:59:18.723346',12,'2026-08-22 22:59:18.723346',1,'asegadsvgvv',80,'2026-08-31','Apex Logistics Group, Badrul','29941880-e503-484b-9a8c-7bd1953eeb59',2,'LOW'),(10,_binary '','PENDING',NULL,'2026-08-22 23:09:52.669539','USD',NULL,'Heavy Duty Double Needle Sewing Machine, Industrial Garments Big Knitting Machine','2026-08-22 23:09:52.661412',13,'2026-08-22 23:09:52.662426',20,'adfsdgvdc asdfsdfd',80,'2026-08-31','Apex Logistics Group','865526da-fb47-4372-85a0-1a2e023aca43',2,'LOW'),(11,_binary '','PENDING',NULL,'2026-08-22 23:14:54.100760','USD',NULL,'Heavy Duty Double Needle Sewing Machine, Industrial Garments Big Knitting Machine','2026-08-22 23:14:54.093615',14,'2026-08-22 23:14:54.093615',50,'scbdf sdfgsd',80,'2026-09-02','Apex Logistics Group, Badrul','7919bbc1-8131-4f66-b26d-885d49044ca0',2,'LOW'),(12,_binary '','PENDING',NULL,'2026-08-22 23:54:14.826688','USD',NULL,'Heavy Duty Double Needle Sewing Machine, High Speed Garments Stitching System','2026-08-22 23:54:14.819974',15,'2026-08-22 23:54:14.819974',50,'',80,'2026-08-27','Apex Logistics Group, Badrul','1f32db95-8bf8-41c9-8fb1-9090fb7e12db',2,'LOW');
/*!40000 ALTER TABLE `purchase_requisition_tokens` ENABLE KEYS */;
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
