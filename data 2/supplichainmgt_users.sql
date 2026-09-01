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
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `active` bit(1) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `phone_number` varchar(255) DEFAULT NULL,
  `role` enum('ADMIN','COMMERCIAL_OFFICER','CUSTOMER','DRIVER','LOGISTICS_OFFICER','MANAGER','PROCUREMENT','QC_INSPECTOR','SALES_OFFICER','SUPPLIER') DEFAULT NULL,
  `police_station_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK6dotkott2kjsp8vw4d0m25fb7` (`email`),
  UNIQUE KEY `UK9q63snka3mdh91as4io72espi` (`phone_number`),
  KEY `FKipgo66qij29k0c5viibscm8y6` (`police_station_id`),
  CONSTRAINT `FKipgo66qij29k0c5viibscm8y6` FOREIGN KEY (`police_station_id`) REFERENCES `policestations` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=97 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,_binary '\0','rafiq.driver2@gmail.com','Md. Rafiqul Islam','$2a$10$.5NbH3B8Z0FNqPlk1V5VSexLrV5VT0y18BHGFYj8zt31chrOqTwly','01812345688','DRIVER',2),(3,_binary '\0','rafiq.driver23@gmail.com','Md. Islam','$2a$10$9CrMdq6nNYiG4nqOMaegGuCslPxwip/o90oEFLdxFgYQSkJzssU/m','01812345658','DRIVER',76),(5,_binary '\0','rafiq.driver233@gmail.com','Md. Islam','$2a$10$zrwOsCnJbzf4TkrDm2PpquBlQheDZVqGgW6EDZBp3uI1cFK7ZKlaS','01812345558','DRIVER',81),(7,_binary '\0','srabonhasan66270@gmail.com','Md. Tanvir Hasan','$2a$10$A3.R6FaAHQhnvG1xljm0W.A1l7Y9KPg9MuUyABHZTacjlnYnYNykO','017123456788','CUSTOMER',NULL),(11,_binary '\0','srabonhasan662702@gmail.com','Md.Hasan','$2a$10$ur8i46A7Sri7nQFxzQyJwOXc9XR7Ab0h.e5bdxbvV9MkatqqqcZPO','0171234567828','CUSTOMER',NULL),(12,_binary '\0','srabonhasan66272@gmail.com','Md.Hasan','$2a$10$qN94Yt6VtM8IeRXVT88HE.W8jQUCZyfPQAg.jKgUF./deYw3Jy7u.','01712345628','CUSTOMER',NULL),(13,_binary '\0','srabonhasan6622@gmail.com','Md.Hasan','$2a$10$M9nUo/6N.nSxyNxoc8RzeeY/n31wC5IpZ/EOhg0VElbtxzHK9Z8la','017123456228','CUSTOMER',11),(16,_binary '','tanvirha70@gmail.com','Tanvir Rahman','123456','01712345678','COMMERCIAL_OFFICER',NULL),(18,_binary '','tanvirhasan0@gmail.com','Tanvir islam','$2a$10$88S7oJE0KPa18Zkz3vfiQOVT9t69WlonzRZ0x0qXB6C810tpSAaR.','017123456728','DRIVER',2),(19,_binary '','tanvirhasan6@gmail.com','Tanvir ','$2a$10$0xCUcI.pzljslN4VAmN/8uRRdg1gNRHM7du8fP2F0SdISRGnjD.HS','017123456718','LOGISTICS_OFFICER',1),(26,_binary '','tanvirhas@gmail.com','Robin','$2a$10$5lp3vB45f6g9mRA3suE86usztURWIlrGHyXm0aq2Y3NPKrKr8y.qO','017123456778','QC_INSPECTOR',2),(35,_binary '','kamal.sales@example.com','Kamal Hasan','$2a$10$Bu.hE/v1kWbwT3BLv2.8PeJiLAHgLN1gOjtdw2RIpk0douIwZCezW','+8801899887766','SALES_OFFICER',10),(36,_binary '','srabonhasn66270@gmail.com','Apex Logistics Group','$2a$10$qyJImmm8cgJcYAeKw.D17.4ZQK8tQ5GRwlt/3tH1m1JCB9klbTXBK','+8801555443322','SUPPLIER',3),(37,_binary '','tanvirhan66270@gmail.com','Rashed Khan','$2a$10$.o1uam2l/ZoyV8HTvOkFuuT19Jb6DAriorUCNZKm63NoCMqqX6.YW','+8801711223344','CUSTOMER',2),(38,_binary '\0','tanvirhasan6270@gmail.com','Tanvir Hasan','$2a$10$vTRbAIP2Bqble2rH0ba5YuQxKLpPHrkEEJE9/TbkRbGDrgIw26VhK','+8801712345678','CUSTOMER',4),(43,_binary '\0','85625@gmail.com','MD: TANVIRsaasfa','$2a$10$LyvA67SEDcaXRwxdpSYT3u02VE6fjGq6GL8ckbeSYEKJNKysFsHSi','1156','CUSTOMER',1),(45,_binary '\0','8565@gmail.com','MD: TANVIR','$2a$10$NE0CilUad7Ag45vmsHTXQuAVo1xYo7XXPSQPIAo.2ZB5PQO2uJ.CK','017123456828','CUSTOMER',1),(48,_binary '\0','65@gmail.com','MD: TANVIR','$2a$10$R8SOcHRXv8Yqm1XvjAjmguJeDyJCLxdZx4tE9V0bPJNBfJRSB4nme','3324+6355+985','CUSTOMER',1),(59,_binary '\0','855@gmail.com','MD TANVIR','123456','017123567828','COMMERCIAL_OFFICER',NULL),(62,_binary '\0','taniasan66270@gmail.com','hasan','123456','0112345678','COMMERCIAL_OFFICER',NULL),(65,_binary '','rahim@gmail.com','Rahim','$2a$10$pBe8NMcoC3HYpX2FyD0z3ea6lHbRDOqCKpfkP0qr6j6.sJQE/xJti','01752413241','DRIVER',1),(66,_binary '','rehana@gmail.com','Mst Rehana','$2a$10$1tbaMpZC.9gVu5rPr0LKHuPu5NGysofjQHWOR20.cIRn.eVxLha2K','017642524125','LOGISTICS_OFFICER',1),(68,_binary '','miskat@gmail.com','Miskat','$2a$10$1TH6mkI/XLcRAWKK2s9a3O/cPF2I4DuyXCKKHcOaPiAAuQkpzti9u','01714215421','QC_INSPECTOR',1),(71,_binary '','admin@supplychain.com','System Administrator','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAg/P6Qd6jO7M1K9P8L9M4Y5X8YyK','55555','ADMIN',NULL),(80,_binary '','shimulpk53@gmail.com','PK','$2a$10$Rnj62/JUI17cMpW9ztl50uKWoQ01U/RxcyEos.YrL2r4aewIcUz22','01712456828','PROCUREMENT',1),(82,_binary '','tanvirhasan66270@gmail.com','MD: TANVIR','$2a$10$Bu.hE/v1kWbwT3BLv2.8PeJiLAHgLN1gOjtdw2RIpk0douIwZCezW','21254231654','MANAGER',72),(83,_binary '','badrulaminidb69@gmail.com','Badrul','$2a$10$qyJImmm8cgJcYAeKw.D17.4ZQK8tQ5GRwlt/3tH1m1JCB9klbTXBK','32132135422341','SUPPLIER',1),(84,_binary '','johan52@gmail.com','johan','$2a$10$d6NcdFAdcVMLC0JPYKfsoeaqQnWacxJh9Vof0j6UkiqkzGp9A8Kty','0171255252','CUSTOMER',1),(85,_binary '\0','dgdfdfg@gmail.com','dghfgf','$2a$10$JI/1uYxnOcGv/uZpsAX0LORQAWLA4VD69lGJdGVzW3yCb8uf.UHi2','0171234567828454','CUSTOMER',19),(88,_binary '','hasan66270@gmail.com','Hasan','$2a$10$n6vcKEQiJc/1xagPP9DvoOMFJle7gBe/cWfyNkltpOYinn8iEbPuO','23452318521','COMMERCIAL_OFFICER',NULL),(90,_binary '','admin@gmail.com','Admin','$2a$10$U2QYZ6PLUJ6ytsqg4eDfiuyuAJd1gjADaxsQ6jDj2rI5Iuv7cVSMy','01254144514174','ADMIN',NULL),(96,_binary '\0','admidaxvn@gmail.com','xsv','$2a$10$aVtbvrZWY.K.X9bCVq9e.O1gTcieG3RXAD3IIVVm33TVlmjLp4I8K','admin@gmail.com','CUSTOMER',1);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
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
