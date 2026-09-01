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
-- Table structure for table `quotations`
--

DROP TABLE IF EXISTS `quotations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `quotations` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `attachment_url` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `delivery_time` date NOT NULL,
  `is_selected` double DEFAULT NULL,
  `lead_time_days` int NOT NULL,
  `notes` text,
  `product_description` text NOT NULL,
  `product_name` varchar(255) NOT NULL,
  `quantity` int NOT NULL,
  `quotation_number` varchar(50) NOT NULL,
  `received_at` date NOT NULL,
  `status` enum('APPROVED','EXPIRED','PENDING','REJECTED','UNDER_REVIEW') DEFAULT NULL,
  `total_price` double NOT NULL,
  `unit_price` double NOT NULL,
  `valid_until` date NOT NULL,
  `warranty` varchar(255) DEFAULT NULL,
  `product_id` bigint NOT NULL,
  `purchase_requisition_id` bigint NOT NULL,
  `supplier_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK9kbnjdxcf5d7qxwy80ple68bh` (`quotation_number`),
  KEY `FKbfn4c8ah06l9jhg5dakufbr0e` (`product_id`),
  KEY `FK67fnj0t9wpb730h5i30o13viy` (`purchase_requisition_id`),
  KEY `FK9vdoa49dekeoytb3pchlxbmcl` (`supplier_id`),
  CONSTRAINT `FK67fnj0t9wpb730h5i30o13viy` FOREIGN KEY (`purchase_requisition_id`) REFERENCES `purchase_requisitions` (`id`),
  CONSTRAINT `FK9vdoa49dekeoytb3pchlxbmcl` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`),
  CONSTRAINT `FKbfn4c8ah06l9jhg5dakufbr0e` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quotations`
--

LOCK TABLES `quotations` WRITE;
/*!40000 ALTER TABLE `quotations` DISABLE KEYS */;
INSERT INTO `quotations` VALUES (1,'Industrial_Knitting_Machine_Gear_3fdf3d20-30ea-4af5-9843-d859793ac0a8.JPG','2026-07-01 15:58:25.889589','2026-07-15',0,14,'Price includes logistics and customs clearing handling costs.','High-grade hardened steel replacement gear components.','Industrial Knitting Machine Gear',15,'QTN-1782899905889','2026-07-01','PENDING',6750,450,'2026-09-30','1 Year Comprehensive',10,1,1),(3,'Industrial_Grade_Steel_Pipe_ffc6385d-45ce-4251-981f-0542be49c3c5.JPG','2026-07-08 15:36:05.404090','2026-07-15',0,7,'Bulk discount pricing applied based on PR quota requirements.','Seamless structural carbon steel pipes for SCM fluid logistics grid.','Industrial Grade Steel Pipe',50,'QTN-1783503365404','2026-07-08','PENDING',6025,120.5,'2026-09-30','1 Year Manufacturer Warranty',15,1,1),(4,'Industrial_Garments_Big_Knitting_Machine,_Heavy_Duty_Double_Needle_Sewing_Machine_6793745d-f53f-495a-bcb5-408b19257f56.png','2026-07-19 14:52:18.754628','2026-07-31',0,200,'ddddzsnskz jn','kdrfgtb ksz','Industrial Garments Big Knitting Machine, Heavy Duty Double Needle Sewing Machine',420,'QTN-A4764DA6','2026-07-19','REJECTED',210008400,500020,'2026-08-18','3years',2,4,2),(5,'Industrial_Garments_Big_Knitting_Machine,_Heavy_Duty_Double_Needle_Sewing_Machine_76df151d-d20c-456c-82b8-18f7717c8da3.png','2026-07-19 18:25:48.984285','2026-07-20',0,200,'zxdvsd','dafb','Industrial Garments Big Knitting Machine, Heavy Duty Double Needle Sewing Machine',120,'QTN-8DA2DF4E','2026-07-19','APPROVED',14400,120,'2026-08-18','nd,s',2,4,2),(6,'Pneumatic_Air_Pressure_Regulator_Node,_Industrial_Machine_Degreaser_Fluid,_Type-C_Braided_Nylon_Fast_Charging_Cable_a6a7dee6-e364-44ed-94a5-f900b64e93ee.jpg','2026-07-28 19:08:27.463136','2026-08-05',0,200,'asdfsdf','sdafgsa','Pneumatic Air Pressure Regulator Node, Industrial Machine Degreaser Fluid, Type-C Braided Nylon Fast Charging Cable',5,'QTN-5830030C','2026-07-26','APPROVED',2500000,500000,'2026-08-27','1 year',15,1,1),(7,'Super_Fast_Dual_Port_Charger_2.0,_Premium_Heavy_Duty_Silicone_Protection_Cover,_Ergonomic_Desktop_Mobile_Handle_Stand_9ace0347-5397-4f3d-89db-5d6a8b7e80be.png','2026-08-16 03:18:25.718762','2027-02-25',0,200,'srdgerggftre edsgrerfge esdrfg','sdfgsdfgvsfdr dfgvdesfrg defgedrftgsdfr dfrgedfrg','Super Fast Dual Port Charger 2.0, Premium Heavy Duty Silicone Protection Cover, Ergonomic Desktop Mobile Handle Stand',1,'QTN-38A80A10','2026-08-16','REJECTED',0,0,'2026-09-15','5',8,5,2),(8,'Heavy_Duty_Double_Needle_Sewing_Machine,_Industrial_Garments_Big_Knitting_Machine_4a8c617d-2fcc-4fb0-af08-b2429474d530.png','2026-08-16 03:58:42.929341','2027-03-16',0,190,'dfghbdfgh','dfghbgfdhn ','Heavy Duty Double Needle Sewing Machine, Industrial Garments Big Knitting Machine',420,'QTN-A6ACA465','2026-07-19','APPROVED',210004200,500010,'2026-09-15','5',1,4,1);
/*!40000 ALTER TABLE `quotations` ENABLE KEYS */;
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
