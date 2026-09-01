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
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `availability` varchar(255) DEFAULT NULL,
  `has_expiry_date` varchar(255) DEFAULT NULL,
  `image` longtext,
  `is_active` bit(1) NOT NULL,
  `name` varchar(255) NOT NULL,
  `product_code` varchar(255) DEFAULT NULL,
  `quantity` int NOT NULL,
  `reorder_point` int NOT NULL,
  `selling_price` double NOT NULL,
  `unit` varchar(255) DEFAULT NULL,
  `unit_cost` double NOT NULL,
  `weight` double NOT NULL,
  `category_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK922x4t23nx64422orei4meb2y` (`product_code`),
  KEY `FKog2rp4qthbtt2lfyhfo32lsw9` (`category_id`),
  CONSTRAINT `FKog2rp4qthbtt2lfyhfo32lsw9` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES (1,'AVAILABLE','NO','Heavy_Duty_Double_Needle_Sewing_Machine_53827700-12b0-461d-af0a-604e9eeebee3.jpg',_binary '','Heavy Duty Double Needle Sewing Machine','PRD-GAR-001',15,5,32000,'PCS',25000,45.5,1),(2,'AVAILABLE','NO','Industrial_Garments_Big_Knitting_Machine_16e94422-046e-40c4-b133-0670d7ce8cf6.webp',_binary '','Industrial Garments Big Knitting Machine','PRD-GAR-002',4,2,110000,'PCS',85000,120,1),(3,'AVAILABLE','NO','High_Speed_Garments_Stitching_System_671f7f6f-f2c5-47e7-a146-9a2c7dca59a0.jpg',_binary '','High Speed Garments Stitching System','PRD-GAR-003',22,8,24000,'PCS',18000,38.2,1),(4,'AVAILABLE','NO','Commercial_Garments_Washing_Machine_0430fcd3-c057-4600-8170-fd9fdd1221ba.jpg',_binary '','Commercial Garments Washing Machine','PRD-GAR-004',8,3,72000,'PCS',55000,95,1),(5,'AVAILABLE','NO','Automatic_Thread_Trimming_Overlock_Device_c7f3178d-dc95-48b8-8b24-607d266e80d0.jpg',_binary '','Automatic Thread Trimming Overlock Device','PRD-GAR-005',30,10,16500,'PCS',12000,25,1),(6,'AVAILABLE','NO','Ergonomic_Desktop_Mobile_Handle_Stand_fceac757-fca8-4897-9156-9213b6e00f87.jpg',_binary '','Ergonomic Desktop Mobile Handle Stand','PRD-CEL-006',200,50,450,'PCS',250,0.15,2),(7,'AVAILABLE','NO','Premium_Heavy_Duty_Silicone_Protection_Cover_dc136075-4dbd-4380-8530-a4430437ac2f.jpg',_binary '','Premium Heavy Duty Silicone Protection Cover','PRD-CEL-007',500,100,290,'PCS',120,0.05,2),(8,'AVAILABLE','NO','Super_Fast_Dual_Port_Charger_2.0_056560a5-05b8-4ec3-a82c-594e6b398897.jpg',_binary '','Super Fast Dual Port Charger 2.0','PRD-CEL-008',150,40,850,'PCS',450,0.08,2),(9,'AVAILABLE','NO','Eiffel_Tower_Souvenir_Tech_Desk_Ornament_1a721578-6c92-4182-8d7a-7d02bffed0a6.jpg',_binary '','Eiffel Tower Souvenir Tech Desk Ornament','PRD-CEL-009',45,15,1200,'PCS',600,0.35,2),(10,'AVAILABLE','NO','Type-C_Braided_Nylon_Fast_Charging_Cable_794ae766-ff31-4f80-ad3a-ab51f908194b.jpg',_binary '','Type-C Braided Nylon Fast Charging Cable','PRD-CEL-010',350,80,220,'PCS',80,0.03,2),(11,'AVAILABLE','NO','Reinforced_Steel_Thread_Spool_Holder_a5bf81ae-cda8-40a0-b7e4-87f600e6ce5c.jpg',_binary '','Reinforced Steel Thread Spool Holder','PRD-IND-011',85,20,650,'PCS',350,1.2,3),(12,'AVAILABLE','NO','Heavy_Clutch_Motor_for_Sewing_Machine_d785e417-23aa-4020-b4b0-872a87265871.jpg',_binary '','Heavy Clutch Motor for Sewing Machine','PRD-IND-012',18,6,6200,'PCS',4500,14.5,3),(13,'AVAILABLE','NO','Rotary_Hook_Assembly_Gear_df28c21a-cf29-4f26-ba36-d5908344ed27.jpg',_binary '','Rotary Hook Assembly Gear','PRD-IND-013',120,25,1400,'PCS',850,0.22,3),(14,'AVAILABLE','NO','Industrial_Conveyor_Drive_Belt_34201d41-55fa-48d9-b612-63606a690643.jpg',_binary '','Industrial Conveyor Drive Belt','PRD-IND-014',60,15,1800,'MTR',1100,2.1,3),(15,'AVAILABLE','NO','Pneumatic_Air_Pressure_Regulator_Node_ded89553-acbb-4dde-84e1-ba5baeacd7e2.jpg',_binary '','Pneumatic Air Pressure Regulator Node','PRD-IND-015',14,5,4800,'PCS',3200,0.95,3),(16,'AVAILABLE','NO','Heavy_Duty_Lathe_Machine_-_Eco_Series_-_Macpower_Industries_2fb086aa-cef9-4ca2-a84d-1caa172505c9.jpg',_binary '','Heavy Duty Lathe Machine - Eco Series - Macpower Industries','PRD-PKG-016',2500,500,75,'BOX',45000000,0.4,4),(17,'AVAILABLE','NO','Key_Features_and_Benefits_of_Changlin_Wheel_Loader_-_B_&_F_Group_f9ac19e5-219a-4998-941d-718c05488081.jpg',_binary '','Key Features and Benefits of Changlin Wheel Loader - B & F Group','PRD-PKG-017',180,40,950,'ROLL',65000000,4.5,4),(18,'AVAILABLE','NO','Anti-Static_Bubble_Wrap_Roll_Matrix_cbbb8dab-2fe7-469a-ad41-4782027ecceb.jpg',_binary '','Anti-Static Bubble Wrap Roll Matrix','PRD-PKG-018',55,15,1750,'ROLL',1200,3.8,4),(19,'AVAILABLE','NO','D_miningwell_450m_water_well_drilling_rig_for_sale_in_japan--D_Miningwell_Driling_Machine_3e56f497-de54-44e6-a8ab-25afe89bd70d.jpg',_binary '','D miningwell 450m water well drilling rig for sale in japan--D Miningwell Driling Machine','PRD-PKG-019',140,30,680,'ROLL',40000000,5,4),(20,'AVAILABLE','NO','Polypropylene_Euro_Container_Shipping_Box_595d3362-8ab2-4c2e-bbde-1f1c0e5fdf3b.jpg',_binary '','Polypropylene Euro Container Shipping Box','PRD-PKG-020',240,60,520,'PCS',300,1.8,4),(21,'AVAILABLE','YES','High-Purity_Silicon_Lubricant_Spray_4cf4f701-1f35-46f1-a09e-6442b21d1f8c.jpg',_binary '','High-Purity Silicon Lubricant Spray','PRD-CHM-021',210,50,350,'CAN',180,0.3,5),(22,'AVAILABLE','YES','Industrial_Machine_Degreaser_Fluid_e651ac0f-d9bd-465c-acbd-a14f5f650c67.jpg',_binary '','Industrial Machine Degreaser Fluid','PRD-CHM-022',90,20,750,'LIT',450,1,5),(23,'AVAILABLE','YES','Premium_Anti-Rust_Coating_Liquid_b3d03887-5c19-4d8b-9d0a-e8ad7c8d7b6a.jpg',_binary '','Premium Anti-Rust Coating Liquid','PRD-CHM-023',40,15,1300,'LIT',850,1.05,5),(24,'AVAILABLE','YES','Textile_Fabric_Stain_Remover_Node_31385218-49d6-4403-91b6-417b59e33da5.jpg',_binary '','Textile Fabric Stain Remover Node','PRD-CHM-024',115,35,420,'CAN',220,0.4,5),(25,'AVAILABLE','YES','Universal_Machine_Bearing_Grease_Tub_f8f48c88-2491-4594-8d62-5000041de401.jpg',_binary '','Universal Machine Bearing Grease Tub','PRD-CHM-025',70,25,590,'KG',380,1,5),(26,'AVAILABLE','NO','Digital_Vernier_Caliper_Gauge_4df10fd4-f752-4654-9ac7-10c19b4e5ff3.jpg',_binary '','Digital Vernier Caliper Gauge','PRD-ENG-026',35,12,2900,'PCS',1850,0.25,6),(27,'AVAILABLE','NO','Laser_Infrared_Surface_Thermometer_d3f5e2f6-6670-498c-936a-39c5ee2816d2.jpg',_binary '','Laser Infrared Surface Thermometer','PRD-ENG-027',20,8,3800,'PCS',2400,0.18,6),(28,'AVAILABLE','NO','default.jpg',_binary '','Electronic Digital Weighing Scale Node','PRD-ENG-028',11,4,9200,'PCS',6500,8.5,6),(29,'AVAILABLE','NO','Fabric_GSM_Circular_Cutter_Plate_1ae49820-790c-4782-8eac-f9d6df405f0f.jpg',_binary '','Fabric GSM Circular Cutter Plate','PRD-ENG-029',15,6,4500,'PCS',3100,1.4,6),(30,'AVAILABLE','NO','Handheld_Digital_Tacho-Rotation_Meter_6759c6a5-f991-4fa2-b72d-f2a6ad1bca70.jpg',_binary '','Handheld Digital Tacho-Rotation Meter','PRD-ENG-030',12,5,4200,'PCS',2800,0.3,6),(61,'AVAILABLE','NO','Industrial_Sewing_Machine_Motor_14009f8e-7f41-42d7-9d66-ec9149c0e4d0.jpg',_binary '\0','Industrial Sewing Machine Motor','PRD-ELC-092',50,10,6200,'PCS',4500,12.5,1),(62,'AVAILABLE','NO','febricks_6f7ee5bd-1160-4c74-8bef-fab9135b1c22.jpg',_binary '\0','febricks','COD-541',100,50000,2000,'PCS',200,2.5,2);
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
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
