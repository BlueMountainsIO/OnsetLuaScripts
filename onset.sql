-- phpMyAdmin SQL Dump
-- version 4.9.0.1
-- https://www.phpmyadmin.net/

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `onset`
--

-- --------------------------------------------------------

--
-- Table structure for table `accounts`
--

CREATE TABLE `accounts` (
  `id` int(10) UNSIGNED NOT NULL,
  `steamid` varchar(17) NOT NULL,
  `steam_name` varchar(32) NOT NULL,
  `game_version` mediumint(10) UNSIGNED NOT NULL,
  `locale` varchar(6) NOT NULL,
  `email` varchar(28) NOT NULL DEFAULT '',
  `time` int(10) UNSIGNED NOT NULL,
  `admin` tinyint(3) UNSIGNED NOT NULL,
  `health` float NOT NULL DEFAULT '100',
  `armor` float NOT NULL DEFAULT '0',
  `cash` int(11) NOT NULL,
  `bank_balance` int(11) NOT NULL,
  `kills` mediumint(8) UNSIGNED NOT NULL,
  `deaths` mediumint(8) UNSIGNED NOT NULL,
  `bounty` int(11) NOT NULL,
  `registration_time` int(10) UNSIGNED NOT NULL,
  `registration_ip` varchar(16) NOT NULL,
  `count_login` int(10) UNSIGNED NOT NULL,
  `count_kick` int(10) UNSIGNED NOT NULL,
  `last_login_time` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `atm`
--

CREATE TABLE `atm` (
  `id` int(10) UNSIGNED NOT NULL,
  `modelid` mediumint(8) UNSIGNED NOT NULL,
  `x` float NOT NULL,
  `y` float NOT NULL,
  `z` float NOT NULL,
  `rx` float NOT NULL,
  `ry` float NOT NULL,
  `rz` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `atm`
--

INSERT INTO `atm` (`id`, `modelid`, `x`, `y`, `z`, `rx`, `ry`, `rz`) VALUES
(1, 494, 129221, 78053, 1478, 0, 90, 0);

-- --------------------------------------------------------

--
-- Table structure for table `bans`
--

CREATE TABLE `bans` (
  `id` int(10) UNSIGNED NOT NULL,
  `admin_id` int(10) UNSIGNED NOT NULL,
  `ban_time` int(10) UNSIGNED NOT NULL,
  `expire_time` int(10) UNSIGNED NOT NULL,
  `reason` varchar(128) NOT NULL,
  `ping` smallint(5) UNSIGNED NOT NULL,
  `packetloss` float(4,2) NOT NULL,
  `locx` float(14,4) NOT NULL,
  `locy` float(14,4) NOT NULL,
  `locz` float(14,4) NOT NULL,
  `health` float(10,2) NOT NULL,
  `armor` float(10,2) NOT NULL,
  `weapon_id` smallint(5) UNSIGNED NOT NULL,
  `weapon_ammo` mediumint(8) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `ipbans`
--

CREATE TABLE `ipbans` (
  `ip` varchar(16) NOT NULL,
  `account_id` int(10) UNSIGNED NOT NULL,
  `admin_id` int(10) UNSIGNED NOT NULL,
  `ban_time` int(10) UNSIGNED NOT NULL,
  `reason` varchar(128) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `kicks`
--

CREATE TABLE `kicks` (
  `id` int(10) UNSIGNED NOT NULL,
  `admin_id` int(10) UNSIGNED NOT NULL,
  `time` int(10) UNSIGNED NOT NULL,
  `reason` varchar(128) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `log_chat`
--

CREATE TABLE `log_chat` (
  `id` int(10) UNSIGNED NOT NULL,
  `time` int(10) UNSIGNED NOT NULL,
  `text` varchar(300) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `log_login`
--

CREATE TABLE `log_login` (
  `id` int(10) UNSIGNED NOT NULL,
  `ip` varchar(16) NOT NULL,
  `time` int(10) UNSIGNED NOT NULL,
  `action` enum('ACTION_LOGIN','ACTION_LOGOUT') NOT NULL,
  `service` enum('SERVICE_SERVER','SERVICE_OTHER') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `log_reports`
--

CREATE TABLE `log_reports` (
  `id` int(10) UNSIGNED NOT NULL,
  `reportedby_id` int(10) UNSIGNED NOT NULL,
  `report_time` int(10) UNSIGNED NOT NULL,
  `message` varchar(128) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `log_weaponshot`
--

CREATE TABLE `log_weaponshot` (
  `id` int(10) UNSIGNED NOT NULL,
  `time` int(10) UNSIGNED NOT NULL,
  `hittype` tinyint(3) UNSIGNED NOT NULL,
  `hitplayer` int(10) UNSIGNED NOT NULL,
  `hitx` float NOT NULL,
  `hity` float NOT NULL,
  `hitz` float NOT NULL,
  `startx` float NOT NULL,
  `starty` float NOT NULL,
  `startz` float NOT NULL,
  `weapon` tinyint(3) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `accounts`
--
ALTER TABLE `accounts`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `atm`
--
ALTER TABLE `atm`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `bans`
--
ALTER TABLE `bans`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `ipbans`
--
ALTER TABLE `ipbans`
  ADD PRIMARY KEY (`ip`);

--
-- Indexes for table `kicks`
--
ALTER TABLE `kicks`
  ADD KEY `id` (`id`) USING BTREE;

--
-- Indexes for table `log_chat`
--
ALTER TABLE `log_chat`
  ADD KEY `id` (`id`);

--
-- Indexes for table `log_login`
--
ALTER TABLE `log_login`
  ADD KEY `id` (`id`) USING BTREE;

--
-- Indexes for table `log_reports`
--
ALTER TABLE `log_reports`
  ADD KEY `id` (`id`);

--
-- Indexes for table `log_weaponshot`
--
ALTER TABLE `log_weaponshot`
  ADD KEY `id` (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `accounts`
--
ALTER TABLE `accounts`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `atm`
--
ALTER TABLE `atm`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bans`
--
ALTER TABLE `bans`
  ADD CONSTRAINT `bans_ibfk_1` FOREIGN KEY (`id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `kicks`
--
ALTER TABLE `kicks`
  ADD CONSTRAINT `kicks_ibfk_1` FOREIGN KEY (`id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `log_chat`
--
ALTER TABLE `log_chat`
  ADD CONSTRAINT `log_chat_ibfk_1` FOREIGN KEY (`id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `log_login`
--
ALTER TABLE `log_login`
  ADD CONSTRAINT `log_login_ibfk_1` FOREIGN KEY (`id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `log_reports`
--
ALTER TABLE `log_reports`
  ADD CONSTRAINT `log_reports_ibfk_1` FOREIGN KEY (`id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `log_weaponshot`
--
ALTER TABLE `log_weaponshot`
  ADD CONSTRAINT `log_weaponshot_ibfk_1` FOREIGN KEY (`id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
