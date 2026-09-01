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
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `category_name` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES (1,'Electronics','Electronic supply chain components, consumer devices, and hardware modules.'),(2,'Apparel & Garments','Raw fabrics, finished clothing lines, and bulk textile inventory items.'),(3,'Pharmaceuticals','Temperature-controlled medical nodes, prescription drugs, and clinical supplies.'),(4,'Automotive Parts','Vehicle machinery sub-assemblies, spare engine nodes, and industrial tires.'),(5,'Perishable Foods','Cold-chain tracking items, fresh agro-produce, and dairy matrix lots.'),(6,'Construction Materials','Bulk cement pallets, reinforced steel structures, and structural aggregates.'),(7,'Chemicals & Fluids','Hazardous and non-hazardous manufacturing chemical solutions and raw fluids.'),(8,'Office Supplies','Administrative enterprise stationery, printer cartridges, and paper stock nodes.'),(9,'Logistics Packaging','Heavy-duty corrugated boxes, plastic pallets, and shrink-wrap rolls.'),(10,'Renewable Energy Kit','Solar panel arrays, photovoltaic inverter blocks, and grid battery units.'),(11,'Industrial Machinery','Factory automated CNC components, conveyor belt parts, and hydraulic pumps.'),(12,'Consumer Packaged Goods','Fast-moving consumer retail items, packaged snacks, and personal hygiene products.'),(13,'Aviation Hardware','Aircraft structural spare nodes, navigation avionics, and landing gear parts.'),(14,'Maritime Gear','Cargo ship anchor chains, marine-grade lubricants, and vessel ballast parts.'),(15,'Telecommunications','Fiber-optic core cable spools, cellular antenna systems, and network routers.'),(16,'Beverages','Bottled mineral water clusters, carbonated soft drinks, and brewery supply lines.'),(17,'Agricultural Machinery','Tractor engine spare units, automated seed drillers, and irrigation node pipes.'),(18,'Raw Minerals & Ore','Bulk unprocessed iron ore shipments, coal aggregate matrix, and copper concentrates.'),(19,'Medical Equipment','Hospital diagnostic MRI sensors, surgical steel toolsets, and patient ventilators.'),(20,'Defense Logistics','Secure tactical communication arrays, military vehicle armor segments, and aerospace components.'),(21,'Electronics','Electronic supply chain components, consumer devices, and hardware modules.'),(22,'Apparel & Garments','Raw fabrics, finished clothing lines, and bulk textile inventory items.'),(23,'Pharmaceuticals','Temperature-controlled medical nodes, prescription drugs, and clinical supplies.'),(24,'Automotive Parts','Vehicle machinery sub-assemblies, spare engine nodes, and industrial tires.'),(25,'Perishable Foods','Cold-chain tracking items, fresh agro-produce, and dairy matrix lots.'),(26,'Construction Materials','Bulk cement pallets, reinforced steel structures, and structural aggregates.'),(27,'Chemicals & Fluids','Hazardous and non-hazardous manufacturing chemical solutions and raw fluids.'),(28,'Office Supplies','Administrative enterprise stationery, printer cartridges, and paper stock nodes.'),(29,'Logistics Packaging','Heavy-duty corrugated boxes, plastic pallets, and shrink-wrap rolls.'),(30,'Renewable Energy Kit','Solar panel arrays, photovoltaic inverter blocks, and grid battery units.'),(31,'Industrial Machinery','Factory automated CNC components, conveyor belt parts, and hydraulic pumps.'),(32,'Consumer Packaged Goods','Fast-moving consumer retail items, packaged snacks, and personal hygiene products.'),(33,'Aviation Hardware','Aircraft structural spare nodes, navigation avionics, and landing gear parts.'),(34,'Maritime Gear','Cargo ship anchor chains, marine-grade lubricants, and vessel ballast parts.'),(35,'Telecommunications','Fiber-optic core cable spools, cellular antenna systems, and network routers.'),(36,'Beverages','Bottled mineral water clusters, carbonated soft drinks, and brewery supply lines.'),(37,'Agricultural Machinery','Tractor engine spare units, automated seed drillers, and irrigation node pipes.'),(38,'Raw Minerals & Ore','Bulk unprocessed iron ore shipments, coal aggregate matrix, and copper concentrates.'),(39,'Medical Equipment','Hospital diagnostic MRI sensors, surgical steel toolsets, and patient ventilators.'),(40,'Defense Logistics','Secure tactical communication arrays, military vehicle armor segments, and aerospace components.'),(41,'dfd','sfdvds');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-08-31 23:43:08
