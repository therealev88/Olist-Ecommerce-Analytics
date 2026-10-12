CREATE DATABASE  IF NOT EXISTS `olist_ecommerce` /*!40100 DEFAULT CHARACTER SET utf8mb3 */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `olist_ecommerce`;
-- MySQL dump 10.13  Distrib 8.0.44, for Win64 (x86_64)
--
-- Host: localhost    Database: olist_ecommerce
-- ------------------------------------------------------
-- Server version	8.0.44

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
  `customer_id` char(32) NOT NULL,
  `customer_unique_id` char(32) NOT NULL,
  `customer_zip_code_prefix` char(5) DEFAULT NULL,
  `customer_city` varchar(100) DEFAULT NULL,
  `customer_state` char(2) DEFAULT NULL,
  PRIMARY KEY (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `customers_clean`
--

DROP TABLE IF EXISTS `customers_clean`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers_clean` (
  `customer_id` char(32) NOT NULL,
  `customer_unique_id` char(32) NOT NULL,
  `customer_zip_code_prefix` char(5) DEFAULT NULL,
  `customer_city` varchar(100) DEFAULT NULL,
  `customer_state` char(2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `geolocation`
--

DROP TABLE IF EXISTS `geolocation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `geolocation` (
  `geolocation_zip_code_prefix` char(5) NOT NULL,
  `geolocation_lat` decimal(10,7) NOT NULL,
  `geolocation_lng` decimal(10,7) NOT NULL,
  `geolocation_city` varchar(100) NOT NULL,
  `geolocation_state` char(2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `geolocation_clean`
--

DROP TABLE IF EXISTS `geolocation_clean`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `geolocation_clean` (
  `geolocation_zip_code_prefix` char(5) NOT NULL,
  `geolocation_lat` decimal(10,7) NOT NULL,
  `geolocation_lng` decimal(10,7) NOT NULL,
  `geolocation_city` varchar(100) NOT NULL,
  `geolocation_state` char(2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `order_items`
--

DROP TABLE IF EXISTS `order_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_items` (
  `order_id` char(32) NOT NULL,
  `order_item_id` int NOT NULL,
  `product_id` char(32) NOT NULL,
  `seller_id` char(32) NOT NULL,
  `shipping_limit_date` datetime NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `freight_value` decimal(10,2) NOT NULL,
  PRIMARY KEY (`order_id`,`order_item_id`),
  CONSTRAINT `fk_order_items_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `order_items_clean`
--

DROP TABLE IF EXISTS `order_items_clean`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_items_clean` (
  `order_id` char(32) NOT NULL,
  `order_item_id` int NOT NULL,
  `product_id` char(32) NOT NULL,
  `seller_id` char(32) NOT NULL,
  `shipping_limit_date` datetime NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `freight_value` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `order_payments`
--

DROP TABLE IF EXISTS `order_payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_payments` (
  `order_id` char(32) NOT NULL,
  `payment_sequential` int NOT NULL,
  `payment_type` varchar(20) NOT NULL,
  `payment_installments` int NOT NULL,
  `payment_value` decimal(10,2) NOT NULL,
  PRIMARY KEY (`order_id`,`payment_sequential`),
  CONSTRAINT `fk_order_payments_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `order_payments_clean`
--

DROP TABLE IF EXISTS `order_payments_clean`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_payments_clean` (
  `order_id` char(32) NOT NULL,
  `payment_sequential` int NOT NULL,
  `payment_type` varchar(20) NOT NULL,
  `payment_installments` int NOT NULL,
  `payment_value` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `order_reviews`
--

DROP TABLE IF EXISTS `order_reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_reviews` (
  `review_id` char(32) NOT NULL,
  `order_id` char(32) NOT NULL,
  `review_score` int NOT NULL,
  `review_comment_title` text,
  `review_comment_message` text,
  `review_creation_date` datetime NOT NULL,
  `review_answer_timestamp` datetime NOT NULL,
  PRIMARY KEY (`review_id`,`order_id`),
  KEY `fk_order_reviews_order` (`order_id`),
  CONSTRAINT `fk_order_reviews_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `order_reviews_clean`
--

DROP TABLE IF EXISTS `order_reviews_clean`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_reviews_clean` (
  `review_id` char(32) NOT NULL,
  `order_id` char(32) NOT NULL,
  `review_score` int NOT NULL,
  `review_comment_title` text,
  `review_comment_message` text,
  `review_creation_date` datetime NOT NULL,
  `review_answer_timestamp` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `order_id` char(32) NOT NULL,
  `customer_id` char(32) NOT NULL,
  `order_status` varchar(20) NOT NULL,
  `order_purchase_timestamp` datetime NOT NULL,
  `order_approved_at` datetime DEFAULT NULL,
  `order_delivered_carrier_date` datetime DEFAULT NULL,
  `order_delivered_customer_date` datetime DEFAULT NULL,
  `order_estimated_delivery_date` datetime DEFAULT NULL,
  PRIMARY KEY (`order_id`),
  KEY `fk_orders_customer` (`customer_id`),
  CONSTRAINT `fk_orders_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `orders_clean`
--

DROP TABLE IF EXISTS `orders_clean`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders_clean` (
  `order_id` char(32) NOT NULL,
  `customer_id` char(32) NOT NULL,
  `order_status` varchar(20) NOT NULL,
  `order_purchase_timestamp` datetime NOT NULL,
  `order_approved_at` datetime DEFAULT NULL,
  `order_delivered_carrier_date` datetime DEFAULT NULL,
  `order_delivered_customer_date` datetime DEFAULT NULL,
  `order_estimated_delivery_date` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `product_category_name_translation`
--

DROP TABLE IF EXISTS `product_category_name_translation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_category_name_translation` (
  `product_category_name` varchar(100) NOT NULL,
  `product_category_name_english` varchar(100) NOT NULL,
  PRIMARY KEY (`product_category_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `product_category_name_translation_clean`
--

DROP TABLE IF EXISTS `product_category_name_translation_clean`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_category_name_translation_clean` (
  `product_category_name` varchar(100) NOT NULL,
  `product_category_name_english` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `product_id` char(32) NOT NULL,
  `product_category_name` varchar(100) DEFAULT NULL,
  `product_name_lenght` int DEFAULT NULL,
  `product_description_lenght` int DEFAULT NULL,
  `product_photos_qty` int DEFAULT NULL,
  `product_weight_g` int DEFAULT NULL,
  `product_length_cm` decimal(5,2) DEFAULT NULL,
  `product_height_cm` decimal(5,2) DEFAULT NULL,
  `product_width_cm` decimal(5,2) DEFAULT NULL,
  PRIMARY KEY (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `products_clean`
--

DROP TABLE IF EXISTS `products_clean`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products_clean` (
  `product_id` char(32) NOT NULL,
  `product_category_name` varchar(100) DEFAULT NULL,
  `product_name_lenght` int DEFAULT NULL,
  `product_description_lenght` int DEFAULT NULL,
  `product_photos_qty` int DEFAULT NULL,
  `product_weight_g` int DEFAULT NULL,
  `product_length_cm` decimal(5,2) DEFAULT NULL,
  `product_height_cm` decimal(5,2) DEFAULT NULL,
  `product_width_cm` decimal(5,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sellers`
--

DROP TABLE IF EXISTS `sellers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sellers` (
  `seller_id` char(32) NOT NULL,
  `seller_zip_code_prefix` char(5) DEFAULT NULL,
  `seller_city` varchar(100) DEFAULT NULL,
  `seller_state` char(2) DEFAULT NULL,
  PRIMARY KEY (`seller_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sellers_clean`
--

DROP TABLE IF EXISTS `sellers_clean`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sellers_clean` (
  `seller_id` char(32) NOT NULL,
  `seller_zip_code_prefix` char(5) DEFAULT NULL,
  `seller_city` varchar(100) DEFAULT NULL,
  `seller_state` char(2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-09 11:34:55
