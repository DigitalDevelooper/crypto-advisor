-- phpMyAdmin SQL Dump
-- version 4.8.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 29, 2021 at 10:38 AM
-- Server version: 10.1.34-MariaDB
-- PHP Version: 7.2.7

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `crypto_advisor`
--

-- --------------------------------------------------------

--
-- Table structure for table `alerts`
--

CREATE TABLE `alerts` (
  `id` int(11) NOT NULL,
  `alert_price` float NOT NULL,
  `alert_price_condition` varchar(2) COLLATE utf8mb4_croatian_ci NOT NULL,
  `is_alerted` tinyint(1) NOT NULL,
  `user_id` int(11) NOT NULL,
  `crypto_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_croatian_ci;

--
-- Dumping data for table `alerts`
--

INSERT INTO `alerts` (`id`, `alert_price`, `alert_price_condition`, `is_alerted`, `user_id`, `crypto_id`) VALUES
(1, 48550, '>=', 1, 2, 1),
(2, 505050, '<=', 1, 2, 1),
(3, 101010, '>=', 0, 2, 1),
(4, 606060, '>=', 0, 2, 2),
(5, 707070, '<=', 1, 2, 2),
(6, 5000, '<=', 1, 2, 2),
(7, 100000, '<=', 1, 2, 1),
(8, 50000, '>=', 0, 2, 1),
(9, 45975, '>=', 1, 2, 1),
(10, 45975, '<=', 0, 2, 1),
(11, 40000, '>=', 1, 2, 1),
(12, 40000, '>=', 1, 2, 1);

-- --------------------------------------------------------

--
-- Table structure for table `cryptocurrency`
--

CREATE TABLE `cryptocurrency` (
  `id` int(11) NOT NULL,
  `name` varchar(25) COLLATE utf8mb4_croatian_ci NOT NULL,
  `name_short` varchar(5) COLLATE utf8mb4_croatian_ci NOT NULL,
  `current_value` float NOT NULL,
  `curr_tmstp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `icon` varchar(50) COLLATE utf8mb4_croatian_ci NOT NULL,
  `color` varchar(7) COLLATE utf8mb4_croatian_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_croatian_ci;

--
-- Dumping data for table `cryptocurrency`
--

INSERT INTO `cryptocurrency` (`id`, `name`, `name_short`, `current_value`, `curr_tmstp`, `icon`, `color`) VALUES
(1, 'Bitcoin', 'BTC', 48500, '2021-08-29 08:37:18', 'fab fa-btc', '#fbcf33'),
(2, 'Ethereum', 'ETH', 3210, '2021-08-29 08:37:18', 'fab fa-ethereum', '#5b4f79');

-- --------------------------------------------------------

--
-- Table structure for table `is_tracking`
--

CREATE TABLE `is_tracking` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `crypto_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_croatian_ci;

--
-- Dumping data for table `is_tracking`
--

INSERT INTO `is_tracking` (`id`, `user_id`, `crypto_id`) VALUES
(1, 2, 1),
(2, 2, 2);

-- --------------------------------------------------------

--
-- Table structure for table `settings`
--

CREATE TABLE `settings` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `alert_whale` int(10) NOT NULL DEFAULT '0',
  `alert_price_change_daily` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_croatian_ci;

--
-- Dumping data for table `settings`
--

INSERT INTO `settings` (`id`, `user_id`, `alert_whale`, `alert_price_change_daily`) VALUES
(1, 2, 2000000, 1);

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `id` int(11) NOT NULL,
  `username` varchar(20) COLLATE utf8mb4_croatian_ci NOT NULL,
  `password` varchar(20) COLLATE utf8mb4_croatian_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_croatian_ci;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`id`, `username`, `password`) VALUES
(2, 'rlangus', 'test');

--
-- Triggers `user`
--
DELIMITER $$
CREATE TRIGGER `createSettings` AFTER INSERT ON `user` FOR EACH ROW INSERT INTO `settings`(`id`, `user_id`, `valuta`, `alert_whale`, `alert_price_change_daily`) VALUES (NULL,new.id,DEFAULT,DEFAULT,DEFAULT)
$$
DELIMITER ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `alerts`
--
ALTER TABLE `alerts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `crypto_id` (`crypto_id`);

--
-- Indexes for table `cryptocurrency`
--
ALTER TABLE `cryptocurrency`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `is_tracking`
--
ALTER TABLE `is_tracking`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `crypto_id` (`crypto_id`);

--
-- Indexes for table `settings`
--
ALTER TABLE `settings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `alerts`
--
ALTER TABLE `alerts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `cryptocurrency`
--
ALTER TABLE `cryptocurrency`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `is_tracking`
--
ALTER TABLE `is_tracking`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `settings`
--
ALTER TABLE `settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `alerts`
--
ALTER TABLE `alerts`
  ADD CONSTRAINT `alerts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  ADD CONSTRAINT `alerts_ibfk_2` FOREIGN KEY (`crypto_id`) REFERENCES `cryptocurrency` (`id`);

--
-- Constraints for table `is_tracking`
--
ALTER TABLE `is_tracking`
  ADD CONSTRAINT `is_tracking_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  ADD CONSTRAINT `is_tracking_ibfk_2` FOREIGN KEY (`crypto_id`) REFERENCES `cryptocurrency` (`id`);

--
-- Constraints for table `settings`
--
ALTER TABLE `settings`
  ADD CONSTRAINT `settings_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
